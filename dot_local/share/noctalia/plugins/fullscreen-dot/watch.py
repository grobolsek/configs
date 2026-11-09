#!/usr/bin/env python3
# Prints "<monitor>=<0|1> ..." whenever the fullscreen state of any monitor's
# active workspace changes. 1 = it holds a maximized (Super+D) or fullscreen window.
import json, os, socket, sys

base = os.path.join(os.environ["XDG_RUNTIME_DIR"], "hypr", os.environ["HYPRLAND_INSTANCE_SIGNATURE"])

def query(cmd):
    s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    s.connect(os.path.join(base, ".socket.sock"))
    s.sendall(("j/" + cmd).encode())
    data = b""
    while chunk := s.recv(65536):
        data += chunk
    s.close()
    return json.loads(data)

def state():
    full = {c["workspace"]["id"] for c in query("clients") if c.get("fullscreen", 0) > 0}
    return " ".join(f'{m["name"]}={int(m["activeWorkspace"]["id"] in full)}' for m in query("monitors"))

last = None
def emit():
    global last
    try:
        cur = state()
    except Exception:
        return
    if cur != last:
        last = cur
        print(cur, flush=True)

emit()
ev = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
ev.connect(os.path.join(base, ".socket2.sock"))
buf = b""
while chunk := ev.recv(4096):
    buf += chunk
    if b"\n" in buf:
        buf = buf.rsplit(b"\n", 1)[1]
        emit()
