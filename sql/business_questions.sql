-- Package revenue and profitability
SELECT b.package_name, COUNT(DISTINCT b.booking_id) bookings, SUM(p.amount) revenue,
 SUM(p.amount)-SUM(pk.variable_cost) gross_profit,
 ROUND((SUM(p.amount)-SUM(pk.variable_cost))/NULLIF(SUM(p.amount),0),3) margin
FROM bookings b JOIN packages pk USING(package_id) LEFT JOIN payments p USING(booking_id)
GROUP BY 1 ORDER BY revenue DESC;

-- Channel conversion, response time, and revenue
WITH booked AS (SELECT lead_id,COUNT(*) booked FROM bookings GROUP BY lead_id)
SELECT l.lead_source,COUNT(*) leads,SUM(COALESCE(booked,0)) bookings,
 ROUND(1.0*SUM(COALESCE(booked,0))/COUNT(*),3) conversion_rate,
 ROUND(AVG((julianday(first_response_at)-julianday(inquiry_date))*24),1) response_hours
FROM leads l LEFT JOIN booked USING(lead_id) GROUP BY 1 ORDER BY bookings DESC;

-- Outstanding balances
SELECT b.booking_id,c.first_name||' '||c.last_name client,b.booking_value,
 COALESCE(SUM(p.amount),0) paid,b.booking_value-COALESCE(SUM(p.amount),0) outstanding
FROM bookings b JOIN clients c USING(client_id) LEFT JOIN payments p USING(booking_id)
GROUP BY b.booking_id HAVING outstanding>0 ORDER BY outstanding DESC;

-- Workflow bottlenecks by outcome
SELECT booking_status,COUNT(*) bookings,ROUND(AVG(julianday(booking_date)-julianday(inquiry_date)),1) avg_days_to_book
FROM bookings JOIN leads USING(lead_id) GROUP BY booking_status;

