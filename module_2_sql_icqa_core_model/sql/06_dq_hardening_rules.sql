USE AdventureWorks2022;
GO
SET NOCOUNT ON;

IF OBJECT_ID('dbo.vw_kpi_base', 'V') IS NULL
BEGIN
    RAISERROR('Required object missing: dbo.vw_kpi_base', 16, 1);
    RETURN;
END;

IF OBJECT_ID('dbo.kpi_hardened', 'U') IS NOT NULL
    DROP TABLE dbo.kpi_hardened;

SELECT
    k.ProductID,
    k.LocationID,
    k.ProductName,
    k.ProductNumber,
    k.LocationName,

    -- Raw values from base
    k.OnHandQty,
    k.CountedQty,
    k.VarianceQty,
    k.AccuracyPct,
    k.HighRiskFlag,

    /* -----------------------------
       Hardening: clamp negatives
       ExpectedQty is modeled as OnHandQty in this KPI design
       ----------------------------- */
    CASE WHEN k.OnHandQty  < 0 THEN 0 ELSE k.OnHandQty  END AS ExpectedQty_Clamped,
    CASE WHEN k.CountedQty < 0 THEN 0 ELSE k.CountedQty END AS CountedQty_Clamped,

    /* Hardened variance based on clamped values */
    (CASE WHEN k.CountedQty < 0 THEN 0 ELSE k.CountedQty END)
      - (CASE WHEN k.OnHandQty < 0 THEN 0 ELSE k.OnHandQty END)
      AS VarianceQty_Hardened,

    /* -----------------------------
       AccuracyPct hardened (0..1)
       Accuracy = 1 - ABS(Variance) / Expected
       where Expected = OnHandQty (clamped)
       ----------------------------- */
    CASE
        WHEN (CASE WHEN k.OnHandQty < 0 THEN 0 ELSE k.OnHandQty END) = 0
             AND (CASE WHEN k.CountedQty < 0 THEN 0 ELSE k.CountedQty END) = 0
            THEN CAST(1.0 AS DECIMAL(10,6))
        WHEN (CASE WHEN k.OnHandQty < 0 THEN 0 ELSE k.OnHandQty END) = 0
             AND (CASE WHEN k.CountedQty < 0 THEN 0 ELSE k.CountedQty END) <> 0
            THEN CAST(0.0 AS DECIMAL(10,6))
        ELSE
        (
            SELECT CAST(
                CASE
                    WHEN raw_acc < 0 THEN 0
                    WHEN raw_acc > 1 THEN 1
                    ELSE raw_acc
                END AS DECIMAL(10,6)
            )
            FROM (
                SELECT
                    1.0
                    - (
                        ABS(
                            (
                              (CASE WHEN k.CountedQty < 0 THEN 0 ELSE k.CountedQty END)
                              - (CASE WHEN k.OnHandQty < 0 THEN 0 ELSE k.OnHandQty END)
                            ) * 1.0
                        )
                        / NULLIF((CASE WHEN k.OnHandQty < 0 THEN 0 ELSE k.OnHandQty END) * 1.0, 0.0)
                      ) AS raw_acc
            ) a
        )
    END AS AccuracyPct_Hardened

INTO dbo.kpi_hardened
FROM dbo.vw_kpi_base k;

-- Grain validation
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT CONCAT(ProductID,'-',LocationID)) AS distinct_grain,
    CASE WHEN COUNT(*) = COUNT(DISTINCT CONCAT(ProductID,'-',LocationID)) THEN 'PASS' ELSE 'FAIL' END AS status
FROM dbo.kpi_hardened;