#!/usr/bin/env sh
set -e

# 1) Apply any new migrations
python3 manage.py migrate --noinput

# 2) Launch Django on the port Cloud Run expects
#    $PORT is injected by Cloud Run 
exec gunicorn url_shortener.wsgi:application \
     --bind 0.0.0.0:${PORT} \
     --workers 2 \
     --timeout 300
