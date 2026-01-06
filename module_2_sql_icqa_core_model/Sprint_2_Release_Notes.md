# Sprint 2 Release Notes  
**Sprint 2 — SQL ICQA Core Model & KPI Feasibility**

---

## Sprint Objective

Sprint 2 focused on establishing the core SQL analytical model for ICQA reporting and validating that all KPIs defined in Sprint 1 can be reproduced accurately, safely, and at scale in SQL Server.

This sprint bridges exploratory Excel analytics and production-grade reporting by enforcing analytical grain, deterministic KPI logic, and embedded data quality controls.

---

## Scope Delivered

### Core Analytical Model
- Identified `Production.ProductInventory` as the driving fact table
- Enforced ProductID × LocationID as the non-negotiable analytical grain
- Defined join strategy with Product and Location dimensions for enrichment only
- Prevented pre-aggregation prior to KPI calculation

---

### SQL KPI Implementation

The following KPIs were implemented and validated in SQL:

- On-Hand Quantity  
- Counted Quantity (deterministic simulation)  
- Variance Quantity  
- Inventory Accuracy Percentage  
- High-Risk Flag (rule-based classification)

All calculations were validated for mathematical safety and consistency with Sprint 1 logic.

---

### High-Risk Classification

- Implemented deterministic high-risk logic aligned to ICQA review thresholds
- Validated distribution of high-risk SKU × Location combinations
- Surfaced worst-accuracy positions for operational prioritization

---

### Data Quality & Controls

Embedded SQL-based controls were executed and validated:

- Analytical grain validation
- Accuracy bounds enforcement (0–1)
- Null and missing value checks
- Duplicate grain detection
- Referential integrity validation
- Sanity checks for simulated quantities

All critical controls passed. Non-blocking warnings related to simulated data were documented and intentionally surfaced.

---

## Key Outcomes

- SQL model faithfully reproduces Excel KPI logic
- Analytical grain is explicitly enforced and validated
- High-risk inventory positions are traceable and auditable
- Model is ready for BI-layer consumption

---

## Risks Identified

- Risk of KPI distortion if grain enforcement is bypassed  
- Risk of silent failures without embedded QA controls  
- Risk of edge cases arising from simulated quantities  

Each risk was mitigated through enforced grain, embedded controls, and explicit documentation.

---

## Definition of Done — Sprint 2

Sprint 2 is considered complete when:

- Core SQL analytical model is validated
- KPI logic matches Sprint 1 outputs
- Data quality controls return expected results
- High-risk classification is meaningful and testable

All acceptance criteria have been met.

---

## Next Phase

Sprint 3 will focus on production hardening and BI enablement, including:

- Data quality pack expansion
- Constraint and remediation logic
- Power BI semantic modeling
- Executive and operational dashboards

---

## Artifacts

- sql/01_inventory_base_extract.sql  
- sql/02_kpi_calculations.sql  
- sql/03_high_risk_logic.sql  
- sql/04_data_quality_checks.sql  
- sql/05_reconciliation_vs_excel.sql  
- Sprint_2_Release_Notes.md