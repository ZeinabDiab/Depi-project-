USE egx_db;
DROP FUNCTION IF EXISTS fn_pct_change;
DROP FUNCTION IF EXISTS fn_period_return;
DROP FUNCTION IF EXISTS fn_volatility_label;
DELIMITER $$

-- نسبة التغير بين قيمتين
CREATE FUNCTION fn_pct_change(old_val DECIMAL(14,4), new_val DECIMAL(14,4))
RETURNS DECIMAL(12,4) DETERMINISTIC
BEGIN
  IF old_val IS NULL OR old_val = 0 OR new_val IS NULL THEN RETURN NULL; END IF;
  RETURN (new_val / old_val - 1) * 100;
END$$

-- Period Return: ((آخر إغلاق / أول إغلاق) - 1) * 100 لسهم في فترة
CREATE FUNCTION fn_period_return(p_ticker VARCHAR(20), p_start DATE, p_end DATE)
RETURNS DECIMAL(12,4) READS SQL DATA
BEGIN
  DECLARE first_close DECIMAL(14,4);
  DECLARE last_close  DECIMAL(14,4);
  SELECT close_price INTO first_close FROM daily_prices
   WHERE ticker = p_ticker AND trade_date BETWEEN p_start AND p_end ORDER BY trade_date ASC  LIMIT 1;
  SELECT close_price INTO last_close  FROM daily_prices
   WHERE ticker = p_ticker AND trade_date BETWEEN p_start AND p_end ORDER BY trade_date DESC LIMIT 1;
  RETURN fn_pct_change(first_close, last_close);
END$$

-- تصنيف التذبذب
CREATE FUNCTION fn_volatility_label(vol DOUBLE)
RETURNS VARCHAR(10) DETERMINISTIC
BEGIN
  IF vol IS NULL THEN RETURN 'N/A';
  ELSEIF vol < 1 THEN RETURN 'Low';
  ELSEIF vol < 3 THEN RETURN 'Medium';
  ELSE RETURN 'High';
  END IF;
END$$
DELIMITER ;

-- تجربة:
-- SELECT fn_period_return('COMI.CA','2026-11-01','2026-11-18');
-- SELECT ticker, fn_volatility_label(historical_volatility) FROM vw_stock_summary;
