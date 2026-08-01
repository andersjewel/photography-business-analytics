"""Calculate canonical KPIs and load the normalized SQLite model."""
from __future__ import annotations
import json, sqlite3
from pathlib import Path
import pandas as pd
ROOT=Path(__file__).resolve().parents[1]; PROC=ROOT/"data"/"processed"; RAW=ROOT/"data"/"raw"

def calculate_kpis(df: pd.DataFrame) -> dict[str,float]:
    completed=df.booking_status.eq("completed"); clients=df.groupby("client_id").booking_id.nunique()
    total=float(df.amount_paid.sum()); expenses=float(pd.read_csv(RAW/"expenses.csv").amount.sum())
    return {"total_revenue":round(total,2),"net_revenue":round(total,2),"total_expenses":round(expenses,2),"gross_profit":round(total-expenses,2),
      "profit_margin":round((total-expenses)/total,4),"average_booking_value":round(float(df.booking_value.mean()),2),
      "lead_to_booking_conversion_rate":round(len(df)/len(pd.read_csv(RAW/"marketing_leads.csv")),4),"repeat_client_rate":round(float((clients>1).mean()),4),
      "cancellation_rate":round(float(df.booking_status.eq("cancelled").mean()),4),"rescheduling_rate":round(float(df.booking_status.eq("rescheduled").mean()),4),
      "outstanding_balance":round(float(df.outstanding_balance.sum()),2),"average_lead_response_hours":round(float(df.response_hours.mean()),2),
      "average_days_inquiry_to_booking":round(float(df.days_to_booking.mean()),2),"session_completion_rate":round(float(df.session_completed.mean()),4)}

def main() -> None:
    df=pd.read_csv(PROC/"analytics_dataset.csv"); kpis=calculate_kpis(df); (ROOT/"reports"/"kpis.json").write_text(json.dumps(kpis,indent=2),encoding="utf-8")
    con=sqlite3.connect(ROOT/"photography_analytics.db")
    for name,path in {"clients":PROC/"cleaned_clients.csv","leads":RAW/"marketing_leads.csv","bookings":PROC/"cleaned_bookings.csv","sessions":PROC/"cleaned_sessions.csv","packages":RAW/"packages.csv","payments":PROC/"cleaned_payments.csv","expenses":RAW/"expenses.csv"}.items(): pd.read_csv(path).to_sql(name,con,if_exists="replace",index=False)
    df.to_sql("analytics_dataset",con,if_exists="replace",index=False); con.close(); print(json.dumps(kpis,indent=2))
if __name__=="__main__": main()

