-- SQL Server  |  شغّليه في SSMS
IF DB_ID('egx_db') IS NULL CREATE DATABASE egx_db;
GO
USE egx_db;
GO

IF OBJECT_ID('dbo.companies') IS NULL
CREATE TABLE dbo.companies (
    ticker       VARCHAR(20)   NOT NULL PRIMARY KEY,
    code         VARCHAR(10)   NOT NULL,
    company_name NVARCHAR(250) NOT NULL,
    last_trade_date DATE NULL
);
GO

IF OBJECT_ID('dbo.daily_prices') IS NULL
CREATE TABLE dbo.daily_prices (
    ticker      VARCHAR(20)   NOT NULL,
    trade_date  DATE          NOT NULL,
    open_price  DECIMAL(14,4) NULL,
    high_price  DECIMAL(14,4) NULL,
    low_price   DECIMAL(14,4) NULL,
    close_price DECIMAL(14,4) NULL,
    adj_close   DECIMAL(14,4) NULL,
    volume      BIGINT        NULL,
    CONSTRAINT pk_daily_prices PRIMARY KEY (ticker, trade_date),
    CONSTRAINT fk_prices_company FOREIGN KEY (ticker) REFERENCES dbo.companies(ticker)
);
GO
CREATE INDEX ix_prices_date ON dbo.daily_prices (trade_date);
GO

IF OBJECT_ID('dbo.price_audit') IS NULL
CREATE TABLE dbo.price_audit (
    audit_id   BIGINT IDENTITY(1,1) PRIMARY KEY,
    ticker     VARCHAR(20)   NOT NULL,
    trade_date DATE          NOT NULL,
    old_close  DECIMAL(14,4) NULL,
    new_close  DECIMAL(14,4) NULL,
    changed_by NVARCHAR(100) NULL,
    changed_at DATETIME      DEFAULT GETDATE()
);
GO
