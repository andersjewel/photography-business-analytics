from pathlib import Path
import pandas as pd
ROOT=Path(__file__).resolve().parents[1]
def test_cleaned_integrity():
 c=pd.read_csv(ROOT/"data/processed/cleaned_clients.csv"); p=pd.read_csv(ROOT/"data/processed/cleaned_payments.csv")
 assert not c.duplicated(["first_name","last_name","email"]).any()
 assert (p.amount>=0).all()

