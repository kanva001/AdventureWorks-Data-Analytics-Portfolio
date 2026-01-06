/*
03_high_risk_logic.sql

Purpose:
- Classify high-risk SKU×Location rows using rules aligned to ICQA thinking
- Deterministic flags for validation & pivoting
*/

USE AdventureWorks2022;
GO

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
        END AS AccuracyPct
    FROM sim s
),
flag AS (
    SELECT
        k.*,
        CASE
            /* High-risk if absolute variance is meaningful OR accuracy drops below threshold */
            WHEN ABS(k.VarianceQty) >= 3 THEN 'Y'
            WHEN k.AccuracyPct < 0.98 THEN 'Y'
            ELSE 'N'
        END AS HighRiskFlag
    FROM kpi k
)
SELECT
    f.ProductID,
    f.LocationID,
    p.[Name]          AS ProductName,
    p.ProductNumber,
    l.[Name]          AS LocationName,
    f.OnHandQty,
    f.CountedQty,
    f.VarianceQty,
    f.AccuracyPct,
    f.HighRiskFlag
FROM flag f
JOIN Production.Product  p ON p.ProductID  = f.ProductID
JOIN Production.Location l ON l.LocationID = f.LocationID
ORDER BY f.HighRiskFlag DESC, f.ProductID, f.LocationID;