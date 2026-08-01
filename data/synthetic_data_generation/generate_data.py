"""Generate reproducible, fully synthetic Wildlight Portrait Studio data."""
from __future__ import annotations
import logging
from pathlib import Path
import numpy as np
import pandas as pd

SEED = 20260731
ROOT = Path(__file__).resolve().parents[2]
RAW = ROOT / "data" / "raw"
LABEL = "Independent portfolio case study using synthetic data inspired by common photography-business workflows."
SERVICES = ["Family portraits","Couples","Weddings","Maternity","Newborn","Graduation","Branding/headshots","Mini sessions"]
SOURCES = ["Instagram","Facebook","Google Search","Referral","Repeat Client","Wedding Vendor","Local Event","Paid Advertisement"]

def weighted_service(month: int, rng: np.random.Generator) -> str:
    w=np.array([.17,.10,.10,.10,.09,.12,.14,.18])
    if month in (10,11): w[[0,7]] += [.16,.12]
    if month in (4,5): w[5] += .22
    if month in (4,5,6,9,10): w[2] += .14
    if month == 1: w *= .75
    return str(rng.choice(SERVICES,p=w/w.sum()))

def main() -> None:
    logging.basicConfig(level=logging.INFO, format="%(levelname)s %(message)s")
    RAW.mkdir(parents=True,exist_ok=True); rng=np.random.default_rng(SEED)
    packages=pd.DataFrame([
      (1,"Mini Moment","Mini sessions",225,55,20),(2,"Essential Portrait","Family portraits",475,110,60),
      (3,"Signature Story","Couples",650,145,90),(4,"Milestone","Graduation",525,120,70),
      (5,"Brand Builder","Branding/headshots",850,210,120),(6,"Wedding Collection","Weddings",3200,1150,480)],
      columns=["package_id","package_name","default_service","list_price","variable_cost","duration_minutes"])
    packages.to_csv(RAW/"packages.csv",index=False)
    first=["Avery","Jordan","Morgan","Taylor","Riley","Cameron","Casey","Quinn","Parker","Skyler","Reese","Rowan"]
    last=["Adams","Bennett","Clark","Diaz","Evans","Foster","Green","Hayes","Irwin","Jones","Kim","Lopez"]
    clients=[]
    for i in range(1,1201):
        fn=str(rng.choice(first)); ln=str(rng.choice(last)); email=f"{fn.lower()}.{ln.lower()}{i}@example.test"
        phone=f"555-{rng.integers(100,1000)}-{rng.integers(1000,10000)}" if rng.random()>.08 else ""
        clients.append([i,fn,ln,email,phone,pd.Timestamp("2024-01-01")+pd.Timedelta(days=int(rng.integers(0,730)))])
    clients=pd.DataFrame(clients,columns=["client_id","first_name","last_name","email","phone","created_date"])
    clients.loc[rng.choice(clients.index,12,replace=False),"email"]="invalid-email"
    # Ten deliberate duplicate identities with new IDs.
    dup=clients.sample(10,random_state=SEED).copy(); dup["client_id"]=range(1201,1211); clients=pd.concat([clients,dup],ignore_index=True)
    clients["created_date"]=clients["created_date"].dt.strftime("%Y-%m-%d")
    clients.to_csv(RAW/"clients.csv",index=False)
    dates=pd.date_range("2024-01-01","2025-12-31",freq="D")
    month_weight={1:.55,2:.75,3:.95,4:1.25,5:1.35,6:1.05,7:.9,8:.95,9:1.25,10:1.55,11:1.65,12:1.2}
    p=np.array([month_weight[d.month] for d in dates]); p=p/p.sum()
    leads=[]
    typos={"Instagram":"instgram","Facebook":"Face book","Google Search":"google","Referral":"Referal"}
    for i in range(1,1801):
        inquiry=pd.Timestamp(rng.choice(dates,p=p)); src=str(rng.choice(SOURCES,p=[.22,.13,.18,.18,.08,.07,.06,.08])); svc=weighted_service(inquiry.month,rng)
        raw_src=typos.get(src,src) if rng.random()<.06 else src
        responded=inquiry+pd.Timedelta(hours=int(rng.integers(1,73)))
        leads.append([i,int(rng.integers(1,1201)),raw_src,svc,inquiry,responded,str(rng.choice(["new","contacted","qualified","lost"],p=[.05,.12,.48,.35]))])
    leads=pd.DataFrame(leads,columns=["lead_id","client_id","lead_source","service_category","inquiry_date","first_response_at","lead_status"])
    leads.to_csv(RAW/"marketing_leads.csv",index=False,date_format="%Y-%m-%d %H:%M:%S")
    chosen=rng.choice(leads.index,900,replace=False); bookings=[]; sessions=[]; payments=[]
    pkgmap={"Mini sessions":1,"Family portraits":2,"Couples":3,"Maternity":2,"Newborn":2,"Graduation":4,"Branding/headshots":5,"Weddings":6}
    for bid,idx in enumerate(chosen,1):
        lead=leads.loc[idx]; booked=pd.Timestamp(lead.inquiry_date)+pd.Timedelta(days=int(rng.integers(1,25)))
        status=str(rng.choice(["completed","confirmed","cancelled","rescheduled"],p=[.78,.06,.08,.08])); pid=pkgmap[lead.service_category]
        price=float(packages.loc[packages.package_id==pid,"list_price"].iloc[0]*rng.uniform(.9,1.08)); session_date=booked+pd.Timedelta(days=int(rng.integers(7,121)))
        pkgname=str(packages.loc[packages.package_id==pid,"package_name"].iloc[0]); pkgraw="" if rng.random()<.025 else pkgname
        bookings.append([bid,int(lead.lead_id),int(lead.client_id),pid,pkgraw,lead.service_category,booked,session_date,status,round(price,2)])
        if status!="cancelled" and (status=="completed" or rng.random()<.65):
            actual=session_date+pd.Timedelta(days=int(rng.integers(-2,3)))
            sessions.append([len(sessions)+1,bid,actual,"completed" if status=="completed" else "scheduled",int(rng.integers(45,500))])
        paid=max(0,price*rng.choice([0,.35,.5,1],p=[.04,.08,.10,.78])); paid=round(paid,2)
        if rng.random()<.02: paid=-paid
        payments.append([bid,bid,booked+pd.Timedelta(days=int(rng.integers(0,45))),paid,str(rng.choice(["Card","ACH","Cash"],p=[.72,.22,.06])),"late" if rng.random()<.13 else "on_time"])
    bookings=pd.DataFrame(bookings,columns=["booking_id","lead_id","client_id","package_id","package_name","service_category","booking_date","session_date","booking_status","booking_value"])
    # Mixed raw date formats.
    mix=rng.choice(bookings.index,90,replace=False); bookings.loc[mix,"booking_date"]=bookings.loc[mix,"booking_date"].dt.strftime("%m/%d/%Y")
    bookings.to_csv(RAW/"bookings.csv",index=False)
    pd.DataFrame(sessions,columns=["session_id","booking_id","actual_session_date","session_status","images_delivered"]).to_csv(RAW/"sessions.csv",index=False)
    pd.DataFrame(payments,columns=["payment_id","booking_id","payment_date","amount","payment_method","timeliness"]).to_csv(RAW/"payments.csv",index=False)
    exp=[]
    cats=["Equipment","Software","Marketing","Travel","Insurance","Contract labor","Studio supplies"]
    for i in range(1,1001):
        d=pd.Timestamp(rng.choice(dates)); cat=str(rng.choice(cats,p=[.14,.12,.21,.13,.08,.18,.14])); base={"Equipment":420,"Software":65,"Marketing":180,"Travel":95,"Insurance":110,"Contract labor":260,"Studio supplies":80}[cat]
        exp.append([i,d,cat,round(float(rng.gamma(2,base/2)),2),"Operating expense"])
    pd.DataFrame(exp,columns=["expense_id","expense_date","expense_category","amount","description"]).to_csv(RAW/"expenses.csv",index=False)
    logging.info("Generated 24 months: %d raw clients, %d leads, %d bookings, %d sessions",len(clients),len(leads),len(bookings),len(sessions))

if __name__ == "__main__":
    main()

