#!/usr/bin/env bash
# Удалить службу launchd, поставленную scripts/service-install.sh, и
# остановить сайт. После этого он снова управляется start.sh / stop.sh.
# Настройку «включаться после пропадания питания» (pmset autorestart)
# не трогает: выключить — sudo pmset -a autorestart 0
set -euo pipefail
DIR="$(dirname "$0")"
. "$DIR/_common.sh"

[ "$(uname -s)" = Darwin ] || die "launchd есть только в macOS"
[ "$(id -u)" -ne 0 ] || die "запускайте без sudo — пароль спросит сам скрипт"

say "нужны права администратора — sudo спросит пароль"
sudo -v

if ! service_installed && ! sudo launchctl print "system/$SERVICE_LABEL" >/dev/null 2>&1; then
  ok "служба $SERVICE_LABEL не установлена"
  exit 0
fi

say "останавливаю службу $SERVICE_LABEL"
sudo launchctl bootout "system/$SERVICE_LABEL" 2>/dev/null || true
for _ in $(seq 1 30); do
  sudo launchctl print "system/$SERVICE_LABEL" >/dev/null 2>&1 || break
  sleep 1
done
sudo rm -f "$SERVICE_PLIST"

# bootout шлёт gunicorn TERM; если он не успел выйти — дожимает stop.sh.
if running_pid >/dev/null; then
  "$DIR/stop.sh"
fi
rm -f "$PID_FILE"

ok "служба удалена, сайт остановлен"
echo "  запустить вручную:   scripts/start.sh"
echo "  поставить заново:    scripts/service-install.sh"
