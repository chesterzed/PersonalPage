#!/usr/bin/env bash
# Поставить сайт службой launchd (LaunchDaemon) на маке:
#   - gunicorn стартует при загрузке, даже если никто не вошёл в систему;
#   - если gunicorn упал, launchd поднимает его снова;
#   - мак сам включается, когда после отключения появляется питание.
# Запускать от своего пользователя, без sudo: пароль спросит сам скрипт.
# Повторный запуск переустанавливает службу. Удалить: scripts/service-uninstall.sh
set -euo pipefail
DIR="$(dirname "$0")"
. "$DIR/_common.sh"

[ "$(uname -s)" = Darwin ] || die "launchd есть только в macOS"
[ "$(id -u)" -ne 0 ] || die "запускайте без sudo: служба работает от вашего пользователя"
require_venv
[ -f "$ENV_FILE" ] || die "нет $ENV_FILE — создайте его из .env.example"
[ -n "${SECRET_KEY:-}" ] || die "в .env пуст SECRET_KEY"

# Службам macOS закрыт доступ к этим папкам — gunicorn не стартует.
case "$PROJECT_DIR" in
  "$HOME/Desktop"*|"$HOME/Documents"*|"$HOME/Downloads"*)
    die "проект в $PROJECT_DIR: служба не получит доступа к Рабочему столу, Документам и Загрузкам. Перенесите папку, например в ~/Projects" ;;
esac

RUN_USER="$(id -un)"
LAUNCHD_LOG="$LOG_DIR/launchd.log"
mkdir -p "$LOG_DIR"   # launchd не создаёт папку для журнала

xml() { printf '%s' "$1" | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g'; }

TMP="$(mktemp "${TMPDIR:-/tmp}/personalpage-plist.XXXXXX")"
trap 'rm -f "$TMP"' EXIT
cat > "$TMP" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>$(xml "$SERVICE_LABEL")</string>
	<key>UserName</key>
	<string>$(xml "$RUN_USER")</string>
	<key>ProgramArguments</key>
	<array>
		<string>/bin/bash</string>
		<string>$(xml "$PROJECT_DIR/scripts/run.sh")</string>
	</array>
	<key>WorkingDirectory</key>
	<string>$(xml "$PROJECT_DIR")</string>
	<key>EnvironmentVariables</key>
	<dict>
		<key>HOME</key>
		<string>$(xml "$HOME")</string>
		<key>LANG</key>
		<string>en_US.UTF-8</string>
		<key>PATH</key>
		<string>/usr/bin:/bin:/usr/sbin:/sbin</string>
	</dict>
	<key>RunAtLoad</key>
	<true/>
	<key>KeepAlive</key>
	<true/>
	<key>ThrottleInterval</key>
	<integer>10</integer>
	<key>StandardOutPath</key>
	<string>$(xml "$LAUNCHD_LOG")</string>
	<key>StandardErrorPath</key>
	<string>$(xml "$LAUNCHD_LOG")</string>
</dict>
</plist>
PLIST
plutil -lint "$TMP" >/dev/null || die "собранный plist не прошёл проверку plutil"

say "нужны права администратора — sudo спросит пароль"
sudo -v

# Старую службу убрать, иначе bootstrap откажется («already loaded»).
if sudo launchctl print "system/$SERVICE_LABEL" >/dev/null 2>&1; then
  say "служба уже стоит — переустанавливаю"
  sudo launchctl bootout "system/$SERVICE_LABEL" 2>/dev/null || true
  for _ in $(seq 1 30); do
    sudo launchctl print "system/$SERVICE_LABEL" >/dev/null 2>&1 || break
    sleep 1
  done
fi
sudo rm -f "$SERVICE_PLIST"

# gunicorn, запущенный вручную через start.sh, занял бы порт.
if running_pid >/dev/null; then
  "$DIR/stop.sh"
fi

say "ставлю $SERVICE_PLIST (пользователь $RUN_USER)"
sudo install -m 644 -o root -g wheel "$TMP" "$SERVICE_PLIST"
sudo launchctl enable "system/$SERVICE_LABEL"
sudo launchctl bootstrap system "$SERVICE_PLIST"

if ! wait_up; then
  warn "журнал службы $LAUNCHD_LOG:"
  tail -n 20 "$LAUNCHD_LOG" >&2 2>/dev/null || true
  warn "состояние: sudo launchctl print system/$SERVICE_LABEL"
  exit 1
fi

# Без этого после отключения света мак так и останется выключенным.
if [ "$(pmset -g | awk '$1 == "autorestart" {print $2}')" != 1 ]; then
  say "включаю автозапуск мака после пропадания питания"
  sudo pmset -a autorestart 1
fi
ok "мак включится сам, когда появится питание"

# Что ещё может не дать сайту подняться после перезагрузки — только предупреждаем.
if fdesetup status 2>/dev/null | grep -q "On"; then
  warn "включён FileVault: после перезагрузки мак ждёт пароль на экране входа,"
  warn "и до его ввода не стартует ничего, включая эту службу"
fi
if sudo launchctl print system/homebrew.mxcl.caddy >/dev/null 2>&1; then
  ok "Caddy стоит системной службой и стартует при загрузке"
else
  warn "Caddy не стоит системной службой — после перезагрузки без входа в систему"
  warn "сайт снаружи не откроется. Исправить:"
  warn "  brew services stop caddy; sudo brew services start caddy"
fi

echo
ok "служба $SERVICE_LABEL установлена"
echo "  перезапуск после git pull:  scripts/restart.sh"
echo "  состояние:                  sudo launchctl print system/$SERVICE_LABEL | grep -E 'state|last exit'"
echo "  журналы:                    $LOG_DIR/error.log, $LAUNCHD_LOG"
echo "  удалить:                    scripts/service-uninstall.sh"
