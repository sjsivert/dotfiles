#!/usr/bin/env python3
"""Create an Apple Note for the latest Obsidian meeting note and link them both ways."""
import datetime as dt, glob, html, os, re, sqlite3, subprocess, sys, time, urllib.parse

VAULT = os.path.expanduser("~/obsidian")
VAULT_NAME = "obsidian"
FOLDER = "Møter"
NOTES_DB = os.path.expanduser("~/Library/Group Containers/group.com.apple.notes/NoteStore.sqlite")

JXA = r'''
function run(argv) {
  const N = Application("Notes");
  const acc = N.accounts.byName("iCloud");
  let f = acc.folders().find(x => x.name() === argv[0]);
  if (!f) { f = N.Folder({name: argv[0]}); acc.folders.push(f); }
  const n = N.Note({body: argv[1]});
  f.notes.push(n);
  return n.id();
}
'''

def prop(text, key):
    m = re.search(rf'^{key}:\s*"?(.*?)"?\s*$', text, re.M)
    return m.group(1) if m else ""

def pick_note():
    cands = []
    for p in glob.glob(os.path.join(VAULT, "Meeting notes", "*.md")):
        t = open(p, encoding="utf-8").read()
        if prop(t, "type") == "meeting":
            cands.append((os.path.getmtime(p), p, t))
    today = dt.date.today().isoformat()
    todays = [c for c in cands if prop(c[2], "date") == today] or cands
    return max(todays)[1:] if todays else None

def note_uuid(coredata_id):
    pk = int(re.search(r"/p(\d+)$", coredata_id).group(1))
    for _ in range(10):
        try:
            con = sqlite3.connect(f"file:{NOTES_DB}?mode=ro", uri=True)
            row = con.execute("select ZIDENTIFIER from ZICCLOUDSYNCINGOBJECT where Z_PK=?", (pk,)).fetchone()
            if row and row[0]:
                return row[0]
        except sqlite3.Error:
            pass
        time.sleep(0.5)
    return None

def main():
    found = pick_note()
    if not found:
        sys.exit("No meeting note found. Run 'New meeting note' first.")
    path, text = found
    existing = prop(text, "apple-note")
    if existing:
        subprocess.run(["open", existing]); print("Opened existing Apple Note"); return
    rel = os.path.relpath(path, VAULT)
    title = os.path.basename(rel)[:-3]
    obs = f"obsidian://open?vault={VAULT_NAME}&file={urllib.parse.quote(rel[:-3])}"
    body = f'<h1>{html.escape(title)}</h1><div><a href="{obs}">Åpne i Obsidian</a></div><div><br></div>'
    cid = subprocess.run(["osascript", "-l", "JavaScript", "-e", JXA, FOLDER, body],
                         capture_output=True, text=True, check=True).stdout.strip()
    uuid = note_uuid(cid)
    if not uuid:
        sys.exit("Apple Note created, but its link ID could not be read.")
    link = f"applenotes://showNote?identifier={uuid}"
    text = re.sub(r'^apple-note:.*$', f'apple-note: "{link}"', text, count=1, flags=re.M)
    if "iPad-notat" not in text:
        text = re.sub(r'(\*\*Tid:\*\*[^\n]*\n)', rf'\1**iPad-notat:** [Åpne i Notater]({link})\n', text, count=1)
    open(path, "w", encoding="utf-8").write(text)
    subprocess.run(["open", link])
    print(f"Apple Note created in {FOLDER}: {title}")

main()
