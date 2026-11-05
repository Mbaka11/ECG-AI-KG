# LITFL ECG test set (local, teaching-grade)

Small set of ECG images from the [LITFL ECG library](https://litfl.com/ecg-library/) used for
quick end-to-end checks of the photo-to-ECG pipeline (step 1 of the plan). Images are
**never committed or shipped**; only the index (`litfl_index.csv`), the review overlay
(`litfl_selection.csv`) and the crawler live in git.

## Licence and allowed use

LITFL content is CC BY-NC-SA 4.0; ECG images may be reused for not-for-profit education with
credit to litfl.com (see [research 12](../../docs/research/12-litfl-ecg-library.md); that note
was not present in this branch when the crawler was written). Use: local evaluation and
teaching only, no redistribution of the images, no training of shipped models, credit
"litfl.com". Images live in `data/litfl/images/` (git-ignored).

## Rebuild

```
cd ml
python -m venv .venv && .venv\Scripts\pip install -e .[eval]
python eval/litfl_crawl.py all          # crawl (cached) -> download -> index
python eval/litfl_crawl.py index        # only regenerate litfl_index.csv
```

Default data dir is `D:\Projects\ECG-AI_KG\data\litfl` (`--data-dir` to change): `cache/`
(HTML), `images/`, `litfl_raw.csv` (full crawl metadata). Politeness: descriptive User-Agent,
at least 2 s between requests, HTML cached, hard cap of 450 requests per run. robots.txt
(read in a browser, because plain HTTP clients get a bot-challenge 403) only disallows
`/wp-admin/`. When the site answers 403 the script skips the URL and does not try to work
around it.

## Index

`litfl_index.csv`: id, page_url, image_url, topic, caption, target_label, label_source,
layout_guess, selected. Labels come from explicit keyword rules in the script and are
conservative: a class is set only if page title and caption agree (or the title names one
class and the caption none); anything ambiguous or excluded (WPW, toxicity, mimics, blocks
other than the targets, ...) is `other`. They are teaching labels, **not a reference
standard**. `selected` and `layout_guess` come from `litfl_selection.csv`, filled by eye
after opening the images.

## Counts (state of this build)

Crawl: 145 pages visited, 852 images found, 707 kept as likely ECGs (rest: diagrams, logos).
Top-100 quiz case pages (`ecg-case-N`) have no diagnosis in the title, so their images map to
`other`. Only 27 images were downloaded (see caveats).

All index rows by target_label: other 547, stemi_or_ischaemia 93, vt 20, flutter 10, lbbb 9,
rbbb 8, af 6, vf 5, chb_avb3 4, sinus_tachy 2, normal 2, sinus_brady 1.

Selected (21), by target_label: af 6, rbbb 5, vt 4, stemi_or_ischaemia 3, normal 2, lbbb 1.
Selected, by layout: 12lead_3x4+rhythm 11, rhythm_strip 3, 2lead_crop 3, 6lead_V1-V6_crop 3,
12lead_3x4_no_rhythm 1.

## Caveats

- After about 180 requests litfl.com started answering 403 (bot challenge) for most image and
  some page requests; 17 pages and ~130 of ~160 candidate images were not fetched. Missing
  from the local set: flutter, vf, chb_avb3, sinus_brady, sinus_tachy, and classic STEMI
  tracings (only Wellens/OMI examples). Rerun `download` later (cache and existing files are
  reused) or add the images by hand; do not bypass the challenge.
- Several images are crops (2 or 6 leads) or drawings, not full 12-lead tracings.
- Page-level labels can be wrong for a given image; clinical review is still required.
