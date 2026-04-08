#!/bin/bash
# Server Guard - Keeps Next.js alive with 2-second restart
# Runs as a persistent background process

PROJECT="/home/z/my-project"
HEALTH_URL="http://localhost:3000/"
LOG="/tmp/server-guard.log"
GUARD_PID_FILE="/tmp/server-guard.pid"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Server Guard starting..." > "$LOG"
echo $$ > "$GUARD_PID_FILE"

start_server() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting Next.js server..." >> "$LOG"
    cd "$PROJECT"
    NODE_OPTIONS="--max-old-space-size=2048" npx next start -p 3000 </dev/null >/tmp/next-prod.log 2>&1 &
    SERVER_PID=$!
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Server PID: $SERVER_PID" >> "$LOG"
    # Wait for it to come up
    sleep 5
}

# Start server initially
start_server

# Main loop - check every 3 seconds
while true; do
    sleep 3
    RESPONSE=$(curl -m 2 -s -o /dev/null -w '%{http_code}' "$HEALTH_URL" 2>/dev/null)
    
    if [ "$RESPONSE" != "200" ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Server DOWN (HTTP $RESPONSE). Restarting..." >> "$LOG"
        
        # Kill any leftover processes
        pkill -f "next-server" 2>/dev/null
        pkill -f "next start" 2>/dev/null
        sleep 1
        
        # Restart
        start_server
    fi
done
