from sqlalchemy import text
from database import engine
with engine.connect() as c:
    c.execute(text("ALTER TABLE orders DROP CONSTRAINT IF EXISTS orders_status_check;"))
    c.commit()
print("Constraint dropped")
