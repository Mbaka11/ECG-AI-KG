# Open Questions for the Author

Questions raised while translating and reading the specification. Answers will be recorded
under each question. A Russian version, ready to send, is at the bottom.

Status legend: ⬜ open · ✅ answered · ⏸ parked

## Goals and organisation

1. ⬜ Who is on the team, and what is each person's role? Who decides on scope changes?
2. ⬜ What is the timeline (school year, admission deadlines, competitions)? Is the 12-month
   roadmap fixed?
3. ⬜ What is expected from us: research, ML prototype, full app, research paper, the MoH
   presentation — or all of them? Which is the priority?
4. ⬜ In which language(s) should the research paper and the MoH documents be written?

## Partners and clinical expertise

5. ⬜ Are there existing contacts at NCCIM, KSMA or the MoH KR? Is a cardiologist available
   to advise and review clinical content?
6. ⬜ Are the MoH KR clinical protocols (ACS, arrhythmias) available? The "action
   algorithms" in the app must follow them.

## Field context

7. ⬜ Which ECG machines are used in FAPs/CFMs (models, number of channels, paper layout,
   e.g. 3×4, 6×2, 12×1)? Can any of them export a digital file instead of paper?
8. ⬜ Which phones do feldshers use (Android/iOS, typical model), and what is the internet
   coverage at the target sites?
9. ⬜ Can we get sample photos of real ECG strips (anonymised) — even a few — early on?

## Data and validation

10. ⬜ Is there a realistic way to obtain anonymised Kyrgyz ECGs with cardiologist reports
    for testing? Under which consent / ethics approval?

## Technical choices

11. ⬜ Is the proposed stack (Flutter, FastAPI, YOLOv11, CNN + BiLSTM, TensorFlow Lite,
    React + PostgreSQL) a requirement or a suggestion? Note: Ultralytics YOLO is licensed
    AGPL-3.0.
12. ⬜ Is the administrative panel part of the first MVP?
13. ⬜ Is there a budget for hosting (Google Cloud or other)?

## Document details

14. ⬜ What does the source "МСС КР, 2022–2026" refer to (full name / link)?
15. ⬜ Can you share the links for the cited sources (European Heart Journal 2024, IJMEDRI
    2024, Nature 2024/2025, World Bank PHC report, NCCIM, National Statistical Committee)?

## Repository

16. ⬜ Should the GitHub repository be public now or later? Which open-source licence
    (e.g. MIT, Apache-2.0)?

---

## Версия на русском (для отправки)

**Цели и организация**
1. Кто входит в команду и какова роль каждого? Кто принимает решения об изменении объёма проекта?
2. Каковы сроки (учебный год, дедлайны поступления, конкурсы)? Является ли 12-месячная дорожная карта фиксированной?
3. Что ожидается от нас: исследование, ML-прототип, полноценное приложение, научная работа, презентация для МЗ — или всё вместе? Что в приоритете?
4. На каком языке (языках) должны быть научная работа и документы для МЗ?

**Партнёры и клиническая экспертиза**
5. Есть ли уже контакты в НЦКиТ, КГМА или МЗ КР? Есть ли кардиолог, который может консультировать и проверять клиническое содержание?
6. Доступны ли клинические протоколы МЗ КР (ОКС, аритмии)? «Алгоритмы действий» в приложении должны им соответствовать.

**Условия на местах**
7. Какие аппараты ЭКГ используются в ФАП/ЦСМ (модели, число каналов, формат плёнки, например 3×4, 6×2, 12×1)? Может ли какой-либо из них выгружать цифровой файл вместо бумаги?
8. Какие телефоны у фельдшеров (Android/iOS, типичная модель) и какое покрытие интернета в целевых учреждениях?
9. Можно ли на раннем этапе получить несколько (обезличенных) фотографий реальных ЭКГ-плёнок?

**Данные и валидация**
10. Есть ли реальная возможность получить обезличенные кыргызские ЭКГ с заключениями кардиолога для тестирования? На основании какого согласия / одобрения этического комитета?

**Технические решения**
11. Предложенный стек (Flutter, FastAPI, YOLOv11, CNN + BiLSTM, TensorFlow Lite, React + PostgreSQL) — обязательное требование или предложение? Примечание: Ultralytics YOLO распространяется по лицензии AGPL-3.0.
12. Входит ли административная панель в первую версию MVP?
13. Есть ли бюджет на хостинг (Google Cloud или другой)?

**Детали документа**
14. Что означает источник «МСС КР, 2022–2026» (полное название / ссылка)?
15. Можете ли вы поделиться ссылками на цитируемые источники (European Heart Journal 2024, IJMEDRI 2024, Nature 2024/2025, отчёт Всемирного банка по ПМСП, НЦКиТ, Нацстатком)?

**Репозиторий**
16. Сделать репозиторий на GitHub публичным сейчас или позже? Какую open-source лицензию выбрать (например, MIT, Apache-2.0)?
