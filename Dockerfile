FROM python:3.11-slim

# System deps for psycopg2 + curl (healthcheck)
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc libpq-dev curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install Python dependencies (cached layer — only re-runs if requirements.txt changes)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy source code
COPY . .

# Make start script executable (fix Windows line endings too)
RUN apt-get update && apt-get install -y --no-install-recommends dos2unix \
    && dos2unix start.sh \
    && chmod +x start.sh \
    && apt-get purge -y dos2unix && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

CMD ["./start.sh"]
