# ADR 0002 — Android first

Status: accepted (2026-11-04, default; revisable) · Phase 2

## Context
Android is 70–84 % of phones in Kyrgyzstan, led by Xiaomi and Samsung
([research 02](../research/02-kyrgyz-context.md)). Flutter is the proposed UI stack.

## Decision
The MVP targets mid-range Android phones first. Keep the code cross-platform (Flutter) so iOS
is possible later, but do not test or optimise for iOS in the MVP. The POC (Phase 3) is not a
mobile app, so this affects Phase 4 only.

## Consequences
Smaller test matrix; on-device inference via LiteRT. Revisit if the pilot partner mandates iOS.
