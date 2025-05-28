# Dockerfile

# 1. Base image
FROM python:3.11-slim

# 2. Set workdir
WORKDIR /app

# 3. Install system dependencies
RUN apt-get update \
 && apt-get install -y build-essential libpq-dev curl \
 && rm -rf /var/lib/apt/lists/*

# 4. Copy and install Python deps
COPY requirements.txt .
RUN pip install --upgrade pip \
 && pip install -r requirements.txt

# 5. Copy application code
COPY . .

# 6. Copy and make entrypoint executable
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# 7. Expose port for documentation (doesn't affect Cloud Run)
EXPOSE 8000

# 8. Use the entrypoint
ENTRYPOINT ["/app/entrypoint.sh"]
