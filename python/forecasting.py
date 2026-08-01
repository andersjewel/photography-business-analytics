"""Simple linear trend plus seasonal month indicators for portfolio forecasting."""
from pathlib import Path
import pandas as pd
from sklearn.linear_model import LinearRegression
ROOT=Path(__file__).resolve().parents[1]; df=pd.read_csv(ROOT/"data"/"processed"/"analytics_dataset.csv")
m=df.groupby("month",as_index=False).amount_paid.sum(); m["date"]=pd.to_datetime(m.month+"-01"); m["t"]=range(len(m))
X=pd.concat([m[["t"]],pd.get_dummies(m.date.dt.month,prefix="m",dtype=int)],axis=1); model=LinearRegression().fit(X,m.amount_paid)
future=pd.DataFrame({"date":pd.date_range(m.date.max()+pd.offsets.MonthBegin(),periods=6,freq="MS")}); future["t"]=range(len(m),len(m)+6)
XF=pd.concat([future[["t"]],pd.get_dummies(future.date.dt.month,prefix="m",dtype=int)],axis=1).reindex(columns=X.columns,fill_value=0)
future["forecast_revenue"]=model.predict(XF).clip(min=0).round(2); future.to_csv(ROOT/"data"/"processed"/"revenue_forecast.csv",index=False)

