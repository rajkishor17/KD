#!/bin/bash
# Kolkata Durgotsav - Server Start Script with Auto-Restart
# If server dies, it restarts within 2 seconds automatically

cd /home/z/my-project

# Kill any existing server/daemon processes
pkill -f "daemon.sh" 2>/dev/null
pkill -f "next start" 2>/dev/null
pkill -f "next-server" 2>/dev/null
sleep 1

# Clean up old PID file
rm -f .server.pid

# Create daemon that will keep server alive forever
(
    (
        while true; do
            # Check if another instance is already running
            if [ -f "/home/z/my-project/.server.pid" ]; then
                OLD_PID=$(cat "/home/z/my-project/.server.pid" 2>/dev/null)
                if [ -n "$OLD_PID" ] && kill -0 "$OLD_PID" 2>/dev/null; then
                    sleep 2
                    continue
                fi
            fi
            
            # Start the server
            echo "[$(date)] Starting server..." >> /tmp/next-prod.log
            env NODE_ENV=production NODE_OPTIONS="--max-old-space-size=512" \
                npx next start -p 3000 >> /tmp/next-prod.log 2>&1 &
            SERVER_PID=$!
            echo "$SERVER_PID" > /home/z/my-project/.server.pid
            
            # Wait for the server to exit
            wait $SERVER_PID 2>/dev/null
            
            # Server died - restart immediately
            echo "[$(date)] Server (PID $SERVER_PID) died. Restarting in 1 second..." >> /tmp/next-prod.log
            rm -f /home/z/my-project/.server.pid
            sleep 1
        done
    ) &
    disown
) &
disown

sleep 5

# Verify server started
if curl -sf -o /dev/null --max-time 5 http://localhost:3000/ 2>/dev/null; then
    echo "✅ Server started with auto-restart protection!"
    echo "   Homepage: http://localhost:3000/"
    echo "   Admin:    http://localhost:3000/admin"
    echo "   If server dies, it will auto-restart within 2 seconds."
else
    echo "⚠️  Server starting... (may take a few more seconds)"
    echo "   The auto-restart daemon is running in background."
fi
