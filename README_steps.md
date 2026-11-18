# دليل التشغيل (لكل عضو في الفريق)

كل واحد بيبني قاعدة بيانات على جهازه من نفس الملفات. محدش بيشارك الباسورد بتاعه.

## المطلوب
Python 3.10+  |  MySQL 8+ (Workbench) أو SQL Server (SSMS)  |  إنترنت

## الخطوات
1. افتحي Workbench/SSMS وشغّلي `sql/01_schema_...sql` (حسب نوع قاعدتك).
2. Terminal في فولدر `code`:  `pip install -r requirements.txt`
3. انسخي `config_local.example.py` باسم `config_local.py` وعدّلي `DB_URL`.
4. شغّلي `python run_all.py` (داتا آخر يوم)  
   وللتحليل المتقدم حمّلي تاريخ:  `python run_all.py --days 60`
5. شغّلي بالترتيب في Workbench/SSMS:
   `02_views` ← `04_functions` ← `05_procedures` ← `06_triggers`
   (ملف `03_queries` فيه استعلامات التحليل، بتشغليها وقت ما تحبي)
   * الـ triggers بتتشغل بعد تحميل الداتا الأول، علشان التحميل الأول ميعملش تحديث 277 مرة.
6. اتأكدي: `CALL sp_data_quality_check();` (MySQL) أو `EXEC dbo.sp_data_quality_check;` (SQL Server)

## محتوى فولدر sql
| الملف | فيه إيه |
|---|---|
| 01_schema | الجداول (companies, daily_prices, price_audit)، PK/FK/Index |
| 02_views | vw_daily_kpis, vw_stock_summary (لـ Power BI) |
| 03_queries | 8 استعلامات: CTE, Recursive CTE, Window Functions, RANK, Subquery... |
| 04_functions | fn_pct_change, fn_period_return, fn_volatility_label (+ fn_ticker_history في SQL Server) |
| 05_procedures | sp_top_movers, sp_stock_report, sp_data_quality_check |
| 06_triggers | تحقق من صحة السعر، تسجيل التعديلات (audit)، تحديث آخر يوم تداول |

## Power BI
Get Data ← MySQL/SQL Server ← `localhost` / `egx_db` ← اختاري `vw_daily_kpis` و`vw_stock_summary` و`companies`.
