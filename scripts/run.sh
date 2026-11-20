#!/usr/bin/env bash
# Миграции, статика и gunicorn на 127.0.0.1:$GUNICORN_PORT без ухода в фон —
# так сайт запускает служба launchd (scripts/service-install.sh): она сама
# держит процесс и поднимает его заново, если тот упал.
# Аргументы передаются gunicorn (например, --daemon).
set -euo pipefail
. "$(dirname "$0")/_common.sh"

require_venv
[ -f "$ENV_FILE" ] || die "нет $ENV_FILE — создайте его из .env.example"
[ -n "${SECRET_KEY:-}" ] || die "в .env пуст SECRET_KEY"

# running_pid заодно убирает PID-файл, оставшийся после выключения света:
# с ним gunicorn отказался бы стартовать.
if pid="$(running_pid)"; then
  die "gunicorn уже запущен (PID $pid)"
fi

mkdir -p "$LOG_DIR"
cd "$PROJECT_DIR"

say "миграции и статика"
"$VENV/bin/python" manage.py migrate --noinput -v 0
"$VENV/bin/python" manage.py collectstatic --noinput -v 0

say "gunicorn на 127.0.0.1:$PORT, воркеров: $WORKERS"
exec "$VENV/bin/gunicorn" personalpage.wsgi:application \
  --chdir "$PROJECT_DIR" \
  --bind "127.0.0.1:$PORT" \
  --workers "$WORKERS" \
  --pid "$PID_FILE" \
  --access-logfile "$LOG_DIR/access.log" \
  --error-logfile "$LOG_DIR/error.log" \
  --capture-output \
  ${1+"$@"}
