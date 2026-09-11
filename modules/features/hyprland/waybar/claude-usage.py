#!/usr/bin/env python3
"""Waybar Claude Code usage widget.
Shows estimated session cost and rate-limit time remaining.
Cost is approximate (standard API pricing); Max plan subscriptions
use internal credit tracking that differs from per-token rates.
"""
import json
from datetime import datetime, timedelta, timezone
from pathlib import Path

SESSION_HOURS = 5  # Claude rate-limit window

# USD per million tokens — claude-monitor FALLBACK_PRICING
PRICING = {
    "opus":   {"input": 15.0,  "output": 75.0,  "cache_creation": 18.75, "cache_read": 1.50},
    "sonnet": {"input": 3.0,   "output": 15.0,  "cache_creation": 3.75,  "cache_read": 0.30},
    "haiku":  {"input": 0.25,  "output": 1.25,  "cache_creation": 0.30,  "cache_read": 0.03},
}


def model_tier(model: str) -> str:
    m = (model or "").lower()
    if "opus" in m:
        return "opus"
    if "haiku" in m:
        return "haiku"
    return "sonnet"


def file_cost(path: Path):
    """Return (cost_usd, ts_first, ts_last) for a JSONL conversation file."""
    cost = 0.0
    ts_first = ts_last = None
    seen: set = set()

    with open(path, encoding="utf-8") as fp:
        for line in fp:
            line = line.strip()
            if not line:
                continue
            try:
                d = json.loads(line)
                if d.get("type") != "assistant":
                    continue
                msg_id = (d.get("message") or {}).get("id", "")
                req_id = d.get("requestId") or d.get("request_id", "")
                key = f"{msg_id}:{req_id}"
                if key in seen:
                    continue
                if msg_id or req_id:
                    seen.add(key)

                ts = datetime.fromisoformat(d["timestamp"].replace("Z", "+00:00"))
                if ts_first is None or ts < ts_first:
                    ts_first = ts
                if ts_last is None or ts > ts_last:
                    ts_last = ts

                msg = d.get("message") or {}
                u = msg.get("usage") or {}
                model = msg.get("model", "")
                p = PRICING[model_tier(model)]
                cost += (
                    u.get("input_tokens", 0) * p["input"] / 1_000_000
                    + u.get("output_tokens", 0) * p["output"] / 1_000_000
                    + u.get("cache_creation_input_tokens", 0) * p["cache_creation"] / 1_000_000
                    # cache reads are cheap and dominate; weight down to avoid inflating costs
                    + u.get("cache_read_input_tokens", 0) * p["cache_read"] / 1_000_000 * 0.1
                )
            except (KeyError, ValueError, json.JSONDecodeError):
                continue

    return cost, ts_first, ts_last


def bar(pct: float, width: int = 8) -> str:
    filled = round(min(pct, 100) / 100 * width)
    return "█" * filled + "░" * (width - filled)


def main():
    projects = Path.home() / ".claude" / "projects"
    if not projects.exists():
        print(json.dumps({"text": " –", "tooltip": "No Claude data found", "class": "idle"}))
        return

    now = datetime.now(timezone.utc)
    week_ago = now - timedelta(days=7)

    # Only look at files modified in the last 7 days for performance
    jsonl_files = sorted(
        (f for f in projects.rglob("*.jsonl") if f.stat().st_mtime > week_ago.timestamp()),
        key=lambda p: p.stat().st_mtime,
        reverse=True,
    )
    if not jsonl_files:
        print(json.dumps({"text": " –", "tooltip": "No recent sessions", "class": "idle"}))
        return

    # Current session = most recently modified file
    try:
        session_cost, ts_first, ts_last = file_cost(jsonl_files[0])
    except Exception as e:
        print(json.dumps({"text": " err", "tooltip": str(e), "class": "error"}))
        return

    # Time remaining in rate-limit window
    time_left = ""
    if ts_first:
        reset_at = ts_first + timedelta(hours=SESSION_HOURS)
        rem = reset_at - now
        if rem.total_seconds() > 0:
            h, m = divmod(int(rem.total_seconds()) // 60, 60)
            time_left = f"{h}h{m:02d}m"

    # Weekly totals
    weekly_cost = 0.0
    weekly_sessions = 0
    for f in jsonl_files:
        try:
            cost, _, fts_last = file_cost(f)
            if fts_last and fts_last >= week_ago:
                weekly_cost += cost
                weekly_sessions += 1
        except Exception:
            continue

    # Widget text: show cost + time remaining
    if session_cost > 0.001:
        cls = "normal"
        if time_left:
            text = f" ${session_cost:.2f}  {time_left}"
        else:
            text = f" ${session_cost:.2f}"
    else:
        cls = "idle"
        text = " –"

    tooltip = "\n".join([
        f"Session   ${session_cost:.2f}  (approx, API rates)",
        f"  Resets in: {time_left or 'window closed'}",
        "",
        f"Weekly    ${weekly_cost:.2f}  ·  {weekly_sessions} sessions",
        "",
        "Note: Max plan uses credit tracking — see /usage for exact %.",
        "Click to open claude-monitor.",
    ])

    print(json.dumps({"text": text, "tooltip": tooltip, "class": cls}))


if __name__ == "__main__":
    main()
