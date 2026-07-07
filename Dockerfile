FROM python:3.11-slim

# Prevents Python from writing .pyc files and buffers stdout (nicer logs)
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Copy requirements first so Docker can cache the pip install layer
COPY requirements.txt .

# The repo's requirements.txt is UTF-16 encoded; convert it to UTF-8 so pip can read it
RUN apt-get update && apt-get install -y --no-install-recommends file \
    && iconv -f UTF-16LE -t UTF-8 requirements.txt -o requirements_utf8.txt \
    && mv requirements_utf8.txt requirements.txt \
    && apt-get purge -y file && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the app (app.py, utils.py, models/, templates/)
COPY . .

EXPOSE 8080

# Serve with gunicorn instead of Flask's dev server (debug=True in app.py is fine for
# local dev, but gunicorn is what's actually installed for production use)
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "2", "app:app"]
