USE egx_db;
DROP PROCEDURE IF EXISTS sp_top_movers;
DROP PROCEDURE IF EXISTS sp_stock_report;
DROP PROCEDURE IF EXISTS sp_data_quality_check;
DELIMITER $$

-- أعلى وأقل N سهم في يوم معين.   CALL sp_top_movers('2026-11-18', 5);
CREATE PROCEDURE sp_top_movers(IN p_date DATE, IN p_n INT)
BEGIN
  SELECT 'Top Gainers' AS category, ticker, company_name, close_price, ROUND(daily_return_pct,2) AS return_pct
  FROM vw_daily_kpis WHERE trade_date = p_date AND daily_return_pct IS NOT NULL
  ORDER BY daily_return_pct DESC LIMIT p_n;

  SELECT 'Top Losers' AS category, ticker, company_name, close_price, ROUND(daily_return_pct,2) AS return_pct
  FROM vw_daily_kpis WHERE trade_date = p_date AND daily_return_pct IS NOT NULL
  ORDER BY daily_return_pct ASC LIMIT p_n;
END$$

-- تقرير كامل عن سهم في فترة.   CALL sp_stock_report('COMI.CA','2026-10-01','2026-11-18');
CREATE PROCEDURE sp_stock_report(IN p_ticker VARCHAR(20), IN p_start DATE, IN p_end DATE)
BEGIN
  SELECT p_ticker AS ticker,
         COUNT(*)                          AS trading_days,
         MIN(close_price)                  AS min_close,
         MAX(close_price)                  AS max_close,
         ROUND(AVG(volume),0)              AS avg_volume,
         ROUND(STDDEV(daily_return_pct),3) AS volatility,
         fn_period_return(p_ticker, p_start, p_end) AS period_return_pct,
         fn_volatility_label(STDDEV(daily_return_pct)) AS risk_label
  FROM vw_daily_kpis
  WHERE ticker = p_ticker AND trade_date BETWEEN p_start AND p_end;
END$$

-- فحص جودة الداتا.   CALL sp_data_quality_check();
CREATE PROCEDURE sp_data_quality_check()
BEGIN
  SELECT 'Rows total' AS check_name, COUNT(*) AS cnt FROM daily_prices
  UNION ALL SELECT 'Zero volume', COUNT(*) FROM daily_prices WHERE volume = 0
  UNION ALL SELECT 'High < Low', COUNT(*) FROM daily_prices WHERE high_price < low_price
  UNION ALL SELECT 'Missing close', COUNT(*) FROM daily_prices WHERE close_price IS NULL
  UNION ALL SELECT 'Companies without prices', COUNT(*) FROM companies WHERE last_trade_date IS NULL;
END$$
DELIMITER ;
