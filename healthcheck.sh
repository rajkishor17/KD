#!/bin/bash
# Quick health check + restart script (called by cron)
# Lightweight - just checks if server responds, starts it if not

PID_FILE="/home/z/my-project/.server.pid"
LOG_FILE="/tmp/next-prod.log"
HEALTH_URL="http://localhost:3000/"

# Check if server is responding
if curl -sf -o /dev/null --max-time 3 "$HEALTH_URL" 2>/dev/null; then
    exit 0
fi

# Server not responding - check daemon
if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE" 2>/dev/null)
    if [ -n "$PID" ] && kill -0 "$PID" 2>/dev/null; then
        # Daemon is running but server isn't responding - kill the whole process tree
        kill -9 "$PID" 2>/dev/null
        rm -f "$PID_FILE"
    fi
fi

# Kill any leftover node/next processes
pkill -f "next start" 2>/dev/null
sleep 1

# Restart daemon
cd /home/z/my-project
bash /home/z/my-project/daemon.sh
