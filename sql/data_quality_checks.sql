SELECT email, COUNT(*) duplicate_count FROM clients WHERE email<>'' GROUP BY email HAVING COUNT(*)>1;
SELECT * FROM payments WHERE amount<0;
SELECT b.booking_id FROM bookings b LEFT JOIN sessions s ON b.booking_id=s.booking_id WHERE b.booking_status='completed' AND s.session_id IS NULL;
SELECT * FROM bookings WHERE package_name IS NULL OR TRIM(package_name)='';
SELECT lead_source, COUNT(*) FROM leads GROUP BY lead_source ORDER BY 2 DESC;

