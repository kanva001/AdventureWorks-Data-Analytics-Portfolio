# Spike 3A — KPI Hardening & Exception Strategy

## Objective

Define how ICQA KPIs should behave under edge conditions to ensure
production-safe, trustworthy analytics outputs.

This spike establishes **explicit rules** for exception handling,
thresholds, and governance before additional SQL hardening and BI
delivery.

---

## Context

Sprint 2 validated that Excel-based ICQA KPIs can be reproduced in SQL
at the SKU × Location grain.

During validation, several non-blocking edge conditions were surfaced,
including:
- Negative simulated CountedQty values
- High concentration of high-risk rows
- Potential for KPI distortion if edge cases are silently corrected

These conditions must be addressed **deliberately**, not implicitly.

---

## Design Principles

- KPIs must be **safe by default**
- Exceptions must be **visible**, not hidden
- Business rules must be **explicit and documented**
- Hardening should not obscure underlying data quality issues
- Leadership views and Ops views may tolerate different levels of detail

---

## Identified Edge Cases

### 1. Negative CountedQty
**Observed**
- Small number of rows with negative simulated CountedQty

**Risk**
- Negative inventory counts are not meaningful operationally
- Can distort variance and accuracy metrics

**Decision**
- Clamp CountedQty to 0 for KPI calculation
- Preserve original value in an exception flag for visibility

---

### 2. Accuracy Percentage Bounds
**Observed**
- AccuracyPct calculations depend on division logic

**Risk**
- Divide-by-zero or extreme variance can push values outside valid range

**Decision**
- Enforce AccuracyPct bounds between 0 and 1
- Any out-of-bounds values must:
  - Be flagged
  - Excluded from executive aggregation
  - Included in Ops exception reporting

---

### 3. High-Risk Classification Thresholds
**Observed**
- HighRiskFlag currently driven by variance threshold

**Risk**
- Thresholds may be misinterpreted without documentation
- Over-flagging can reduce signal value

**Decision**
- Retain current threshold for continuity
- Document threshold explicitly
- Revisit thresholds only after BI usage feedback

---

## Governance Rules

| Area | Rule |
|-----|-----|
| Grain | SKU × Location is mandatory |
| Corrections | Never silently overwrite raw values |
| Flags | All corrections must be flagged |
| Aggregation | No aggregation before KPI calculation |
| Visibility | Ops dashboards show flags; Exec dashboards suppress noise |

---

## Impact on Downstream Work

This spike enables:
- SQL hardening rules in Sprint 3
- Consistent BI semantic model
- Clear separation between **data issues** and **metric behavior**
- Auditable analytics suitable for production use

---

## Decisions Summary

- Clamp negative quantities but flag them
- Enforce AccuracyPct bounds with explicit flags
- Preserve raw values for investigation
- Maintain SKU × Location grain throughout
- Separate Ops vs Leadership consumption logic

---

## Definition of Done — Spike 3A

This spike is complete when:
- Exception handling rules are explicitly defined
- KPI correction behavior is documented
- Governance rules are agreed before implementation
- Sprint 3 SQL hardening can proceed without ambiguity

Status: Complete