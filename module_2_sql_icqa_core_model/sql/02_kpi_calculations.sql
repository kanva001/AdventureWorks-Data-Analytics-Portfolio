/*
02_kpi_calculations.sql

Purpose:
- Add deterministic CountedQty simulation
- Compute VarianceQty and AccuracyPct
- Preserve ProductID × LocationID grain
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
        /* Deterministic variance: yields values between -5 and +5 */
        ((b.ProductID + b.LocationID) % 11) - 5 AS SimulatedVarianceQty
    FROM base b
),
kpi AS (
    SELECT
        s.ProductID,
        s.LocationID,
        s.OnHandQty,
        (s.OnHandQty + s.SimulatedVarianceQty) AS CountedQty,
        s.SimulatedVarianceQty                 AS VarianceQty,
        CASE 
            WHEN s.OnHandQty = 0 THEN 1.0
            ELSE CAST(1.0 - (ABS(s.SimulatedVarianceQty) * 1.0 / NULLIF(s.OnHandQty,0)) AS decimal(10,6))
        END AS AccuracyPct
    FROM sim s
)
SELECT
    k.ProductID,
    k.LocationID,
    p.[Name]          AS ProductName,
    p.ProductNumber,
    l.[Name]          AS LocationName,
    k.OnHandQty,
    k.CountedQty,
    k.VarianceQty,
    k.AccuracyPct
FROM kpi k
JOIN Production.Product  p ON p.ProductID  = k.ProductID
JOIN Production.Location l ON l.LocationID = k.LocationID
ORDER BY k.ProductID, k.LocationID;