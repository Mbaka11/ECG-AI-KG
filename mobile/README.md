# ECG-AI KG — app prototype (Flutter)

**Status:** clickable UI prototype, v0.1.0-demo. **No model runs.** Every result is a canned
demo scenario. Clinical texts are short paraphrases of the KR MoH protocols in
[`docs/research/10-kr-protocols.md`](../docs/research/10-kr-protocols.md). They are tagged
"pending cardiologist review" and carry no drug doses (hazard H-07).

Screenshots: [`docs/design/`](../docs/design/README.md).

## Run

Needs Flutter ≥ 3.47 (stable).

```sh
cd mobile
flutter pub get
flutter run -d chrome            # or an Android device / emulator
flutter test                     # smoke + safety-rule tests
flutter build web --release      # static build in build/web
```

Demo links on the web build:
- `?lang=en|ru|ky` preselects the UI language.
- `#/home`, `#/new/guide`, `#/case/C-10388` (red), `C-10419` (amber), `C-10427` (green),
  `C-10371` (grey) open a screen directly.

## Flow

Welcome (language, research disclaimer D1) → Home → **New ECG**:
1. Photo checklist.
2. Camera with a framing guide. A demo chip picks the sample strip: ST, AF, sinus or poor photo.
3. Photo check: the trace the app read is drawn over the photo, with a quality verdict and the
   detected speed, gain, leads and layout. Retake or continue.
4. Optional patient info. Symptom chips, sex, age band. No name or ID.

→ Processing, which is on-device and shows its steps → **Result**:
- an urgency banner (colour, icon and word, plus heart rate),
- numbered action steps, each with its source,
- the findings, marked "suspected" where it applies,
- the mandatory notices (D5, D6, D7),
- the ECG trace with highlights,
- the values to check (D8) and the versions (D9),
- "send to an expert",
- a fixed disclaimer footer (D2).

Also: History (sync state per case), Settings (language, account, data), About (D1, D11,
limitations). The offline/online chip on Home is a demo toggle.

Working features beyond the mock-up:
- **Photo input.** "From gallery" on Home and "Use phone camera" on the camera screen both use
  `image_picker`. The photo appears on the check screen with a demo notice: it is not analysed
  yet, and the result still comes from the chosen sample.
- **PDF export.** The PDF icon on a result builds a one-page A4 report with `pdf` and
  `printing`, then opens the share sheet on Android or downloads it on the web. The report has
  the same content and disclaimers as the screen, a vector ECG trace, and no patient name or ID.
  It embeds Noto Sans so Cyrillic renders.
- **Cases kept between launches.** `state/case_store.dart` uses `shared_preferences` to keep the
  last 50 cases. It stores metadata only, never photos.

## Design rules (from [research 11](../docs/research/11-ux-market.md) and [`docs/safety/`](../docs/safety/))

- Urgency is never shown by colour alone. Each level has its own colour, icon and word, and
  grey ("no result") is outlined, not filled.
- Low quality or low confidence is never green. Symptoms such as chest pain, breathlessness or
  fainting add a red notice on non-red results.
- The UI never uses the word "normal". Green means "no urgent pattern".
- One primary action per screen. Buttons are at least 56 dp tall. Body text is 15–17 sp.
- Noto Sans is bundled (OFL, see `assets/fonts/OFL.txt`) and covers Kyrgyz letters ң ө ү. No
  runtime font downloads.

Urgency tokens in `lib/theme/tokens.dart`:

| Level | Fill | Text |
|---|---|---|
| Red | `#B3261E` | white |
| Amber | `#FFC107` | `#1F1F1F` |
| Green | `#1B6E3C` | white |
| Grey | dashed outline `#5F6368`, fill `#ECEEF1` | `#3C4043` |

All colour pairs are WCAG AA or better. The tokens are proposals, pending cardiologist review.
Spacing, shape and neutral colour tokens, with their contrast ratios, are listed in
[`docs/design/README.md`](../docs/design/README.md#tokens-mobilelibthemetokensdart). The app icon is
drawn by `tool/gen_icons.py` (Pillow, dev only).

## Languages

Strings are generated from one table, `tool/gen_arb.py`, into `lib/l10n/app_{en,ru,ky}.arb`,
so all three files always have the same keys. After editing the table, run
`python tool/gen_arb.py lib/l10n`.

- **Russian and English** are complete.
- **Kyrgyz** is a placeholder holding the Russian text, marked in the ARB. It needs a native
  medical translator. Machine-translating clinical text is not allowed.

## Structure

```
lib/
  app.dart              router (go_router) + MaterialApp, locales
  state/app_state.dart  Riverpod notifiers: settings, draft case, case list
  models/ecg_case.dart  EcgCase, Urgency, Finding, ActionStep, notices
  data/demo_cases.dart  the 4 demo scenarios (clinical text lives here, as data)
  theme/                tokens + ThemeData
  widgets/              EcgPaper (synthetic ECG on 25 mm/s grid), banners, notices
  screens/              welcome, home, capture flow, result, history, settings/about
```

## Known gaps / next steps

- A guided live camera with edge detection (`camera` or a document scanner). Today the app
  uses the system camera through `image_picker`.
- Drift (SQLite) storage with retention rules and sync, replacing the `shared_preferences`
  prototype store, per [ADR 0006](../docs/adr/0006-inference-location.md) and
  [ADR 0007](../docs/adr/0007-app-and-backend-stack.md).
- The model and digitiser (Phase 3). The UI already expects `TechDetails`, findings, a quality
  score and versions.
- Partial adherence to the vendored `design-system-structure` skill. Most colours are tokens
  since design v2, but the ECG paper and a few tints are still raw values, and there is no
  dark theme yet.
- The Kyrgyz translation and a review of all clinical text by a cardiologist.
- Usability test with 3–5 feldshers (IEC 62366-lite, hazard H-06).
