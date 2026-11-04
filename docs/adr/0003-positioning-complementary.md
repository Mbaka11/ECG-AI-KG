# ADR 0003 — Positioning: complementary to MoH/NCCIM programmes

Status: accepted (2026-11-04, default; revisable) · Phase 2

## Context
The MoH has agreed "Digital FAP" kits with AI-ECG (SberMedAI) and NCCIM plans tele-ECG from
FAPs; PMcardio is a regulated photo-based competitor
([research 02](../research/02-kyrgyz-context.md), [06](../research/06-existing-solutions.md)).

## Decision
ECG-AI KG is an offline, free, Russian/Kyrgyz assistant that reads the paper ECGs FAPs
already print, gives an urgency level and protocol-based next steps, and can forward a case
to a tele-ECG centre. It is decision support, never a diagnosis, and is framed as research
until regulatory steps are done. We do not compete with or duplicate MoH programmes; contact
NCCIM only via the cardiologist after the POC.

## Consequences
Spec v2 must include a "forward to expert" path and avoid replacement claims.
