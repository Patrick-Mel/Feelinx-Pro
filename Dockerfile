FROM python:3.12-slim

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    gettext \
    curl \
    && rm -rf /var/lib/apt/lists/*

COPY . /app/

RUN if [ -f "backend/requirements/prod.txt" ]; then \
        cd backend && pip install --no-cache-dir -r requirements/prod.txt; \
    elif [ -f "requirements/prod.txt" ]; then \
        pip install --no-cache-dir -r requirements/prod.txt; \
    else \
        pip install --no-cache-dir -r requirements.txt; \
    fi

RUN if [ -f "backend/entrypoint.sh" ]; then \
        chmod +x backend/entrypoint.sh; \
    elif [ -f "entrypoint.sh" ]; then \
        chmod +x entrypoint.sh; \
    fi

EXPOSE 8000

CMD ["sh", "-c", "if [ -f 'backend/entrypoint.sh' ]; then cd backend && ./entrypoint.sh; else ./entrypoint.sh; fi"]
