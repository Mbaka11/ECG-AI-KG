# Photo session: printed test pages → phone photos → scores

Goal: measure how the digitiser and the rules behave on **real phone photos** where the true
signal is known. The pages are public PTB-XL records (CC BY 4.0) rendered as ECG pages. **They are
not patients. Never use real patient ECGs for this test.**

About 40 minutes of shooting, then about 30 minutes of automatic scoring.

## 1. Print

- Build the pack (once): `make_print_pack.py` → `data/photo_pack/print_pack_A4.pdf` (24 pages).
- Print **in colour**, A4 landscape, "fit to page" (pages come out at ~97 % of true size; the
  digitiser measures scale from the page, so this is fine).
- Optional: print pages 1-4 again in black and white (put their photos in a `bw` folder).

## 2. Phone settings

- Normal camera app, no zoom, no filters, no "document scan" mode.
- **JPG**, not HEIC (iPhone: Settings → Camera → Formats → *Most Compatible*).
- Keep the **QR code** (top right of each page) inside the photo; it identifies the page.

## 3. What to shoot (one folder per condition)

| Folder | Pages | How |
|---|---|---|
| `ideal` | all 1-24 | Flat on a table, daylight or bright room, phone held parallel above the page, page fills most of the frame. |
| `angle` | 1-8 | Same, but phone tilted about 20-30° (page looks like a trapezoid). |
| `shadow` | 1-8 | A hand or phone shadow across part of the page. |
| `curved` | 9-16 | Page folded once and unfolded, or held so it curls. |
| `dim` | 9-16 | Evening, one indoor lamp, no flash. |
| `far` | 17-24 | Page fills only about half the frame. |
| `flash` | 17-24 | Flash on (glare spot is expected). |

72 photos in total. Partial sets are fine: anything is better than nothing; `ideal` matters most.

## 4. Put the photos in place

```
data/photos/ideal/IMG_….jpg
data/photos/angle/IMG_….jpg
...
```

(`data/` is git-ignored; photos never go into git.)

## 5. Score

From `ml/`:

```
.venv/Scripts/python.exe -m digitise.score_photos ../data/photos ../data/photo_pack ../data/photo_work
```

It reads each QR code, runs the digitiser, compares with the true signal, runs the rules on both
and prints a table per condition:

- `digitised`: photos where the digitiser produced a signal,
- `SNR med`: median SNR in dB over all leads (higher is better; above ~10 dB is good, 0 dB is
  useless),
- `same` / `grey` / `UNDER` / `over`: urgency from the photo vs from the true signal. **`UNDER`
  is the dangerous one** (photo looks less urgent than the truth).

Per-photo details are in `data/photo_work/results.csv`. If a QR was not read, the photo's
`record` in `data/photo_work/stage/photos.csv` is empty: fill in the record id (e.g. `00318_hr`,
printed on the page) and rerun with `--skip-digitise`.
