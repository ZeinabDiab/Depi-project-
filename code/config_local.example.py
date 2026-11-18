# انسخي الملف ده باسم config_local.py وعدّلي سطر واحد بس (اللي يناسب قاعدة بياناتك).

# --- MySQL ---
DB_URL = "mysql+pymysql://root:ضعي_الباسورد_هنا@localhost:3306/egx_db"

# --- SQL Server بـ Windows Authentication (من غير باسورد) ---
# DB_URL = "mssql+pyodbc://@localhost/egx_db?driver=ODBC+Driver+17+for+SQL+Server&trusted_connection=yes"
# لو السيرفر اسمه مختلف (زي localhost\SQLEXPRESS) غيّري localhost
