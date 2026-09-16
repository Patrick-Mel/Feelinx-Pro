#!/bin/sh
set -e

PORT="${PORT:-8000}"
echo "=========================================="
echo "Starting Feelinx Backend on Port: $PORT"
echo "=========================================="

python manage.py migrate --noinput
python manage.py seed_demo || true
python manage.py collectstatic --noinput || true

exec daphne -b 0.0.0.0 -p "$PORT" config.asgi:application
