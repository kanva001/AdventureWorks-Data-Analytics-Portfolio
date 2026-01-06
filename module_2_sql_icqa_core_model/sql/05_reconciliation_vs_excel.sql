/*
05_reconciliation_vs_excel.sql

Purpose:
Reconciliation/controls layer for Sprint 2.
Creates KPI control metrics similar to Sprint 1 Excel controls:
- Grain validation
- Accuracy bounds
- High-risk counts
- Negative CountedQty anomalies
- Summary by Location (optional ops slice)

Notes:
- CountedQty is simulated deterministically for feasibility validation.
*/

USE AdventureWorks2022;
GO

SET NOCOUNT ON;

IF OBJECT_ID('tempdb..#kpi') IS NOT NULL DROP TABLE #kpi;

/* ========= Build KPI dataset once ========= */
SELECT
    pi.ProductID,
    pi.LocationID,
    p.[Name] AS ProductName,
    p.ProductNumber,
    l.[Name] AS LocationName,
    CAST(pi.Quantity AS int) AS OnHandQty,
    ((pi.ProductID + pi.LocationID) % 11) - 5 AS VarianceQty,
    CAST(pi.Quantity AS int) + (((pi.ProductID + pi.LocationID) % 11) - 5) AS CountedQty,
    CAST(
        CASE
            WHEN CAST(pi.Quantity AS int) = 0 THEN 1.0
            ELSE 1.0 - (ABS((((pi.ProductID + pi.LocationID) % 11) - 5)) * 1.0 / NULLIF(CAST(pi.Quantity AS int), 0))
        END
    AS decimal(10,6)) AS AccuracyPct,
    CASE
        WHEN ABS((((pi.ProductID + pi.LocationID) % 11) - 5)) >= 3 THEN 'Y'
        WHEN
            CASE
                WHEN CAST(pi.Quantity AS int) = 0 THEN 1.0
                ELSE 1.0 - (ABS((((pi.ProductID + pi.LocationID) % 11) - 5)) * 1.0 / NULLIF(CAST(pi.Quantity AS int), 0))
            END < 0.98 THEN 'Y'
        ELSE 'N'
    END AS HighRiskFlag
INTO #kpi
FROM Production.ProductInventory pi
JOIN Production.Product  p ON p.ProductID  = pi.ProductID
JOIN Production.Location l ON l.LocationID = pi.LocationID;

/* ========= CONTROL 1: Grain validation ========= */
SELECT
    'CONTROL_GrainValidation' AS control_name,
    COUNT(*) AS total_rows,
    COUNT(DISTINCT CONCAT(ProductID,'-',LocationID)) AS distinct_grain,
    CASE
        WHEN COUNT(*) = COUNT(DISTINCT CONCAT(ProductID,'-',LocationID)) THEN 'PASS'
        ELSE 'FAIL'
    END AS status
FROM #kpi;

/* ========= CONTROL 2: Accuracy bounds ========= */
SELECT
    'CONTROL_AccuracyBounds' AS control_name,
    SUM(CASE WHEN AccuracyPct < 0 OR AccuracyPct > 1 THEN 1 ELSE 0 END) AS out_of_bounds_count,
    CASE
        WHEN SUM(CASE WHEN AccuracyPct < 0 OR AccuracyPct > 1 THEN 1 ELSE 0 END) = 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS status
FROM #kpi;

/* ========= CONTROL 3: High-risk count ========= */
SELECT
    'CONTROL_HighRiskCount' AS control_name,
    SUM(CASE WHEN HighRiskFlag = 'Y' THEN 1 ELSE 0 END) AS high_risk_rows,
    CAST(100.0 * SUM(CASE WHEN HighRiskFlag = 'Y' THEN 1 ELSE 0 END) / NULLIF(COUNT(*),0) AS decimal(10,2)) AS high_risk_pct
FROM #kpi;

/* ========= CONTROL 4: Negative counted quantity anomalies ========= */
SELECT
    'CONTROL_NegativeCountedQty' AS control_name,
    SUM(CASE WHEN CountedQty < 0 THEN 1 ELSE 0 END) AS negative_counted_rows,
    CASE
        WHEN SUM(CASE WHEN CountedQty < 0 THEN 1 ELSE 0 END) = 0 THEN 'PASS'
        ELSE 'WARN'
    END AS status
FROM #kpi;

/* ========= CONTROL 5: Top 10 worst-accuracy (High-risk only) ========= */
SELECT TOP 10
    'CONTROL_WorstAccuracy_HighRisk' AS control_name,
    ProductName,
    LocationName,
    OnHandQty,
    CountedQty,
    VarianceQty,
    AccuracyPct
FROM #kpi
WHERE HighRiskFlag = 'Y'
ORDER BY AccuracyPct ASC, ABS(VarianceQty) DESC;

/* ========= OPTIONAL OPS SLICE: Location summary ========= */
SELECT
    LocationName,
    CAST(AVG(AccuracyPct) AS decimal(10,6)) AS avg_accuracy,
    SUM(CASE WHEN HighRiskFlag = 'Y' THEN 1 ELSE 0 END) AS high_risk_rows
FROM #kpi
GROUP BY LocationName
ORDER BY avg_accuracy ASC;