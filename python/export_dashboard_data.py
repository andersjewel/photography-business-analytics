from pathlib import Path
import pandas as pd
ROOT=Path(__file__).resolve().parents[1]; df=pd.read_csv(ROOT/"data"/"processed"/"analytics_dataset.csv")
out=ROOT/"data"/"processed"
df.groupby("month",as_index=False).agg(revenue=("amount_paid","sum"),bookings=("booking_id","count"),outstanding=("outstanding_balance","sum")).to_csv(out/"dashboard_monthly.csv",index=False)
df.groupby(["package_name","service_category"],as_index=False).agg(revenue=("amount_paid","sum"),gross_profit=("gross_profit","sum"),bookings=("booking_id","count")).to_csv(out/"dashboard_packages.csv",index=False)
df.groupby("lead_source",as_index=False).agg(bookings=("booking_id","count"),revenue=("amount_paid","sum"),response_hours=("response_hours","mean")).to_csv(out/"dashboard_leads.csv",index=False)

