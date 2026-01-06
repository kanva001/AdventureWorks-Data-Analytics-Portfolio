USE AdventureWorks2022;
GO

IF OBJECT_ID('dbo.vw_kpi_base', 'V') IS NOT NULL
    DROP VIEW dbo.vw_kpi_base;
GO

CREATE VIEW dbo.vw_kpi_base
AS
SELECT
    pi.ProductID,
    pi.LocationID,
    p.[Name] AS ProductName,
    p.ProductNumber,
    l.[Name] AS LocationName,

    CAST(pi.Quantity AS int) AS OnHandQty,

    ((pi.ProductID + pi.LocationID) % 11) - 5 AS VarianceQty,

    CAST(pi.Quantity AS int)
        + (((pi.ProductID + pi.LocationID) % 11) - 5) AS CountedQty,

    CAST(
        CASE
            WHEN CAST(pi.Quantity AS int) = 0 THEN 1.0
            ELSE 1.0 - (ABS((((pi.ProductID + pi.LocationID) % 11) - 5)) * 1.0
                        / NULLIF(CAST(pi.Quantity AS int), 0))
        END
        AS decimal(10,6)
    ) AS AccuracyPct,

    CASE
        WHEN ABS((((pi.ProductID + pi.LocationID) % 11) - 5)) >= 3 THEN 'Y'
        WHEN
            CASE
                WHEN CAST(pi.Quantity AS int) = 0 THEN 1.0
                ELSE 1.0 - (ABS((((pi.ProductID + pi.LocationID) % 11) - 5)) * 1.0
                            / NULLIF(CAST(pi.Quantity AS int), 0))
            END < 0.98 THEN 'Y'
        ELSE 'N'
    END AS HighRiskFlag
FROM Production.ProductInventory pi
JOIN Production.Product  p ON p.ProductID  = pi.ProductID
JOIN Production.Location l ON l.LocationID = pi.LocationID;
GO