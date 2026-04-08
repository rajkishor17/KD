#!/bin/bash
cd /home/z/my-project
while true; do
  NODE_ENV=production NODE_OPTIONS="--max-old-space-size=2048" npx next start -p 3000 </dev/null >/tmp/next-prod.log 2>&1
  sleep 2
done
