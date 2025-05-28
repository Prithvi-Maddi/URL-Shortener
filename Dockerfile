FROM python:3.11-slim

WORKDIR /app

RUN apt-get update \
 && apt-get install -y build-essential libpq-dev curl \
 && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --upgrade pip \
 && pip install -r requirements.txt

COPY . .

# default PORT for Cloud Run
ENV PORT 8000

RUN chmod +x /app/entrypoint.sh

EXPOSE 8000
ENTRYPOINT ["/app/entrypoint.sh"]
