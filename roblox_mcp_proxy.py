import sys
import json
import subprocess
import glob
import os
import threading
import traceback
import time

# Ensure UTF-8 everywhere on Windows
try:
    if hasattr(sys.stdin, 'reconfigure'):
        sys.stdin.reconfigure(encoding='utf-8', errors='replace')
    if hasattr(sys.stdout, 'reconfigure'):
        sys.stdout.reconfigure(encoding='utf-8', errors='replace')
    if hasattr(sys.stderr, 'reconfigure'):
        sys.stderr.reconfigure(encoding='utf-8', errors='replace')
except Exception:
    pass

LOG_FILE = r'd:\Script\mcp_proxy.log'

def log(msg):
    try:
        with open(LOG_FILE, 'a', encoding='utf-8', errors='replace') as f:
            f.write(f"[{time.strftime('%Y-%m-%d %H:%M:%S')}] {msg}\n")
    except Exception:
        pass

log("=== Proxy starting ===")

try:
    roblox_path = os.path.expandvars(r'%LOCALAPPDATA%\Roblox\Versions\*\StudioMCP.exe')
    files = glob.glob(roblox_path)

    if not files:
        log("Error: StudioMCP.exe not found")
        sys.stderr.write("Error: StudioMCP.exe not found\n")
        sys.exit(1)

    latest_mcp = max(files, key=os.path.getmtime)
    log(f"Using StudioMCP: {latest_mcp}")

    proc = subprocess.Popen(
        [latest_mcp],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        encoding='utf-8',
        errors='replace',
        bufsize=1
    )
    log(f"StudioMCP started with PID: {proc.pid}")

    def forward_stderr():
        while True:
            try:
                line = proc.stderr.readline()
                if not line:
                    break
                log(f"StudioMCP STDERR: {line.strip()}")
                sys.stderr.write(line)
                sys.stderr.flush()
            except Exception as e:
                log(f"forward_stderr error (handled): {e}")

    threading.Thread(target=forward_stderr, daemon=True).start()

    def forward_output():
        while True:
            try:
                line = proc.stdout.readline()
                if not line:
                    break
                log(f"StudioMCP -> IDE: {line.strip()[:200]}")
                sys.stdout.write(line)
                sys.stdout.flush()
            except Exception as e:
                log(f"forward_output error (handled): {e}")

    threading.Thread(target=forward_output, daemon=True).start()

    log("Listening to IDE stdin...")
    while True:
        try:
            line = sys.stdin.readline()
            if not line:
                break
            if not line.strip():
                continue
            log(f"IDE -> Proxy: {line.strip()[:200]}")
            try:
                data = json.loads(line)
                if data.get("method") == "server/discover":
                    response = {
                        "jsonrpc": "2.0",
                        "id": data.get("id"),
                        "result": {}
                    }
                    resp_str = json.dumps(response) + "\n"
                    log(f"Proxy responding to server/discover: {resp_str.strip()}")
                    sys.stdout.write(resp_str)
                    sys.stdout.flush()
                    continue
            except Exception as e:
                log(f"JSON parse warning: {e}")

            if proc.stdin and not proc.stdin.closed:
                try:
                    proc.stdin.write(line)
                    proc.stdin.flush()
                except Exception as e:
                    log(f"Error writing to StudioMCP stdin: {e}")
                    break
        except Exception as e:
            log(f"sys.stdin reading error (handled): {e}")

    log("IDE stdin closed. Terminating StudioMCP.")
    proc.terminate()

except Exception as e:
    log(f"Fatal exception: {traceback.format_exc()}")
    sys.exit(1)
