from pathlib import Path
import pandas as pd
ROOT=Path(__file__).resolve().parents[1]
def test_required_raw_counts():
 assert len(pd.read_csv(ROOT/"data/raw/clients.csv"))>=1200
 assert len(pd.read_csv(ROOT/"data/raw/marketing_leads.csv"))==1800
 assert len(pd.read_csv(ROOT/"data/raw/bookings.csv"))==900
 assert len(pd.read_csv(ROOT/"data/raw/expenses.csv"))==1000

