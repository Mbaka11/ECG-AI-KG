# 06 - Existing solutions: AI ECG interpretation (photo-based, low-resource)

Date of research: 2026-10-29. Method: web search plus reading of vendor and primary pages. Vendor claims are marketing unless a peer-reviewed paper is cited. Status labels: **Verified** (source page read), **Partly verified** (seen only in a search snippet or a vendor-only claim), **Unverified** (not found or not checked).
I did not re-read the project spec or PLAN.md for this note. The context comes from the task brief.

## Summary

- **PMcardio (Powerful Medical, Slovakia) is the closest competitor and a direct threat to the "photo of paper ECG, then AI" idea.** It takes a smartphone photo of a 12-lead paper ECG and is free for 5 ECGs per month. It lists AF/flutter, SVT/VT, sinus brady/tachy, LBBB/RBBB, 2nd/3rd-degree AV block and STEMI/STEMI equivalents, and it has CE MDR Class IIb and FDA De Novo status for the Queen of Hearts module. (Verified: vendor pages.)
- PMcardio is **online only** (as far as found), has no Russian or Kyrgyz UI that I could verify, and is a paid subscription beyond the free tier (10 EUR/month for individuals). It also has no MoH integration or urgency-plus-action-steps output of the kind we plan. Offline use was **not found**, and that is an absence of evidence rather than proof.
- **Peer-reviewed evidence for photo-based ECG AI exists but is thin outside PMcardio and ECG Buddy.** Phone photos are measurably worse than scans (SNR about 10-12 dB versus 19.7 dB in one open-source study). A 2025 paper reports digitisation in under 7 s on the PMcardio image database (6,000 images). (Partly verified: search summaries, not full papers.)
- **Open-source building blocks exist.** The PhysioNet/CinC 2024 Challenge produced open-source digitisation and classification code. The winning team's paper is on arXiv, and a 2025 npj Digital Medicine paper describes an open-source digitiser. Licences are unchecked.
- **Kyrgyzstan is already moving.** The Ministry of Health announced 200 "Digital FAP" kits from SberMedAI (Russia) with an AI-interpreting ECG machine, integrated with the planned "Sanarip Clinic" EHR (Jan 2025). In March 2026 the director of the National Centre of Cardiology and Therapy described a plan for ECG in any FAP without a doctor, with remote reading by an expert centre. (Verified: SberMedAI and Kabar pages. Procurement status is unknown.)
- **Most low-resource successes are tele-ECG with human over-read** (Tricog in India, Kazakh services). They need connectivity and a digital ECG device, not a photo of paper.
- **Russian AI-ECG products are mostly digital-signal, cloud, hospital-use medical devices.** Example: ISP RAS, registered in Russia (RZN 2024/24366), 11 syndromes, digital 12-channel input only, server requirements 8 cores and 16 GB RAM. None of those I could check does offline photo-to-urgency on a phone.
- **Honest gap assessment:** offline operation, Russian/Kyrgyz language, a free MoH-integrated tool and local validation are real differentiators. The AI classification itself will not beat PMcardio on evidence or regulation. A one-developer team should reuse open digitisation work and treat PMcardio and SberMedAI as potential partners or benchmarks, not just rivals.

## 1. Photo-capable AI ECG products

| Product | Input | What it does | Regulatory status | Evidence (numbers) | Price / model | Offline? | Russian/Kyrgyz? | Kyrgyzstan | Status |
|---|---|---|---|---|---|---|---|---|---|
| **PMcardio / Queen of Hearts** (Powerful Medical) | Phone photo of paper or screen 12-lead, or digital file | 50+ findings: AF/flutter, SVT/VT, sinus brady/tachy, LBBB/RBBB, 2nd/3rd-degree AV block, STEMI/OMI, QTc/PR/QRS, LVEF module | CE MDR Class IIb (EU and UK); FDA Breakthrough designation; FDA De Novo for the Queen of Hearts ACS module announced 2026-09-15. "Not all modules available in every region." | OMI model: AUC 0.938, accuracy 90.9%, sensitivity 80.6%, specificity 93.7% on 18,616 ECGs from 10,543 patients (vendor blog on the EHJ-Digital Health paper). Vendor claims 25+ peer-reviewed studies and 98.3% AF accuracy. | Free 5 ECGs/month; individuals 10 EUR/month (50 ECGs); teams 2,610 EUR/year for 10 users; enterprise on request | Not found; the privacy FAQ implies cloud processing | UI languages not verified | Apps available on Google Play and App Store (regional availability not checked) | Verified (vendor), numbers vendor-reported |
| **ECG Buddy** (ARPI, Korea) | Phone scan or image of 12-lead printout with visible grid, 25 mm/s and 10 mm/mV | 11 rhythm classes plus digital biomarkers (LVEF, shock, MI, HF) | Korea MFDS Class II (licence 24-1179, Jan 2024); CE MDR announced Feb 2026; US status not verified | LVEF paper in a US ED population (PMC12541512): the figures were not read | Free Android app for healthcare staff; hospital licences | Unknown | Unknown | Not checked | Partly verified |
| **ProCordis.AI** | Phone photo | "Educational" structured read (rhythm, axis, blocks, infarction) | Not a medical device: "educational use" | None found | Unknown | Unknown | Unknown | Unknown | Partly verified |
| **MedStata** (Russia) | Photo or PDF of ECG | Recognises indicators and gives a plain-language result for the patient; "not a diagnosis" | Not stated | None found | Unknown | No, likely cloud | Russian | Unknown | Partly verified (snippet) |
| **Qaly / ReadMyECG** | Device or photo ECG | Human technicians read, not AI | n/a | n/a | Pay per read | No | No | n/a | Partly verified |

Not verified: Cardio.ai, ECG.AI (Russian startups), "Кардиокласс", "КардиРу", Cardiomarker. I found no reliable pages for them, so I make no claims about them. See Open questions.

## 2. Device-based or digital-file AI ECG (not photo)

| Product | Input | Status | Notes | Status label |
|---|---|---|---|---|
| **Philips Cardiologs** | Long-term ambulatory ECG (Holter/patch) in cloud | FDA 510(k) for AF/arrhythmia (first FDA-cleared AI ECG analysis in 2017 per Philips); CE mark | Not a 12-lead photo tool | Verified (vendor and MassDevice) |
| **Anumana** | Digital 12-lead (Mayo Clinic-derived) | FDA 510(k): Low EF (Oct 2023), pulmonary hypertension (K252360, Mar 2026), cardiac amyloidosis (K253801, Apr 2026) | Structural-disease algorithms, not urgent triage | Verified |
| **Idoven Willem** | Digital ECG and long-term recordings | EU MDR Class IIa; 22 patterns plus 4 intervals | Cardiology-as-a-service, B2B | Verified (vendor) |
| **Eko** | Digital stethoscope plus ECG | FDA clearance for Low EF AI (2 Apr 2024) | Not an ECG-paper tool | Verified (vendor) |
| **AliveCor Kardia 12L / KAI 12L** | Proprietary hardware, 5 electrodes | FDA-cleared; 39 determinations (Jan 2026); device listed at $2,295 | Hardware-dependent and costly for rural FAPs | Verified (vendor) |
| **AliveCor Kardia single-lead** | Single-lead device | AF screening. Ethiopian TEFF-AF study (JMIR mHealth 2021) tested it in a semirural African population; metrics not extracted. Dated 2021. | Single-lead cannot see ST changes, blocks or VT well (inference) | Partly verified |
| **Apple Watch ECG** | Single-lead wearable | FDA De Novo, Class II | Consumer AF tool; irrelevant for paper strips | Verified (MedTech Dive) |
| **Tricog InstaECG** (India) | Digital ECG from cloud-connected machines at spokes | Not verified. AI prelim read plus in-house cardiologist over-read. Deployed in tier-I/II towns and villages; hub-and-spoke ACS study in Cureus | Business model: tele-ECG service. Cureus numbers not read (403 on fetch). Marketing: 2.37 million+ patients, 30,540 heart-attack cases (BioSpectrum, vendor-sourced, may be outdated) | Partly verified |
| **SanketLife / Agatsa** (India) | Pocket 12-lead device via phone | CDSCO approval claimed; diagnostic accuracy study vs GE-2000 (PMC7082670, tertiary care, details not extracted) | Device-based, about INR 5,000 | Partly verified |
| **Cardiotrack Pulse** (India) | Handheld 12-lead; AI report signed by a physician in under 60 s | CDSCO licensed (vendor claim) | Report via WhatsApp | Partly verified |

## 3. Russian and Central Asian landscape

| Item | What | Relevance | Status |
|---|---|---|---|
| **SberMedAI "Цифровой ФАП"** | Portable case with an AI-interpreting ECG, blood/urine analysers and a diagnostic-assistant service. In use in 50+ Russian regions. 200 kits planned for Kyrgyzstan (announced 2025-01-28), to integrate with "Sanarip Clinic" EHR | The biggest strategic overlap: same facility type (FAP), same Ministry. Kit hardware is digital ECG, not photo of paper. Contract and delivery status unknown. | Verified (SberMedAI press page citing the MoH KR) |
| **Kyrgyz National Centre of Cardiology and Therapy plan** | ECG in any FAP without a doctor, data sent automatically to an expert centre for remote interpretation (Kabar, 2026-03-26) | Indicates a tele-ECG model with human experts is the MoH's preferred direction. Our app would need to fit or complement it. | Verified (one news item) |
| **ISP RAS ECG classification** | Server-side AI on digital 12-lead signals; Russian registration RZN 2024/24366 (28.12.2024); 11 syndromes (AF, LBBB/RBBB, 1st-degree AV block, sinus tachy/brady, PVC/SVE, axis deviations); for medical staff | Only 1st-degree AV block among the AV blocks, no ACS and no VT, so coverage is narrower than ours. No photo input. | Verified |
| **Webiomed** | A Russian CDSS platform. A registry document (sii.pdf) surfaced but I did not confirm any ECG module | Unverified for ECG | Unverified |
| **Третье Мнение (Third Opinion)** | Moscow AI platform: radiology, monitoring. No ECG product seen on the home page excerpt | Probably not relevant | Partly verified |
| **ECG Reader (ecg-reader.com)** | Russian-language dual-AI CDS; "target class 2b, registration in progress" | Early-stage; no evidence found | Partly verified (snippet) |
| **HealthOS Cardio (rtlab.ru)** | Draft report from ECG; physician signs with a qualified e-signature | Regulated workflow product; no validation data found | Partly verified (snippet) |
| **Kazakhstan: SmartECG, Rhythmus, OHKZ/mobiCARE (Seers)** | Remote ECG over-read by physicians (SmartECG); Holter-based cloud AI plus staff physicians (Rhythmus); wearable patch AI (mobiCARE, contract July 2024) | Central Asian tele-ECG exists but is device-based and mostly human-read. Prices were not found. | Partly verified (landing pages) |
| **Uzbekistan** | General AI/telemedicine strategy documents (ITU submission, presidential proposals) | No specific AI-ECG product found | Unverified |

## 4. Research and open-source work on photo digitisation

| Work | Finding | Status |
|---|---|---|
| Wong et al., *Heart* 2024: "DigitHeart"/phone-photo detection of cardiac conditions | An app pipeline that extracts waveforms from phone photos and feeds downstream algorithms (PubMed 38768982). I could not extract the results. | Partly verified |
| PhysioNet/CinC Challenge 2024 | Digitisation and classification of ECG images. Hidden set about 35.6k images from 1,977 records (as reported by search summary). Open-source entries required; winners' methods are published (e.g. arXiv 2410.14185, Hough transform plus deep learning). | Partly verified |
| Stenhede et al., npj Digit Med 2025/26 (PMC12891466) | Open-source digitiser validated on 37,191 images. SNR 19.65 dB for scans vs 10.47 dB (iPhone) and 12.19 dB (OnePlus). | Partly verified (numbers via search summary) |
| Isaksen et al., J Electrocardiol 2025 | Deep-learning digitisation under 7 s; tested on the PMcardio 6,000-image set (vendor-affiliated page). | Partly verified |
| PRESENT-SHD, JACC 2025 | AUROC 0.924 for structural heart disease from photos of printouts. Different task. | Partly verified |
| ACC 2026 abstract (JACC 2026.02.049) | MobileViT model for VT vs non-VT from phone photos; only 94 images, so very small. | Partly verified |

Takeaway (interpretation): phone photos degrade signal quality. Digitisation-then-classification works, and lightweight models (MobileViT-class) can plausibly run on-device. Labelled data from Kyrgyz paper ECGs is the missing piece.

## 5. Comparison with ECG-AI KG (planned)

| Feature | PMcardio | ECG Buddy | SberMedAI Digital FAP | ISP RAS | Tricog / tele-ECG | **ECG-AI KG (plan)** |
|---|---|---|---|---|---|---|
| Photo of paper ECG | Yes | Yes | No (digital ECG) | No | No | **Yes** |
| Offline | Not found | Unknown | Likely yes on device (unverified) | No (server) | No | **Planned** |
| Russian / Kyrgyz UI | Not verified | Not verified | Russian likely | Russian | English / Indian languages | **RU/KY/EN** |
| Urgency (R/Y/G) plus action steps | No (findings list) | No | Unknown | No | Human report | **Yes** |
| Regulatory | CE IIb, FDA De Novo | MFDS II, CE MDR | Russian registration (unverified for KG) | Russian only | CDSCO (not checked) | **None (research POC)** |
| Peer-reviewed evidence | Substantial | Some | Unknown | Unknown | Real-world study | **None yet** |
| Cost for feldshers | Free 5/month, then 10 EUR | Free app | Government-funded kit | Institutional | Per-ECG fee | **Free** |
| MoH integration | None | None | Sanarip Clinic planned | None | None | **Admin panel planned** |

## Implications for ECG-AI KG

1. **Do not claim novelty in "AI reads a phone photo of an ECG".** PMcardio does this with regulatory clearance and evidence. The differentiators to emphasise are: offline on-device inference, Russian/Kyrgyz UI, urgency tier plus protocol-based action steps, no per-use fee, MoH reporting, and **validation on Kyrgyz paper ECGs**.
2. **Benchmark against PMcardio early.** Its free tier (5 ECGs/month) can serve as a comparator on the POC test set (check terms of use first). If a foreign vendor is clearly better and permissive, a partnership may serve patients better than a new classifier.
3. **Reuse open digitisation research** (PhysioNet 2024 winners, Stenhede 2025). Check licences (unverified) and training data. Do the classification on the signal, plus a lightweight image model as a cross-check.
4. **Align with MoH early.** The MoH is buying SberMedAI kits and planning tele-ECG with an expert centre in Bishkek. Position the app as the paper-ECG fallback for FAPs that have an ordinary printing ECG machine, and as a triage layer that works when the network is down. Check which ECG machines the FAPs actually have.
5. **Scope.** Start with the highest-value, most feasible classes (AF, VT/VF, complete AV block, bundle branch block, brady/tachy). ACS/OMI from a phone photo is the hardest. Show it only as a cautious "possible ischaemia, refer", and never as "normal". (Inference.)
6. **Regulatory realism.** Competitors are CE IIb/FDA. Without clearance, label the app "decision support, research use" and plan a pilot study with ethics approval. A Kyrgyz regulatory path was not researched here.
7. **Safety framing:** the urgency rules must cite an official protocol or a cardiologist review (AGENTS.md). Photo quality gating (reject blurry, cropped or no-grid images) is essential, as ECG Buddy and PMcardio both do.

## Open questions

| Question | Who to ask |
|---|---|
| Does PMcardio work offline? Which UI languages? Is it available in KG? Terms of use for benchmarking? | Check app and vendor FAQ (researcher); contact Powerful Medical if partnering |
| Does the SberMedAI Digital FAP contract with Kyrgyzstan exist? Which ECG machine and AI? Is it photo-capable? | Author or MoH contact |
| What ECG machines do FAPs/CSMs use (digital vs thermal paper, paper widths, layouts)? | Author (field knowledge) |
| Real Tricog and Cureus numbers (sensitivity, turnaround), DigitHeart results | Re-fetch the papers (researcher) |
| Existence and quality of "КардиРу", "Кардиокласс", Cardiomarker, Cardio.ai, ECG.AI | Further web research; low priority |
| Webiomed ECG module; Sber AI-ECG model details | Further research |
| Kyrgyz regulatory status for software as a medical device | Author, MoH |
| Access to labelled Kyrgyz ECGs and cardiologist review for validation | Cardiologist, after POC |
| Licences of open-source digitisation code and datasets | Researcher, before adopting |

## Sources (all accessed 2026-10-29)

- PMcardio home and FAQ: https://www.powerfulmedical.com/ (read in full)
- PMcardio pricing: https://www.powerfulmedical.com/pricing/ (search snippet)
- Queen of Hearts page: https://www.powerfulmedical.com/pmcardio-stemi/ (snippet)
- FDA De Novo announcement: https://www.powerfulmedical.com/blog/powerful-medical-receives-fda-de-novo-authorization-for-pmcardio-queen-of-hearts-its-ai-ecg-model-for-detecting-acute-heart-attacks/ (snippet)
- FDA Breakthrough designation: https://www.powerfulmedical.com/blog/powerful-medical-receives-fda-breakthrough-device-designation-for-pmcardio-stemi-ai-ecg-model/ (snippet)
- OMI validation blog (EHJ-Digital Health): https://www.powerfulmedical.com/blog/european-heart-journal-clinical-validation-study-of-the-pmcardio-omi-ai-model/ (read)
- PMcardio Google Play: https://play.google.com/store/apps/details?id=com.powerfulmedical.pmcardio
- High-precision digitisation: https://www.powerfulmedical.com/research/high-precision-ecg-digitization-using-artificial-intelligence/ and https://www.sciencedirect.com/science/article/abs/pii/S0022073625000287
- ECG Buddy: https://www.ecgbuddy.ai/en ; https://www.arpi.ai/en/products/ecg-buddy ; https://www.arpi.ai/en/news-media/pr/detail/215 ; https://pmc.ncbi.nlm.nih.gov/articles/PMC12541512/ ; https://play.google.com/store/apps/details?hl=en_US&id=ai.arpi.app
- Philips Cardiologs: https://www.usa.philips.com/healthcare/technology/ai-cardiology-solutions ; https://www.massdevice.com/cardiologs-wins-fda-510k-ecg-analysis-platform/
- Anumana: https://anumana.ai/anumana-receives-u-s-fda-510k-clearance-for-ecg-ai-algorithm-to-detect-low-ejection-fraction/ ; https://www.accessdata.fda.gov/cdrh_docs/pdf25/K253801.pdf ; https://www.accessdata.fda.gov/cdrh_docs/pdf25/K252360.pdf
- Idoven: https://www.idoven.ai/
- Eko: https://www.ekohealth.com/blogs/newsroom/fda-clears-low-ejection-fraction-ai
- AliveCor: https://alivecor.com/products/kardia12l ; https://alivecor.com/press/press_release/alivecor-announces-fda-clearance-new-cardiac-determinations-kardia-12l-ecg-system
- Apple Watch ECG: https://www.medtechdive.com/news/new-apple-watch-adds-fda-cleared-ecg-application/532198/
- KardiaMobile in Ethiopia (2021): https://mhealth.jmir.org/2021/5/e24470/
- Tricog: https://www.cureus.com/articles/349742-... (403, not read); https://www.tricog.com/wp-content/uploads/2023/11/Tricog_InstaECG_Whitepaper.pdf ; https://biospectrumindia.com/public/article/pdf/14689
- SanketLife study: https://pmc.ncbi.nlm.nih.gov/articles/PMC7082670/ ; https://www.cardiotrack.io/ecg-device.html
- SberMedAI Digital FAP in Kyrgyzstan: https://sbermed.ai/v-kyrgyzstane-poyavyatsya-cifrovye-fap (read)
- Kabar, 2026-03-26: https://ru.kabar.kg/news/ekg-v-fapah-bez-vracha-ii-pomozhet-vyyavlyat-bolezni-serdca-v-regionah/ (read)
- ISP RAS ECG: https://www.ispras.ru/technologies/ecg/ (read)
- Other Russian: https://ecg-reader.com/ ; https://cardio.rtlab.ru/ru/how/ ; https://medstata.ru/prilozhenie-dlya-rasshifrovki-ekg ; https://thirdopinion.ai/ ; https://webiomed.ru/media/docs/sii.pdf
- Kazakhstan: https://smartecg.kz/ ; https://rhythmus.kz/ ; https://www.ohc.kz/ohkz-implements-mobicare-ecg-analysis-solution/
- Photo research: https://heart.bmj.com/content/heartjnl/110/17/1074.full.pdf ; https://pmc.ncbi.nlm.nih.gov/articles/PMC12891466/ ; https://moody-challenge.physionet.org/2024/ ; https://arxiv.org/html/2410.14185v1 ; https://www.jacc.org/doi/10.1016/j.jacc.2025.01.030 ; https://www.jacc.org/doi/10.1016/j.jacc.2026.02.049 ; https://doi.org/10.22489/cinc.2024.224
- Deprioritised: ProCordis.AI, Qaly, MedStata (marketing pages only).
