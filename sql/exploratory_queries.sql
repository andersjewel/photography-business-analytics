WITH monthly AS (
 SELECT substr(payment_date,1,7) month, SUM(amount) revenue FROM payments GROUP BY 1
)
SELECT month,revenue,LAG(revenue) OVER(ORDER BY month) prior_month,
 ROUND((revenue/LAG(revenue) OVER(ORDER BY month)-1)*100,1) growth_pct FROM monthly;

SELECT b.service_category,COUNT(*) bookings,SUM(p.amount) revenue
FROM bookings b LEFT JOIN payments p USING(booking_id) GROUP BY 1 ORDER BY revenue DESC;

