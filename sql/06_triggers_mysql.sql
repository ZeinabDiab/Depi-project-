USE egx_db;
DROP TRIGGER IF EXISTS trg_prices_validate;
DROP TRIGGER IF EXISTS trg_prices_audit;
DROP TRIGGER IF EXISTS trg_prices_last_date;
DELIMITER $$

-- 1) يرفض أي صف سعره غلط قبل ما يتحفظ
CREATE TRIGGER trg_prices_validate BEFORE INSERT ON daily_prices
FOR EACH ROW
BEGIN
  IF NEW.high_price < NEW.low_price OR NEW.close_price <= 0 OR NEW.volume < 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid price row rejected (high<low, close<=0 or volume<0)';
  END IF;
END$$

-- 2) يسجل أي تعديل على سعر الإغلاق في price_audit
CREATE TRIGGER trg_prices_audit AFTER UPDATE ON daily_prices
FOR EACH ROW
BEGIN
  IF NOT (OLD.close_price <=> NEW.close_price) THEN
    INSERT INTO price_audit (ticker, trade_date, old_close, new_close, changed_by)
    VALUES (OLD.ticker, OLD.trade_date, OLD.close_price, NEW.close_price, USER());
  END IF;
END$$

-- 3) يحدّث آخر تاريخ تداول للشركة تلقائياً
CREATE TRIGGER trg_prices_last_date AFTER INSERT ON daily_prices
FOR EACH ROW
BEGIN
  UPDATE companies SET last_trade_date = NEW.trade_date
  WHERE ticker = NEW.ticker AND (last_trade_date IS NULL OR last_trade_date < NEW.trade_date);
END$$
DELIMITER ;
