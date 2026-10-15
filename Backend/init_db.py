import os
from db import get_db_connection

def init_database():
    sql_file_path = os.path.join(os.path.dirname(__file__), 'db.sql')
    
    if not os.path.exists(sql_file_path):
        print(f"Error: {sql_file_path} not found.")
        return

    with open(sql_file_path, 'r') as f:
        sql_commands = f.read().split(';')

    conn = get_db_connection()
    try:
        with conn.cursor() as cursor:
            for command in sql_commands:
                cmd = command.strip()
                if cmd and not cmd.startswith('--') and not cmd.startswith('/*'):
                    cursor.execute(cmd)
            conn.commit()
            print("Database initialized successfully!")
    except Exception as e:
        print(f"Database initialization failed: {str(e)}")
        conn.rollback()
    finally:
        conn.close()

if __name__ == '__main__':
    init_database()