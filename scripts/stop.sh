#!/bin/bash

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PID_FILE="$PROJECT_DIR/gunicorn.pid"

echo "=========================================="
echo "Остановка PersonalPage..."
echo "=========================================="

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
