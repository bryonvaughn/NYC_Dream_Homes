/*--------------------------
  Sales Performance Section
----------------------------*/
-- Total Sales By Month
SELECT 
    DATE_TRUNC('month', t.closing_date) AS Month,
    SUM(t.price) AS Total_Sales
FROM 
    transactions t
WHERE 
    t.transaction_type_id = (SELECT type_id FROM transaction_types WHERE type_name = 'Sale')
GROUP BY 
    DATE_TRUNC('month', t.closing_date)
ORDER BY 
    Month;

-- Sales By Property Type
SELECT 
    pt.type_name AS Property_Type,
    SUM(t.price) AS Total_Sales
FROM 
    transactions t
JOIN 
    properties p ON t.property_id = p.property_id
JOIN 
    property_types pt ON p.type_id = pt.type_id
WHERE 
    t.transaction_type_id = (SELECT type_id FROM transaction_types WHERE type_name = 'Sale')
GROUP BY 
    pt.type_name
ORDER BY 
    Total_Sales DESC;

/*--------------------------
  Agent Performance Section
----------------------------*/

-- Top Performing Agents

SELECT 
    p.name AS Agent_Name,
    SUM(t.price) AS Total_Sales,
    COUNT(t.transaction_id) AS Total_Transactions
FROM 
    transactions t
JOIN 
    agents a ON t.agent_id = a.employee_id
JOIN 
    person p ON a.employee_id = p.person_id
GROUP BY 
    p.name
ORDER BY 
    Total_Sales DESC;

-- Agent Commissions
SELECT 
    p.name AS Agent_Name,
    SUM(t.commission) AS Total_Commission,
    COUNT(t.transaction_id) AS Total_Transactions
FROM 
    transactions t
JOIN 
    agents a ON t.agent_id = a.employee_id
JOIN 
    person p ON a.employee_id = p.person_id
GROUP BY 
    p.name
ORDER BY 
    Total_Commission DESC;

/*--------------------------
  Client Metrics Section
----------------------------*/

-- Purchase Patterns By Client Type
SELECT 
    ct.type_name AS Client_Type,
    COUNT(t.transaction_id) AS Total_Purchases,
    ROUND(AVG(t.price)::numeric, 2) AS Avg_Purchase_Amount
FROM 
    transactions t
JOIN 
    clients c ON t.client_id = c.client_id
JOIN 
    client_types ct ON c.client_type_id = ct.client_type_id
WHERE 
    t.transaction_type_id = (SELECT type_id FROM transaction_types WHERE type_name = 'Purchase')
GROUP BY 
    ct.type_name
ORDER BY 
    Total_Purchases DESC;

/*--------------------------
  Property Metrics Section
----------------------------*/

-- Property Listings By Status
SELECT 
    ps.status_name AS Status,
    COUNT(p.property_id) AS Total_Properties
FROM 
    properties p
JOIN 
    property_status ps ON p.status_id = ps.status_id
GROUP BY 
    ps.status_name
ORDER BY 
    Total_Properties DESC;

-- Average Days on Market By Property Type
SELECT 
    pt.type_name AS Property_Type,
    ROUND(AVG(t.closing_date - p.listing_date)::numeric, 2) AS Avg_Days_On_Market
FROM 
    properties p
JOIN 
    transactions t ON p.property_id = t.property_id
JOIN 
    property_types pt ON p.type_id = pt.type_id
WHERE 
    t.transaction_type_id = (SELECT type_id FROM transaction_types WHERE type_name = 'Sale')
GROUP BY 
    pt.type_name
ORDER BY 
    Avg_Days_On_Market ASC;

/*--------------------------
  Expense Metrics Section
----------------------------*/

-- Expenses By Office
SELECT 
    o.office_name AS Office,
    be.expense_type AS Expense_Type,
    SUM(be.amount) AS Total_Amount
FROM 
    business_expenses be
JOIN 
    offices o ON be.office_id = o.office_id
GROUP BY 
    o.office_name, be.expense_type
ORDER BY 
    Total_Amount DESC;


-- Others

--Average Days on Market
SELECT 
    pt.type_name AS Property_Type,
    ROUND(AVG(t.closing_date - p.listing_date), 2) AS Avg_Days_On_Market
FROM 
    transactions t
JOIN 
    properties p ON t.property_id = p.property_id
JOIN 
    property_types pt ON p.type_id = pt.type_id
WHERE 
    t.transaction_type_id = (SELECT type_id FROM transaction_types WHERE type_name = 'Sale')
GROUP BY 
    pt.type_name
ORDER BY 
    Avg_Days_On_Market ASC;
