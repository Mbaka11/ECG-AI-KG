# Photo session: printed test pages → phone photos → scores

Goal: measure how the digitiser and the rules behave on **real phone photos** where the true
signal is known. The pages are public PTB-XL records (CC BY 4.0) rendered as ECG pages. **They are
not patients. Never use real patient ECGs for this test.**

About 40 minutes of shooting, then about 30 minutes of automatic scoring.

## 1. Print (once)

- File: `data/photo_pack/print_pack_A4.pdf` (24 pages, A4 landscape, already the right orientation).
- **Colour** (the red grid is what the digitiser removes), **one-sided**, plain **matte** paper
  (glossy paper makes glare). Printer quality **Standard or Best, not Draft/Economy**: a faded grid
  changes what the model sees and spoils the test.
- Scale: "Fit to page" is fine (pages come out at ~97 % of true size; the digitiser measures the
  scale from the page).
- **One copy is enough**: shoot every condition from the same sheets, in the order in section 3
  (flat conditions first, folding last). Do not write on the pages.
- Check the printout: the grid is red and clearly visible, the QR code (top right) is sharp, and the
  line "Test page NN - PTB-XL ..." is readable.

## 2. Phone settings

- Normal camera app, no zoom, no filters, no "document scan" mode.
- **JPG**, not HEIC (iPhone: Settings → Camera → Formats → *Most Compatible*).
- Keep the **QR code** (top right of each page) inside the photo; it identifies the page.

## 3. What to shoot (one folder per condition)

Shoot in this order, so one copy of each page survives all conditions: flat first, folded last.

| Order | Folder | How | Minimum (72 total) | Full (168 total) |
|---|---|---|---|---|
| 1 | `ideal` | Flat on a table, daylight or bright room, phone parallel above the page, page fills most of the frame. | pages 1-24 | pages 1-24 |
| 2 | `far` | Same, but the page fills only about half the frame. | pages 17-24 | pages 1-24 |
| 3 | `angle` | Phone tilted about 20-30° (page looks like a trapezoid). | pages 1-8 | pages 1-24 |
| 4 | `shadow` | A hand or phone shadow across part of the page. | pages 1-8 | pages 1-24 |
| 5 | `flash` | Flash on (a glare spot is expected). | pages 17-24 | pages 1-24 |
| 6 | `dim` | Evening, one indoor lamp, no flash. | pages 9-16 | pages 1-24 |
| 7 | `curved` | Page folded once and unfolded, or held so it curls. | pages 9-16 | pages 1-24 |

Start with the minimum set. If you have time, add the rest of the full set, always starting with the
conditions that cost the least (`far`, `angle`, `shadow`). `ideal` matters most; the QR code must be
visible in every photo. Take each photo once, do not delete "bad" ones: bad photos are the test.

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
