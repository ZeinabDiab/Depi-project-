USE egx_db;
GO
-- 1) يرفض أي صف سعره غلط
CREATE OR ALTER TRIGGER dbo.trg_prices_validate ON dbo.daily_prices AFTER INSERT
AS
BEGIN
  SET NOCOUNT ON;
  IF EXISTS (SELECT 1 FROM inserted WHERE high_price < low_price OR close_price <= 0 OR volume < 0)
  BEGIN
    ROLLBACK TRANSACTION;
    THROW 50001, 'Invalid price row rejected (high<low, close<=0 or volume<0)', 1;
  END
END;
GO
-- 2) يسجل أي تعديل على سعر الإغلاق
CREATE OR ALTER TRIGGER dbo.trg_prices_audit ON dbo.daily_prices AFTER UPDATE
AS
BEGIN
  SET NOCOUNT ON;
  INSERT INTO dbo.price_audit (ticker, trade_date, old_close, new_close, changed_by)
  SELECT d.ticker, d.trade_date, d.close_price, i.close_price, SUSER_SNAME()
  FROM deleted d JOIN inserted i ON i.ticker = d.ticker AND i.trade_date = d.trade_date
  WHERE ISNULL(d.close_price,-1) <> ISNULL(i.close_price,-1);
END;
GO
-- 3) يحدّث آخر تاريخ تداول للشركة
CREATE OR ALTER TRIGGER dbo.trg_prices_last_date ON dbo.daily_prices AFTER INSERT
AS
BEGIN
  SET NOCOUNT ON;
  UPDATE c SET last_trade_date = x.d
  FROM dbo.companies c
  JOIN (SELECT ticker, MAX(trade_date) AS d FROM inserted GROUP BY ticker) x ON x.ticker = c.ticker
  WHERE c.last_trade_date IS NULL OR c.last_trade_date < x.d;
END;
GO
