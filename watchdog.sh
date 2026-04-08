#!/bin/bash
while true; do
  sleep 5
  if ! pgrep -f "next start" > /dev/null 2>&1; then
    echo "[$(date)] Server not running, restarting..." >> /tmp/next-watchdog.log
    cd /home/z/my-project
    NODE_OPTIONS="--max-old-space-size=2048" nohup npx next start -p 3000 </dev/null >>/tmp/next-prod.log 2>&1 &
    disown
  fi
done
