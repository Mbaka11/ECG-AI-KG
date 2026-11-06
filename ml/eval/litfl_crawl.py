"""Polite crawler that builds a LOCAL LITFL ECG test set (images are never committed).

LITFL ECG library: CC BY-NC-SA 4.0; images reusable for not-for-profit education with credit
to litfl.com (see docs/research/12-litfl-ecg-library.md). Images stay in the git-ignored data/ dir.

Usage (from ml/):
    python eval/litfl_crawl.py crawl      # fetch pages (cached), write litfl_raw.csv
    python eval/litfl_crawl.py download   # download candidate ECG images
    python eval/litfl_crawl.py index      # write committed eval/litfl_index.csv
    python eval/litfl_crawl.py all
Needs: pip install -e .[eval]   (requests, beautifulsoup4)
"""
from __future__ import annotations

import argparse
import csv
import re
import sys
import time
from pathlib import Path
from urllib.parse import urljoin, urlparse

import requests
from bs4 import BeautifulSoup

UA = "ECG-AI-KG research crawler (non-commercial; github.com/Mbaka11/ECG-AI-KG)"
BASE = "https://litfl.com"
MIN_DELAY = 2.0
MAX_REQUESTS = 450  # hard cap over pages + images in one run
MAX_TOP100_CASES = 25
MAX_IMAGES = 200
# robots.txt of litfl.com (read in a normal browser on 2026-11-04; plain HTTP clients get a
# bot-challenge 403 for /robots.txt): "User-agent: *  Disallow: /wp-admin/"
DISALLOWED = ("/wp-admin/",)

HERE = Path(__file__).resolve().parent
DEFAULT_DATA = Path(r"D:\Projects\ECG-AI_KG\data\litfl")
LABEL_SOURCE = "litfl page title/caption \u2014 teaching label, not reference standard"

TARGETS = {
    "stemi_or_ischaemia": r"stemi|myocardial infarction|\bomi\b|wellens|de winter|ischaemi|ischemi|occlusion|infarction",
    "af": r"atrial fibrillation|\bafib\b|\baf\b",
    "flutter": r"atrial flutter",
    "vt": r"ventricular tachycardia|\bvt\b",
    "vf": r"ventricular fibrillation|\bvf\b",
    "chb_avb3": r"3rd degree|third degree|complete heart block|complete av block",
    "lbbb": r"left bundle branch block|\blbbb\b",
    "rbbb": r"right bundle branch block|\brbbb\b",
    "sinus_tachy": r"sinus tachycardia",
    "sinus_brady": r"sinus bradycardia",
    "normal": r"normal sinus rhythm|normal ecg|\bsinus rhythm\b",
}
EXCLUDE = (r"bifascicular|trifascicular|sgarbossa|versus|\bvs\.?\b|mimic|differential|wpw|wolff|"
           r"pre-?excitation|pacemaker|paced|toxicity|poisoning|artefact|artifact|svt|hyperkal|"
           r"brugada|aberran|ventricular flutter|sinus arrhythmia|torsades|polymorphic|ectopic|"
           r"escape|junctional|lead reversal|aneurysm|pericarditis|"
           r"hypertrophy|mobitz|1st degree|first degree|2nd degree|second degree")
NON_ECG = (r"logo|icon|avatar|gravatar|badge|banner|button|author|portrait|headshot|cartoon|"
           r"diagram|schematic|illustration|algorithm|flowchart|mechanism|anatomy|infographic|"
           r"table|criteria|ladder|graph|chart|screenshot|xray|x-ray|cxr|echo|angiogram|"
           r"sequence|pathway|activation|cloudfront|medmastery|amazon|\.svg|\.gif")


def classify_kind(url: str, alt: str) -> str:
    """Heuristic 'kind' guess from URL and caption: 'ecg' or 'non_ecg'."""
    t = f"{url} {alt}".lower()
    return "non_ecg" if re.search(NON_ECG, t) else "ecg"


def _hits(text: str) -> list[str] | None:
    """Target classes matched by one text; None if the text hits an exclusion keyword."""
    text = text.lower()
    if re.search(EXCLUDE, text):
        return None
    return [k for k, rx in TARGETS.items() if re.search(rx, text)]


def map_label(topic: str, caption: str) -> str:
    """Explicit keyword rules, conservative: a class is assigned only when the page title and
    the caption agree, or when one of them names exactly one class and the other names none
    and no exclusion word. Anything ambiguous, conflicting or excluded -> other."""
    c, t = _hits(caption), _hits(topic)
    if c is None or t is None or len(c) > 1 or len(t) > 1:
        return "other"
    if c and t:
        return c[0] if c == t else "other"
    if t and not c:
        return t[0]
    return "other"  # caption-only evidence on an unrelated page is not trusted


class Fetcher:
    def __init__(self, cache: Path):
        self.cache = cache
        self.cache.mkdir(parents=True, exist_ok=True)
        self.s = requests.Session()
        self.s.headers["User-Agent"] = UA
        self.n = 0
        self.last = 0.0

    def _wait(self):
        if self.n >= MAX_REQUESTS:
            raise SystemExit(f"request cap {MAX_REQUESTS} reached")
        d = MIN_DELAY - (time.time() - self.last)
        if d > 0:
            time.sleep(d)
        self.last = time.time()
        self.n += 1

    def page(self, url: str) -> str | None:
        if any(urlparse(url).path.startswith(p) for p in DISALLOWED):
            return None
        f = self.cache / (re.sub(r"[^a-z0-9]+", "_", urlparse(url).path.lower()).strip("_") + ".html")
        if f.exists():
            return f.read_text(encoding="utf-8")
        self._wait()
        r = self.s.get(url, timeout=30)
        if r.status_code != 200:
            print("skip", r.status_code, url)
            return None
        r.encoding = "utf-8"
        f.write_text(r.text, encoding="utf-8")
        return r.text

    def binary(self, url: str) -> bytes | None:
        self._wait()
        r = self.s.get(url, timeout=60)
        return r.content if r.status_code == 200 else None


def soup(html: str) -> BeautifulSoup:
    return BeautifulSoup(html, "html.parser")


def az_links(html: str) -> list[tuple[str, str]]:
    """Diagnosis A-Z list: links in the entry content until the first off-list link."""
    c = soup(html).select_one(".entry-content")
    out, seen = [], set()
    for a in c.find_all("a", href=True):
        h = urljoin(BASE, a["href"]).split("#")[0]
        if "medmastery" in h or "amazon" in h or "author" in h:
            break
        if urlparse(h).netloc != "litfl.com" or "/wp-content/" in h or "/ecg-library/" in urlparse(h).path:
            continue
        if h not in seen:
            seen.add(h)
            out.append((h, a.get_text(" ", strip=True)))
    return out


def top100_links(html: str) -> list[str]:
    c = soup(html).select_one(".entry-content")
    seen, out = set(), []
    for a in c.find_all("a", href=True):
        h = urljoin(BASE, a["href"])
        if re.search(r"/ecg-case-\d+/?$", h) and h not in seen:
            seen.add(h)
            out.append(h)
    return out


def orig_url(src: str) -> str:
    return re.sub(r"-\d+x\d+(\.\w+)$", r"\1", src)


def page_images(html: str, page_url: str, section: str):
    s = soup(html)
    title = (s.select_one("h1.entry-title") or s.find("h1") or s.title).get_text(" ", strip=True)
    c = s.select_one(".entry-content")
    rows = []
    if not c:
        return title, rows
    for img in c.find_all("img"):
        src = img.get("data-src") or img.get("src") or ""
        if not src or src.startswith("data:"):
            continue
        cls = " ".join(img.get("class", []))
        if "litfl-cc" in cls or "avatar" in cls:
            continue
        src = urljoin(BASE, re.sub(r"[\s﻿​]+", "", src))
        if "/wp-content/uploads/" not in src:
            continue
        alt = (img.get("alt") or "").strip()
        fig = img.find_parent("figure")
        cap = fig.find("figcaption").get_text(" ", strip=True) if fig and fig.find("figcaption") else ""
        heading = ""
        h = img.find_previous(["h2", "h3", "h4"])
        if h and c in h.parents:
            heading = h.get_text(" ", strip=True)
        caption = cap or alt
        rows.append({
            "page_url": page_url, "topic": title, "image_url": orig_url(src), "sized_url": src,
            "alt": alt, "caption": caption, "heading": heading, "section": section,
            "kind": classify_kind(src, caption),
        })
    return title, rows


def crawl(data: Path):
    f = Fetcher(data / "cache")
    az = f.page(f"{BASE}/ecg-library/diagnosis/")
    top = f.page(f"{BASE}/top-100/ecg/")
    f.page(f"{BASE}/ecg-library/")
    jobs = [(u, "diagnosis_az") for u, _ in az_links(az)]
    jobs += [(u, "top100_case") for u in top100_links(top)[:MAX_TOP100_CASES]]
    rows, seen = [], set()
    for u, sec in jobs:
        html = f.page(u)
        if not html:
            continue
        _, r = page_images(html, u, sec)
        for x in r:
            k = (x["page_url"], x["image_url"])
            if k not in seen:
                seen.add(k)
                rows.append(x)
    for i, x in enumerate(rows, 1):
        x["id"] = f"litfl_{i:04d}"
        x["target_label"] = map_label(x["topic"], x["caption"])
        x["file"] = ""
    cols = ["id", "page_url", "topic", "image_url", "sized_url", "alt", "caption", "heading",
            "section", "kind", "target_label", "file"]
    with open(data / "litfl_raw.csv", "w", newline="", encoding="utf-8") as fh:
        w = csv.DictWriter(fh, cols)
        w.writeheader()
        w.writerows(rows)
    print(f"{f.n} requests; {len(jobs)} pages; {len(rows)} images")


def read_raw(data: Path):
    with open(data / "litfl_raw.csv", encoding="utf-8") as fh:
        return list(csv.DictReader(fh))


def download(data: Path):
    rows = read_raw(data)
    img_dir = data / "images"
    img_dir.mkdir(parents=True, exist_ok=True)
    f = Fetcher(data / "cache")
    todo = [r for r in rows if r["kind"] == "ecg" and r["target_label"] != "other"][:MAX_IMAGES]
    for r in todo:
        ext = Path(urlparse(r["image_url"]).path).suffix.lower() or ".jpg"
        dest = img_dir / f"{r['id']}{ext}"
        r["file"] = dest.name
        if dest.exists():
            continue
        b = f.binary(r["image_url"]) or (f.binary(r["sized_url"]) if r["sized_url"] != r["image_url"] else None)
        if b:
            dest.write_bytes(b)
        else:
            r["file"] = ""
            print("failed", r["image_url"].encode("ascii", "replace").decode())
    with open(data / "litfl_raw.csv", "w", newline="", encoding="utf-8") as fh:
        w = csv.DictWriter(fh, list(rows[0].keys()))
        w.writeheader()
        w.writerows(rows)
    print(f"{f.n} requests; {sum(1 for r in rows if r['file'])} images on disk")


def build_index(data: Path):
    """Committed index. selected/layout come from litfl_selection.csv (manual review)."""
    sel = {}
    p = HERE / "litfl_selection.csv"
    if p.exists():
        with open(p, encoding="utf-8") as fh:
            sel = {r["id"]: r for r in csv.DictReader(fh)}
    out = []
    for r in read_raw(data):
        if r["kind"] != "ecg":
            continue
        s = sel.get(r["id"], {})
        out.append({
            "id": r["id"], "page_url": r["page_url"], "image_url": r["image_url"],
            "topic": r["topic"], "caption": r["caption"], "target_label": r["target_label"],
            "label_source": LABEL_SOURCE, "layout_guess": s.get("layout_guess", "unknown"),
            "selected": s.get("selected", "false"),
        })
    with open(HERE / "litfl_index.csv", "w", newline="", encoding="utf-8") as fh:
        w = csv.DictWriter(fh, list(out[0].keys()))
        w.writeheader()
        w.writerows(out)
    print(len(out), "rows in litfl_index.csv")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("step", choices=["crawl", "download", "index", "all"])
    ap.add_argument("--data-dir", type=Path, default=DEFAULT_DATA)
    a = ap.parse_args()
    a.data_dir.mkdir(parents=True, exist_ok=True)
    if a.step in ("crawl", "all"):
        crawl(a.data_dir)
    if a.step in ("download", "all"):
        download(a.data_dir)
    if a.step in ("index", "all"):
        build_index(a.data_dir)


if __name__ == "__main__":
    sys.exit(main())
