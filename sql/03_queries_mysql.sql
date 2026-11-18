USE egx_db;

-- Q1: أعلى 10 أسهم ارتفاعاً في آخر يوم تداول (CTE + JOIN)
WITH latest AS (SELECT MAX(trade_date) AS d FROM daily_prices)
SELECT k.ticker, k.company_name, k.close_price, ROUND(k.daily_return_pct,2) AS return_pct
FROM vw_daily_kpis k JOIN latest l ON k.trade_date = l.d
WHERE k.daily_return_pct IS NOT NULL
ORDER BY k.daily_return_pct DESC LIMIT 10;

-- Q2: متوسط متحرك 5 و20 يوم لسهم CIB (Window Function)
SELECT ticker, trade_date, close_price,
  AVG(close_price) OVER (PARTITION BY ticker ORDER BY trade_date ROWS BETWEEN 4  PRECEDING AND CURRENT ROW) AS ma_5,
  AVG(close_price) OVER (PARTITION BY ticker ORDER BY trade_date ROWS BETWEEN 19 PRECEDING AND CURRENT ROW) AS ma_20
FROM daily_prices WHERE ticker = 'COMI.CA' ORDER BY trade_date;

-- Q3: ترتيب الأسهم حسب التذبذب (CTE + RANK)
WITH vol AS (
  SELECT ticker, company_name, STDDEV(daily_return_pct) AS volatility, AVG(volume) AS avg_volume
  FROM vw_daily_kpis WHERE daily_return_pct IS NOT NULL
  GROUP BY ticker, company_name HAVING COUNT(*) >= 5
)
SELECT RANK() OVER (ORDER BY volatility DESC) AS rnk, ticker, company_name,
       ROUND(volatility,3) AS volatility, ROUND(avg_volume,0) AS avg_volume
FROM vol ORDER BY rnk LIMIT 10;

-- Q4: العائد التراكمي من أول يوم (FIRST_VALUE)
SELECT ticker, trade_date, close_price,
  ROUND((close_price / FIRST_VALUE(close_price) OVER (PARTITION BY ticker ORDER BY trade_date) - 1) * 100, 2) AS cum_return_pct
FROM daily_prices WHERE ticker = 'COMI.CA' ORDER BY trade_date;

-- Q5: ملخص شهري لكل سهم (GROUP BY)
SELECT ticker, YEAR(trade_date) AS yr, MONTH(trade_date) AS mth,
       ROUND(AVG(close_price),2) AS avg_close, MAX(high_price) AS max_high,
       MIN(low_price) AS min_low, SUM(volume) AS total_volume
FROM daily_prices GROUP BY ticker, YEAR(trade_date), MONTH(trade_date)
ORDER BY ticker, yr, mth;

-- Q6: أكثر الأسهم قيمة تداول في آخر يوم (Subquery)
SELECT p.ticker, c.company_name, p.volume, ROUND(p.volume * p.close_price, 0) AS traded_value
FROM daily_prices p JOIN companies c ON c.ticker = p.ticker
WHERE p.trade_date = (SELECT MAX(trade_date) FROM daily_prices)
ORDER BY traded_value DESC LIMIT 10;

-- Q7: أيام تداول ناقصة (Recursive CTE) - البورصة المصرية بتشتغل الأحد-الخميس
WITH RECURSIVE cal AS (
  SELECT MIN(trade_date) AS d FROM daily_prices
  UNION ALL
  SELECT DATE_ADD(d, INTERVAL 1 DAY) FROM cal WHERE d < (SELECT MAX(trade_date) FROM daily_prices)
)
SELECT d AS missing_day FROM cal
WHERE DAYOFWEEK(d) NOT IN (6, 7)                       -- مش جمعة ولا سبت
  AND d NOT IN (SELECT DISTINCT trade_date FROM daily_prices);

-- Q8: شركات مفيش لها داتا في آخر يوم (NOT EXISTS)
SELECT c.ticker, c.company_name, c.last_trade_date
FROM companies c
WHERE NOT EXISTS (SELECT 1 FROM daily_prices p
                  WHERE p.ticker = c.ticker AND p.trade_date = (SELECT MAX(trade_date) FROM daily_prices));
