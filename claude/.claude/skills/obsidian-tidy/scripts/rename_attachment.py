#!/usr/bin/env python3
"""Rename an attachment and rewrite every reference to it in the vault's notes.

  rename_attachment.py VAULT OLD_REL_PATH NEW_NAME [--dry-run]
  rename_attachment.py VAULT --undo RUN_ID

Renames stay in the same folder. Every change is appended to
VAULT/.obsidian/tidy-log.jsonl so a run can be undone.
"""
import json, os, sys, time, urllib.parse

def notes(vault):
    for root, dirs, files in os.walk(vault):
        dirs[:] = [d for d in dirs if d != ".obsidian" and not d.startswith(".")]
        for f in files:
            if f.endswith(".md"):
                yield os.path.join(root, f)

def rewrite(vault, old, new, dry):
    variants = [(old, new), (urllib.parse.quote(old), urllib.parse.quote(new))]
    hits = []
    for path in notes(vault):
        text = open(path, encoding="utf-8").read()
        out = text
        for a, b in variants:
            out = out.replace(a, b)
        if out != text:
            hits.append(os.path.relpath(path, vault))
            if not dry:
                open(path, "w", encoding="utf-8").write(out)
    return hits

def log(vault, entry):
    with open(os.path.join(vault, ".obsidian", "tidy-log.jsonl"), "a", encoding="utf-8") as f:
        f.write(json.dumps(entry, ensure_ascii=False) + "\n")

def rename(vault, rel, new_name, dry, run_id):
    src = os.path.join(vault, rel)
    if not os.path.isfile(src):
        sys.exit(f"missing: {rel}")
    old_name = os.path.basename(src)
    if new_name == old_name:
        sys.exit("same name")
    dst = os.path.join(os.path.dirname(src), new_name)
    if os.path.exists(dst):
        sys.exit(f"target exists: {new_name}")
    # basenames must be unique in the vault, or name-based links become ambiguous
    for root, dirs, files in os.walk(vault):
        dirs[:] = [d for d in dirs if not d.startswith(".")]
        if new_name in files:
            sys.exit(f"name already used elsewhere in vault: {root}/{new_name}")
    hits = rewrite(vault, old_name, new_name, dry)
    if not dry:
        os.rename(src, dst)
        log(vault, {"run": run_id, "t": time.time(), "from": rel,
                    "to": os.path.relpath(dst, vault), "notes": hits})
    print(f"{'would rename' if dry else 'renamed'}: {old_name} -> {new_name} ({len(hits)} notes updated)")

def undo(vault, run_id):
    p = os.path.join(vault, ".obsidian", "tidy-log.jsonl")
    entries = [json.loads(l) for l in open(p, encoding="utf-8") if l.strip()]
    for e in reversed([e for e in entries if e["run"] == run_id]):
        a, b = os.path.basename(e["to"]), os.path.basename(e["from"])
        rewrite(vault, a, b, False)
        os.rename(os.path.join(vault, e["to"]), os.path.join(vault, e["from"]))
        print(f"restored: {a} -> {b}")

if __name__ == "__main__":
    args = [a for a in sys.argv[1:] if a != "--dry-run"]
    dry = "--dry-run" in sys.argv
    vault = os.path.abspath(os.path.expanduser(args[0]))
    if not os.path.isdir(os.path.join(vault, ".obsidian")):
        sys.exit("not an Obsidian vault")
    if args[1] == "--undo":
        undo(vault, args[2])
    else:
        rename(vault, args[1], args[2], dry, os.environ.get("TIDY_RUN", time.strftime("%Y%m%d-%H%M%S")))
