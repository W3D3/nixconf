#!/usr/bin/env python3
"""Waybar Claude Code usage widget. Reads ~/.claude/projects/*.jsonl directly."""
import json
from datetime import datetime, timedelta, timezone
from pathlib import Path

SESSION_HOURS = 5
# Pro: 19k tokens / session. Weekly max ≈ 19k × 14 sessions (2/day × 7 days)
SESSION_TOKEN_LIMIT = 19_000
WEEKLY_TOKEN_MAX = SESSION_TOKEN_LIMIT * 14


def load_entries(hours_back=168):
    projects = Path.home() / ".claude" / "projects"
    if not projects.exists():
        return []

    cutoff = datetime.now(timezone.utc) - timedelta(hours=hours_back)
    entries = []
    seen = set()

    for f in sorted(projects.rglob("*.jsonl")):
        try:
            with open(f, encoding="utf-8") as fp:
                for line in fp:
                    line = line.strip()
                    if not line:
                        continue
                    try:
                        d = json.loads(line)
                        ts_str = d.get("timestamp", "")
                        if not ts_str:
                            continue
                        ts = datetime.fromisoformat(ts_str.replace("Z", "+00:00"))
                        if ts < cutoff:
                            continue

                        msg_id = d.get("message_id") or (d.get("message") or {}).get("id", "")
                        req_id = d.get("request_id") or d.get("requestId", "")
                        key = f"{msg_id}:{req_id}"
                        if key in seen:
                            continue
                        if msg_id or req_id:
                            seen.add(key)

                        # Tokens live in message.usage for assistant entries
                        usage = {}
                        if d.get("type") == "assistant":
                            usage = (d.get("message") or {}).get("usage") or d.get("usage") or {}
                        else:
                            usage = d.get("usage") or {}

                        inp = int(usage.get("input_tokens") or d.get("input_tokens") or 0)
                        out = int(usage.get("output_tokens") or d.get("output_tokens") or 0)

                        total = inp + out
                        if total == 0:
                            continue

                        entries.append({"ts": ts, "total": total})
                    except (json.JSONDecodeError, ValueError):
                        continue
        except Exception:
            continue

    return sorted(entries, key=lambda e: e["ts"])


def group_sessions(entries):
    sessions = []
    cur = None
    gap = timedelta(hours=SESSION_HOURS)
    for e in entries:
        if cur is None or e["ts"] > cur["end"]:
            cur = {"start": e["ts"], "end": e["ts"] + gap, "entries": [e]}
            sessions.append(cur)
        else:
            cur["entries"].append(e)
    return sessions


def bar(pct, width=8):
    filled = round(pct / 100 * width)
    return "█" * filled + "░" * (width - filled)


def main():
    now = datetime.now(timezone.utc)

    try:
        entries = load_entries()
        sessions = group_sessions(entries)

        # Current session
        active = None
        if sessions and now <= sessions[-1]["end"]:
            active = sessions[-1]

        session_tokens = 0
        session_pct = 0
        time_left = ""

        if active:
            session_tokens = sum(e["total"] for e in active["entries"])
            session_pct = min(100, round(session_tokens / SESSION_TOKEN_LIMIT * 100))
            rem = active["end"] - now
            if rem.total_seconds() > 0:
                h, m = divmod(int(rem.total_seconds()) // 60, 60)
                time_left = f"{h}h{m:02d}m"

        # Weekly
        week_ago = now - timedelta(days=7)
        weekly_tokens = sum(e["total"] for e in entries if e["ts"] >= week_ago)
        weekly_pct = min(100, round(weekly_tokens / WEEKLY_TOKEN_MAX * 100))
        weekly_sessions = len([s for s in sessions if s["start"] >= week_ago])

        # Widget text
        if active:
            cls = "critical" if session_pct >= 90 else ("warning" if session_pct >= 70 else "normal")
            text = f" {session_pct}%  {weekly_pct}%  {time_left}"
        else:
            cls = "idle"
            text = " –"

        tooltip = "\n".join([
            f"Session   {bar(session_pct)} {session_pct}%",
            f"  {session_tokens:,} / {SESSION_TOKEN_LIMIT:,} tokens",
            f"  Resets in: {time_left or '–'}",
            "",
            f"Weekly    {bar(weekly_pct)} {weekly_pct}%",
            f"  {weekly_tokens:,} tokens · {weekly_sessions} sessions",
            f"  (Pro · 14 sessions/wk max)",
        ])

        print(json.dumps({"text": text, "tooltip": tooltip, "class": cls, "percentage": session_pct}))

    except Exception as exc:
        print(json.dumps({"text": " err", "tooltip": str(exc), "class": "error"}))


if __name__ == "__main__":
    main()
