# Translation Notes

The original specification is in Russian:
`original/ECG-AI_KG_TS_RU_original.docx` (original file name:
`ЭКГ-ИИ ТЗ и обоснование для МЗ КР.docx` — "ECG-AI: Technical Specification and Rationale
for the MoH KR"). Document metadata author: ~~██████ ████████████~~ (redacted for privacy, also in the
original file's metadata; the document content is unchanged).

The English (`en/`) and French (`fr/`) versions are **translations only**: same content,
same structure, same layout. Nothing was added, removed or corrected, except:

- **Abbreviation expansions** in parentheses at first use (e.g. "FAPs (feldsher-midwife
  posts)"), because the Russian abbreviations are not known outside the region.
- **Number formatting** adapted to each language (EN `98–99.4%`, `21,837`; FR `98–99,4 %`,
  `21 837`).
- Proofing language of the Word files set to en-GB / fr-FR.

Known items kept as in the original (to be checked during research, not in the translation):
- PTB-XL size "21,837 ECGs" (this is the count of PTB-XL v1.0.1; later versions list 21,799).
- Source "МСС КР, 2022–2026" is transliterated as "MSS KR" — meaning unknown, see
  `../OPEN_QUESTIONS.md`.

## Abbreviations

| Russian | English | French | Meaning |
|---|---|---|---|
| ЭКГ-ИИ | ECG-AI | ECG-IA | Project name (ECG + artificial intelligence) |
| ТЗ | TS | CdC | Technical specification / cahier des charges |
| КР | KR | RK | Kyrgyz Republic / République kirghize |
| МЗ КР | MoH KR | MS RK | Ministry of Health of the Kyrgyz Republic |
| ССЗ | CVD | MCV | Cardiovascular diseases |
| АГ | arterial hypertension | hypertension artérielle | — |
| ОКС | ACS | SCA | Acute coronary syndrome |
| ВОП | GP | MG | General practitioner (врач общей практики) |
| ФАП | FAP | FAP | Feldsher-midwife post (фельдшерско-акушерский пункт), rural primary care point |
| ЦСМ | CFM | CMF | Centre of Family Medicine (центр семейной медицины) |
| ПМСП | PHC | SSP | Primary health care |
| НЦКиТ | NCCIM | CNCMI | National Center of Cardiology and Internal Medicine |
| КГМА | KSMA | AMEK | Kyrgyz State Medical Academy |
| Нацстатком | NSC | CNS | National Statistical Committee of the KR |
| ИМН | medical device | dispositif médical | Изделие медицинского назначения |
| ЧСС | heart rate | fréquence cardiaque | — |
| БЛНПГ / БПНПГ | LBBB / RBBB | BBG / BBD | Left / right bundle branch block |
| АВ-блокада | AV block | bloc AV | Atrioventricular block |
| ПРООН | UNDP | PNUD | United Nations Development Programme |
| ВОЗ | WHO | OMS | World Health Organization |
| МОУ | MoU | protocole d'accord | Memorandum of understanding |

"Feldsher" (фельдшер) is kept as is in both languages: a mid-level health worker with no
exact Western equivalent.

## Rebuilding

The translation strings live in `tools/spec-translation/translations.py`.
`python tools/spec-translation/build.py --pdf` regenerates the `.docx`, `.md` and `.pdf`
files (PDF export needs Microsoft Word on Windows).
