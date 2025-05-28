#!/bin/sh
set -e

# Run migrations
python manage.py migrate --noinput

# Port is already in $PORT thanks to ENV in Dockerfile
: "${PORT:=8000}"

# Start Gunicorn (bind to 0.0.0.0 so Cloud Run health checks work)
exec gunicorn url_shortener.wsgi:application \
     --bind 0.0.0.0:"$PORT" \
     --workers 2 \
     --timeout 300
