# 12 — LITFL ECG Library as a source of real ECG images

Date accessed: 2026-11-04 · Status: first pass · Suggested by the author (2026-10-25).

## What it is
[LITFL ECG Library](https://litfl.com/ecg-library/) (Life in the Fast Lane, emergency medicine
education) covers "over 100 ECG topics" with sections: ECG basics, A–Z by diagnosis, Top 100
ECG (cases and quiz), "Activate or Wait" (cath lab or not), clinical-case series. The general
[library index](https://litfl.com/library/) links it. **Verified** (both pages read).

Not verified: how many tracings there are, their layouts (3×4 + rhythm strip, etc.), and
whether they are scans, photos or machine exports. Inspect them by hand before relying on them.

## Licence (verified, page footer and ECG library page)
- Site content: "licensed under a Creative Commons Attribution-NonCommercial-ShareAlike 4.0
  International License".
- ECG images: "free to reproduce for educational purposes, provided: the image is credited to
  litfl.com; the teaching activity is on a not-for-profit basis; the image is not otherwise
  labelled as belonging to a third-party."

## What this means for the project ([ADR 0001](../adr/0001-permissive-licence-policy.md))
| Use | Allowed? | Why |
|---|---|---|
| Train models that ship in the app | **No** | Non-commercial and share-alike terms conflict with the permissive product path |
| Ship images in the app or commit them to git | **No** | Licence terms. AGENTS.md also bans real ECG images in git |
| Local, non-commercial **evaluation** of the digitiser and the rule-based safety net | Yes, with credit | Research and education use; images stay in git-ignored `data/` |
| Own-photo test set: print selected tracings, photograph them on phones (PROTOCOL §3) | Yes, local only | Gives real-paper morphology the synthetic images lack |
| Cardiologist POC demo, and teaching examples in the review package (as links) | Yes, with credit | Not-for-profit teaching |

## Caveats
- LITFL's explanations are teaching text, not a reference standard. A diagnosis named on a
  LITFL page is a weak label, so report results from it as qualitative.
- The tracings come mostly from emergency-medicine settings in English-speaking countries and
  were selected because they are good teaching examples. That is a different spectrum and
  paper format from rural FAP strips (A1).
- Any download must be manual or a polite, rate-limited script that stores only to `data/`,
  with a committed list of source URLs, never the images.

## Next steps
1. Build `ml/eval/litfl_index.csv` by hand: URL, diagnosis label, layout, lead count. Commit
   only the list of links, never the images.
2. Use 20–40 tracings covering the target findings for the own-photo set.
