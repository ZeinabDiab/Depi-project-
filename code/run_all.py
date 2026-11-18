"""تشغيل كل حاجة بأمر واحد: تحميل الشركات ثم داتا اليوم.
    python run_all.py
    python run_all.py --date 2026-11-17
"""
import argparse
import load_companies
import update_daily

if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--date", help="YYYY-MM-DD (اختياري)")
    ap.add_argument("--days", help="تحميل تاريخ آخر N يوم (اختياري)")
    args = ap.parse_args()
    print("1/2 تحميل الشركات...")
    load_companies.main()
    print("2/2 تحميل داتا اليوم...")
    update_daily.main(args.date, args.days)
    print("خلصنا. الداتا في الجداول، والـ views جاهزة لـ Power BI.")
