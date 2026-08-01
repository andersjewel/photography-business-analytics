CREATE VIEW IF NOT EXISTS vw_booking_financials AS
SELECT b.*,COALESCE(SUM(p.amount),0) amount_paid,
 MAX(b.booking_value-COALESCE((SELECT SUM(p2.amount) FROM payments p2 WHERE p2.booking_id=b.booking_id),0),0) outstanding_balance
FROM bookings b LEFT JOIN payments p USING(booking_id) GROUP BY b.booking_id;
CREATE VIEW IF NOT EXISTS vw_monthly_kpis AS
SELECT substr(booking_date,1,7) month,COUNT(*) bookings,SUM(amount_paid) revenue,SUM(outstanding_balance) outstanding
FROM vw_booking_financials GROUP BY 1;
CREATE VIEW IF NOT EXISTS vw_package_performance AS
SELECT package_name,COUNT(*) bookings,SUM(amount_paid) revenue,AVG(booking_value) avg_booking_value
FROM vw_booking_financials GROUP BY 1;

