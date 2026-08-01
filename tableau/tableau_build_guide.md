# Tableau Build Guide

> Independent portfolio case study using synthetic data inspired by common photography-business workflows.

Connect to `analytics_dataset.csv`, `marketing_leads.csv`, and `expenses.csv`; relate at lead and month grain rather than physically joining expenses to bookings. Build an Executive dashboard, revenue trend, lead-source funnel, package-profitability view, client-retention view, and seasonal-demand heatmap. Filters: booking month, service, package, lead source, status.

Suggested fields: `Profit Margin = SUM([gross_profit])/SUM([amount_paid])`; `Cancellation Rate = SUM(IIF([booking_status]='cancelled',1,0))/COUNT([booking_id])`; `Balance Status = IF [outstanding_balance]>0 THEN 'Open' ELSE 'Paid' END`; `Repeat Flag = { FIXED [client_id] : COUNTD([booking_id]) }>1`; and `Conversion Rate = COUNTD([booking lead_id])/COUNTD([lead_id])`. Use a dashboard action from source/package charts to booking detail and a parameter for Revenue vs Gross Profit.

