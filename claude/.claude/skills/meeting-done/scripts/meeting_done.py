#!/usr/bin/env python3
"""Helper for /meeting-done. Metadata only: never reads or edits Apple Note bodies.

  meeting_done.py status                          JSON: today's meeting notes, today's calendar events
                                                  without a note, and candidate Apple Notes
  meeting_done.py link NOTE_ID MEETING_MD         link that Apple Note to that meeting note, file it in Møter
  meeting_done.py create NOTE_ID --uid UID        create the meeting note from a calendar event, then link
  meeting_done.py create NOTE_ID --title TITLE    create the meeting note with a typed title, then link
"""
import datetime as dt, glob, json, os, re, sqlite3, subprocess, sys

VAULT = os.path.expanduser("~/obsidian")
FOLDER = "Møter"
DB = os.path.expanduser("~/Library/Group Containers/group.com.apple.notes/NoteStore.sqlite")

def prop(text, key):
    m = re.search(rf'^{key}:\s*"?(.*?)"?\s*$', text, re.M)
    return m.group(1) if m else ""

def meeting_notes():
    out = []
    for p in glob.glob(os.path.join(VAULT, "Meeting notes", "*.md")):
        t = open(p, encoding="utf-8").read()
        if prop(t, "type") == "meeting":
            out.append((os.path.getmtime(p), p, t))
    return sorted(out, reverse=True)

def todays_meetings():
    today = dt.date.today().isoformat()
    return [n for n in meeting_notes() if prop(n[2], "date") == today]

VENV_PY = os.path.expanduser("~/.config/meeting-note/venv/bin/python")
NEW_MEETING = os.path.expanduser("~/dotfiles/raycast-scripts/new_meeting.py")

def calendar_events():
    r = subprocess.run([VENV_PY, NEW_MEETING, "--list"], capture_output=True, text=True)
    try:
        return json.loads(r.stdout), None
    except ValueError:
        return [], (r.stderr.strip() or "calendar unavailable")

def jxa(code, *args):
    r = subprocess.run(["osascript", "-l", "JavaScript", "-e", code, *args],
                       capture_output=True, text=True)
    if r.returncode:
        sys.exit(r.stderr.strip())
    return r.stdout.strip()

def uuid_of(cid):
    pk = int(re.search(r"/p(\d+)$", cid).group(1))
    con = sqlite3.connect(f"file:{DB}?mode=ro", uri=True)
    row = con.execute("select ZIDENTIFIER from ZICCLOUDSYNCINGOBJECT where Z_PK=?", (pk,)).fetchone()
    return row[0] if row else None

def status():
    today = todays_meetings()
    linked = {prop(t, "apple-note") for _, _, t in meeting_notes()} - {""}
    since = (dt.datetime.now() - dt.timedelta(hours=24)).isoformat()
    raw = jxa('''function run(a){const N=Application("Notes");const out=[];
      for(const acc of N.accounts()){for(const f of acc.folders()){
        if(f.name()==="Recently Deleted")continue;
        for(const n of f.notes()){const c=n.creationDate();
          if(c>new Date(a[0]))out.push({id:n.id(),name:n.name(),folder:f.name(),created:c.toISOString(),modified:n.modificationDate().toISOString()});}}}
      return JSON.stringify(out);}''', since)
    cands = []
    for n in json.loads(raw):
        u = uuid_of(n["id"])
        if u and f"applenotes://showNote?identifier={u}" not in linked:
            n["uuid"] = u
            for k in ("created", "modified"):
                n[k + "_local"] = dt.datetime.fromisoformat(n[k].replace("Z", "+00:00")).astimezone().strftime("%Y-%m-%d %H:%M")
            cands.append(n)
    cands.sort(key=lambda n: n["created"], reverse=True)   # newest created first
    events, err = calendar_events()
    have = {prop(t, "outlook-uid") for _, _, t in today} - {""}
    print(json.dumps({
        "now": dt.datetime.now().strftime("%Y-%m-%d %H:%M"),
        "meetings_today": [{"md": os.path.relpath(p, VAULT), "title": prop(t, "title"), "start": prop(t, "start"),
                            "end": prop(t, "end"), "apple_note": prop(t, "apple-note")} for _, p, t in today],
        "events_without_note": [e for e in events if e["uid"] not in have],
        "calendar_error": err,
        "candidates": cands}, ensure_ascii=False, indent=1))

def link(cid, md_rel):
    path = os.path.join(VAULT, md_rel)
    if not path.startswith(os.path.join(VAULT, "Meeting notes") + os.sep) or not os.path.isfile(path):
        sys.exit("meeting note not found: " + md_rel)
    text = open(path, encoding="utf-8").read()
    u = uuid_of(cid)
    if not u:
        sys.exit("could not read link id for that note")
    url = f"applenotes://showNote?identifier={u}"
    old = prop(text, "apple-note")
    if old and old != url:
        sys.exit("that meeting note is already linked to another Apple Note")
    jxa('''function run(a){const N=Application("Notes");
      const acc=N.accounts.byName("iCloud");
      let f=acc.folders().find(x=>x.name()===a[1]);
      if(!f){f=N.Folder({name:a[1]});acc.folders.push(f);}
      N.move(N.notes.byId(a[0]),{to:f});}''', cid, FOLDER)
    if re.search(r'^apple-note:.*$', text, re.M):
        text = re.sub(r'^apple-note:.*$', f'apple-note: "{url}"', text, count=1, flags=re.M)
    else:
        text = text.replace("\ntags:", f'\napple-note: "{url}"\ntags:', 1)
    if "iPad-notat" not in text:
        text = re.sub(r'(\*\*Tid:\*\*[^\n]*\n)', rf'\1**iPad-notat:** [Åpne i Notater]({url})\n', text, count=1)
    open(path, "w", encoding="utf-8").write(text)
    print(f"Linked {md_rel} -> {url}; note moved to {FOLDER}")

def create(cid, args):
    cmd = [VENV_PY, NEW_MEETING, "--no-open"]
    if args[0] == "--uid" and len(args) == 2:
        cmd += ["--uid", args[1]]
    elif args[0] == "--title" and len(args) >= 2:
        cmd += [" ".join(args[1:])]
    else:
        sys.exit(__doc__)
    r = subprocess.run(cmd, capture_output=True, text=True)
    if r.returncode:
        sys.exit(r.stderr.strip() or r.stdout.strip())
    md_rel = r.stdout.strip().split(": ", 1)[1]
    print("Created " + md_rel)
    link(cid, md_rel)

cmd = sys.argv[1:2]
if cmd == ["status"]: status()
elif cmd == ["link"] and len(sys.argv) == 4: link(sys.argv[2], sys.argv[3])
elif cmd == ["create"] and len(sys.argv) >= 5: create(sys.argv[2], sys.argv[3:])
else: sys.exit(__doc__)
