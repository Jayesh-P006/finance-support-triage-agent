FROM python:3.11-slim

# System deps for psycopg2, Pillow, EasyOCR
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc libpq-dev libgl1 libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy source code
COPY . .

# Make start script executable
RUN chmod +x start.sh

# Railway sets $PORT at runtime (default 8501 for local testing)
ENV PORT=8501

EXPOSE $PORT

CMD ["./start.sh"]
