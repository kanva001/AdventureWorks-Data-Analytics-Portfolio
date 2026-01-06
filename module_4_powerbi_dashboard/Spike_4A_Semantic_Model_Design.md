# Spike 4A — Semantic Model Design (Power BI Enablement)

## Objective
Define the governed BI semantic model for ICQA reporting to ensure:
- KPI consistency across stakeholders
- Clear separation of Ops exception workflows vs Leadership signal reporting
- Stable contracts between SQL and Power BI

This spike establishes the model design before PBIX implementation.

---

## Data Contracts (Source of Truth)

### Primary KPI Sources
- `dbo.kpi_hardened`  
  Production-safe KPI dataset at ProductID × LocationID grain.

- `dbo.kpi_exceptions`  
  Exception visibility layer used for Ops triage and quality monitoring.

### Supporting Analytical Contract
- `dbo.vw_kpi_base`  
  Baseline view used for traceability and reconciliation.

---

## Analytical Grain
Mandatory grain for KPI computation and exception reporting:
- ProductID × LocationID

No aggregation is permitted prior to KPI computation.

---

## Model Entities (BI Layer)

### Fact Tables
1) Fact_KPI_Hardened (source: `dbo.kpi_hardened`)
- Primary dataset for KPI reporting
- Used for both Ops and Leadership views (with different filtering/aggregation)

2) Fact_KPI_Exceptions (source: `dbo.kpi_exceptions`)
- Exception queue and audit layer
- Used primarily for Ops workflows and data quality rate metrics

### Dimensions
1) Dim_Product (source: `Production.Product`)
- Key: ProductID
- Attributes: ProductName, ProductNumber, ProductCategory (optional in Sprint 4)

2) Dim_Location (source: `Production.Location`)
- Key: LocationID
- Attributes: LocationName

Optional future dimensions:
- Dim_Date (requires time-series source; not in scope unless inventory snapshots exist)

---

## Relationships (Power BI)
- Fact_KPI_Hardened[ProductID] → Dim_Product[ProductID] (Many-to-one)
- Fact_KPI_Hardened[LocationID] → Dim_Location[LocationID] (Many-to-one)

- Fact_KPI_Exceptions[ProductID] → Dim_Product[ProductID] (Many-to-one)
- Fact_KPI_Exceptions[LocationID] → Dim_Location[LocationID] (Many-to-one)

Cross-filter direction:
- Single direction from dimensions to facts

---

## Measures vs Columns (Governance)

### KPI Columns (from SQL; not recalculated in BI)
- AccuracyPct_Hardened
- VarianceQty_Hardened
- CountedQty_Clamped
- ExpectedQty_Clamped
- HighRiskFlag

Power BI should treat these as authoritative outputs from SQL hardening.

### BI Measures (aggregation layer)
Leadership measures:
- Avg Accuracy Percentage (weighted or simple; decision below)
- High-Risk Exposure Percentage
- Exception Rate

Ops measures:
- Exception Row Count
- High-Risk Row Count
- Worst Accuracy Top N

---

## Aggregation Decisions

### Accuracy Aggregation Policy
Decision required:
- Option A: Simple average of AccuracyPct_Hardened
- Option B: Weighted by ExpectedQty_Clamped (recommended for realism)

Selected for Sprint 4:
- Weighted accuracy (preferred) with fallback to simple average if needed.

Rationale:
- Prevents low-quantity SKUs from distorting location-level accuracy.

---

## Exception Handling Rules (BI)

Ops dashboards:
- Surface exceptions explicitly (HasException = 1)
- Allow drill-down to raw vs clamped values

Leadership dashboards:
- Default to HasException = 0 (signal over noise)
- Show exception rate as a separate KPI to retain transparency

No silent suppression:
- Exceptions are filtered intentionally and documented.

---

## Dashboard Separation (Consumption Design)

### Ops Dashboard (Execution View)
Primary focus:
- Exception queue
- Worst offenders (low accuracy, high variance)
- High-risk inventory positions by location
- Drill-through to SKU × Location details

### Leadership Dashboard (Oversight View)
Primary focus:
- Accuracy trend / distribution by location
- High-risk exposure by location
- Exception rate (as a governance indicator)
- Minimal row-level detail

---

## Risks & Mitigations

Risk: Incorrect relationships causing duplication
- Mitigation: Validate cardinality and totals against SQL aggregates

Risk: Recomputing KPIs in BI causing drift vs SQL
- Mitigation: KPIs remain SQL-authored; BI only aggregates

Risk: Over-filtering exceptions hiding quality issues
- Mitigation: Exception rate KPI displayed alongside leadership metrics

---

## Definition of Done — Spike 4A
This spike is complete when:
- Facts, dimensions, grain, and relationships are documented
- Measure policy (accuracy aggregation) is decided
- Exception handling rules are defined
- Ops vs Leadership consumption model is explicit

Status: Complete