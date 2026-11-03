#!/usr/bin/env python3
"""Preview for the session switcher (jump.sh), drawn like tmux's `choose-tree`.

  preview.py =sess:        tiles of every window in the session
  preview.py =sess:idx     the window's pane layout, to scale, with contents
  preview.py =sess:idx.p   the pane's contents (in color)

Size comes from fzf's FZF_PREVIEW_COLUMNS / FZF_PREVIEW_LINES.
"""
import os
import subprocess
import sys
import unicodedata


def tmux(*args):
    r = subprocess.run(["tmux", *args], capture_output=True, text=True, errors="replace")
    return r.stdout


def opt(name):
    return tmux("display", "-p", "#{" + name + "}").strip()


def fg(hexcol):
    h = hexcol.lstrip("#")
    try:
        return "\x1b[38;2;%d;%d;%dm" % (int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16))
    except ValueError:
        return ""


ACC, DIM, FG = fg(opt("@c_accent")), fg(opt("@dim")), fg(opt("@fg"))
BOLD, RESET = "\x1b[1m", "\x1b[0m"


def cw(ch):
    return 2 if unicodedata.east_asian_width(ch) in "WF" else 1


class Canvas:
    def __init__(self, w, h):
        self.w, self.h = w, h
        self.ch = [[" "] * w for _ in range(h)]
        self.st = [[""] * w for _ in range(h)]

    def put(self, x, y, s, style="", maxw=None):
        end = self.w if maxw is None else min(self.w, x + maxw)
        for c in s:
            if c in "\t\r\n" or ord(c) < 32:
                c = " "
            n = cw(c)
            if x + n > end or y < 0 or y >= self.h:
                break
            if x >= 0:
                self.ch[y][x], self.st[y][x] = c, style
                if n == 2:
                    self.ch[y][x + 1], self.st[y][x + 1] = "", style
            x += n

    def box(self, x, y, w, h, title="", style=DIM, tstyle=None):
        if w < 2 or h < 2:
            return
        self.put(x, y, "╭" + "─" * (w - 2) + "╮", style)
        for yy in range(y + 1, y + h - 1):
            self.put(x, yy, "│", style)
            self.put(x + w - 1, yy, "│", style)
        self.put(x, y + h - 1, "╰" + "─" * (w - 2) + "╯", style)
        if title and w > 6:
            self.put(x + 2, y, " " + title + " ", tstyle or style, maxw=w - 4)

    def text(self, x, y, w, h, lines):
        for i, line in enumerate(lines[:h]):
            self.put(x, y + i, line, FG, maxw=w)

    def render(self):
        out = []
        for y in range(self.h):
            row, cur = [], None
            for x in range(self.w):
                if self.st[y][x] != cur:
                    cur = self.st[y][x]
                    row.append(RESET + cur)
                row.append(self.ch[y][x])
            out.append("".join(row) + RESET)
        return "\n".join(out)


def pane_lines(pane_id, h):
    """Last `h` lines up to the last non-empty one (where the prompt usually is)."""
    lines = tmux("capture-pane", "-p", "-t", pane_id).split("\n")
    while lines and not lines[-1].strip():
        lines.pop()
    return lines[-h:] if h > 0 else []


def draw_window(cv, target, x, y, w, h):
    """Draw a window's panes scaled into the rect (x, y, w, h)."""
    ww, wh = (int(v) for v in tmux("display", "-p", "-t", target, "#{window_width} #{window_height}").split())
    fmt = "#{pane_id}\t#{pane_left}\t#{pane_top}\t#{pane_width}\t#{pane_height}\t#{pane_active}\t#{pane_current_command}"
    for line in tmux("list-panes", "-t", target, "-F", fmt).splitlines():
        pid, pl, pt, pw, ph, active, cmd = line.split("\t")
        pl, pt, pw, ph = int(pl), int(pt), int(pw), int(ph)
        # scale pane edges; +1 covers the border column/row tmux puts between panes
        x0 = x + round(pl * w / ww)
        x1 = x + round(min(pl + pw + 1, ww) * w / ww)
        y0 = y + round(pt * h / wh)
        y1 = y + round(min(pt + ph + 1, wh) * h / wh)
        bw, bh = max(x1 - x0, 3), max(y1 - y0, 3)
        st = ACC if active == "1" else DIM
        cv.box(x0, y0, bw, bh, cmd, st, (ACC + BOLD) if active == "1" else FG)
        cv.text(x0 + 1, y0 + 1, bw - 2, bh - 2, pane_lines(pid, bh - 2))


def draw_session(cv, target):
    fmt = "#{window_index}\t#{window_name}\t#{window_active}\t#{pane_id}\t#{window_panes}"
    wins = [l.split("\t") for l in tmux("list-windows", "-t", target, "-F", fmt).splitlines()]
    n = len(wins)
    if not n:
        return
    cols = max(1, min(n, cv.w // 28))           # tiles at least ~28 columns wide
    rows = -(-n // cols)
    while rows > 1 and cv.h // rows < 6 and cols < n:   # too short: use more columns
        cols += 1
        rows = -(-n // cols)
    tw, th = cv.w // cols, cv.h // rows
    for i, (idx, name, active, pid, npanes) in enumerate(wins):
        x, y = (i % cols) * tw, (i // cols) * th
        st = ACC if active == "1" else DIM
        title = f"{idx} {name}" + (f" · {npanes} panes" if npanes != "1" else "")
        cv.box(x, y, tw, th, title, st, (ACC + BOLD) if active == "1" else FG)
        cv.text(x + 1, y + 1, tw - 2, th - 2, pane_lines(pid, th - 2))


def main():
    target = sys.argv[1]
    w = int(os.environ.get("FZF_PREVIEW_COLUMNS", 80))
    h = int(os.environ.get("FZF_PREVIEW_LINES", 24))
    if "." in target.rsplit(":", 1)[-1]:        # pane: real colors
        sys.stdout.write(tmux("capture-pane", "-ep", "-t", target))
        return
    cv = Canvas(w, h)
    if target.endswith(":"):
        draw_session(cv, target)
    else:
        draw_window(cv, target, 0, 0, w, h)
    sys.stdout.write(cv.render())


if __name__ == "__main__":
    main()
