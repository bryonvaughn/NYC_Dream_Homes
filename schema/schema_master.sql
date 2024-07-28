
-- property_types table
CREATE TABLE property_types (
    type_id SERIAL PRIMARY KEY,
    type_name VARCHAR(20) NOT NULL,
    CONSTRAINT chk_type_name CHECK (type_name IN ('Apartment', 'Townhouse', 'Condo', 'Villa', 'Studio'))
);

-- property_status table
CREATE TABLE property_status (
    status_id SERIAL PRIMARY KEY,
    status_name VARCHAR(20) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    CONSTRAINT chk_status_name CHECK (status_name IN ('Pending', 'Reserved', 'Sold', 'Listed', 'Unavailable'))
);

-- client_types table
CREATE TABLE client_types (
    client_type_id SERIAL PRIMARY KEY,
    type_name VARCHAR(20) NOT NULL,
    CONSTRAINT chk_type_name CHECK (type_name IN ('Corporate', 'Individual', 'Non-Profit', 'Government', 'Small Business', 'VIP'))
);

-- event_types table
CREATE TABLE event_types (
    type_id SERIAL PRIMARY KEY,
    type_name VARCHAR(20) NOT NULL,
    CONSTRAINT chk_type_name CHECK (type_name IN ('Personal Showing', 'Virtual Tour', 'Open House'))
);

-- transaction_types table
CREATE TABLE transaction_types (
    type_id SERIAL PRIMARY KEY,
    type_name VARCHAR(20) NOT NULL,
    CONSTRAINT chk_type_name CHECK (type_name IN ('Purchase', 'Sale', 'Rent'))
);

-- addresses table
CREATE TABLE addresses (
    address_id SERIAL PRIMARY KEY,
    address VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    state VARCHAR(50) NOT NULL,
    zipcode VARCHAR(15) NOT NULL,
    neighborhood VARCHAR(30)
);

-- person table
CREATE TABLE person (
    person_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(50) NOT NULL,
    phone_number VARCHAR(30),
    date_of_birth DATE,
    address_id INT REFERENCES addresses(address_id)
);

-- offices table
CREATE TABLE offices (
    office_id SERIAL PRIMARY KEY,
    office_name VARCHAR(100) NOT NULL,
    address_id INT REFERENCES addresses(address_id),
    phone_number VARCHAR(30),
    email VARCHAR(100),
    manager_id INT
);

-- employees table
CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    person_id INT REFERENCES person(person_id),
    office_id INT REFERENCES offices(office_id),
    employment_status VARCHAR(20) NOT NULL,
    sales_total NUMERIC(15, 2) DEFAULT 0.00,
    expense_budget NUMERIC(10, 2),
    hire_date DATE,
    termination_date DATE,
    CONSTRAINT chk_employment_status CHECK (employment_status IN ('Active', 'Inactive', 'On Leave', 'Terminated'))
);

-- Add foreign key constraint for manager_id in offices table
ALTER TABLE offices
ADD CONSTRAINT fk_manager_id
FOREIGN KEY (manager_id)
REFERENCES employees(employee_id);

-- agents table
-- this will be helpful to separate admin staff from agents that represent properties
CREATE TABLE agents (
    agent_id SERIAL PRIMARY KEY,
    employee_id INT REFERENCES employees(employee_id),
    license_number VARCHAR(50) NOT NULL,
    specialties TEXT,
    rating NUMERIC(3, 2) DEFAULT 0.00
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
    year_built INT,
    description TEXT,
    amenities TEXT,
    listing_date DATE,
    agent_id INT REFERENCES agents(agent_id)
);

-- clients table
CREATE TABLE clients (
    client_id SERIAL PRIMARY KEY,
    person_id INT REFERENCES person(person_id),
    preferred_contact_method VARCHAR(20),
    notes TEXT,
    client_type_id INT REFERENCES client_types(client_type_id)
);

-- client_interactions table
CREATE TABLE client_interactions (
    interaction_id SERIAL PRIMARY KEY,
    client_id INT REFERENCES clients(client_id),
    employee_id INT REFERENCES employees(employee_id),
    interaction_date DATE NOT NULL,
    interaction_type VARCHAR(50) NOT NULL,
    notes TEXT
);

-- transactions table
CREATE TABLE transactions (
    transaction_id SERIAL PRIMARY KEY,
    property_id INT REFERENCES properties(property_id),
    client_id INT REFERENCES clients(client_id),
    agent_id INT REFERENCES employees(employee_id),
    date DATE NOT NULL,
    transaction_type_id INT REFERENCES transaction_types(type_id),
    price NUMERIC(10, 4),
    commission NUMERIC(10, 4),
    contract_signed_date DATE,
    closing_date DATE
);

-- events table
CREATE TABLE events (
    event_id SERIAL PRIMARY KEY,
    type_id INT REFERENCES event_types(type_id),
    property_id INT REFERENCES properties(property_id),
    agent_id INT REFERENCES employees(employee_id),
    client_id INT REFERENCES clients(client_id),
    date DATE NOT NULL,
    client_attended BOOLEAN,
    duration INT
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

-- property_images table
-- this table will be used to manage all images of the property to be displayed
CREATE TABLE property_images (
    image_id SERIAL PRIMARY KEY,
    property_id INT REFERENCES properties(property_id),
    image_url VARCHAR(255) NOT NULL,
    description TEXT,
    uploaded_date DATE DEFAULT CURRENT_DATE
);

-- business_expenses Table
CREATE TABLE business_expenses (
    expense_id SERIAL PRIMARY KEY,
    office_id INT REFERENCES offices(office_id),
    expense_date DATE NOT NULL,
    expense_type VARCHAR(50) NOT NULL,
    amount NUMERIC(10, 2) NOT NULL,
    description TEXT,
    approved_by INT REFERENCES employees(employee_id),
    CONSTRAINT chk_expense_type CHECK (expense_type IN ('Office Supplies', 'Utilities', 'Rent', 'Marketing', 'Travel', 'Maintenance', 'Technology', 'Training', 'Event', 'Miscellaneous'))
);

-- Indexes for Business Expenses
CREATE INDEX idx_expense_date ON business_expenses(expense_date);
CREATE INDEX idx_expense_type ON business_expenses(expense_type);

-- Functions for calculated fields

-- Running total_sales for employees associated with transactions
CREATE OR REPLACE FUNCTION update_sales_total()
RETURNS TRIGGER AS $$
BEGIN
    -- Update the sales_total for the affected employee
    UPDATE employees e
    SET sales_total = (
        SELECT COALESCE(SUM(t.price), 0)
        FROM transactions t
        WHERE t.agent_id = e.employee_id
    )
    WHERE e.employee_id = NEW.agent_id OR e.employee_id = OLD.agent_id;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_sales_total_trigger
AFTER INSERT OR UPDATE OR DELETE ON transactions
FOR EACH ROW
EXECUTE FUNCTION update_sales_total();

-- Property is_active flag based on the status
CREATE OR REPLACE FUNCTION set_is_active()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status_name IN ('Listed', 'Reserved', 'Pending') THEN
        NEW.is_active := TRUE;
    ELSIF NEW.status_name IN ('Sold', 'Unavailable') THEN
        NEW.is_active := FALSE;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_is_active_trigger
BEFORE INSERT OR UPDATE ON property_status
FOR EACH ROW
EXECUTE FUNCTION set_is_active();
