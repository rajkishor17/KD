#!/bin/bash
# Ultra-fast server health check and auto-restart
# Checks if Next.js is responding, restarts if not

HEALTH_URL="http://localhost:3000/"
LOG="/tmp/auto-restart.log"
PROJECT="/home/z/my-project"

# Quick health check with 2-second timeout
RESPONSE=$(curl -m 2 -s -o /dev/null -w '%{http_code}' "$HEALTH_URL" 2>/dev/null)

if [ "$RESPONSE" != "200" ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Server DOWN (HTTP $RESPONSE). Restarting..." >> "$LOG"
    
    # Kill any lingering processes
    pkill -f "next-server" 2>/dev/null
    pkill -f "next start" 2>/dev/null
    sleep 1
    
    # Restart the server
    cd "$PROJECT"
    NODE_OPTIONS="--max-old-space-size=2048" setsid npx next start -p 3000 </dev/null >/tmp/next-prod.log 2>&1 &
    
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Restart initiated. Waiting for server..." >> "$LOG"
    
    # Wait up to 10 seconds for server to come up
    for i in $(seq 1 10); do
        sleep 1
        CHECK=$(curl -m 2 -s -o /dev/null -w '%{http_code}' "$HEALTH_URL" 2>/dev/null)
        if [ "$CHECK" = "200" ]; then
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] Server UP (HTTP $CHECK)" >> "$LOG"
            exit 0
        fi
    done
    
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] WARNING: Server still not responding after 10s" >> "$LOG"
else
    # Silent when healthy - don't spam logs
    : 
fi
