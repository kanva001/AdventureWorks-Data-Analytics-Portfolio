# Sprint 5 — Power BI Executive & Operations Dashboard

## Sprint Objective
Deliver a production-ready Power BI dashboard that presents ICQA inventory accuracy metrics at multiple decision levels.

Sprint 5 focuses on **presentation, consumption, and decision usability**, not metric invention.

---

## Scope Delivered

### Executive Overview (Leadership View)
- Weighted Inventory Accuracy KPI
- High-Risk Exposure Percentage
- Data Quality Exception Rate
- Inventory Accuracy by Location (aggregated, non-operational view)

**Designed for executive consumption**, emphasizing:
- Signal over noise
- Correct aggregation
- Immediate risk awareness

---

### Operations Exception View (Ops View)
- SKU × Location grain exception table
- Explicit `HighRiskFlag = Y` filtering
- Worst-accuracy records surfaced first
- Conditional formatting driven by `AccuracyPct` thresholds
- On-hand, counted, variance, and accuracy metrics aligned to SQL logic

Supports ICQA analysts and operations teams in **root-cause investigation**.

---

## Semantic Model Design
- Dedicated `_Measures` table created to isolate business logic
- All KPI measures defined explicitly (no implicit aggregation)
- Fact table (`kpi_hardened`) maintained at SKU × Location grain
- Dimension tables used strictly for enrichment

This ensures:
- Predictable aggregation behavior
- Reusable KPI definitions
- Clear ownership of calculation logic

---

## Data Quality & Governance Controls
- Accuracy bounded between 0 and 1
- Negative counted quantity exceptions explicitly flagged
- High-risk exposure quantified and tracked
- Visual logic aligned with SQL validation outputs

---

## Outcome
Sprint 5 completes the analytical delivery pipeline by translating validated SQL ICQA metrics into an **executive-ready and operations-usable Power BI dashboard**, suitable for leadership review, operational monitoring, and audit discussion.