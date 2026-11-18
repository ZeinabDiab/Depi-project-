# دليل فريق Power BI

> اتفقوا الأول كلكم على نوع قاعدة بيانات واحد: MySQL أو SQL Server.

## 1) التثبيت (مرة واحدة)
1. نزّلي الريبو: GitHub ← Code ← Download ZIP، وفكّيه في فولدر.
2. ثبّتي Python 3.10+ (علّمي Add Python to PATH).
3. ثبّتي قاعدة البيانات:
   - MySQL: MySQL Server + Workbench + **MySQL Connector/NET** (مطلوب لـ Power BI)
   - SQL Server: SQL Server Express + SSMS
4. ثبّتي Power BI Desktop.

## 2) بناء الداتا على جهازك
5. شغّلي `sql/01_schema_*.sql` في Workbench/SSMS.
6. Terminal في فولدر `code`: `pip install -r requirements.txt`
7. انسخي `config_local.example.py` باسم `config_local.py` وعدّلي `DB_URL` ببياناتك أنتِ.
8. `python run_all.py --days 60`
9. شغّلي بالترتيب: `02_views` ← `04_functions` ← `05_procedures` ← `06_triggers`
10. تأكدي: `SELECT COUNT(*) FROM daily_prices;`

## 3) الربط بـ Power BI
11. Get Data ← MySQL / SQL Server database
12. Server: `localhost` | Database: `egx_db` | Mode: Import
13. اختاري: `vw_daily_kpis` و`vw_stock_summary` و`companies`
14. Model view: اربطي `companies[ticker]` ← `vw_daily_kpis[ticker]` (One-to-Many)
15. الـ KPIs: daily_return_pct, daily_range, volume (في vw_daily_kpis) + avg_volume, historical_volatility (في vw_stock_summary)

## 4) التحديث اليومي
`python run_all.py` ثم Refresh في Power BI.

## 5) شغل الفريق
- ملفات .pbix الكبيرة (فوق 100MB) مش بتترفع على GitHub: شاركوها بـ Drive.
- قبل أي شغل على الريبو: `git pull`.
- متشاركوش الباسورد ولا ترفعوا `config_local.py`.

## مشاكل شائعة
| المشكلة | الحل |
|---|---|
| python is not recognized | أعيدي تثبيت Python مع Add to PATH |
| Power BI مش بيتصل بـ MySQL | ثبّتي MySQL Connector/NET وأعيدي تشغيل Power BI |
| Access denied | الباسورد في config_local.py غلط |
| daily_prices فاضي | أعيدي `python run_all.py --days 60` وراجعي الرسائل |
| أسهم بدون داتا | طبيعي: Yahoo مش بيغطي كل الأسهم المصرية |
