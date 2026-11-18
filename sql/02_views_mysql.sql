USE egx_db;

CREATE OR REPLACE VIEW vw_daily_kpis AS
SELECT
    p.ticker, c.company_name, p.trade_date,
    p.open_price, p.close_price, p.volume,
    p.high_price - p.low_price AS daily_range,
    (p.close_price / LAG(p.close_price) OVER (PARTITION BY p.ticker ORDER BY p.trade_date) - 1) * 100
        AS daily_return_pct
FROM daily_prices p
JOIN companies c ON c.ticker = p.ticker;

CREATE OR REPLACE VIEW vw_stock_summary AS
SELECT
    ticker, company_name,
    COUNT(*)              AS trading_days,
    AVG(volume)           AS avg_volume,
    STDDEV(daily_return_pct) AS historical_volatility
FROM vw_daily_kpis
GROUP BY ticker, company_name;
