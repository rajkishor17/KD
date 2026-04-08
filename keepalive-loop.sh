#!/bin/bash
while true; do
  cd /home/z/my-project
  NODE_OPTIONS="--max-old-space-size=2048" npx next start -p 3000 </dev/null >>/tmp/next-prod.log 2>&1
  EXITCODE=$?
  echo "[$(date)] EXIT:$EXITCODE" >> /tmp/next-prod.log
  # Restart immediately
  sleep 1
done
