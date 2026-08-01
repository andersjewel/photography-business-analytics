# Power BI Build Guide

> Independent portfolio case study using synthetic data inspired by common photography-business workflows.

Use a star schema with `bookings`/analytics as the booking fact, `payments` and `expenses` as transaction facts, and Date, Client, Package, Lead Source, and Service as dimensions. Create one-to-many single-direction relationships from each dimension; keep active date relationships to booking/payment/expense dates as appropriate. Add a marked Date table with Year, Quarter, Month, Month Number, and Year-Month. Calculated columns: booking outcome group, balance status, response-time band, and client type.

Pages: (1) Executive Overview—KPI cards, monthly revenue, package rank, outcome mix; (2) Sales and Revenue—service/package trends and margin; (3) Marketing Performance—source funnel, conversion, response time; (4) Client Behavior—repeat rate, segment, service; (5) Operations and Payments—outstanding table, lateness, completion, bottlenecks. Slicers: date, service, package, source, booking status. Drill through from source/package/client to booking detail. Apply currency/percentage formats and accessible Wildlight colors.

