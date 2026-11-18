"""يحمّل/يحدّث جدول companies من ملف الإكسيل. تشغيله أكتر من مرة آمن."""
import pandas as pd
from sqlalchemy import create_engine, text
import config


def main(db_url=config.DB_URL, excel=config.EXCEL_FILE):
    df = pd.read_excel(excel, usecols=["Code", "Ticker", "Company Name"], keep_default_na=False)  # عشان كود زي NAN ميتقريش على إنه فاضي
    df = df.rename(columns={"Code": "code", "Ticker": "ticker", "Company Name": "company_name"})
    for col in df.columns:
        df[col] = df[col].astype(str).str.strip()
    # صف واحد في الملف باظ: الكود طلع "nan" (شركة TAWASOA For Factoring) - بنتجاهله لحد ما الكود الصح يتحدد
    bad = df["code"].str.lower().isin(["nan", ""])
    if bad.any():
        print("تم تجاهل صفوف بكود غير صالح:", df.loc[bad, "company_name"].tolist())
    df = df[~bad].drop_duplicates(subset="ticker")
    # (الأسعار/Drift/Sigma في الملف قيمتها واحدة في كل الصفوف فمش بنحمّلها)

    engine = create_engine(db_url)
    with engine.begin() as conn:
        existing = {r[0] for r in conn.execute(text("SELECT ticker FROM companies"))}
        new_rows = [r for r in df.to_dict("records") if r["ticker"] not in existing]
        old_rows = [r for r in df.to_dict("records") if r["ticker"] in existing]
        if new_rows:
            conn.execute(text("INSERT INTO companies (ticker, code, company_name) "
                              "VALUES (:ticker, :code, :company_name)"), new_rows)
        if old_rows:
            conn.execute(text("UPDATE companies SET code=:code, company_name=:company_name "
                              "WHERE ticker=:ticker"), old_rows)
    print(f"companies: {len(new_rows)} جديد، {len(old_rows)} اتحدّث، الإجمالي {len(df)}")


if __name__ == "__main__":
    main()
