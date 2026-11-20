#!/bin/bash

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENV_PATH="$PROJECT_DIR/.venv/bin/activate"
PID_FILE="$PROJECT_DIR/gunicorn.pid"
export $(grep -v '^#' "$PROJECT_DIR/.env" | xargs)
PORT=${GUNICORN_PORT:-8002}

echo "=========================================="
echo "Перезапуск PersonalPage..."
echo "=========================================="

cd "$PROJECT_DIR"

# 1. Остановка Gunicorn
if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    echo "▶️ Остановка Gunicorn (PID: $PID)..."
    kill "$PID"
    rm "$PID_FILE"
    sleep 2
else
    echo "ℹ️ Gunicorn не был запущен (PID-файл отсутствует)."
fi

# 2. Запуск заново
if [ -f "$VENV_PATH" ]; then
    source "$VENV_PATH"
else
    echo "❌ Виртуальное окружение не найдено!"
    exit 1
fi

echo "▶️ Запуск Gunicorn..."
caffeinate -i -s gunicorn personalpage.wsgi:application \
    --bind 127.0.0.1:$PORT \
    --workers 2 \
    --pid "$PID_FILE" \
    --daemon

if [ $? -eq 0 ]; then
    echo "✅ Gunicorn перезапущен."
else
    echo "❌ Ошибка при перезапуске Gunicorn!"
    exit 1
fi

echo "▶️ Попытка перезагрузки Caddy..."
caddy reload --config ../Caddyfile

if [ $? -eq 0 ]; then
    echo "✅ Caddy успешно перезагружен."
else
    echo "ℹ️ Caddy не перезагружен (возможно, он не запущен или требует sudo)."
fi

echo "=========================================="
echo "Перезапуск завершен."
echo "=========================================="
