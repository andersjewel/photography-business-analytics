# DAX Measures

```DAX
Total Revenue = SUM(Analytics[amount_paid])
Total Expenses = SUM(Expenses[amount])
Gross Profit = [Total Revenue] - [Total Expenses]
Profit Margin = DIVIDE([Gross Profit], [Total Revenue])
Average Booking Value = AVERAGE(Analytics[booking_value])
Conversion Rate = DIVIDE(DISTINCTCOUNT(Analytics[lead_id]), DISTINCTCOUNT(Leads[lead_id]))
Repeat Client Rate = DIVIDE(COUNTROWS(FILTER(VALUES(Analytics[client_id]), CALCULATE(DISTINCTCOUNT(Analytics[booking_id])) > 1)), DISTINCTCOUNT(Analytics[client_id]))
Cancellation Rate = DIVIDE(CALCULATE(COUNTROWS(Analytics), Analytics[booking_status] = "cancelled"), COUNTROWS(Analytics))
Outstanding Balance = SUM(Analytics[outstanding_balance])
YoY Revenue Growth = DIVIDE([Total Revenue] - CALCULATE([Total Revenue], SAMEPERIODLASTYEAR('Date'[Date])), CALCULATE([Total Revenue], SAMEPERIODLASTYEAR('Date'[Date])))
```

