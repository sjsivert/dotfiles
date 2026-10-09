#!/usr/bin/env python3
"""Create an Obsidian meeting note from the Outlook ICS feed (or a typed title).

  new_meeting.py [TITLE...]            current Outlook meeting, or TITLE
  new_meeting.py --list [YYYY-MM-DD]   print that day's events as JSON
  new_meeting.py --uid UID [--date D]  note for a specific event of that day
  --no-open                            do not open Obsidian
"""
import argparse, datetime as dt, json, os, re, subprocess, sys, urllib.parse, urllib.request
import icalendar, recurring_ical_events

HOME = os.path.expanduser("~/.config/meeting-note")
VAULT = os.path.expanduser("~/obsidian")
VAULT_NAME = "obsidian"
LOOKAHEAD = dt.timedelta(minutes=15)   # meeting starting soon counts as current
LOOKBACK = dt.timedelta(minutes=30)    # just ended counts too

def ics_url():
    for line in open(os.path.join(HOME, "config")):
        if line.startswith("ICS_URL="):
            return line.split("=", 1)[1].strip().strip("'\"").replace("\\", "")
    sys.exit("ICS_URL missing in config")

def load_cal():
    try:
        return icalendar.Calendar.from_ical(urllib.request.urlopen(ics_url(), timeout=15).read())
    except Exception as e:
        print(f"Calendar unavailable: {e}", file=sys.stderr)
        return None

def timed(events):
    return [e for e in events if isinstance(e["DTSTART"].dt, dt.datetime)]   # skip all-day

def current_event(cal, now):
    best = None
    for ev in timed(recurring_ical_events.of(cal).between(now - LOOKBACK, now + LOOKAHEAD)):
        s, e = ev["DTSTART"].dt, ev["DTEND"].dt
        score = 0 if s <= now <= e else min(abs(s - now), abs(e - now)).total_seconds()
        if best is None or score < best[0]:
            best = (score, ev)
    return best[1] if best else None

def day_events(cal, day):
    return sorted(timed(recurring_ical_events.of(cal).at(day)), key=lambda e: e["DTSTART"].dt)

def as_dict(ev):
    s, e = ev["DTSTART"].dt.astimezone(), ev["DTEND"].dt.astimezone()
    return dict(title=str(ev["SUMMARY"]), date=s.strftime("%Y-%m-%d"), start=s.strftime("%H:%M"),
                end=e.strftime("%H:%M"), location=str(ev.get("LOCATION", "")), uid=str(ev.get("UID", "")))

def safe(name):
    return re.sub(r'[\\/:*?"<>|#^\[\]]', "", name).strip()

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("title", nargs="*")
    ap.add_argument("--list", nargs="?", const="today")
    ap.add_argument("--uid")
    ap.add_argument("--date")
    ap.add_argument("--no-open", action="store_true")
    a = ap.parse_args()
    now = dt.datetime.now().astimezone()
    day = lambda s: dt.date.today() if s in (None, "today") else dt.date.fromisoformat(s)

    if a.list is not None:
        cal = load_cal()
        print(json.dumps([as_dict(e) for e in day_events(cal, day(a.list))] if cal else [], ensure_ascii=False))
        return

    typed = " ".join(a.title).strip()
    ev = None
    if a.uid:
        cal = load_cal()
        ev = next((e for e in (day_events(cal, day(a.date)) if cal else []) if str(e.get("UID", "")) == a.uid), None)
        if not ev:
            sys.exit(f"event {a.uid} not found on {day(a.date)}")
    elif not typed:
        cal = load_cal()
        ev = current_event(cal, now) if cal else None
    if ev:
        vals = as_dict(ev)
    else:
        vals = dict(title=typed or "Møte", date=now.strftime("%Y-%m-%d"),
                    start=now.strftime("%H:%M"), end="", location="", uid="")
    vals["title"] = vals["title"].replace('"', "'")
    os.makedirs(os.path.join(VAULT, "Meeting notes"), exist_ok=True)
    rel = f"Meeting notes/{vals['date']} {safe(vals['title'])}.md"
    path = os.path.join(VAULT, rel)
    if not os.path.exists(path):
        text = open(os.path.join(VAULT, "Templates", "Meeting.md"), encoding="utf-8").read()
        for k, v in vals.items():
            text = text.replace("{{%s}}" % k, v)
        text = re.sub(r"(\*\*Tid:\*\*[^\n]*?)(?:–)?(?: · )?\n", lambda m: m.group(1).rstrip(" ·–") + "\n", text, count=1)
        open(path, "w", encoding="utf-8").write(text)
    if not a.no_open:
        subprocess.run(["open", f"obsidian://open?vault={VAULT_NAME}&file={urllib.parse.quote(rel[:-3])}"])
    print(("Opened: " if ev or typed else "Created: ") + rel)

main()
