# shellcheck shell=bash
# Общее для run/service-install/service-uninstall и проверок в start/stop/restart.
# Подключается через `.`, сам по себе не запускается.

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
ENV_FILE="$PROJECT_DIR/.env"
VENV="$PROJECT_DIR/venv"
PID_FILE="$PROJECT_DIR/gunicorn.pid"
LOG_DIR="$PROJECT_DIR/logs"

# .env — те же переменные, что читает personalpage/settings.py.
if [ -f "$ENV_FILE" ]; then
  set -a
  # shellcheck disable=SC1090
  . "$ENV_FILE"
  set +a
fi

PORT="${GUNICORN_PORT:-8000}"
WORKERS="${GUNICORN_WORKERS:-3}"

# macOS: без этого воркер gunicorn после fork() может упасть
# с «objc[...] may have been in progress in another thread».
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

say()  { printf '→ %s\n' "$*"; }
ok()   { printf '✓ %s\n' "$*"; }
warn() { printf '! %s\n' "$*" >&2; }
die()  { printf '✗ %s\n' "$*" >&2; exit 1; }

# Служба launchd (scripts/service-install.sh): сайт поднимается при
# загрузке мака и перезапускается, если gunicorn упал.
SERVICE_LABEL="${SERVICE_LABEL:-com.personalpage.web}"
SERVICE_PLIST="/Library/LaunchDaemons/$SERVICE_LABEL.plist"

service_installed() { [ -f "$SERVICE_PLIST" ]; }

# PID живого мастера gunicorn или код 1. Протухший PID-файл удаляет.
# Одного kill -0 мало: после внезапного выключения номер из PID-файла
# может достаться чужому процессу, поэтому проверяем, что это gunicorn.
running_pid() {
  local pid
  [ -f "$PID_FILE" ] || return 1
  pid="$(cat "$PID_FILE" 2>/dev/null)"
  if [ -n "$pid" ] && ps -p "$pid" -o command= 2>/dev/null | grep -q gunicorn; then
    echo "$pid"
    return 0
  fi
  rm -f "$PID_FILE"
  return 1
}

require_venv() {
  [ -x "$VENV/bin/gunicorn" ] || die "нет окружения $VENV (или в нём нет gunicorn) — сначала создайте venv и установите зависимости"
}

# HTTP-код главной страницы (000 — нет ответа). Первый разрешённый хост
# из ALLOWED_HOSTS, чтобы Django не ответил 400.
probe_code() {
  local host="${ALLOWED_HOSTS%%,*}"
  host="$(echo "${host:-127.0.0.1}" | tr -d '[:space:]')"
  [ "$host" = "*" ] && host=127.0.0.1
  curl -s -o /dev/null -m 5 -w '%{http_code}' -H "Host: $host" \
    "http://127.0.0.1:$PORT/" || true
}

# Ждать ответа 200/301/302 до 30 секунд. Код 1 — не дождались.
wait_up() {
  local code=000 i
  for i in $(seq 1 60); do
    sleep 0.5
    if [ "$i" -gt 20 ] && ! running_pid >/dev/null; then
      warn "gunicorn не поднялся"
      break
    fi
    code="$(probe_code)"
    case "$code" in
      200|301|302)
        ok "сайт работает: http://127.0.0.1:$PORT/ → $code"
        return 0 ;;
    esac
  done
  warn "сайт не ответил (последний ответ: $code)"
  [ "$code" = 400 ] && warn "400 — проверьте ALLOWED_HOSTS в .env"
  warn "последние строки $LOG_DIR/error.log:"
  tail -n 20 "$LOG_DIR/error.log" >&2 2>/dev/null || true
  return 1
}
