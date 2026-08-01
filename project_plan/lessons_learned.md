# Lessons Learned

The staged raw-to-clean design made defects auditable and kept analytical code simpler. Reconciliation required one canonical KPI function and a booking-grain dataset. Package-only variable cost is useful for package comparisons but is not full job costing; future work could add labor hours and payment fees. Two years capture seasonality but are insufficient for a high-confidence forecast. Future iterations could add campaign spend, response-event logs, capacity, and automated BI refreshes.

