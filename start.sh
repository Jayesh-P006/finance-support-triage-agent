#!/bin/bash
# ──────────────────────────────────────────────────────
# Railway Startup Script
# Runs FastAPI backend (internal :8000) + Streamlit frontend (exposed :$PORT)
# ──────────────────────────────────────────────────────

set -e

echo "🚀 Starting Finance Support Triage Agent on Railway..."
echo "   PORT=$PORT"

# 1. Start FastAPI backend on port 8000 (internal, not exposed to internet)
echo "📦 Starting FastAPI backend on :8000 ..."
cd /app/backend
uvicorn main:app --host 0.0.0.0 --port 8000 --workers 1 &
BACKEND_PID=$!

# Wait for backend to be ready
echo "⏳ Waiting for backend to start..."
for i in $(seq 1 30); do
    if curl -s http://127.0.0.1:8000/ > /dev/null 2>&1; then
        echo "✅ Backend is ready!"
        break
    fi
    sleep 1
done

# 2. Start Streamlit frontend on $PORT (exposed by Railway)
echo "🖥️  Starting Streamlit frontend on :${PORT:-8501} ..."
cd /app
streamlit run frontend/app.py \
    --server.port "${PORT:-8501}" \
    --server.address 0.0.0.0 \
    --server.headless true \
    --browser.gatherUsageStats false \
    --server.fileWatcherType none &
FRONTEND_PID=$!

echo "✅ Both services started. Backend PID=$BACKEND_PID, Frontend PID=$FRONTEND_PID"

# Wait for either process to exit (if one dies, stop everything)
wait -n $BACKEND_PID $FRONTEND_PID
echo "❌ A process exited. Shutting down..."
kill $BACKEND_PID $FRONTEND_PID 2>/dev/null
exit 1
