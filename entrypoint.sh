#!/bin/sh
set -e

# Default to 8000 if PORT isn't set (Cloud Run will inject PORT=8080 or 8000)
PORT="${PORT:-8000}"

# Run Django migrations 
echo "Running migrations…"
python manage.py migrate --no-input

# Launch Gunicorn
exec gunicorn url_shortener.wsgi:application \
     --bind "0.0.0.0:${PORT}" \
     --workers 2
