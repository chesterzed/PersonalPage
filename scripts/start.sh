#!/bin/bash

# Определение путей
# Скрипт находит корень проекта относительно своего местоположения
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENV_PATH="$PROJECT_DIR/venv/bin/activate"
PID_FILE="$PROJECT_DIR/gunicorn.pid"
export $(grep -v '^#' "$PROJECT_DIR/.env" | xargs)
PORT=${GUNICORN_PORT:-8000}

echo "=========================================="
echo "Запуск PersonalPage на Mac Mini..."
echo "=========================================="

cd "$PROJECT_DIR"

# 1. Запуск Gunicorn (слушает локальный порт 8000)
if [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE") 2>/dev/null; then
    echo "⚠️ Gunicorn уже запущен (PID: $(cat $PID_FILE))."
else
    echo "▶️ Запуск Gunicorn в фоне..."
    if [ -f "$VENV_PATH" ]; then
        source "$VENV_PATH"
    else
        echo "❌ Виртуальное окружение не найдено по пути: $VENV_PATH"
        exit 1
    fi

    gunicorn personalpage.wsgi:application \
        --bind 127.0.0.1:$PORT \
        --workers 2 \
        --pid "$PID_FILE" \
        --daemon

    if [ $? -eq 0 ]; then
        echo "✅ Gunicorn успешно запущен."
    else
        echo "❌ Ошибка запуска Gunicorn!"
        exit 1
    fi
fi

# 2. Перезагрузка Caddy
echo "▶️ Попытка перезагрузки Caddy..."
# Мы предполагаем, что Caddy установлен глобально или как служба.
# Если вы используете специфичный путь к конфигу, укажите его здесь:
# caddy reload --config /path/to/your/main/Caddyfile
caddy reload 2>/dev/null

if [ $? -eq 0 ]; then
    echo "✅ Caddy успешно перезагружен."
else
    echo "ℹ️ Caddy не перезагружен (возможно, он не запущен или требует sudo)."
    echo "   Пожалуйста, убедитесь, что блок для порта 6969 добавлен в ваш основной Caddyfile."
fi

echo "=========================================="
echo "Проект должен быть доступен по порту 6969"
echo "=========================================="
