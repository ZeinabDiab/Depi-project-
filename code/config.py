"""
إعدادات الاتصال بقاعدة البيانات.
كل واحد على جهازه بيعمل ملف اسمه config_local.py (مش بيترفع على GitHub)
وبيحط فيه بيانات الـ SQL بتاعته. شوفي config_local.example.py.
"""
import os

DB_URL = os.environ.get("EGX_DB_URL")
if not DB_URL:
    try:
        from config_local import DB_URL  # noqa
    except ImportError:
        raise SystemExit(
            "مفيش إعدادات اتصال. انسخي config_local.example.py باسم config_local.py "
            "وعدّلي DB_URL جواه."
        )

EXCEL_FILE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "EGX_stock_symbols.xlsx")
