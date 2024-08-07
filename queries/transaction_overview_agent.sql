WITH transaction_summary AS (
    SELECT 
        t.transaction_id,
        a.address,
        a.city,
        a.state,
        a.zipcode,
        a.neighborhood,
        pt.type_name AS property_type,
        ps.status_name AS property_status,
        c.client_id,
        cl_type.type_name AS client_type,
        per.name AS client_name,
        e.employee_id AS agent_id,
        emp_per.name AS agent_name,
        tt.type_name AS transaction_type,
        t.date AS transaction_date,
        t.price AS transaction_value,
        t.commission,
        t.contract_signed_date,
        t.closing_date
    FROM 
        transactions t
    JOIN 
        properties p ON t.property_id = p.property_id
    JOIN 
        addresses a ON p.address_id = a.address_id
    JOIN 
        property_types pt ON p.type_id = pt.type_id
    JOIN 
        property_status ps ON p.status_id = ps.status_id
    JOIN 
        clients c ON t.client_id = c.client_id
    JOIN 
        client_types cl_type ON c.client_type_id = cl_type.client_type_id
    JOIN 
        person per ON c.person_id = per.person_id
    JOIN 
        employees e ON t.agent_id = e.employee_id
    JOIN 
        person emp_per ON e.person_id = emp_per.person_id
    JOIN 
        transaction_types tt ON t.transaction_type_id = tt.type_id
    WHERE 
        t.date >= CURRENT_DATE - INTERVAL '1 year'
),
agent_performance AS (
    SELECT
        agent_id,
        agent_name,
        COUNT(*) AS total_transactions,
        SUM(transaction_value) AS total_transaction_value,
        SUM(commission) AS total_commission
    FROM 
        transaction_summary
    GROUP BY 
        agent_id, agent_name
)
SELECT 
    ts.transaction_id,
    ts.address,
    ts.city,
    ts.state,
    ts.zipcode,
    ts.neighborhood,
    ts.property_type,
    ts.property_status,
    ts.client_name,
    ts.client_type,
    ts.agent_name,
    ts.transaction_type,
    ts.transaction_date,
    ts.transaction_value,
    ts.commission,
    ts.contract_signed_date,
    ts.closing_date,
    ap.total_transactions,
    ap.total_transaction_value,
    ap.total_commission,
    ROW_NUMBER() OVER (ORDER BY ap.total_transaction_value DESC) AS agent_rank
FROM 
    transaction_summary ts
JOIN 
    agent_performance ap ON ts.agent_id = ap.agent_id
ORDER BY 
    ts.transaction_date DESC;
