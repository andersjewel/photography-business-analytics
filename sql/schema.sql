PRAGMA foreign_keys=ON;
CREATE TABLE clients (client_id INTEGER PRIMARY KEY, first_name TEXT NOT NULL, last_name TEXT NOT NULL, email TEXT, phone TEXT, created_date DATE);
CREATE TABLE leads (lead_id INTEGER PRIMARY KEY, client_id INTEGER NOT NULL REFERENCES clients(client_id), lead_source TEXT NOT NULL, service_category TEXT NOT NULL, inquiry_date DATETIME NOT NULL, first_response_at DATETIME, lead_status TEXT);
CREATE TABLE packages (package_id INTEGER PRIMARY KEY, package_name TEXT UNIQUE NOT NULL, default_service TEXT, list_price REAL CHECK(list_price>=0), variable_cost REAL CHECK(variable_cost>=0), duration_minutes INTEGER CHECK(duration_minutes>0));
CREATE TABLE bookings (booking_id INTEGER PRIMARY KEY, lead_id INTEGER REFERENCES leads(lead_id), client_id INTEGER NOT NULL REFERENCES clients(client_id), package_id INTEGER REFERENCES packages(package_id), package_name TEXT, service_category TEXT, booking_date DATE, session_date DATE, booking_status TEXT CHECK(booking_status IN ('completed','confirmed','cancelled','rescheduled')), booking_value REAL CHECK(booking_value>=0));
CREATE TABLE sessions (session_id INTEGER PRIMARY KEY, booking_id INTEGER UNIQUE REFERENCES bookings(booking_id), actual_session_date DATE, session_status TEXT, images_delivered INTEGER CHECK(images_delivered>=0));
CREATE TABLE payments (payment_id INTEGER PRIMARY KEY, booking_id INTEGER REFERENCES bookings(booking_id), payment_date DATE, amount REAL CHECK(amount>=0), payment_method TEXT, timeliness TEXT);
CREATE TABLE expenses (expense_id INTEGER PRIMARY KEY, expense_date DATE, expense_category TEXT, amount REAL CHECK(amount>=0), description TEXT);

