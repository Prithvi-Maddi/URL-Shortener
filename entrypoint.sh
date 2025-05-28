#!/usr/bin/env sh

# Exit on any error
set -e

# 1. Apply any outstanding Django migrations
python3 manage.py migrate

# 2. (Optional) Collect static files
# python3 manage.py collectstatic --noinput

# 3. Launch the Django development server,
#    binding to 0.0.0.0 on the port defined in $PORT (default 8080)
exec python3 manage.py runserver 0.0.0.0:${PORT:-8080}
