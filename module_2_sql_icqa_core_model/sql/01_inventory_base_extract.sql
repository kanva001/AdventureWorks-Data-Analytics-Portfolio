/* 
Sprint 2 — SQL ICQA Foundations
01_inventory_base_extract.sql

Purpose:
- Establish the driving dataset at ProductID × LocationID grain
- Enrich with ProductName / ProductNumber / LocationName
- No KPI calcs yet
*/

USE AdventureWorks2022;
GO

WITH base AS (
    SELECT
        pi.ProductID,
        pi.LocationID,
        CAST(pi.Quantity AS int) AS OnHandQty
    FROM Production.ProductInventory pi
)
SELECT
    b.ProductID,
    b.LocationID,
    p.[Name]           AS ProductName,
    p.ProductNumber,
    l.[Name]           AS LocationName,
    b.OnHandQty
FROM base b
JOIN Production.Product  p ON p.ProductID   = b.ProductID
JOIN Production.Location l ON l.LocationID  = b.LocationID
ORDER BY b.ProductID, b.LocationID;