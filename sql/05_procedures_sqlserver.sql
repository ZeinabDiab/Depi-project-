USE egx_db;
GO
-- EXEC dbo.sp_top_movers @date='2026-11-18', @n=5;
CREATE OR ALTER PROCEDURE dbo.sp_top_movers @date DATE, @n INT = 5
AS
BEGIN
  SET NOCOUNT ON;
  SELECT TOP (@n) 'Top Gainers' AS category, ticker, company_name, close_price, ROUND(daily_return_pct,2) AS return_pct
  FROM dbo.vw_daily_kpis WHERE trade_date = @date AND daily_return_pct IS NOT NULL
  ORDER BY daily_return_pct DESC;

  SELECT TOP (@n) 'Top Losers' AS category, ticker, company_name, close_price, ROUND(daily_return_pct,2) AS return_pct
  FROM dbo.vw_daily_kpis WHERE trade_date = @date AND daily_return_pct IS NOT NULL
  ORDER BY daily_return_pct ASC;
END;
GO
-- EXEC dbo.sp_stock_report @ticker='COMI.CA', @start='2026-10-01', @end='2026-11-18';
CREATE OR ALTER PROCEDURE dbo.sp_stock_report @ticker VARCHAR(20), @start DATE, @end DATE
AS
BEGIN
  SET NOCOUNT ON;
  SELECT @ticker AS ticker,
         COUNT(*)                          AS trading_days,
         MIN(close_price)                  AS min_close,
         MAX(close_price)                  AS max_close,
         ROUND(AVG(CAST(volume AS FLOAT)),0) AS avg_volume,
         ROUND(STDEV(daily_return_pct),3)  AS volatility,
         dbo.fn_period_return(@ticker, @start, @end)  AS period_return_pct,
         dbo.fn_volatility_label(STDEV(daily_return_pct)) AS risk_label
  FROM dbo.vw_daily_kpis
  WHERE ticker = @ticker AND trade_date BETWEEN @start AND @end;
END;
GO
-- EXEC dbo.sp_data_quality_check;
CREATE OR ALTER PROCEDURE dbo.sp_data_quality_check
AS
BEGIN
  SET NOCOUNT ON;
  SELECT 'Rows total' AS check_name, COUNT(*) AS cnt FROM dbo.daily_prices
  UNION ALL SELECT 'Zero volume', COUNT(*) FROM dbo.daily_prices WHERE volume = 0
  UNION ALL SELECT 'High < Low', COUNT(*) FROM dbo.daily_prices WHERE high_price < low_price
  UNION ALL SELECT 'Missing close', COUNT(*) FROM dbo.daily_prices WHERE close_price IS NULL
  UNION ALL SELECT 'Companies without prices', COUNT(*) FROM dbo.companies WHERE last_trade_date IS NULL;
END;
GO
