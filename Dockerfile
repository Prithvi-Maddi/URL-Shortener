FROM python:3.11-slim

WORKDIR /app

# 1) OS deps for Postgres & tooling
RUN apt-get update \
 && apt-get install -y build-essential libpq-dev curl \
 && rm -rf /var/lib/apt/lists/*

# 2) Install Python deps
COPY requirements.txt .
RUN pip install --upgrade pip \
 && pip install -r requirements.txt

# 3) Copy code & our entrypoint script
COPY . .
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# 4) Tell Cloud Run what port we’ll listen on
ENV PORT=8000

# 5) Use our entrypoint (runs migrate, then Gunicorn)
ENTRYPOINT ["/app/entrypoint.sh"]
