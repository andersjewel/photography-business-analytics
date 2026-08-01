import sys
from pathlib import Path
import pandas as pd
ROOT=Path(__file__).resolve().parents[1]; sys.path.insert(0,str(ROOT/"python"))
from business_analysis import calculate_kpis
def test_metrics_reconcile():
 d=pd.read_csv(ROOT/"data/processed/analytics_dataset.csv"); k=calculate_kpis(d)
 assert k["total_revenue"]==round(d.amount_paid.sum(),2)
 assert 0<=k["cancellation_rate"]<=1 and k["outstanding_balance"]>=0
