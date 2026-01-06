/*
04_data_quality_checks.sql

Purpose:
SQL QA pack for the KPI dataset at ProductID × LocationID grain.
Includes null checks, duplicate checks, referential integrity, and bounds checks.
*/

USE AdventureWorks2022;
GO

/* ========= KPI Dataset (single source of truth for checks) ========= */
WITH base AS (
    SELECT
        pi.ProductID,
        pi.LocationID,
        CAST(pi.Quantity AS int) AS OnHandQty
    FROM Production.ProductInventory pi
),
sim AS (
    SELECT
        b.*,
        ((b.ProductID + b.LocationID) % 11) - 5 AS VarianceQty
    FROM base b
),
kpi AS (
    SELECT
        s.ProductID,
        s.LocationID,
        s.OnHandQty,
        (s.OnHandQty + s.VarianceQty) AS CountedQty,
        s.VarianceQty,
        CASE
            WHEN s.OnHandQty = 0 THEN 1.0
            ELSE CAST(1.0 - (ABS(s.VarianceQty) * 1.0 / NULLIF(s.OnHandQty,0)) AS decimal(10,6))
        END AS AccuracyPct,
        CASE
            WHEN ABS(s.VarianceQty) >= 3 THEN 'Y'
            WHEN (CASE WHEN s.OnHandQty = 0 THEN 1.0
                       ELSE 1.0 - (ABS(s.VarianceQty) * 1.0 / NULLIF(s.OnHandQty,0))
                  END) < 0.98 THEN 'Y'
            ELSE 'N'
        END AS HighRiskFlag
    FROM sim s
)

/* ========= 1) Null checks ========= */
SELECT 'NULL_CHECK_ProductID' AS check_name, COUNT(*) AS issue_count
FROM kpi WHERE ProductID IS NULL
UNION ALL
SELECT 'NULL_CHECK_LocationID', COUNT(*)
FROM kpi WHERE LocationID IS NULL
UNION ALL
SELECT 'NULL_CHECK_OnHandQty', COUNT(*)
FROM kpi WHERE OnHandQty IS NULL
UNION ALL
SELECT 'NULL_CHECK_AccuracyPct', COUNT(*)
FROM kpi WHERE AccuracyPct IS NULL
UNION ALL
SELECT 'NULL_CHECK_HighRiskFlag', COUNT(*)
FROM kpi WHERE HighRiskFlag IS NULL;

/* ========= 2) Duplicate grain check ========= */
WITH grain AS (
    SELECT ProductID, LocationID, COUNT(*) AS cnt
    FROM kpi
    GROUP BY ProductID, LocationID
)
SELECT 'DUPLICATE_GRAIN_ProductID_LocationID' AS check_name, COUNT(*) AS issue_count
FROM grain
WHERE cnt > 1;

/* ========= 3) Referential integrity checks ========= */
SELECT 'RI_Product_missing' AS check_name, COUNT(*) AS issue_count
FROM kpi k
LEFT JOIN Production.Product p ON p.ProductID = k.ProductID
WHERE p.ProductID IS NULL
UNION ALL
SELECT 'RI_Location_missing', COUNT(*)
FROM kpi k
LEFT JOIN Production.Location l ON l.LocationID = k.LocationID
WHERE l.LocationID IS NULL;

/* ========= 4) Bounds and sanity checks ========= */
SELECT 'BOUNDS_AccuracyPct_outside_0_1' AS check_name, COUNT(*) AS issue_count
FROM kpi
WHERE AccuracyPct < 0 OR AccuracyPct > 1
UNION ALL
SELECT 'SANITY_OnHand_negative', COUNT(*)
FROM kpi
WHERE OnHandQty < 0
UNION ALL
SELECT 'SANITY_Counted_negative', COUNT(*)
FROM kpi
WHERE CountedQty < 0;

/* ========= 5) Summary counts (for release notes) ========= */
SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN HighRiskFlag = 'Y' THEN 1 ELSE 0 END) AS high_risk_rows
FROM kpi;