const { spawn } = require('child_process');
const fs = require('fs');

function start() {
  const child = spawn('npx', ['next', 'start', '-p', '3000'], {
    cwd: '/home/z/my-project',
    env: { ...process.env, NODE_OPTIONS: '--max-old-space-size=2048' },
    detached: false,
    stdio: ['ignore', fs.openSync('/tmp/next-prod.log', 'a'), fs.openSync('/tmp/next-prod.log', 'a')]
  });

  child.on('exit', (code, signal) => {
    const msg = `[${new Date().toISOString()}] Server died: code=${code} signal=${signal}, restarting in 2s\n`;
    fs.appendFileSync('/tmp/next-prod.log', msg);
    setTimeout(start, 2000);
  });

  child.on('error', (err) => {
    fs.appendFileSync('/tmp/next-prod.log', `[${new Date().toISOString()}] Error: ${err.message}\n`);
  });
}

fs.appendFileSync('/tmp/next-prod.log', `[${new Date().toISOString()}] Keepalive started\n`);
start();
