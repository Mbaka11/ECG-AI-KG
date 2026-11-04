# 11 - UX market scan and design guidance (capture, results, low-literacy health workers)

Date of research: 2026-11-04. Method: web search plus partial page reads; vendor IFUs and store listings. Status labels: **Verified** (page read), **Partly verified** (search snippet or secondary source), **Unverified** (inference or not found). Items marked "(computed)" were calculated locally for this note.

Related: [06 existing solutions](06-existing-solutions.md), [INTENDED_USE](../safety/INTENDED_USE.md) (disclaimers D1-D12, never-green rule), [08 tooling](08-dev-tooling-and-agent-skills.md).

## Summary

- No competitor publishes a full public description of its capture or result screens. What is public: PMcardio's format-picker plus rotate flow, Kardia/Apple/Samsung result categories (including explicit "cannot classify" and "poor recording" states), and Tricog's critical/abnormal split. Screens themselves could not be retrieved by the tools used (see `temp/ux-refs/README.md`); a manual look at the store screenshots is still worthwhile.
- Consumer ECG products (Apple, Samsung, Kardia) all have a third outcome besides "normal" and "abnormal": **inconclusive / unclassified / poor recording**, with a retake instruction and a "normal does not exclude disease" disclaimer. This matches our grey "cannot interpret" state and never-green rule.
- Professional tools (PMcardio, Cardiologs) present a **findings list and measurements for a clinician**, not a colour-coded action. Our urgency colour plus next-step text is a differentiator, which also makes the colour design a safety feature.
- For low-literacy users the consistent advice is: pair icons with text, few options per screen, numbers and pictures over prose, test with low-literacy users, and test on low-end phones. Never use colour alone.
- Measured here: our candidate red and green have almost the same lightness (contrast 1.04:1), so a colour-blind user cannot tell them apart without a shape and a word. Shape plus text is mandatory.
- Inter, Noto Sans, Roboto and Rubik all contain Ң ң Ө ө Ү ү (checked in the font files, computed).

## 1. Competitor UI patterns

### 1.1 PMcardio (Powerful Medical)

| Aspect | What is public | Status |
|---|---|---|
| Capture flow | Log in, **pick the ECG format icon** (lead layout, leads per page; multi-page formats let you upload several images), "Change Format" button top right, take the photo, **check that leads run horizontally** and use the rotate button in the bottom menu, then enter reason for exam, sex and age after upload. | Verified ([first-scan guide](https://www.powerfulmedical.com/blog/get-your-first-ecg-scan-right/)) |
| Guides/overlays/retake | The guide page has no cropping or retake advice. Vendor says the AI digitises faded, crumpled, stained or angled ECGs but poor images may still be a problem. No camera overlay found. | Partly verified ([search summary](https://powerfulmedical.com/blog/how-to-improve-ecg-quality)) |
| Unsupported input | IFU says not to analyse flatline/disconnected-lead recordings, exercise stress ECGs or Holter recordings. | Partly verified ([IFU 2.8](https://documents.powerfulmedical.com/pmcardio/ifu/en/PMcardio_2-8.pdf), snippet) |
| Result screen | Findings from 36 core diagnoses; Pro adds measurements (HR, axes, P/PR/QRS/QT/QTc), "ECGxplain" heatmaps for STEMI results and AI confidence indicators; reports can be archived and shared; later versions add culprit-artery highlighting. No evidence of a red/amber/green action level. Exact layout not retrieved. | Verified for the feature list ([App Store listing](https://apps.apple.com/BR/app/id1640037895)); layout Unverified |
| Disclaimers | "Regulated as medical devices and intended for use by healthcare professionals"; CE for EU/UK only, not all modules in every region. IFU says the app can misidentify conditions and that additional tests may be needed. | Verified (listing), Partly verified (IFU snippet) |
| Languages | German, Slovak, Spanish, French, Dutch, English, Italian (iOS listing). No Russian or Kyrgyz. | Verified |
| IFU sections to read by hand | 8.1 digitisation requirements, 8.1.3 unsupported formats, 8.4 ECG analysis (the PDF text was not extractable by the tool). | Open |

Lesson: format selection **before** capture and an explicit rotate step are cheap ways to cope with layout variety. Our app should detect the layout automatically and let the user correct it, because FAP strips are often 3- or 6-channel ([00](00-synthesis.md)).

### 1.2 ECG Buddy (ARPI)

Public information is thin: phone scan of a printout, 11 rhythm classes plus 11 "digital biomarkers"; separate Clinic (Korean MFDS class III per the listing), Research ("not a medical device, not for clinical decisions") and general listings; users are told to read the IFU before clinical use ([search results](https://play.google.com/store/apps/details?id=ai.arpi.app&pli=1), [App Store Research listing](https://apps.apple.com/app/id6447230344)). The official site URL tried (`/en/ecg-buddy`-style page) returned 404, and no capture or result screen description was found. **Unverified:** guides, overlays, result layout, languages.

### 1.3 Cardiologs (Philips)

A browser platform for clinician review of long-term (Holter/patch) ECG: displays the analysis with the original signal and tools (ruler, zoom), highlights AI-detected abnormalities, lets the clinician confirm findings and generate a PDF report; API output to other systems. FDA filings state the interpretation is not intended to be the sole means of diagnosis ([FDA 510(k) summary K212112](https://510k.innolitics.com/device/K212112), [Philips brochure](https://www.documents.philips.com/assets/20240822/e638246e69384c069c9fb1d401210d14.pdf)). Not a photo-capture tool; no per-beat colour scheme confirmed. Relevance: "show the original signal next to the AI finding and let the human confirm" is the pattern we also need (INTENDED_USE D8).

### 1.4 AliveCor Kardia

Result categories: **Normal, Possible atrial fibrillation, Unclassified, Tachycardia, Bradycardia, and "unreadable/too noisy"** with a re-record instruction; Normal is tied to HR 50-100 with normal beat morphology; the manual says "Normal" is not a guarantee of no arrhythmia and "possible AF" is a potential finding, see a physician if symptomatic. Minimum recording 30 s. Source: older (2016-era) KardiaBand/KardiaMobile manuals, so current wording may differ ([IFU 02LB49.5](https://alivecor-website-k8s.us-production.alivecor.com/previous-labeling/km_ifu/02LB49.5%20English.pdf), [IFU 15LB1.5](https://alivecor-website-k8s.us-production.alivecor.com/previous-labeling/kb_ifu/15LB1.5.pdf)). Partly verified. Kardia 12L (professional 12-lead, 39 determinations) is covered in [06](06-existing-solutions.md); its screens were not found.

### 1.5 Tricog (India)

Workflow: ECG to cloud, AI preliminary read, cardiologist verifies, report back by app and email; classification **critical vs abnormal** (vs normal); turnaround targets under 20 min for standard and under 10 min for critical cases, with phone-call alerts and "real-time STEMI alerts" ([Tricog connected pathway](https://tricog.com/blogs/the-connected-pathway/), [InstaECG page](https://tricog.com/instaecg/)). No evidence of the colours or screen design. Partly verified. Lesson: a two-level language ("critical" / "abnormal") plus a *time promise* is how a rural-spoke service communicates urgency; we cannot promise a time, but we can name the next action.

### 1.6 SberMedAI "Digital FAP"

Only press-level information (digital ECG kit, EHR integration; see [06](06-existing-solutions.md)). **No public UI description found.** Unverified.

### 1.7 Apple Watch ECG and Samsung Health Monitor

| | Apple | Samsung |
|---|---|---|
| Outcomes | Sinus rhythm, Atrial fibrillation, **Inconclusive** (plus high/low HR variants in the app) | Sinus rhythm, AFib, **Inconclusive**, **Poor recording** |
| Retake wording | Inconclusive = could not be classified; reasons listed (HR range, loose watch, arm not resting); can re-record | Poor recording = could not analyse at all, try again (skin contact, movement); Inconclusive = analysable but not classifiable; repeat results: contact doctor |
| Disclaimers | Sinus rhythm "does not mean you are healthy", applies to that recording only | Sinus rhythm does not guarantee absence of arrhythmia |
| Reliance on abstention | 12.2 % of trial recordings inconclusive | 16.8 % inconclusive or poor in US validation |

Sources: [Apple support 120278](https://support.apple.com/en-us/120278), [Apple ECG IFU](https://www.apple.com/legal/ifu/ecg/ecg-ifu-1-en_US.pdf), [Samsung IFU (US)](https://image-us.samsung.com/SamsungUS/home/apps/samsung-health-monitor/IFU_ECG_US_20211214.pdf) (all Partly verified via search summaries; the colour and screen layout were not retrieved). Lesson: mature products accept a double-digit abstention rate and distinguish "bad signal, retake" from "cannot classify rhythm". Our grey state should do the same, and we should budget for a high abstention rate on phone photos ([04](04-digitisation.md)).

### 1.8 Cross-product patterns (synthesis, partly inference)

1. Choose layout/format first or auto-detect it; confirm orientation.
2. Quality verdict before analysis; explicit retake path.
3. At least three result classes: positive finding, no finding, **cannot classify**; a "no finding" disclaimer on the same screen.
4. Findings in plain words, measurements secondary, original signal visible.
5. Professional tools target clinicians with English/European languages; none seen offers Russian or Kyrgyz.

## 2. Design guidance for low-literacy and community health worker apps

Caveat: our users are feldshers/nurses with medical training, not illiterate. The relevant constraint is **low digital literacy, mixed phone quality, stress, and three UI languages**, not inability to read. The low-literacy literature is used for its general rules and applied proportionately. (Inference.)

| Principle | Evidence | Status |
|---|---|---|
| Use images and audio prompts extensively; icons in module/form lists; limit options; avoid multi-select; short case lists; include users of different abilities in pilots; "Sense mode" removes partial-form saving because it confused users | Dimagi, [Designing for Low-Literate Users](https://dimagi.atlassian.net/wiki/x/-jPKfw) (via search summary) | Partly verified |
| Combine icons **with** text labels because icons alone are ambiguous; do not assume users know gestures such as swipe; use short animations for gestures; low-end Android phones break designs that look good on flagships, so test on real low-end devices | Google Design (Next Billion Users team), [Improving comprehension through intuitive actions](https://medium.com/google-design/improving-comprehension-through-intuitive-actions-f7e6336e12e6) (page returned 403; content from search summary) | Partly verified |
| Research on low-literacy UIs supports numbers + icons + audio; a 2023 review lists 16 design considerations (text use, interaction patterns, pictography, audio-video, information architecture) | [Medhi Thies 2015](https://courses.cs.washington.edu/courses/cse490c/18au/readings/medhi-thies-2015.pdf), [Sage Open 2023 review](https://ideas.repec.org/a/sae/sagope/v13y2023i2p21582440231172741.html) (summaries only) | Partly verified |
| Medic/CHT usability tests (Partners in Health, Malawi): a single floating action button for new actions was easier to learn (70 % of CHWs preferred it); visible labels and large icons were clearer; remove unused features to reduce clutter; CHT aims for consistency with Material Design | [Medic remote usability testing](https://medic.org/stories/remote-usability-testing/), [CHT design system](https://docs.communityhealthtoolkit.org/design) (page last modified 2020) | Partly verified |
| WHO 2019 digital-health guideline: most interventions target health workers; some find them inefficient or experience double work when digital and paper systems coexist; digital is not a substitute for a functioning health system | [WHO/RHR/19.10 summary](https://new.aidsdatahub.org/sites/default/files/resource/who-guideline-digital-interventions-health-system-strengthening-2019-summary.pdf) (unofficial copy; WHO's own page not read) | Partly verified |
| Touch targets at least 48 x 48 dp (icon may be 24 dp with padding) | [Google Accessibility Help](https://support.google.com/accessibility/android/answer/7101858) | Verified (search result text) |
| WCAG 2.2: 1.4.1 colour not the only means of conveying information (A); 1.4.3 text contrast 4.5:1 normal / 3:1 large (AA); 1.4.11 non-text 3:1 (AA); 2.5.8 target 24 x 24 CSS px minimum (AA) | [W3C WCAG 2.2 Understanding](https://www.w3.org/WAI/WCAG22/Understanding/) (index; criteria details from secondary pages) | Partly verified |
| Russian text is about 9 % (Alconost study) to 15-20 % (vendor/rule of thumb) longer than English; short UI strings are more affected | [Game World Observer](https://gameworldobserver.com/2016/06/20/localization_guidelines), [ATA guide](https://www.ata-divisions.org/SLD/localizing-into-russian/) | Partly verified. **Kyrgyz expansion: not found; Unverified**, assume at least Russian-level |

Practical consequences (inference): (1) every button gets an icon **and** a word; (2) one primary action per screen; (3) no gestures required beyond tap and scroll; (4) offline state visible but calm (the app works offline, so "offline" is not an error); (5) no feature that requires both paper and app for the same record; (6) test on a 2-3 GB RAM Android phone with a scratched screen in sunlight.

Not found: a formal Google "Next Billion Users" guideline document, a published CHT principle list, and Kyrgyz-specific UI research.

## 3. Alert colour conventions

- **Manchester Triage System:** five colours with maximum time to first assessment: red 0 min (immediate), orange 10, yellow 60, green 120, blue 240 ([SciELO study](https://scielo.br/j/rgenf/a/QWdPXZK7RpYsvCPwKbFDBrd/?lang=en); several low-quality PDFs differ, ignored). Verified in secondary sources; the official MTS manual was not read. Our red/yellow/green plus grey is a **simplified three-level scheme and does not map to MTS**; do not label it as MTS. Whether the KR MoH uses colour triage for ECG is **Unverified**.
- **Colour alone is not enough:** WCAG 1.4.1 requires another cue (text or shape). Red-green colour vision deficiency affects roughly 5-8 % of men depending on population and test; sources found were weak, so the figure is **Partly verified** ([example review](https://www.scielo.org.za/pdf/aveh/v84n1/24.pdf)).
- **Measured (computed):** candidate red `#B3261E` vs green `#1B6E3C` have a contrast ratio of 1.04:1, i.e. almost identical lightness; green vs grey `#5F6368` also 1.04:1. A dichromat or a user in glare will not separate these by colour. Red vs amber is 4.01:1; amber vs grey is 3.71:1. Therefore shape, icon and a word must carry the level.
- Yellow/amber fills fail with white text (amber `#FFC107` on white is 1.63:1, computed); use dark text on amber.

## 4. Recommendation

### 4.1 Screen list for the MVP flow

1. **First launch / language**: three large buttons, native names (Русский, Кыргызча, English), saved choice. Then D1 acknowledgement ("research prototype, not a diagnosis").
2. **Home**: one primary button "New ECG" (camera icon + label); secondary: "History" (local), "Help", "Settings/About". Offline indicator small, neutral; "forward to expert" appears only when relevant.
3. **Pre-capture checklist (3 icons max)**: flat paper, whole strip with grid visible, no glare/shadow. Skippable after first time; "Help" shows it again.
4. **Capture**: live camera with a landscape frame overlay for the strip, level indicator, glare/blur hints; automatic perspective crop (ML Kit document scanner candidate, [08](08-dev-tooling-and-agent-skills.md)); shutter button >= 72 dp.
5. **Quality verdict**: green tick "Photo is good" or a clear problem ("Too dark", "Cut off", "Blurry") with the **same photo** shown and one big "Retake" button; "Use anyway" only as a small secondary action and it forces a grey result when quality is poor.
6. **Confirm layout/scale**: detected leads, paper speed and gain shown as editable chips (D8); rotate button (PMcardio pattern). Max 2 questions here.
7. **Clinical context (2-4 yes/no questions)**: chest pain, fainting, breathlessness, low BP if measured; large Yes/No buttons, final list pending cardiologist review.
8. **Processing**: determinate progress or simple spinner with text; cancel button.
9. **Result**: see 4.2.
10. **Next steps detail**: protocol-derived steps with source and date next to each (D10), tick-off checkboxes optional.
11. **Forward / save**: forward to expert centre (consent text, D11), save to local history, share PDF. No identifiers by default.
12. **History, Help, About**: disclaimers D1-D12, app/model/protocol version (D9), data statement.

Keep the happy path to **home -> capture -> verdict -> result = 4 taps** plus the context questions.

### 4.2 Result screen layout (top to bottom)

1. **Urgency banner** full width: icon + word + short action sentence ("Possible emergency. Act per protocol and call for help now."), in the urgency colour. Words per level: red "URGENT", yellow "REFER / CHECK SOON" (exact wording pending cardiologist review), green "NO URGENT FINDING", grey "CANNOT INTERPRET". Avoid the word "normal" and "healthy".
2. **Heart rate** in large type with unit (numbers beat prose for low-literacy users).
3. **Findings list**: one row each with icon, name ("Suspected atrial fibrillation"), confidence word (e.g. "high / medium / low", not a bare percentage), and a small "?" for the explanation. Highest-urgency finding first.
4. **Trace overlay**: the photo with the digitised trace overlaid, pinch-zoom, toggle overlay on/off, leads labelled; the user can verify against paper.
5. **Next steps** (collapsed to the top 3, "Show all").
6. **Limits notice**: D5/D6/D7 as applicable, e.g. "Only rhythm was assessed".
7. **Fixed footer D2**: "Not a diagnosis. A green result does not exclude disease." Always visible.
8. Primary button: "Forward to expert" (red/yellow) or "Retake / record 12-lead" (grey).

Rules: low quality or low confidence is never green; green banner always includes "no urgent finding found on this strip" not "ECG normal"; abstention is a first-class screen (D4).

### 4.3 Typography

- **Recommended: Noto Sans** (Latin, Cyrillic, Greek; OFL 1.1) as the single UI and report font, bundled in the app and embedded in PDFs. **Inter** and **Roboto** (also from Google Fonts, OFL/Apache) are alternatives. Glyph test (computed from the font files in google/fonts): Inter, Noto Sans, Roboto and Rubik all contain Ң ң Ө ө Ү ү. IBM Plex Sans could not be tested (file download failed); **Unverified**.
- Licences: Noto Sans is OFL-1.1 (package listing, Partly verified). Confirm Inter and Roboto licences in the repo's SOUP table before bundling.
- Sizes (sp): body 16, secondary >= 14, result banner 22-24 bold, heart rate 40+, buttons 18 semibold. Respect system font scale up to 200 % without clipping (test it).
- Plan for **>= 30 % string expansion** for buttons (Russian +9-20 %, Kyrgyz unknown), allow two-line buttons, no fixed-width labels, no ALL CAPS in Cyrillic for long words.
- Use tabular figures for numbers where available.

### 4.4 Colour tokens (contrast ratios computed against stated backgrounds)

| Level | Fill (banner) | Text on fill | Ratio | Soft background | Text on soft | Ratio | Icon / shape |
|---|---|---|---|---|---|---|---|
| Red, urgent | `#B3261E` | white `#FFFFFF` | 6.54 | `#FDE8E7` | `#8C1D18` | 7.76 | Octagon / exclamation, filled |
| Amber, refer/soon | `#FFC107` | `#1F1F1F` | 10.11 | `#FFF4D6` | `#6B4700` | 7.59 | Triangle / exclamation |
| Green, no urgent finding | `#1B6E3C` | white `#FFFFFF` | 6.28 | `#E3F4E8` | `#14532D` | 7.97 | Circle / tick |
| Grey, cannot interpret | `#5F6368` | white `#FFFFFF` | 6.05 | `#ECEFF1` | `#3C4043` | 9.06 | Square with question mark, **dashed outline** |
| Body text | `#1F1F1F` on white | | 16.48 | | | | |

Notes: all text pairs exceed 4.5:1 (computed). Fill-to-fill separation is weak (red-green 1.04:1, green-grey 1.04:1, amber-grey 3.71:1), so **each level has a unique icon shape, a unique word, and the grey state uses a dashed outline and no coloured fill**. Add a 2 dp border in the text colour on banners. Check the palette in a simulator for protanopia/deuteranopia and in a dark theme before freezing. Dark theme is optional for MVP. These tokens are a proposal, not clinically reviewed; urgency wording and thresholds remain pending cardiologist review.

### 4.5 Iconography

- **Material Symbols** (Apache-2.0, Google; confirm licence in SOUP table) rounded or outlined, weight 500, 24 dp glyph inside a 48 dp target. Use filled variants for state icons (error, warning, check_circle, help). Always show a text label next to the icon.
- Avoid abstract medical pictograms the user may not know; use a heart/ECG-line glyph only as decoration, never as the sole label.

### 4.6 Layout rules

- Single column, one primary action per screen, bottom-anchored primary button reachable by thumb, min 48 dp targets, 8 dp spacing between targets, 16 dp side gutters.
- No swipe-only, long-press-only or hidden gestures; no nested menus deeper than 2 levels; no tabs on the capture and result flow.
- Offline is the default state: show a small neutral cloud-off icon with "Works without internet"; queue forward requests and show their status in History.
- Use real photos/line drawings (not text) for the capture checklist.
- Confirm only destructive actions; do not ask for confirmation on retake.
- Test with real strings in ru, ky, en on a low-end Android (2 GB RAM), at 200 % font scale, in sunlight; include 3-5 feldshers in usability tests (after ethics/approval; no patient data in tests).

### 4.7 What to avoid

- Colour as the only urgency signal; red-green pairs without icon and word.
- The word "normal", a bare percentage as "confidence", or any wording that reads as a diagnosis.
- A green state when quality is low or leads are missing (hazard).
- Free-form typing on the main path; long forms; patient name/ID fields by default.
- Auto-dismissing alerts; toasts for safety messages; carousels for disclaimers.
- Icon-only buttons, unlabelled gestures, tiny "i" buttons as the only way to see sources.
- Any LLM-written explanation text (spec v2 C-28); machine-translated clinical Russian/Kyrgyz without a medical reviewer.
- Heavy animation, large fonts files per weight (keep one family, 2-3 weights), anything requiring Google Play Services without a fallback ([08](08-dev-tooling-and-agent-skills.md)).
- Copying competitor visuals or trade dress.

## 5. Open questions

| Question | Who/how |
|---|---|
| Actual PMcardio and ECG Buddy capture/result screens (layout, colours, confidence display) | Researcher: install free tiers, review store screenshots and IFU section 8.4; check terms first |
| Do feldshers recognise the proposed icons and words in ru/ky? Which Kyrgyz medical terms are standard? | Usability test with 3-5 feldshers; medical translator; 2024 RU-KY medical dictionary ([02](02-kyrgyz-context.md)) |
| Final urgency wording and level definitions | Cardiologist (OPEN_QUESTIONS) |
| Does KR MoH or the cardiology centre use a colour triage scheme feldshers already know? | Author / cardiologist |
| Typical FAP phone models, screen sizes, sunlight use | Author (field knowledge); [02](02-kyrgyz-context.md) |
| Kyrgyz string expansion; IBM Plex Sans Kyrgyz coverage; licence confirmation for Inter/Roboto/Material Symbols | Researcher, before freezing the design |
| SberMedAI Digital FAP UI and the tele-ECG hub's reporting format | MoH contact via cardiologist |

## Sources (accessed 2026-11-04)

- PMcardio first-scan guide: https://www.powerfulmedical.com/blog/get-your-first-ecg-scan-right/
- PMcardio image-quality blog (snippet): https://powerfulmedical.com/blog/how-to-improve-ecg-quality
- PMcardio IFU 2.8 / 2.9 (not extractable): https://documents.powerfulmedical.com/pmcardio/ifu/en/PMcardio_2-8.pdf , https://documents.powerfulmedical.com/pmcardio/ifu/en/PMcardio_2-9.pdf
- PMcardio App Store listing: https://apps.apple.com/BR/app/id1640037895
- ECG Buddy: https://play.google.com/store/apps/details?id=ai.arpi.app&pli=1 , https://apps.apple.com/app/id6447230344
- Cardiologs: https://510k.innolitics.com/device/K212112 , https://www.documents.philips.com/assets/20240822/e638246e69384c069c9fb1d401210d14.pdf
- AliveCor IFUs: https://alivecor-website-k8s.us-production.alivecor.com/previous-labeling/km_ifu/02LB49.5%20English.pdf , https://alivecor-website-k8s.us-production.alivecor.com/previous-labeling/kb_ifu/15LB1.5.pdf
- Tricog: https://tricog.com/blogs/the-connected-pathway/ , https://tricog.com/instaecg/
- Apple: https://support.apple.com/en-us/120278 , https://www.apple.com/legal/ifu/ecg/ecg-ifu-1-en_US.pdf
- Samsung: https://image-us.samsung.com/SamsungUS/home/apps/samsung-health-monitor/IFU_ECG_US_20211214.pdf
- Dimagi: https://dimagi.atlassian.net/wiki/x/-jPKfw
- Google Design: https://medium.com/google-design/improving-comprehension-through-intuitive-actions-f7e6336e12e6
- Medhi Thies 2015: https://courses.cs.washington.edu/courses/cse490c/18au/readings/medhi-thies-2015.pdf ; 2023 review: https://ideas.repec.org/a/sae/sagope/v13y2023i2p21582440231172741.html
- Medic / CHT: https://medic.org/stories/remote-usability-testing/ , https://docs.communityhealthtoolkit.org/design
- WHO guideline 2019 (summary copy): https://new.aidsdatahub.org/sites/default/files/resource/who-guideline-digital-interventions-health-system-strengthening-2019-summary.pdf
- Touch target: https://support.google.com/accessibility/android/answer/7101858
- WCAG 2.2 Understanding: https://www.w3.org/WAI/WCAG22/Understanding/
- Manchester Triage (SciELO): https://scielo.br/j/rgenf/a/QWdPXZK7RpYsvCPwKbFDBrd/?lang=en
- Colour vision deficiency: https://www.scielo.org.za/pdf/aveh/v84n1/24.pdf
- Russian text expansion: https://gameworldobserver.com/2016/06/20/localization_guidelines , https://www.ata-divisions.org/SLD/localizing-into-russian/
- Fonts (glyph test files): https://github.com/google/fonts (ofl/inter, ofl/notosans, ofl/roboto, ofl/rubik)
