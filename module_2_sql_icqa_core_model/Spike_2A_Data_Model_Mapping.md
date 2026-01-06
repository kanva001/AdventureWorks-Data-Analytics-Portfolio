# Spike 2A — Data Model Mapping (Excel ICQA → SQL)

## Sprint
Sprint 2 — SQL ICQA Foundations

## Spike Objective
Establish a clear and defensible mapping between the validated Excel ICQA KPI model (Sprint 1) and the AdventureWorks OLTP schema.

This spike ensures:
- Correct grain alignment
- Correct table selection
- No accidental duplication or aggregation
- A stable foundation for SQL-based KPI calculations

This spike must be completed before any KPI SQL logic is written.

---

## Target Analytical Grain

**1 row = 1 ProductID × 1 LocationID**

All SQL queries in Sprint 2 must preserve this grain.
Any deviation from this grain invalidates KPI results.

---

## Core AdventureWorks Tables

### Production.Product
**Purpose:** SKU master data

Key columns:
- ProductID (Primary Key)
- Name (ProductName)
- ProductNumber

Usage:
- Product identification
- Product-level attributes
- Display purposes only (no aggregation)

---

### Production.Location
**Purpose:** Inventory location master

Key columns:
- LocationID (Primary Key)
- Name (LocationName)

Usage:
- Location identification
- Location-level grouping
- Display purposes only

---

### Production.ProductInventory
**Purpose:** On-hand inventory fact table

Key columns:
- ProductID
- LocationID
- Quantity

Important notes:
- Table is already at ProductID × LocationID grain
- No aggregation required before KPI calculation
- This table will drive all inventory KPIs

---

## Excel → SQL Field Mapping

| Excel KPI Field | SQL Source Table | SQL Column / Logic | Notes |
|-----------------|------------------|--------------------|-------|
| ProductID | Production.Product | ProductID | SKU identifier |
| ProductName | Production.Product | Name | Display only |
| LocationID | Production.Location | LocationID | Location key |
| LocationName | Production.Location | Name | Display only |
| OnHandQty | Production.ProductInventory | Quantity | Current on-hand quantity |
| CountedQty | Derived (SQL simulation) | Quantity ± simulated variance | ICQA count simulation |
| VarianceQty | Calculated | CountedQty - OnHandQty | KPI |
| AccuracyPct | Calculated | 1 - ABS(VarianceQty) / NULLIF(OnHandQty, 0) | KPI |
| HighRiskFlag | Calculated | Threshold-based logic | KPI classification |

---

## Design Decisions & Assumptions

- `Production.ProductInventory` is the driving fact table
- All joins must preserve ProductID × LocationID grain
- No aggregation is allowed before KPI calculation
- CountedQty will be simulated in SQL to mirror Excel validation logic
- AccuracyPct calculations must handle divide-by-zero safely
- Product and Location tables are used for enrichment only

---

## Grain Validation Query

The following query validates that `Production.ProductInventory` conforms to the required analytical grain.

```sql
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT CONCAT(ProductID, '-', LocationID)) AS distinct_grain
FROM Production.ProductInventory;
```

## Expected Result

- `total_rows = distinct_grain`

If these values do not match, the data model must be investigated before proceeding.

## Risks Identified

- Risk of accidental aggregation when joining dimension tables  
- Risk of duplication if joins are not constrained correctly  
- Risk of KPI distortion if analytical grain is not enforced consistently  

## Definition of Done — Spike 2A

This spike is considered complete when:
- Data model mapping is fully documented
- Target analytical grain is explicitly defined
- Core tables and join strategy are validated
- Grain validation query returns expected results