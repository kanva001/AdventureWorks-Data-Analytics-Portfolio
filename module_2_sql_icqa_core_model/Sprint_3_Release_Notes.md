# Sprint 3 Release Notes — SQL Hardening & Exception Visibility

## Sprint Objective
Harden Sprint 2 SQL KPI outputs for production-style consumption by enforcing safe calculation rules and making exceptions visible (not silently corrected).

## Scope Delivered
### 1) Stable KPI Contract
- Established `dbo.vw_kpi_base` as the persisted analytical contract at ProductID × LocationID grain
- Enables repeatable downstream processing without relying on temp tables or ad-hoc query output

### 2) Production-Safe KPI Hardening
- Implemented `dbo.kpi_hardened` with defensive logic:
  - Negative quantity clamping for KPI math stability
  - Divide-by-zero safe AccuracyPct computation
  - AccuracyPct bounded to [0,1]
- Preserves ProductID × LocationID grain

### 3) Exception Visibility Layer
- Implemented `dbo.kpi_exceptions` to flag data conditions requiring investigation:
  - Negative CountedQty conditions
  - Expected=0 but Counted≠0 conditions
  - Rollup `HasException` flag for operational triage and BI filtering

## Validation Results
- Grain validation: `total_rows = distinct_grain = 1069` (PASS)
- Exception summary:
  - exception_rows = 4
  - negative counted qty rows = 2
  - expected=0 but counted≠0 rows = 2

## Business Impact
This sprint reduces risk of KPI distortion in downstream reporting by:
- Preventing runtime failures (divide-by-zero, negative values)
- Separating calculation stability from exception handling
- Providing a clear operational queue for follow-up (exception rows)

## Artifacts
- `sql/00_create_kpi_base_view.sql`
- `sql/06_dq_hardening_rules.sql`
- `sql/07_exception_flags.sql`
- `Sprint_3_Test_Evidence/` (screenshots)