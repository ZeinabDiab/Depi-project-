"""
يسحب داتا يوم واحد من Yahoo Finance ويحطها في daily_prices.
تشغيله أكتر من مرة لنفس اليوم آمن (بيمسح اليوم ده ويكتبه تاني).

أمثلة:
    python update_daily.py                    # آخر يوم تداول متاح
    python update_daily.py --date 2026-11-17  # يوم محدد
    python update_daily.py --days 60          # تحميل تاريخ آخر 60 يوم (مرة واحدة علشان التحليل)
"""
import argparse
from datetime import date, datetime, timedelta

import pandas as pd
import yfinance as yf
from sqlalchemy import create_engine, text

import config

CHUNK = 50  # عدد الأسهم في الطلب الواحد


def fetch(tickers, start, end):
    frames = []
    for i in range(0, len(tickers), CHUNK):
        batch = tickers[i:i + CHUNK]
        raw = yf.download(batch, start=start, end=end, group_by="ticker",
                          auto_adjust=False, progress=False, threads=True)
        if raw.empty:
            continue
        if len(batch) == 1:                       # شكل مختلف لما يبقى سهم واحد
            raw.columns = pd.MultiIndex.from_product([batch, raw.columns])
        long = raw.stack(level=0, future_stack=True).reset_index()
        long = long.rename(columns={long.columns[0]: "trade_date", long.columns[1]: "ticker"})
        frames.append(long)
    if not frames:
        return pd.DataFrame()
    df = pd.concat(frames, ignore_index=True)
    df = df.rename(columns={"Open": "open_price", "High": "high_price", "Low": "low_price",
                            "Close": "close_price", "Adj Close": "adj_close", "Volume": "volume"})
    df["trade_date"] = pd.to_datetime(df["trade_date"]).dt.date
    cols = ["ticker", "trade_date", "open_price", "high_price", "low_price",
            "close_price", "adj_close", "volume"]
    df = df[cols].dropna(subset=["close_price"])
    df["volume"] = df["volume"].fillna(0).astype("int64")
    # فلترة الصفوف الغلط علشان الـ trigger (trg_prices_validate) ميرفضش الدفعة كلها
    ok = (df["high_price"] >= df["low_price"]) & (df["close_price"] > 0) & (df["volume"] >= 0)
    if (~ok).any():
        print(f"تم تجاهل {(~ok).sum()} صف بيانات غير منطقية")
    return df[ok]


def main(target_date=None, days=None):
    engine = create_engine(config.DB_URL)
    with engine.connect() as conn:
        tickers = [r[0] for r in conn.execute(text("SELECT ticker FROM companies ORDER BY ticker"))]
    if not tickers:
        raise SystemExit("جدول companies فاضي. شغّلي load_companies.py الأول.")

    if days:                                   # تحميل تاريخ لعدد أيام
        df = fetch(tickers, date.today() - timedelta(days=int(days)), date.today() + timedelta(days=1))
    elif target_date:                          # يوم محدد
        d = datetime.strptime(target_date, "%Y-%m-%d").date()
        df = fetch(tickers, d, d + timedelta(days=1))
    else:                                      # آخر يوم تداول متاح
        df = fetch(tickers, date.today() - timedelta(days=7), date.today() + timedelta(days=1))
        if not df.empty:
            df = df[df["trade_date"] == df["trade_date"].max()]

    if df.empty:
        raise SystemExit("مفيش داتا راجعة (يوم إجازة أو مفيش اتصال).")

    first_day, last_day = df["trade_date"].min(), df["trade_date"].max()
    with engine.begin() as conn:               # transaction واحدة: يا كله يتكتب يا مفيش
        conn.execute(text("DELETE FROM daily_prices WHERE trade_date BETWEEN :a AND :b"),
                     {"a": first_day, "b": last_day})
        df.to_sql("daily_prices", conn, if_exists="append", index=False, chunksize=500)
    print(f"اتحمّل {len(df)} صف من {first_day} إلى {last_day} ({df['ticker'].nunique()} سهم)")


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--date", help="YYYY-MM-DD (اختياري)")
    ap.add_argument("--days", help="عدد الأيام اللي هتتحمل للتاريخ (اختياري)")
    a = ap.parse_args()
    main(a.date, a.days)
