#!/bin/bash
# ──────────────────────────────────────────────────────
# Railway Startup Script
# Runs FastAPI backend (internal :8000) + Streamlit frontend (exposed :$PORT)
# ──────────────────────────────────────────────────────

set -e

# Railway injects PORT — default to 8501 for local testing
export PORT=${PORT:-8501}

echo "🚀 Starting Finance Support Triage Agent..."
echo "   PUBLIC PORT=$PORT (Streamlit)"
echo "   INTERNAL PORT=8000 (FastAPI)"

# 1. Start FastAPI backend on port 8000 (internal only)
echo "📦 Starting FastAPI backend..."
cd /app/backend
python -m uvicorn main:app --host 0.0.0.0 --port 8000 --workers 1 &
BACKEND_PID=$!

# 2. Wait for backend to be healthy
echo "⏳ Waiting for backend..."
for i in $(seq 1 30); do
    if curl -sf http://127.0.0.1:8000/ > /dev/null 2>&1; then
        echo "✅ Backend is ready!"
        break
    fi
    if [ $i -eq 30 ]; then
        echo "❌ Backend failed to start after 30s"
        exit 1
    fi
    sleep 1
done

# 3. Start Streamlit frontend on $PORT (exposed by Railway)
echo "🖥️  Starting Streamlit on port $PORT..."
cd /app
exec streamlit run frontend/app.py \
    --server.port=$PORT \
    --server.address=0.0.0.0 \
    --server.headless=true \
    --server.enableCORS=false \
    --server.enableXsrfProtection=false \
    --browser.gatherUsageStats=false \
    --server.fileWatcherType=none
