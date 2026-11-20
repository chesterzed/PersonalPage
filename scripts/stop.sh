#!/bin/bash

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PID_FILE="$PROJECT_DIR/gunicorn.pid"

echo "=========================================="
echo "Остановка PersonalPage..."
echo "=========================================="

# Служба с KeepAlive сразу подняла бы убитый gunicorn снова.
. "$PROJECT_DIR/scripts/_common.sh"
if service_installed; then
    echo "❌ Сайт запускает служба $SERVICE_LABEL. Остановить её: scripts/service-uninstall.sh"
    exit 1
fi

if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    echo "▶️ Остановка Gunicorn (PID: $PID)..."
    kill "$PID"
    rm "$PID_FILE"
    echo "✅ Остановлено."
else
    echo "ℹ️ Gunicorn не запущен."
fi

echo "=========================================="
