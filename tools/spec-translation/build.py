"""Rebuild the EN/FR translations of the original Russian specification.

The original .docx is copied and only the text of each paragraph is replaced,
so the layout, styles, tables and lists stay identical to the source.

Outputs (in docs/spec/<lang>/):
  ECG-AI_KG_TS_<LANG>.docx   translated Word document
  ECG-AI_KG_TS_<LANG>.md     Markdown rendering of the same text (for reading on GitHub)
  ECG-AI_KG_TS_<LANG>.pdf    PDF export (only with --pdf, needs Microsoft Word on Windows)

Usage:
  pip install python-docx
  python tools/spec-translation/build.py [--pdf]
"""
import copy
import re
import subprocess
import sys
import zipfile
from pathlib import Path

import docx
from docx.oxml.ns import qn
from docx.text.paragraph import Paragraph
from docx.text.run import Run

sys.path.insert(0, str(Path(__file__).parent))
import translations as tr  # noqa: E402

ROOT = Path(__file__).resolve().parents[2]
SRC = ROOT / "docs/spec/original/ECG-AI_KG_TS_RU_original.docx"
OUT = ROOT / "docs/spec"
W = "{http://schemas.openxmlformats.org/wordprocessingml/2006/main}"
CYR = re.compile("[А-Яа-яЁё]")
LANGS = {"en": (0, "en-GB"), "fr": (1, "fr-FR")}


def blocks(d):
    """Yield ('p', Paragraph) and ('tbl', element) in document order."""
    for el in d.element.body.iterchildren():
        if el.tag == W + "p":
            yield "p", Paragraph(el, d)
        elif el.tag == W + "tbl":
            yield "tbl", el


def all_paragraphs(d):
    for kind, b in blocks(d):
        if kind == "p":
            yield b
        else:
            for pe in b.iter(W + "p"):
                yield Paragraph(pe, d)


def marked(p):
    """Paragraph text with mixed bold spans marked as **...**."""
    runs = p.runs
    anyb = any(r.bold for r in runs)
    allb = all(r.bold for r in runs if r.text)
    if not anyb or allb:
        return "".join(r.text for r in runs)
    out, cur = "", None
    for r in runs:
        b = bool(r.bold)
        if b != cur:
            if cur:
                out += "**"
            if b:
                out += "**"
            cur = b
        out += r.text
    if cur:
        out += "**"
    return out


def source_strings(d):
    seen = []
    for p in all_paragraphs(d):
        if CYR.search("".join(r.text for r in p.runs)):
            s = marked(p)
            if s not in seen:
                seen.append(s)
    return seen


def rewrite(p, new):
    runs = list(p.runs)
    first = runs[0]
    normal = next((r for r in runs if not r.bold and r.text.strip()), first)
    bold = next((r for r in runs if r.bold and r.text.strip()), None)
    segs = [(s, i % 2 == 1) for i, s in enumerate(new.split("**"))] if "**" in new else [(new, None)]
    anchor = runs[-1]._r
    for text, b in segs:
        if not text:
            continue
        tmpl = first if b is None else (bold if (b and bold) else normal)
        r = copy.deepcopy(tmpl._r)
        for ch in list(r):
            if ch.tag != W + "rPr":
                r.remove(ch)
        anchor.addnext(r)
        anchor = r
        run = Run(r, p)
        run.text = text
        if b is True and not run.bold:
            run.bold = True
        if b is False and run.bold:
            run.bold = False
    for r in runs:
        r._r.getparent().remove(r._r)


def fix_lang(path, code):
    tmp = path.with_suffix(".tmp")
    with zipfile.ZipFile(path) as zin, zipfile.ZipFile(tmp, "w", zipfile.ZIP_DEFLATED) as zout:
        for it in zin.infolist():
            data = zin.read(it.filename)
            if it.filename in ("word/document.xml", "word/styles.xml"):
                data = data.replace(b'w:val="ru-RU"', f'w:val="{code}"'.encode())
            zout.writestr(it, data)
    tmp.replace(path)


# ---------- Markdown rendering ----------

def num_formats(d):
    num = d.part.numbering_part.element
    abstract = {a.get(qn("w:abstractNumId")): a for a in num.findall(qn("w:abstractNum"))}
    fmt = {}
    for n in num.findall(qn("w:num")):
        a = abstract[n.find(qn("w:abstractNumId")).get(qn("w:val"))]
        fmt[n.get(qn("w:numId"))] = a.find(qn("w:lvl")).find(qn("w:numFmt")).get(qn("w:val"))
    return fmt


def md_inline(p):
    text = marked(p)
    full = p.text
    if not CYR.search(text) and text.replace("**", "") != full:
        text = full  # paragraph with hyperlinks (python-docx runs miss them)
    return text.strip()


def to_markdown(d, src_note):
    fmt = num_formats(d)
    lines, counter, last_num = [], 0, None
    for kind, b in blocks(d):
        if kind == "tbl":
            rows = []
            for tr_ in b.iter(W + "tr"):
                cells = []
                for tc in tr_.iter(W + "tc"):
                    cells.append(" ".join(md_inline(Paragraph(pe, d)) for pe in tc.iter(W + "p")).replace("|", "\\|"))
                rows.append(cells)
            lines.append("| " + " | ".join(rows[0]) + " |")
            lines.append("|" + "---|" * len(rows[0]))
            lines += ["| " + " | ".join(r) + " |" for r in rows[1:]]
            lines.append("")
            continue
        p, style = b, b.style.name
        text = md_inline(p)
        if not text:
            continue
        if style.startswith("Heading"):
            level = int(style.split()[-1])
            lines += ["", "#" * level + " " + text, ""]
            if level == 1:
                lines += [src_note, ""]
        elif style == "List Paragraph":
            numpr = p._p.pPr.numPr if p._p.pPr is not None else None
            nid = str(numpr.numId.val) if numpr is not None else None
            if fmt.get(nid) == "decimal":
                counter = counter + 1 if nid == last_num else 1
                lines.append(f"{counter}. {text}")
            elif text.startswith("☐"):
                lines.append("- [ ] " + text[1:].strip())
            else:
                lines.append("- " + text)
            last_num = nid
            continue
        else:
            lines += [text, ""]
        last_num = None
    out = "\n".join(lines)
    out = re.sub(r"\n{3,}", "\n\n", out)
    out = re.sub(r"(\n[-0-9].*)\n(#|[^-\d|\n])", r"\1\n\n\2", out)
    return out.strip() + "\n"


NOTES = {
    "en": "> English translation of the original Russian document (`docs/spec/original/`). Content unchanged; see `docs/spec/TRANSLATION_NOTES.md`.",
    "fr": "> Traduction française du document original en russe (`docs/spec/original/`). Contenu inchangé ; voir `docs/spec/TRANSLATION_NOTES.md`.",
}


def to_pdf(docx_paths):
    ps = ["$w = New-Object -ComObject Word.Application", "$w.Visible = $false"]
    for p in docx_paths:
        ps += [
            f"$d = $w.Documents.Open('{p}', $false, $true)",
            f"$d.ExportAsFixedFormat('{p.with_suffix('.pdf')}', 17)",
            "$d.Close($false)",
        ]
    ps.append("$w.Quit()")
    subprocess.run(["powershell", "-NoProfile", "-Command", "; ".join(ps)], check=True)


def main():
    src_doc = docx.Document(SRC)
    src = source_strings(src_doc)
    assert len(src) == len(tr.T), f"{len(src)} source strings vs {len(tr.T)} translations"
    built = []
    for lang, (idx, code) in LANGS.items():
        d = docx.Document(SRC)
        mapping = {s: t[idx] for s, t in zip(src, tr.T)}
        for p in all_paragraphs(d):
            t = "".join(r.text for r in p.runs)
            if CYR.search(t):
                m = marked(p)
                new = mapping[m]
                assert m.count("**") == new.count("**"), (m, new)
                rewrite(p, new)
            elif t in tr.NUM[lang]:
                rewrite(p, tr.NUM[lang][t])
        left = [p.text for p in all_paragraphs(d) if CYR.search(p.text)]
        assert not left, left
        d.core_properties.title = tr.TITLE[lang]
        d.core_properties.language = code
        d.core_properties.author = ""
        d.core_properties.last_modified_by = ""
        out = OUT / lang / f"ECG-AI_KG_TS_{lang.upper()}.docx"
        out.parent.mkdir(parents=True, exist_ok=True)
        d.save(out)
        fix_lang(out, code)
        out.with_suffix(".md").write_text(to_markdown(d, NOTES[lang]), encoding="utf-8")
        built.append(out)
        print("wrote", out.relative_to(ROOT))
    if "--pdf" in sys.argv:
        to_pdf(built)
        print("PDFs exported")


if __name__ == "__main__":
    main()
