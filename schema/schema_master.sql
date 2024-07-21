-- Creating roles for different levels of database access
CREATE ROLE read_only NOLOGIN;
CREATE ROLE data_entry NOLOGIN;
CREATE ROLE data_manager NOLOGIN;
CREATE ROLE admin SUPERUSER;

-- Granting role usage
GRANT read_only TO data_entry;
GRANT data_entry TO data_manager;
GRANT data_manager TO admin;

-- Supporting Tables

-- Agent Roles Table
CREATE TABLE agent_roles (
    role_id SERIAL PRIMARY KEY,
    description TEXT NOT NULL,
    role_type varchar(20) NOT NULL CHECK (role_type IN ('agent','vip'))
);

-- Property Types Table
CREATE TABLE Property_Types (
    Type_ID SERIAL PRIMARY KEY,
    Description TEXT NOT NULL
);

-- Property Status Table
CREATE TABLE Property_Status (
    Status_ID SERIAL PRIMARY KEY,
    Status_Description TEXT NOT NULL
);

-- Client Types Table
CREATE TABLE Client_Types (
    Client_Type_ID SERIAL PRIMARY KEY,
    Type_Description TEXT NOT NULL
);

-- Event Types Table
CREATE TABLE Event_Types (
    Type_ID SERIAL PRIMARY KEY,
    Description TEXT NOT NULL
);

-- Transaction Types Table
CREATE TABLE Transaction_Types (
    Type_ID SERIAL PRIMARY KEY,
    Description TEXT NOT NULL
);

-- Employees Table
CREATE TABLE Employees (
    Employee_ID SERIAL PRIMARY KEY,
    Name TEXT NOT NULL,
    Role_ID INT REFERENCES Agent_Roles(Role_ID),
    Office_ID INT,  -- This will be updated to a FK after Offices table creation
    Employment_Status TEXT NOT NULL,
    Performance_Metrics TEXT
);

-- Offices Table
CREATE TABLE Offices (
    Office_ID SERIAL PRIMARY KEY,
    Address TEXT NOT NULL,
    Contact_Info TEXT NOT NULL,
    Manager_ID INT REFERENCES Employees(Employee_ID)
);

-- Now adding foreign key constraint to Employees for Office_ID
ALTER TABLE Employees ADD CONSTRAINT fk_office_id FOREIGN KEY (Office_ID) REFERENCES Offices(Office_ID);

-- Properties Table
CREATE TABLE Properties (
    Property_ID SERIAL PRIMARY KEY,
    Address TEXT NOT NULL,
    Type_ID INT REFERENCES Property_Types(Type_ID),
    Price NUMERIC(10, 4) NOT NULL,
    Status_ID INT REFERENCES Property_Status(Status_ID)
);

-- Clients Table
CREATE TABLE Clients (
    Client_ID SERIAL PRIMARY KEY,
    Name TEXT NOT NULL,
    Contact_Info TEXT NOT NULL,
    Preferences TEXT,
    Client_Type_ID INT REFERENCES Client_Types(Client_Type_ID)
);

-- Transactions Table
CREATE TABLE Transactions (
    Transaction_ID SERIAL PRIMARY KEY,
    Property_ID INT REFERENCES Properties(Property_ID),
    Client_ID INT REFERENCES Clients(Client_ID),
    Agent_ID INT REFERENCES Employees(Employee_ID),
    Date DATE NOT NULL,
    Transaction_Type_ID INT REFERENCES Transaction_Types(Type_ID),
    Price NUMERIC(10, 4),
    Commission NUMERIC(10, 4)
);

-- Events Table
CREATE TABLE Events (
    Event_ID SERIAL PRIMARY KEY,
    Type_ID INT REFERENCES Event_Types(Type_ID),
    Date DATE NOT NULL,
    Property_ID INT REFERENCES Properties(Property_ID),
    Agent_ID INT REFERENCES Employees(Employee_ID),
    Client_Attendance TEXT
);

-- Office Equipments Table
CREATE TABLE Office_Equipments (
    Equipment_ID SERIAL PRIMARY KEY,
    Office_ID INT REFERENCES Offices(Office_ID),
    Description TEXT NOT NULL,
    Status TEXT NOT NULL
);

-- Maintenance Records Table
CREATE TABLE Maintenance_Records (
    Maintenance_ID SERIAL PRIMARY KEY,
    Equipment_ID INT REFERENCES Office_Equipments(Equipment_ID),
    Date DATE NOT NULL,
    Description TEXT NOT NULL,
    Cost NUMERIC(10, 4)
);

-- Property Sales History Table
CREATE TABLE Property_Sales_History (
    Sale_ID SERIAL PRIMARY KEY,
    Property_ID INT REFERENCES Properties(Property_ID),
    Sale_Date DATE NOT NULL,
    Price NUMERIC(10, 4),
    Buyer_ID INT REFERENCES Clients(Client_ID),
    Seller_ID INT REFERENCES Clients(Client_ID)
);

-- Setting up row-level security and policies for sensitive tables
ALTER TABLE Offices ENABLE ROW LEVEL SECURITY;
CREATE POLICY office_access ON Offices FOR SELECT USING (true);

ALTER TABLE Employees ENABLE ROW LEVEL SECURITY;
CREATE POLICY employee_access ON Employees FOR SELECT USING (true);

-- Granting table-level privileges
GRANT SELECT ON ALL TABLES IN SCHEMA public TO read_only;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA public TO data_entry;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO admin;

-- Ensuring only admin can modify user roles and row-level security policies
REVOKE ALL ON SCHEMA public FROM PUBLIC;
GRANT USAGE ON SCHEMA public TO read_only, data_entry, data_manager, admin;