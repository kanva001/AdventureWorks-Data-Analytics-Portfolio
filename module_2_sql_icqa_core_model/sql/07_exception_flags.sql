USE AdventureWorks2022;
GO
SET NOCOUNT ON;

IF OBJECT_ID('dbo.vw_kpi_base', 'V') IS NULL OR OBJECT_ID('dbo.kpi_hardened', 'U') IS NULL
BEGIN
    RAISERROR('Required objects missing: dbo.vw_kpi_base and/or dbo.kpi_hardened', 16, 1);
    RETURN;
END;

IF OBJECT_ID('dbo.kpi_exceptions', 'U') IS NOT NULL
    DROP TABLE dbo.kpi_exceptions;

SELECT
    h.ProductID,
    h.LocationID,

    /* Exception flags (based on raw values in base) */
    CASE WHEN b.CountedQty < 0 THEN 1 ELSE 0 END AS EXC_NegativeCountedQty,
    CASE WHEN b.OnHandQty  < 0 THEN 1 ELSE 0 END AS EXC_NegativeOnHandQty,

    CASE WHEN h.AccuracyPct_Hardened < 0 OR h.AccuracyPct_Hardened > 1 THEN 1 ELSE 0 END AS EXC_AccuracyOutOfBounds,

    CASE
        WHEN h.ExpectedQty_Clamped = 0 AND h.CountedQty_Clamped <> 0 THEN 1 ELSE 0
    END AS EXC_ExpectedZeroButCountedNonZero,

    CASE
        WHEN (CASE WHEN b.CountedQty < 0 THEN 1 ELSE 0 END)
           + (CASE WHEN b.OnHandQty  < 0 THEN 1 ELSE 0 END)
           + (CASE WHEN h.ExpectedQty_Clamped = 0 AND h.CountedQty_Clamped <> 0 THEN 1 ELSE 0 END)
        > 0 THEN 1 ELSE 0
    END AS HasException,

    /* Audit columns */
    b.ProductName,
    b.ProductNumber,
    b.LocationName,

    b.OnHandQty  AS Raw_ExpectedQty,     -- expected modeled as OnHandQty
    b.CountedQty AS Raw_CountedQty,
    b.VarianceQty AS Raw_VarianceQty,
    b.AccuracyPct AS Raw_AccuracyPct,

    h.ExpectedQty_Clamped,
    h.CountedQty_Clamped,
    h.VarianceQty_Hardened,
    h.AccuracyPct_Hardened,
    h.HighRiskFlag

INTO dbo.kpi_exceptions
FROM dbo.kpi_hardened h
JOIN dbo.vw_kpi_base b
  ON h.ProductID = b.ProductID
 AND h.LocationID = b.LocationID;

-- Summary
SELECT
    SUM(HasException) AS exception_rows,
    SUM(EXC_NegativeCountedQty) AS neg_counted_qty_rows,
    SUM(EXC_ExpectedZeroButCountedNonZero) AS expected_zero_counted_nonzero_rows
FROM dbo.kpi_exceptions;