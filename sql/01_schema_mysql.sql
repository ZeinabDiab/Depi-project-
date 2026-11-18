-- MySQL 8+  |  شغّليه في MySQL Workbench
CREATE DATABASE IF NOT EXISTS egx_db CHARACTER SET utf8mb4;
USE egx_db;

CREATE TABLE IF NOT EXISTS companies (
    ticker       VARCHAR(20)  NOT NULL PRIMARY KEY,   -- ABUK.CA
    code         VARCHAR(10)  NOT NULL,               -- ABUK
    company_name VARCHAR(250) NOT NULL,
    last_trade_date DATE NULL                         -- بيتحدث بالـ trigger
);

CREATE TABLE IF NOT EXISTS daily_prices (
    ticker      VARCHAR(20)   NOT NULL,
    trade_date  DATE          NOT NULL,
    open_price  DECIMAL(14,4) NULL,
    high_price  DECIMAL(14,4) NULL,
    low_price   DECIMAL(14,4) NULL,
    close_price DECIMAL(14,4) NULL,
    adj_close   DECIMAL(14,4) NULL,
    volume      BIGINT        NULL,
    PRIMARY KEY (ticker, trade_date),                 -- يمنع التكرار
    CONSTRAINT fk_prices_company FOREIGN KEY (ticker) REFERENCES companies(ticker)
);

CREATE INDEX ix_prices_date ON daily_prices (trade_date);

-- جدول تسجيل التعديلات اليدوية على الأسعار (بيتملى بالـ trigger)
CREATE TABLE IF NOT EXISTS price_audit (
    audit_id    BIGINT AUTO_INCREMENT PRIMARY KEY,
    ticker      VARCHAR(20)   NOT NULL,
    trade_date  DATE          NOT NULL,
    old_close   DECIMAL(14,4) NULL,
    new_close   DECIMAL(14,4) NULL,
    changed_by  VARCHAR(100)  NULL,
    changed_at  DATETIME      DEFAULT CURRENT_TIMESTAMP
);
