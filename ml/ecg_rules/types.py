from __future__ import annotations

from dataclasses import dataclass, field
from enum import IntEnum


class Urgency(IntEnum):
    """Ordered so that max() gives the most urgent. GREY is 'cannot interpret'."""
    GREEN = 0
    YELLOW = 1
    RED = 2
    GREY = 3  # produced only by aggregate() when the quality gate fails


@dataclass(frozen=True)
class RuleResult:
    rule: str
    triggered: bool
    finding: str            # English source string
    urgency: Urgency        # urgency if triggered (GREEN when not)
    evidence: dict = field(default_factory=dict)
    thresholds: dict = field(default_factory=dict)   # threshold name -> value used
    source: str = ""        # citation or PENDING_REVIEW note
