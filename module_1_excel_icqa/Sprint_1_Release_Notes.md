# Sprint 1 Release Notes  
**Sprint 1 — Excel ICQA KPI Model & Dashboard Delivery**

---

## Sprint Objective

Sprint 1 focused on designing and delivering a validated Excel-based ICQA analytical model to establish trusted KPI logic, enforce analytical grain, and surface inventory risk signals prior to downstream SQL and BI implementation.

Excel was intentionally used as a modeling and validation layer, not as a final reporting solution.

---

## Scope Delivered

### ICQA Analytical Model
- Defined SKU × Location as the enforced analytical grain
- Built a normalized Excel data model using structured tables
- Ensured one row per ProductID × LocationID combination
- Eliminated duplication and implicit aggregation risks

---

### KPI Calculations

The following KPIs were implemented and validated:

- On-Hand Quantity  
- Counted Quantity  
- Variance Quantity  
- Inventory Accuracy Percentage  
- High-Risk Flag (rule-based classification)

All KPI formulas were reviewed for correctness, consistency, and edge-case behavior.

---

### Data Quality & Control Checks

Embedded control logic was implemented to validate model integrity:

- Grain validation (duplicate SKU × Location detection)
- Accuracy bounds checks (0–100 percent)
- Null and missing value detection
- Variance sanity checks
- High-risk population monitoring

All critical controls met expected thresholds, confirming analytical soundness.

---

### Dashboard Outputs

An Excel dashboard was delivered to support operational review and prioritization:

- Inventory accuracy percentage by location
- High-risk SKU counts by location
- Bottom 15 worst-accuracy SKUs
- Executive-level KPI summary layout

All visuals are driven exclusively from validated model outputs.

---

## Key Design Decisions

- Excel positioned as a logic validation and feasibility layer
- KPI calculations kept transparent and testable
- Control checks implemented alongside KPIs
- Visuals sourced only from validated pivot outputs
- No manual overrides or hardcoded values

---

## Risks Identified

- Risk of KPI distortion if analytical grain is not enforced
- Risk of silent failures without explicit control checks
- Risk of misinterpretation without documented logic

Each risk was mitigated through enforced grain, embedded controls, and documentation.

---

## Definition of Done — Sprint 1

Sprint 1 is considered complete when:

- Analytical grain is enforced and validated
- KPI calculations are implemented and tested
- Control checks meet expected thresholds
- Dashboard reflects validated model outputs
- Test evidence is captured and stored

All acceptance criteria have been met.

---

## Next Phase

Sprint 2 transitions the validated Excel model into SQL Server to enable:

- Scalable KPI computation
- Embedded SQL-based quality controls
- Reconciliation against Excel outputs
- Readiness for Power BI consumption

---

## Artifacts

- Excel_ICQA_KPI_Model.xlsx  
- Sprint_1_Test_Evidence/  
- Sprint_1_Release_Notes.md