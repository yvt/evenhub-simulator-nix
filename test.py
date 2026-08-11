#!/usr/bin/env python3

"""
Run the EvenHub app `example-minimal.nix` in EvenHub Simulator and check
that the app is working.
"""

import functools
import http.server
import io
import os
import socketserver
import subprocess
import sys
import threading
import time
from pathlib import Path

import requests
from PIL import Image

REPO = os.path.dirname(__file__)
AUTOMATION_PORT = 9898
SCREENSHOT_TIMEOUT = 15


def build_example():
    print("Building example-minimal...", flush=True)
    proc = subprocess.run(
        ["nix", "build", ".#example-minimal", "--no-link", "--print-out-paths", "--print-build-logs"],
        check=True,
        capture_output=True,
        text=True,
        cwd=REPO,
    )
    store_path = Path(proc.stdout.strip().splitlines()[-1])
    print(f"Built: {store_path}", flush=True)
    return store_path


def start_http_server(directory):
    handler = functools.partial(http.server.SimpleHTTPRequestHandler, directory=directory)
    httpd = socketserver.ThreadingTCPServer(("127.0.0.1", 0), handler)
    httpd.daemon_threads = True
    thread = threading.Thread(target=httpd.serve_forever, daemon=True)
    thread.start()
    return httpd, httpd.server_address[1]


def wait_for_nonempty_screenshot():
    url = f"http://127.0.0.1:{AUTOMATION_PORT}/api/screenshot/glasses"
    deadline = time.time() + SCREENSHOT_TIMEOUT
    last_error = None
    while time.time() < deadline:
        try:
            resp = requests.get(url, timeout=5)
            if resp.status_code == 200 and resp.content:
                img = Image.open(io.BytesIO(resp.content))
                img.load()
                if img.width > 0 and img.height > 0:
                    colors = img.getcolors(maxcolors=2)
                    if colors is None or len(colors) > 1:
                        print(f"Got screenshot: {img.size}", flush=True)
                        return img
        except Exception as exc:
            last_error = exc
        time.sleep(1)
    raise TimeoutError(
        f"No non-empty screenshot within {SCREENSHOT_TIMEOUT}s (last error: {last_error!r})"
    )


def main():
    serve_dir = build_example()
    httpd, http_port = start_http_server(serve_dir)
    app_url = f"http://127.0.0.1:{http_port}/"
    print(f"Serving {serve_dir} at {app_url}", flush=True)

    # Start the simulator
    sim = subprocess.Popen(
        ["nix", "run", ".#evenhub-simulator-headless", "--", app_url, "--automation-port", str(AUTOMATION_PORT)],
        cwd=REPO,
    )

    # Wait for the app to load
    try:
        wait_for_nonempty_screenshot()
        print("SUCCESS", flush=True)
        return 0
    finally:
        sim.terminate()
        subprocess.run(["pkill", "-f", "evenhub-simulator"])
        try:
            sim.wait(timeout=10)
        except subprocess.TimeoutExpired:
            sim.kill()
        httpd.shutdown()
        httpd.server_close()


if __name__ == "__main__":
    sys.exit(main())
