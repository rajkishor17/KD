#!/bin/bash
# Self-healing Next.js server runner
PROJECT="/home/z/my-project"
LOG="/tmp/server-run.log"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] run-server started" >> "$LOG"

while true; do
    cd "$PROJECT"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting Next.js..." >> "$LOG"
    NODE_OPTIONS="--max-old-space-size=512" npx next start -p 3000 >> "$LOG" 2>&1
    EXIT_CODE=$?
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Server exited with code $EXIT_CODE. Restarting in 1s..." >> "$LOG"
    sleep 1
done
