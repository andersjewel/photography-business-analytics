# Data Dictionary

All records are synthetic. Primary entities are `clients` (identity/contact), `leads` (source, service, inquiry and response), `bookings` (package, value, dates and status), `sessions` (delivery event), `packages` (list price and variable cost), `payments` (cash received), and `expenses` (operating spend). `analytics_dataset.csv` is a booking-grain denormalized export. `amount_paid` is recognized revenue; `outstanding_balance = max(booking_value - amount_paid, 0)`; `gross_profit = amount_paid - package variable_cost`; rates use booking rows unless explicitly described otherwise.

