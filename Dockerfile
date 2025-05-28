# Use the official Python image
FROM python:3.11-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Set working directory inside the container
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy dependency list
COPY requirements.txt .

# Install Python dependencies
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

# Copy the rest of the code
COPY . .


RUN apt-get update \
 && apt-get install -y curl \
 && rm -rf /var/lib/apt/lists/*

# Run Django server on container start
CMD ["python3", "manage.py", "runserver", "0.0.0.0:8000"]

# Copy the entrypoint script into the image
COPY entrypoint.sh /app/entrypoint.sh

# Make sure it’s executable
RUN chmod +x /app/entrypoint.sh

# Tell Docker to use it as the container’s entrypoint
ENTRYPOINT ["/app/entrypoint.sh"]
