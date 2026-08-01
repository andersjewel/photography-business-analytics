"""Create separate recruiter-ready analytical figures."""
from pathlib import Path
import matplotlib.pyplot as plt
import pandas as pd
ROOT=Path(__file__).resolve().parents[1]; df=pd.read_csv(ROOT/"data"/"processed"/"analytics_dataset.csv")
plt.rcParams.update({"figure.figsize":(10,5.5),"axes.titleweight":"bold","axes.spines.top":False,"axes.spines.right":False})
def save(series,title,ylabel,file,kind="bar"):
    fig,ax=plt.subplots(); getattr(series.plot,kind)(ax=ax,color="#C26A4A" if kind=="bar" else "#2F6F73"); ax.set_title(title); ax.set_ylabel(ylabel); ax.grid(axis="y",alpha=.2); fig.tight_layout(); fig.savefig(ROOT/"visuals"/file,dpi=160); plt.close(fig)
monthly=df.groupby("month").amount_paid.sum(); save(monthly,"Monthly Revenue — Synthetic Data","Revenue (USD)","monthly_revenue.png","line")
lead=df.groupby("lead_source").agg(leads=("lead_id","count"),bookings=("booking_id","count")).sort_values("bookings"); save(lead.bookings,"Bookings by Lead Source","Bookings","booking_conversion.png")
pkg=df.groupby("package_name").amount_paid.sum().sort_values(); save(pkg,"Revenue by Package","Revenue (USD)","package_performance.png")
status=df.booking_status.value_counts(); save(status,"Booking Outcomes","Bookings","cancellation_rate.png")
save(lead.bookings,"Lead Source Performance","Bookings","lead_source_performance.png")

