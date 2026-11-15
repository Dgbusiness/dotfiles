#!/usr/bin/env python3
"""Claude Code status line, shared by ~/.claude and ~/.claude-adaction.

Line 1: [account] [model] 📁 dir | 🌿 branch*
Line 2: context bar % | 5h % · 7d % (↻ reset) | $cost | ⏱️ duration
"""
import json
import os
import subprocess
import sys
from datetime import datetime

CYAN, GREEN, YELLOW, RED, MAGENTA, BLUE, DIM, RESET = (
    "\033[36m", "\033[32m", "\033[33m", "\033[31m", "\033[35m", "\033[34m", "\033[2m", "\033[0m"
)


def level_color(pct):
    return RED if pct >= 90 else YELLOW if pct >= 70 else GREEN


def account():
    cfg = os.path.basename(os.environ.get("CLAUDE_CONFIG_DIR", "").rstrip("/")) or ".claude"
    if cfg == ".claude-adaction":
        return f"{MAGENTA}[adaction]{RESET}"
    if cfg == ".claude":
        return f"{BLUE}[personal]{RESET}"
    return f"{DIM}[{cfg}]{RESET}"


def git_info(directory):
    """Branch + '*' if there are uncommitted changes. One git call, 1s timeout."""
    try:
        out = subprocess.run(
            ["git", "-C", directory, "status", "--porcelain=v2", "--branch"],
            capture_output=True, text=True, timeout=1,
        )
    except Exception:
        return ""
    if out.returncode != 0:
        return ""
    branch, dirty = "", False
    for line in out.stdout.splitlines():
        if line.startswith("# branch.head "):
            branch = line.split(" ", 2)[2]
        elif not line.startswith("#"):
            dirty = True
    if not branch:
        return ""
    if branch == "(detached)":
        branch = "detached"
    mark = f"{YELLOW}*{RESET}" if dirty else ""
    return f" | 🌿 {branch}{mark}"


def rate_limits(data):
    rl = data.get("rate_limits") or {}
    parts = []
    for key, label in (("five_hour", "5h"), ("seven_day", "7d")):
        win = rl.get(key) or {}
        pct = win.get("used_percentage")
        if pct is None:
            continue
        pct = int(pct)
        txt = f"{level_color(pct)}{label} {pct}%{RESET}"
        if key == "five_hour" and win.get("resets_at"):
            txt += f" {DIM}↻{datetime.fromtimestamp(win['resets_at']).strftime('%H:%M')}{RESET}"
        parts.append(txt)
    return " · ".join(parts)


def main():
    data = json.load(sys.stdin)
    model = (data.get("model") or {}).get("display_name", "?")
    cwd = (data.get("workspace") or {}).get("current_dir") or data.get("cwd") or os.getcwd()
    cost = (data.get("cost") or {}).get("total_cost_usd") or 0
    duration_ms = (data.get("cost") or {}).get("total_duration_ms") or 0
    pct = int((data.get("context_window") or {}).get("used_percentage") or 0)

    filled = min(pct, 100) // 10
    bar = "█" * filled + "░" * (10 - filled)
    mins, secs = duration_ms // 60000, (duration_ms % 60000) // 1000

    line1 = f"{account()} {CYAN}[{model}]{RESET} 📁 {os.path.basename(cwd)}{git_info(cwd)}"

    segments = [f"{level_color(pct)}{bar}{RESET} {pct}%"]
    limits = rate_limits(data)
    if limits:
        segments.append(limits)
    segments.append(f"{YELLOW}${cost:.2f}{RESET}")
    segments.append(f"⏱️ {mins}m {secs}s")

    print(line1)
    print(" | ".join(segments))


if __name__ == "__main__":
    main()
