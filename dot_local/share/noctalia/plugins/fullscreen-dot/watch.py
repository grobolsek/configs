#!/usr/bin/env python3
# Prints "<monitor>=<0|1> ..." whenever the fullscreen state of any monitor changes.
# 1 = a workspace visible on that monitor (its active workspace, or the special
# workspace / scratchpad opened on it) holds a maximized (Super+D) or fullscreen window.
# Workspaces are matched by name: special workspaces have no "id" in hyprctl JSON
# (keying on id crashed state() and froze the dot on every monitor).
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
    full = {w.get("name") for w in query("workspaces") if w.get("hasfullscreen")}
    full.discard(None)
    out = []
    for m in query("monitors"):
        visible = {(m.get(k) or {}).get("name") for k in ("activeWorkspace", "specialWorkspace")}
        out.append(f'{m["name"]}={int(bool(visible & full))}')
    return " ".join(out)

last = None
def emit():
    global last
    try:
        cur = state()
    except Exception as e:
        print(f"fullscreen-dot: {e!r}", file=sys.stderr, flush=True)
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
