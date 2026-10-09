#!/usr/bin/env python3
"""Extract the typed text and images of the Apple Note linked from the latest meeting note.

  extract_note.py [MEETING_MD]   JSON: typed text + images copied (and shrunk) into the vault
Read-only on Apple Notes. Images go to ~/obsidian/Meeting notes/Attachment/.
"""
import glob, json, os, re, shutil, sqlite3, subprocess, sys, tempfile

VAULT = os.path.expanduser("~/obsidian")
G = os.path.expanduser("~/Library/Group Containers/group.com.apple.notes")
ATT = os.path.join(VAULT, "Meeting notes", "Attachment")
MARK = "<!-- apple-note-import -->"
IMG = ("com.apple.paper", "com.apple.drawing.2", "com.apple.drawing", "public.jpeg", "public.png", "public.heic")

def prop(t, k):
    m = re.search(rf'^{k}:\s*"?(.*?)"?\s*$', t, re.M)
    return m.group(1) if m else ""

def latest_meeting():
    """The meeting note given as argv[1] (relative to the vault), else today's linked one."""
    import datetime as dt
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    if args:
        p = os.path.join(VAULT, args[0])
        if not os.path.isfile(p):
            sys.exit("meeting note not found: " + args[0])
        return (0, p, open(p, encoding="utf-8").read())
    today = dt.date.today().isoformat()
    ms = []
    for p in glob.glob(os.path.join(VAULT, "Meeting notes", "*.md")):
        t = open(p, encoding="utf-8").read()
        if prop(t, "type") == "meeting" and prop(t, "date") == today and prop(t, "apple-note"):
            ms.append((os.path.getmtime(p), p, t))
    return max(ms) if ms else None

def jxa(code, *args):
    r = subprocess.run(["osascript", "-l", "JavaScript", "-e", code, *args], capture_output=True, text=True)
    if r.returncode:
        sys.exit(r.stderr.strip())
    return r.stdout

def find_file(att_uuid, typ, media_ident, media_name):
    acc = glob.glob(os.path.join(G, "Accounts", "*"))
    for a in acc:
        if typ in ("com.apple.paper", "com.apple.drawing.2", "com.apple.drawing"):
            hits = glob.glob(os.path.join(a, "FallbackImages", att_uuid, "**", "*.png"), recursive=True)
        else:
            hits = glob.glob(os.path.join(a, "Media", media_ident or "-", "**", "*"), recursive=True) if media_ident else []
            hits = [h for h in hits if os.path.isfile(h)]
        if hits:
            return max(hits, key=os.path.getmtime)
    return None

def shrink(src, dst_base):
    ext = os.path.splitext(src)[1].lower()
    if ext in (".png",) and os.path.getsize(src) < 400_000:
        dst = dst_base + ".png"; shutil.copy(src, dst); return dst
    dst = dst_base + ".jpg"
    subprocess.run(["sips", "-Z", "1600", "-s", "format", "jpeg", "-s", "formatOptions", "70", src, "--out", dst],
                   capture_output=True, check=True)
    return dst

def main():
    m = latest_meeting()
    if not m:
        sys.exit("no meeting note found")
    _, path, text = m
    link = prop(text, "apple-note")
    uuid = re.search(r"identifier=([0-9A-F-]+)", link or "")
    if not uuid:
        sys.exit("meeting note has no apple-note link; run /meeting-done first")
    if MARK in text and "--force" not in sys.argv:
        print(json.dumps({"meeting_note": os.path.relpath(path, VAULT), "already_imported": True})); return
    con = sqlite3.connect(f"file:{G}/NoteStore.sqlite?mode=ro", uri=True)
    row = con.execute("select Z_PK from ZICCLOUDSYNCINGOBJECT where ZIDENTIFIER=?", (uuid.group(1),)).fetchone()
    if not row:
        sys.exit("Apple Note not found")
    pk = row[0]
    sample = jxa('function run(){return Application("Notes").notes[0].id()}').strip()
    cid = re.sub(r"/p\d+$", f"/p{pk}", sample)
    note = json.loads(jxa('function run(a){const n=Application("Notes").notes.byId(a[0]);return JSON.stringify({name:n.name(),text:n.plaintext()})}', cid))
    body = note["text"].replace("￼", "").strip()
    lines = body.split("\n")
    if lines and lines[0].strip() == note["name"].strip():
        lines = lines[1:]
    typed = "\n".join(lines).strip()
    os.makedirs(ATT, exist_ok=True)
    stem = os.path.splitext(os.path.basename(path))[0]
    images = []
    q = ("select a.ZIDENTIFIER, a.ZTYPEUTI, m.ZIDENTIFIER, m.ZFILENAME, a.ZHANDWRITINGSUMMARY, a.ZOCRSUMMARY "
         "from ZICCLOUDSYNCINGOBJECT a left join ZICCLOUDSYNCINGOBJECT m on m.Z_PK=a.ZMEDIA "
         "where a.ZNOTE=? and a.ZTYPEUTI in (%s) order by a.Z_PK" % ",".join("?" * len(IMG)))
    for i, (au, typ, mi, mf, hw, ocr) in enumerate(con.execute(q, (pk, *IMG)), 1):
        src = find_file(au, typ, mi, mf)
        if not src:
            images.append({"n": i, "type": typ, "error": "file not found"}); continue
        try:
            dst = shrink(src, os.path.join(ATT, f"{stem} - {i}"))
        except Exception as e:
            images.append({"n": i, "type": typ, "error": str(e)}); continue
        dec = lambda b: b.decode("utf-8", "ignore") if isinstance(b, bytes) else b
        images.append({"n": i, "type": typ, "vault_path": os.path.relpath(dst, VAULT),
                       "embed": f"![[{os.path.basename(dst)}]]",
                       "apple_handwriting_hint": dec(hw), "apple_ocr_hint": dec(ocr)})
    print(json.dumps({"meeting_note": os.path.relpath(path, VAULT), "apple_note_title": note["name"],
                      "typed_text": typed, "images": images, "marker": MARK}, ensure_ascii=False, indent=1))

main()
