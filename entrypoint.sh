#!/usr/bin/env bash
set -e

# Apply migrations
python manage.py migrate --noinput

# Pass through whatever CMD you provided
exec "$@"
