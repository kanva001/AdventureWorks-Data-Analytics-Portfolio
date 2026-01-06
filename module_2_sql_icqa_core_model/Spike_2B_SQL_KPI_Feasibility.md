# Spike 2B — SQL KPI Feasibility (Excel ICQA → SQL)

## Objective

Validate that Sprint 1 Excel ICQA KPI logic can be reproduced in SQL Server at the **SKU × Location** grain using AdventureWorks, with deterministic calculations and embedded quality controls.

---

## Scope

This spike covers:
- Source table selection and grain enforcement
- Deterministic simulation of `CountedQty` for reproducible KPI testing
- KPI computation in SQL (Variance, Accuracy, High-Risk)
- Minimal QA validation required to proceed with Sprint 2 delivery

---

## Approach

- Use `Production.ProductInventory` as the driving fact table
- Enrich with product and location attributes for reporting only (no aggregation)
- Deterministically simulate `CountedQty` to enable repeatable comparison vs Excel logic
- Compute:
  - `VarianceQty`
  - `AccuracyPct`
  - `HighRiskFlag`
- Run embedded QA checks (grain, bounds, nulls, referential integrity, sanity)

---

## Scripts Produced

- `sql/01_inventory_base_extract.sql`
- `sql/02_kpi_calculations.sql`
- `sql/03_high_risk_logic.sql`
- `sql/04_data_quality_checks.sql`
- `sql/05_reconciliation_vs_excel.sql`

---

## Validation Checks

### Grain Validation
- Confirm one row per `ProductID × LocationID`
- Expected: `total_rows = distinct_grain`

### KPI Safety / Bounds
- AccuracyPct must remain within valid bounds (0–1)
- Divide-by-zero handling must be safe and deterministic

### Data Quality Controls
- Null checks for required fields (ProductID, LocationID, OnHandQty, AccuracyPct, HighRiskFlag)
- Duplicate grain detection (ProductID × LocationID)
- Referential integrity checks against product/location dimensions
- Sanity checks (non-negative quantities, outliers)

---

## Findings (Results Summary)

### Row Counts
- KPI output row count: **1,069**
- Grain validation: **PASS** (`total_rows = distinct_grain = 1,069`)

### Bounds / Nulls / Duplicates
- Accuracy bounds violations: **0** (PASS)
- Required field null issues: **0** (PASS)
- Duplicate grain issues: **0** (PASS)
- Referential integrity issues: **0** (PASS)

### High-Risk Population
- High-risk rows (SKU × Location flagged): **609**
- High-risk percentage of total: **56.97%**

### Notable Warning (Non-Blocking)
- Sanity check surfaced **2 rows** with negative simulated `CountedQty` (WARN)
- Interpretation:
  - Caused by deterministic simulation logic under edge conditions
  - Does not invalidate KPI feasibility
  - Requires constraint handling (e.g., clamp to 0) in the hardening phase

---

## Decisions

- Proceed with Sprint 2 delivery using SQL-based KPI logic at SKU × Location grain
- Treat negative simulated `CountedQty` as a hardening item:
  - Add a non-negative constraint (clamp to 0) in Sprint 3 quality hardening
- Continue reconciliation pattern to maintain parity with Sprint 1 KPI intent

---

## Definition of Done — Spike 2B

This spike is considered complete when:
- Core KPI logic is reproducible in SQL at SKU × Location grain
- Grain validation passes (`total_rows = distinct_grain`)
- Accuracy bounds check passes (0 violations)
- Null, duplicate, and RI checks meet expected thresholds
- Risks and follow-up hardening items are explicitly documented

Status: Complete