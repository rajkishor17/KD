#!/bin/bash
# Proper daemon with double-fork to survive session termination
# This script auto-restarts the Next.js server within 2 seconds if it dies

DAEMON_NAME="kolkata-durgotsav"
PID_FILE="/home/z/my-project/.server.pid"
LOG_FILE="/tmp/next-prod.log"

cd /home/z/my-project

# Double-fork to properly daemonize
(
    # First fork
    (
        # Second fork - this process is now truly orphaned
        while true; do
            # Check if another instance is already running
            if [ -f "$PID_FILE" ]; then
                OLD_PID=$(cat "$PID_FILE" 2>/dev/null)
                if [ -n "$OLD_PID" ] && kill -0 "$OLD_PID" 2>/dev/null; then
                    sleep 2
                    continue
                fi
            fi
            
            # Start the server
            env NODE_ENV=production NODE_OPTIONS="--max-old-space-size=2048" \
                npx next start -p 3000 >> "$LOG_FILE" 2>&1 &
            SERVER_PID=$!
            echo "$SERVER_PID" > "$PID_FILE"
            
            # Wait for the server to exit
            wait $SERVER_PID 2>/dev/null
            
            # Server died - clean up and restart immediately
            echo "[$(date)] Server (PID $SERVER_PID) died. Restarting in 1 second..." >> "$LOG_FILE"
            rm -f "$PID_FILE"
            sleep 1
        done
    ) &
    # Exit first fork immediately
    disown
) &
disown

echo "Daemon started successfully. Server will auto-restart if it dies."
echo "Log: $LOG_FILE"
