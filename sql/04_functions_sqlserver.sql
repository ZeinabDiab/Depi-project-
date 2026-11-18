USE egx_db;
GO
CREATE OR ALTER FUNCTION dbo.fn_pct_change(@old DECIMAL(14,4), @new DECIMAL(14,4))
RETURNS DECIMAL(12,4)
AS
BEGIN
  RETURN CASE WHEN @old IS NULL OR @old = 0 OR @new IS NULL THEN NULL ELSE (@new / @old - 1) * 100 END;
END;
GO
CREATE OR ALTER FUNCTION dbo.fn_period_return(@ticker VARCHAR(20), @start DATE, @end DATE)
RETURNS DECIMAL(12,4)
AS
BEGIN
  DECLARE @first DECIMAL(14,4), @last DECIMAL(14,4);
  SELECT TOP 1 @first = close_price FROM dbo.daily_prices
   WHERE ticker = @ticker AND trade_date BETWEEN @start AND @end ORDER BY trade_date ASC;
  SELECT TOP 1 @last  = close_price FROM dbo.daily_prices
   WHERE ticker = @ticker AND trade_date BETWEEN @start AND @end ORDER BY trade_date DESC;
  RETURN dbo.fn_pct_change(@first, @last);
END;
GO
CREATE OR ALTER FUNCTION dbo.fn_volatility_label(@vol FLOAT)
RETURNS VARCHAR(10)
AS
BEGIN
  RETURN CASE WHEN @vol IS NULL THEN 'N/A' WHEN @vol < 1 THEN 'Low' WHEN @vol < 3 THEN 'Medium' ELSE 'High' END;
END;
GO
-- Table-valued function: تاريخ سهم كامل مع KPIs
CREATE OR ALTER FUNCTION dbo.fn_ticker_history(@ticker VARCHAR(20))
RETURNS TABLE
AS RETURN (SELECT trade_date, close_price, volume, daily_range, daily_return_pct
           FROM dbo.vw_daily_kpis WHERE ticker = @ticker);
GO
-- تجربة:
-- SELECT dbo.fn_period_return('COMI.CA','2026-11-01','2026-11-18');
-- SELECT * FROM dbo.fn_ticker_history('COMI.CA') ORDER BY trade_date;
