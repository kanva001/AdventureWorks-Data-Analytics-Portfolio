# Spike 2B — SQL KPI Feasibility (Excel ICQA → SQL)

## Objective
Validate that Sprint 1 Excel ICQA KPI logic can be reproduced in SQL at SKU × Location grain using AdventureWorks.

## Approach
- Use Production.ProductInventory as the driving fact table
- Deterministically simulate CountedQty to enable reproducible KPI validation
- Compute VarianceQty, AccuracyPct, and HighRiskFlag in SQL
- Perform minimal QA checks (grain, bounds)

## Scripts Produced
- sql/01_inventory_base_extract.sql
- sql/02_kpi_calculations.sql
- sql/03_high_risk_logic.sql

## Validation Checks
- Grain check: total rows = distinct ProductID × LocationID
- Accuracy bounds check: out_of_bounds count captured

## Findings
- (Fill after running scripts)

## Decision
Proceed to Sprint 2 delivery scripts and reconciliation against Sprint 1 Excel outcomes.