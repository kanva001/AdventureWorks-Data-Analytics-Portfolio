# Spike 1A — Excel KPI Feasibility & Grain Validation

## Context
This spike supports Sprint 1 of the AdventureWorks Inventory Accuracy & ICQA
Analytics Program by validating KPI feasibility in the Excel layer before
committing to dashboard delivery.

---

## Business Risk
Excel-based KPIs may produce misleading results if:
- Aggregation grain is incorrect
- Filters are inconsistently applied
- KPI logic cannot be reproduced downstream in SQL

---

## Spike Objective
- Confirm required fields exist for Excel KPIs
- Validate aggregation grain (SKU, location)
- Identify Excel-specific constraints or assumptions

---

## KPIs in Scope
- Inventory On-Hand Quantity
- Inventory Variance
- Inventory Accuracy Percentage
- High-Risk SKU Identification

---

## Findings
- Inventory and location data loaded successfully from CSV sources
- SKU + Location grain is supported without duplication
- Quantity values are valid for aggregation in Excel

---

## Decisions
- Proceed with Excel KPI delivery using CSV ingestion
- Maintain SKU + Location grain for Sprint 1
- Defer transactional detail to SQL phase


---

## Impact on Sprint
This spike gates Excel KPI dashboard delivery and reduces rework risk
in Phase 2 (SQL) and Phase 4 (Power BI).