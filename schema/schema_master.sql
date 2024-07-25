-- Creating roles for different levels of database access
CREATE ROLE read_only NOLOGIN;
CREATE ROLE data_entry NOLOGIN;
CREATE ROLE data_manager NOLOGIN;
CREATE ROLE admin SUPERUSER;

-- Granting role usage
GRANT read_only TO data_entry;
GRANT data_entry TO data_manager;
GRANT data_manager TO admin;

-- user_roles table
-- this is the table to determine what access should be granted based on roles
CREATE TABLE user_roles (
    role_id SERIAL PRIMARY KEY,
    role_name VARCHAR(20) NOT NULL,
    description TEXT NOT NULL,
    access_level VARCHAR(20) NOT NULL,
    creation_date DATE DEFAULT CURRENT_DATE,
    is_active BOOLEAN DEFAULT TRUE,
    CONSTRAINT chk_access_level CHECK (access_level IN ('read_only', 'data_entry', 'data_manager', 'admin')),
    CONSTRAINT chk_role_name CHECK (role_name IN ('Manager', 'Intern', 'Executive', 'Supervisor'))
);

-- Property Types Table
CREATE TABLE property_types (
    type_id SERIAL PRIMARY KEY,
    type_name VARCHAR(20) NOT NULL,
    CONSTRAINT chk_type_name CHECK (type_name IN ('Apartment', 'Townhouse', 'Condo', 'Villa', 'Studio'))
);

-- Property Status Table
CREATE TABLE property_status (
    status_id SERIAL PRIMARY KEY,
    status_name VARCHAR(20) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    CONSTRAINT chk_status_name CHECK (status_name IN ('Pending', 'Reserved', 'Sold', 'Listed', 'Unavailable'))
);

-- Client Types Table
CREATE TABLE client_types (
    client_type_id SERIAL PRIMARY KEY,
    type_name VARCHAR(20) NOT NULL,
    type_description VARCHAR(200) NOT NULL,
    CONSTRAINT chk_type_name CHECK (type_name IN ('Corporate', 'Individual', 'Non-Profit', 'Government', 'Small Business', 'VIP'))
);

-- Event Types Table
CREATE TABLE event_types (
    type_id SERIAL PRIMARY KEY,
    type_name VARCHAR(20) NOT NULL,
    CONSTRAINT chk_type_name CHECK (type_name IN ('Room Tour', 'Corporate Party', 'Networking Event', 'Open House'))
);

-- Transaction Types Table
CREATE TABLE transaction_types (
    type_id SERIAL PRIMARY KEY,
    type_name VARCHAR(20) NOT NULL,
    CONSTRAINT chk_type_name CHECK (type_name IN ('Deposit', 'Withdrawal', 'Transfer', 'Payment', 'Refund', 'Charge'))
);

-- Addresses Table
CREATE TABLE addresses (
    address_id SERIAL PRIMARY KEY,
    address VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    state VARCHAR(50) NOT NULL,
    zipcode VARCHAR(15) NOT NULL
);

-- employees Table
CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(50) NOT NULL,
    phone_number VARCHAR(20),
    address_id INT REFERENCES addresses(address_id),
    role_id INT REFERENCES agent_roles(role_id),
    office_id INT, 
    employment_status VARCHAR(20) NOT NULL,
    sales_total NUMERIC(15, 2) DEFAULT 0.00,
    CONSTRAINT chk_employment_status CHECK (employment_status IN ('Active', 'Inactive', 'On Leave', 'Terminated'))
);

-- agents table
-- this will be helpful to separate admin staff from agents that represent properties
CREATE TABLE agents (
    agent_id SERIAL PRIMARY KEY,
    employee_id INT REFERENCES employees(employee_id),
    license_number VARCHAR(50) NOT NULL,
    specialties TEXT,
    rating NUMERIC(3, 2) DEFAULT 0.00
);

-- offices table
CREATE TABLE offices (
    office_id SERIAL PRIMARY KEY,
    office_name VARCHAR(100) NOT NULL,
    address_id INT REFERENCES addresses(address_id),
    phone_number VARCHAR(20),
    email VARCHAR(100),
    manager_id INT REFERENCES employees(employee_id)
);

-- properties table
CREATE TABLE properties (
    property_id SERIAL PRIMARY KEY,
    address_id INT REFERENCES addresses(address_id),
    type_id INT REFERENCES property_types(type_id),
    price NUMERIC(10, 4) NOT NULL,
    status_id INT REFERENCES property_status(status_id),
    square_feet INT,
    number_of_bedrooms INT,
    number_of_bathrooms INT,
    year_built INT
);

-- property_images table
-- this table will be used to manage all images of the property to be displayed
CREATE TABLE property_images (
    image_id SERIAL PRIMARY KEY,
    property_id INT REFERENCES properties(property_id),
    image_url VARCHAR(255) NOT NULL,
    description TEXT,
    uploaded_date DATE DEFAULT CURRENT_DATE
);

-- property_visits table
-- this table will be used to track history of visits of potential clients
CREATE TABLE property_visits (
    visit_id SERIAL PRIMARY KEY,
    property_id INT REFERENCES properties(property_id),
    client_id INT REFERENCES clients(client_id),
    visit_date DATE NOT NULL,
    agent_id INT REFERENCES employees(employee_id),
    feedback TEXT
);

-- clients table
CREATE TABLE clients (
    client_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(50),
    phone_number VARCHAR(20),
    date_of_birth DATE,
    address_id INT REFERENCES addresses(address_id),
    client_type_id INT REFERENCES client_types(client_type_id)
);

-- property_reviews table
-- this table will be used to store reviews and ratings by clients for properties
CREATE TABLE property_reviews (
    review_id SERIAL PRIMARY KEY,
    property_id INT REFERENCES properties(property_id),
    client_id INT REFERENCES clients(client_id),
    review_date DATE NOT NULL,
    rating INT CHECK (rating >= 1 AND rating <= 5),
    review_text TEXT
);

-- client_interactions
CREATE TABLE client_interactions (
    interaction_id SERIAL PRIMARY KEY,
    client_id INT REFERENCES clients(client_id),
    employee_id INT REFERENCES employees(employee_id),
    interaction_date DATE NOT NULL,
    interaction_type VARCHAR(50) NOT NULL,
    notes TEXT
);

-- transactions Table
CREATE TABLE transactions (
    transaction_id SERIAL PRIMARY KEY,
    property_id INT REFERENCES properties(property_id),
    client_id INT REFERENCES clients(client_id),
    agent_id INT REFERENCES employees(employee_id),
    date DATE NOT NULL,
    transaction_type_id INT REFERENCES transaction_types(type_id),
    price NUMERIC(10, 4),
    commission NUMERIC(10, 4),
    payment_status VARCHAR(20) CHECK (payment_status IN ('Pending', 'Completed', 'Failed'))
);

-- events Table
CREATE TABLE events (
    event_id SERIAL PRIMARY KEY,
    type_id INT REFERENCES event_types(type_id),
    date DATE NOT NULL,
    property_id INT REFERENCES properties(property_id),
    agent_id INT REFERENCES employees(employee_id),
    participant_number INT,
    host VARCHAR(50),
    client_attendance TEXT
);

-- Property Sales History Table
CREATE TABLE property_sales_history (
    sale_id SERIAL PRIMARY KEY,
    property_id INT REFERENCES properties(property_id),
    sale_date DATE NOT NULL,
    price NUMERIC(10, 4),
    buyer_id INT REFERENCES clients(client_id),
    seller_id INT REFERENCES clients(client_id),
    agent_id INT REFERENCES employees(employee_id)
);

-- Payments Table
CREATE TABLE payments (
    payment_id SERIAL PRIMARY KEY,
    transaction_id INT REFERENCES transactions(transaction_id),
    payment_date DATE NOT NULL,
    amount NUMERIC(10, 4) NOT NULL,
    payment_method VARCHAR(20) CHECK (payment_method IN ('Credit Card', 'Bank Transfer', 'Cash', 'Check')),
    status VARCHAR(20) CHECK (status IN ('Pending', 'Completed', 'Failed'))
);

-- Leases Table
CREATE TABLE leases (
    lease_id SERIAL PRIMARY KEY,
    property_id INT REFERENCES properties(property_id),
    client_id INT REFERENCES clients(client_id),
    agent_id INT REFERENCES employees(employee_id),
    lease_start_date DATE NOT NULL,
    lease_end_date DATE NOT NULL,
    monthly_rent NUMERIC(10, 4) NOT NULL,
    deposit_amount NUMERIC(10, 4)
);


-- Setting up row-level security and policies for sensitive tables
ALTER TABLE offices ENABLE ROW LEVEL SECURITY;
CREATE POLICY office_access ON offices FOR SELECT USING (true);

ALTER TABLE employees ENABLE ROW LEVEL SECURITY;
CREATE POLICY employee_access ON employees FOR SELECT USING (true);

-- Granting table-level privileges
GRANT SELECT ON ALL TABLES IN SCHEMA public TO read_only;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA public TO data_entry;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO admin;

-- Ensuring only admin can modify user roles and row-level security policies
REVOKE ALL ON SCHEMA public FROM PUBLIC;
GRANT USAGE ON SCHEMA public TO read_only, data_entry, data_manager, admin;
