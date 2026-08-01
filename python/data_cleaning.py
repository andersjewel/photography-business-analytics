"""Validate, clean and join synthetic source files."""
from __future__ import annotations
import json, logging, re
from pathlib import Path
import pandas as pd

ROOT=Path(__file__).resolve().parents[1]; RAW=ROOT/"data"/"raw"; OUT=ROOT/"data"/"processed"
SOURCE_MAP={"instgram":"Instagram","Face book":"Facebook","google":"Google Search","Referal":"Referral"}

def clean_data() -> dict[str,int]:
    logging.basicConfig(level=logging.INFO,format="%(levelname)s %(message)s"); OUT.mkdir(parents=True,exist_ok=True)
    clients=pd.read_csv(RAW/"clients.csv",dtype={"phone":"string"}); original=len(clients)
    clients["email_valid"]=clients.email.fillna("").str.match(r"^[^@\s]+@[^@\s]+\.[^@\s]+$")
    clients.loc[~clients.email_valid,"email"]=""
    clients["phone"]=clients.phone.fillna("")
    clients=clients.sort_values("client_id").drop_duplicates(["first_name","last_name","email"],keep="first")
    valid=set(clients.client_id)
    leads=pd.read_csv(RAW/"marketing_leads.csv",parse_dates=["inquiry_date","first_response_at"])
    leads["lead_source"]=leads.lead_source.replace(SOURCE_MAP); leads=leads[leads.client_id.isin(valid)].copy()
    bookings=pd.read_csv(RAW/"bookings.csv"); bookings["booking_date"]=pd.to_datetime(bookings.booking_date,format="mixed"); bookings["session_date"]=pd.to_datetime(bookings.session_date)
    packages=pd.read_csv(RAW/"packages.csv"); name_map=packages.set_index("package_id").package_name
    bookings["package_name"]=bookings.package_name.fillna("").mask(bookings.package_name.fillna("").eq(""),bookings.package_id.map(name_map))
    bookings=bookings[bookings.client_id.isin(valid)].copy()
    sessions=pd.read_csv(RAW/"sessions.csv",parse_dates=["actual_session_date"]); sessions=sessions[sessions.booking_id.isin(set(bookings.booking_id))]
    payments=pd.read_csv(RAW/"payments.csv",parse_dates=["payment_date"]); neg=int((payments.amount<0).sum()); payments["amount"]=payments.amount.clip(lower=0)
    expenses=pd.read_csv(RAW/"expenses.csv",parse_dates=["expense_date"])
    clients.to_csv(OUT/"cleaned_clients.csv",index=False); bookings.to_csv(OUT/"cleaned_bookings.csv",index=False)
    sessions.to_csv(OUT/"cleaned_sessions.csv",index=False); payments.to_csv(OUT/"cleaned_payments.csv",index=False)
    pay=payments.groupby("booking_id",as_index=False).amount.sum().rename(columns={"amount":"amount_paid"})
    ses=sessions.groupby("booking_id",as_index=False).agg(session_completed=("session_status",lambda x:(x=="completed").any()))
    analytics=bookings.merge(leads[["lead_id","lead_source","inquiry_date","first_response_at"]],on="lead_id").merge(packages[["package_id","variable_cost"]],on="package_id").merge(pay,on="booking_id",how="left").merge(ses,on="booking_id",how="left")
    analytics["amount_paid"]=analytics.amount_paid.fillna(0); analytics["outstanding_balance"]=(analytics.booking_value-analytics.amount_paid).clip(lower=0)
    analytics["net_revenue"]=analytics.amount_paid; analytics["gross_profit"]=analytics.net_revenue-analytics.variable_cost
    analytics["days_to_booking"]=(analytics.booking_date-analytics.inquiry_date).dt.days
    analytics["response_hours"]=(analytics.first_response_at-analytics.inquiry_date).dt.total_seconds()/3600
    analytics["session_completed"]=analytics.session_completed.fillna(False).astype(bool); analytics["month"]=analytics.booking_date.dt.to_period("M").astype(str)
    analytics.to_csv(OUT/"analytics_dataset.csv",index=False)
    report={"duplicate_clients_removed":original-len(clients),"invalid_emails_blank":int((clients.email=="").sum()),"negative_payments_corrected":neg,"missing_phones_retained_as_blank":int((clients.phone=="").sum()),"bookings_without_completed_sessions":int((~analytics.session_completed).sum())}
    (OUT/"data_quality_report.json").write_text(json.dumps(report,indent=2),encoding="utf-8")
    logging.info("Cleaned data and wrote %d-row analytics dataset",len(analytics)); return report

if __name__=="__main__": clean_data()

