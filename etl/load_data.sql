-- PERSONS

-- Insert unique addresses into the address table
INSERT INTO addresses (address, city, state, zipcode, neighborhood)
SELECT DISTINCT address, city, state, zipcode, neighborhood
FROM tmp_clients
UNION
SELECT DISTINCT address, city, state, zipcode, neighborhood
FROM tmp_employees
UNION
SELECT DISTINCT address, city, state, zipcode, neighborhood
FROM tmp_offices;

-- Insert unique persons into the person table
INSERT INTO person (name, email, phone_number, date_of_birth, address_id)
SELECT DISTINCT e.name, e.email, e.phone_number, e.date_of_birth, a.address_id
FROM tmp_employees e
JOIN addresses a ON e.address = a.address AND e.city = a.city AND e.state = a.state AND e.zipcode = a.zipcode
UNION
SELECT DISTINCT c.name, c.email, c.phone_number, c.date_of_birth, a.address_id
FROM tmp_clients c
JOIN addresses a ON c.address = a.address AND c.city = a.city AND c.state = a.state AND c.zipcode = a.zipcode;

-- Insert client types into the client_types table
INSERT INTO client_types (type_name)
SELECT DISTINCT client_type
FROM tmp_clients;

-- Insert data into clients table with references to person_id and client_type_id
INSERT INTO clients (person_id, preferred_contact_method, notes, client_type_id)
SELECT per.person_id, c.preferred_contact_method, c.notes, ct.client_type_id
FROM tmp_clients c
JOIN person per ON c.name = per.name AND c.email = per.email AND c.phone_number = per.phone_number
JOIN client_types ct ON c.client_type = ct.type_name;

-- Insert offices into the offices table
INSERT INTO offices (office_name, address_id, phone_number, email)
SELECT tof.office_name, a.address_id, tof.phone_number, tof.email
FROM tmp_offices tof
JOIN addresses a ON tof.address = a.address AND tof.city = a.city AND tof.state = a.state AND tof.zipcode = a.zipcode AND tof.neighborhood = a.neighborhood;

-- Insert data into employees table with references to person_id and address_id
INSERT INTO employees (person_id, office_id, employment_status, sales_total, hire_date, termination_date)
SELECT per.person_id, o.office_id, e.employment_status, e.sales_total, e.hire_date, e.termination_date
FROM tmp_employees e
JOIN person per ON e.name = per.name AND e.email = per.email AND e.phone_number = per.phone_number
JOIN addresses a ON e.address = a.address AND e.city = a.city AND e.state = a.state AND e.zipcode = a.zipcode AND e.neighborhood = a.neighborhood
JOIN offices o ON e.office_phone_number = o.phone_number AND e.office_email = o.email;

-- Insert data into agents table with references to employee_id
INSERT INTO agents (employee_id, license_number, specialties, rating)
SELECT emp.employee_id, e.license_number, e.specialties, e.rating
FROM tmp_employees e
JOIN person per ON e.name = per.name AND e.email = per.email AND e.phone_number = per.phone_number
JOIN employees emp ON emp.person_id = per.person_id
WHERE e.license_number IS NOT NULL;

-- Insert data into client_interactions table
INSERT INTO client_interactions (client_id, employee_id, interaction_date, interaction_type, notes)
SELECT cl.client_id, e.employee_id, ci.interaction_date, ci.interaction_type, ci.notes
FROM tmp_client_interactions ci
JOIN person cp ON ci.client_name = cp.name AND ci.client_email = cp.email AND ci.client_date_of_birth = cp.date_of_birth
JOIN clients cl ON cp.person_id = cl.person_id
JOIN person ap ON ci.agent_name = ap.name AND ci.agent_email = ap.email AND ci.agent_date_of_birth = ap.date_of_birth
JOIN employees e ON ap.person_id = e.person_id;

-- PROPERTIES

-- Insert unique addresses into the address table
INSERT INTO addresses (address, city, state, zipcode, neighborhood)
SELECT DISTINCT address, city, state, zipcode, neighborhood
FROM tmp_properties;

-- Insert property types into the property_types table
INSERT INTO property_types (type_name)
SELECT DISTINCT type_name
FROM tmp_properties;

-- Insert property statuses into the property_status table
INSERT INTO property_status (status_name)
SELECT DISTINCT status_name
FROM tmp_properties;

-- Insert properties into the properties table
INSERT INTO properties (address_id, type_id, status_id, price, square_feet, number_of_bedrooms, number_of_bathrooms, year_built, description, amenities, listing_date, agent_id)
SELECT a.address_id, pt.type_id, ps.status_id, tp.price, tp.square_feet, tp.number_of_bedrooms, tp.number_of_bathrooms, tp.year_built, tp.description, tp.amenities, tp.listing_date, ag.agent_id
FROM tmp_properties tp
JOIN addresses a ON tp.address = a.address AND tp.city = a.city AND tp.state = a.state AND tp.zipcode = a.zipcode
JOIN property_types pt ON tp.type_name = pt.type_name
JOIN property_status ps ON tp.status_name = ps.status_name
JOIN person p ON tp.agent_name = p.name AND tp.agent_email = p.email AND tp.agent_phone = p.phone_number AND tp.agent_date_of_birth = p.date_of_birth
JOIN employees e ON p.person_id = e.person_id
JOIN agents ag ON e.employee_id = ag.employee_id;

-- Insert data into property_reviews table
INSERT INTO property_reviews (property_id, client_id, review_date, rating, review_text)
SELECT p.property_id, c.client_id, pr.review_date, pr.rating, pr.review_text
FROM tmp_property_reviews pr
JOIN addresses a ON pr.property_address = a.address AND pr.property_city = a.city AND pr.property_state = a.state AND pr.property_zipcode = a.zipcode
JOIN properties p ON a.address_id = p.address_id
JOIN person cp ON pr.client_name = cp.name AND pr.client_email = cp.email AND pr.client_date_of_birth = cp.date_of_birth
JOIN clients c ON cp.person_id = c.person_id;

-- Insert data into property_images table
INSERT INTO property_images (property_id, image_url, description, uploaded_date)
SELECT p.property_id, pi.image_url, pi.description, pi.uploaded_date
FROM tmp_property_images pi
JOIN addresses a ON pi.property_address = a.address AND pi.property_city = a.city AND pi.property_state = a.state AND pi.property_zipcode = a.zipcode
JOIN properties p ON a.address_id = p.address_id;

-- EVENTS

-- Insert event types into the event_types table
INSERT INTO event_types (type_name)
SELECT DISTINCT type_name
FROM tmp_events;

-- Insert events into the events table
INSERT INTO events (type_id, property_id, agent_id, client_id, date, client_attended, duration)
SELECT et.type_id, p.property_id, ag.agent_id, c.client_id, te.date, te.client_attended, te.duration
FROM tmp_events te
JOIN event_types et ON te.type_name = et.type_name
JOIN addresses a ON te.property_address = a.address AND te.property_zipcode = a.zipcode
JOIN properties p ON a.address_id = p.address_id
JOIN person cp ON te.client_name = cp.name AND te.client_email = cp.email AND te.client_date_of_birth = cp.date_of_birth
JOIN clients c ON cp.person_id = c.person_id
JOIN person ap ON te.agent_name = ap.name AND te.agent_email = ap.email AND te.agent_phone = ap.phone_number AND te.agent_date_of_birth = ap.date_of_birth
JOIN employees e ON ap.person_id = e.person_id
JOIN agents ag ON e.employee_id = ag.employee_id;

-- TRANSACTIONS

-- Insert event types into the event_types table
INSERT INTO transaction_types (type_name)
SELECT DISTINCT transaction_type
FROM tmp_transactions;

-- Insert transactions into the transactions table
INSERT INTO transactions (property_id, client_id, agent_id, date, transaction_type_id, price, commission, contract_signed_date, closing_date)
SELECT p.property_id,c.client_id,ag.agent_id,tt.date,tt_type.type_id,tt.price,tt.commission,tt.contract_signed_date,tt.closing_date
FROM tmp_transactions tt
JOIN addresses a ON tt.property_address = a.address AND tt.property_zipcode = a.zipcode
JOIN properties p ON a.address_id = p.address_id
JOIN person cp ON tt.client_name = cp.name AND tt.client_email = cp.email AND tt.client_date_of_birth = cp.date_of_birth
JOIN clients c ON cp.person_id = c.person_id
JOIN person ap ON tt.agent_name = ap.name AND tt.agent_email = ap.email AND tt.agent_phone = ap.phone_number AND tt.agent_date_of_birth = ap.date_of_birth
JOIN employees e ON ap.person_id = e.person_id
JOIN agents ag ON e.employee_id = ag.employee_id
JOIN transaction_types tt_type ON tt.transaction_type = tt_type.type_name;

-- OTHER TABLES

-- Insert data into business_expenses table
INSERT INTO business_expenses (office_id, expense_date, expense_type, amount, description, approved_by)
SELECT o.office_id, tbe.expense_date, tbe.expense_type, tbe.amount, tbe.description, e.employee_id
FROM tmp_business_expenses tbe
JOIN addresses a ON tbe.office_address = a.address AND tbe.office_city = a.city AND tbe.office_state = a.state AND tbe.office_zipcode = a.zipcode
JOIN offices o ON a.address_id = o.address_id AND tbe.office_name = o.office_name
JOIN person p ON tbe.approved_by_name = p.name AND tbe.approved_by_email = p.email AND tbe.approved_by_phone_number = p.phone_number
JOIN employees e ON p.person_id = e.person_id;
