#!/usr/bin/env python3
"""Extract slide text and speaker notes from .pptx, or page text from .pdf, as Markdown.

  extract_text.py FILE            -> Markdown on stdout
No dependencies: .pptx is read as a zip of XML; .pdf uses pdftotext.
"""
import re, subprocess, sys, zipfile
from xml.etree import ElementTree as ET

A = "{http://schemas.openxmlformats.org/drawingml/2006/main}"

NOISE = re.compile(r"^(\d+|\d{1,2}/\d{1,2}/\d{2,4}|Sample Footer Text)$")

def paras(xml):
    out = []
    for p in ET.fromstring(xml).iter(A + "p"):
        t = "".join(x.text or "" for x in p.iter(A + "t")).strip()
        if t and not NOISE.match(t):
            out.append(t)
    return out

def num(name):
    return int(re.search(r"(\d+)\.xml$", name).group(1))

def pptx(path):
    z = zipfile.ZipFile(path)
    slides = sorted((n for n in z.namelist() if re.match(r"ppt/slides/slide\d+\.xml$", n)), key=num)
    for i, n in enumerate(slides, 1):
        print(f"## Slide {i}\n")
        for t in paras(z.read(n)):
            print(f"- {t}")
        # speaker notes via the slide's rels
        rel = n.replace("slides/", "slides/_rels/") + ".rels"
        if rel in z.namelist():
            m = re.search(r'Target="\.\./notesSlides/(notesSlide\d+\.xml)"', z.read(rel).decode())
            if m and f"ppt/notesSlides/{m.group(1)}" in z.namelist():
                notes = [t for t in paras(z.read(f"ppt/notesSlides/{m.group(1)}")) if not t.isdigit()]
                if notes:
                    print("\n> Notes: " + " ".join(notes))
        print()

def pdf(path):
    txt = subprocess.run(["pdftotext", "-layout", path, "-"], capture_output=True, text=True).stdout
    for i, page in enumerate(txt.split("\f"), 1):
        page = page.strip()
        if page:
            print(f"## Page {i}\n\n{page}\n")

if __name__ == "__main__":
    f = sys.argv[1]
    (pptx if f.lower().endswith(".pptx") else pdf)(f)
