# URL Shortener Service

A simple URL shortener with RESTful API, built with Django & Django REST Framework, containerized with Docker, CI/CD via GitHub Actions, and deployed on Google Cloud Run.

---

## Table of Contents

- [Features](#features)  
- [Tech Stack](#tech-stack)  
- [Prerequisites](#prerequisites)  
- [Running Locally](#running-locally)  
- [API Examples](#api-examples)  
- [CI/CD](#cicd)  
- [Deployment](#deployment)  
- [Time Breakdown](#time-breakdown)  
- [Tradeoffs & Shortcuts](#tradeoffs--shortcuts)  

---

## Features

- **POST `/shorten`** – Create a short URL  
- **GET `/<short_code>`** – Redirect to original URL  
- **GET `/analytics/<short_code>`** – Get redirect count & metadata  

---

## Tech Stack

- **Backend:** Python 3.11, Django 5.2, Django REST Framework  
- **Database:** PostgreSQL  
- **Containerization:** Docker  
- **CI/CD:** GitHub Actions  
- **Hosting:** Google Cloud Run + Cloud SQL  

---

## Prerequisites

- Python 3.11  
- Docker  
- Google Cloud SDK (`gcloud`)  
- GitHub account (public repo)  
- GCP project with:
  - Cloud Run & Secret Manager APIs enabled  
  - Cloud SQL (PostgreSQL) instance  
  - Secret Manager entry for your DB password  

---

## Running Locally

1. **Clone & enter repo**  
~~~bash
git clone https://github.com/<your-username>/url-shortener.git
cd url-shortener
~~~


2. **Start PostgreSQL in Docker**
~~~bash
docker run --rm --name pg-test
-e POSTGRES_DB=shortener_db
-e POSTGRES_USER=shortener_user
-e POSTGRES_PASSWORD=shortener_pass
-p 5432:5432
postgres:15
~~~

3. **Create & activate virtualenv**  
~~~bash
python3 -m venv .venv
source .venv/bin/activate
~~~


4. **Install dependencies**  
~~~bash
pip install --upgrade pip
pip install -r requirements.txt
~~~

5. **Export environment variables**  
~~~bash
export DB_NAME=shortener_db
export DB_USER=shortener_user
export DB_PASSWORD=shortener_pass
export DB_HOST=localhost
export DB_PORT=5432
export ALLOWED_HOSTS=localhost
~~~

6. **Apply migrations**  
~~~bash
python manage.py migrate
~~~

7. **Run development server**  
~~~bash
python manage.py runserver 0.0.0.0:8000
~~~
8. **Verify health**  
~~~bash
curl http://localhost:8000/health/
~~~

_**Troubleshooting tips:**_  
- Make sure `DB_HOST` is reachable (use `host.docker.internal` on Mac Docker if needed).  
- Ensure `ALLOWED_HOSTS` includes your hostname.  

---

## API Examples

1. **Shorten a URL**  
~~~bash
curl -i -X POST http://localhost:8000/shorten
-H "Content-Type: application/json"
-d '{"original_url":"https://www.example.com"}'
~~~

2. **Redirect**  
~~~bash
curl -i http://localhost:8000/<short_code>
~~~

3. **Analytics**  
~~~bash
curl -i http://localhost:8000/analytics/<short_code>
~~~

---

## CI/CD

Workflow file: `.github/workflows/ci-cd.yml`  
**On push to `main`:**  
1. **tests** job  
- Starts Postgres service  
- Exports DB credentials  
- Installs deps & runs `python manage.py test`  
2. **publish-image** job (if tests pass)  
- Builds Docker image  
- Logs in to GitHub Container Registry  
- Tags & pushes image to `ghcr.io/<your-username>/url-shortener:latest`  

---

## Deployment

1. **Build & push to GCR**  
~~~bash
docker build --platform linux/amd64
-t gcr.io/$GCP_PROJECT_ID/url-shortener:latest .
docker push gcr.io/$GCP_PROJECT_ID/url-shortener:latest
~~~


2. **Deploy on Cloud Run**  
~~~bash
gcloud run deploy url-shortener-service
--image gcr.io/$GCP_PROJECT_ID/url-shortener:latest
--platform managed --region us-central1
--allow-unauthenticated
--add-cloudsql-instances=$CLOUD_SQL_CONNECTION_NAME
--set-env-vars=DB_HOST=/cloudsql/$CLOUD_SQL_CONNECTION_NAME,DB_NAME=shortener_db,DB_USER=shortener_user,ALLOWED_HOSTS='.run.app'
--set-secrets=DB_PASSWORD=db-password:latest
--concurrency=80 --timeout=300s
~~~

3. **Test live endpoint (Optional, used to ensure proper operation)**  
~~~bash
export SERVICE_URL=$(gcloud run services describe url-shortener-service
--platform managed --region us-central1
--format="value(status.url)")
curl -i -X POST $SERVICE_URL/shorten
-H "Content-Type: application/json"
-d '{"original_url":"https://www.example.com"}'
~~~


---

## Time Breakdown

- **API implementation & tests:** 4 hrs  
- **Docker & local testing:** 4 hrs  
- **CI/CD workflow:** 3 hrs  
- **Cloud Run deployment & troubleshooting:** 7 hrs  
- **Documentation & README:** 1.5 hrs  

---

## Tradeoffs & Shortcuts

- Used **Gunicorn** with two workers for simplicity, which means no auto-scaling tuning.  
- Allowed all hosts (`ALLOWED_HOSTS="*"`) during development to allow flexibility.  
- Skipped advanced Cloud Monitoring/Logging setup to focus on core delivery.  
- CI does not push to GCR (only GHCR) to avoid GCP auth complexity; deployment uses manual GCR push.  
