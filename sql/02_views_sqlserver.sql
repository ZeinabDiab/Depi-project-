USE egx_db;
GO
CREATE OR ALTER VIEW dbo.vw_daily_kpis AS
SELECT
    p.ticker, c.company_name, p.trade_date,
    p.open_price, p.close_price, p.volume,
    p.high_price - p.low_price AS daily_range,
    (p.close_price / NULLIF(LAG(p.close_price) OVER (PARTITION BY p.ticker ORDER BY p.trade_date),0) - 1) * 100
        AS daily_return_pct
FROM dbo.daily_prices p
JOIN dbo.companies c ON c.ticker = p.ticker;
GO
CREATE OR ALTER VIEW dbo.vw_stock_summary AS
SELECT
    ticker, company_name,
    COUNT(*)                 AS trading_days,
    AVG(CAST(volume AS FLOAT)) AS avg_volume,
    STDEV(daily_return_pct)  AS historical_volatility
FROM dbo.vw_daily_kpis
GROUP BY ticker, company_name;
GO
