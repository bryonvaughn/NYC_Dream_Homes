WITH neighborhood_prices AS (
    SELECT 
        a.neighborhood,
        AVG(p.price) AS average_price,
        MIN(p.price) AS min_price,
        MAX(p.price) AS max_price,
        COUNT(p.property_id) AS total_properties,
        SUM(CASE WHEN p.price > (SELECT AVG(price) FROM properties) THEN 1 ELSE 0 END) AS high_value_transactions
    FROM 
        properties p
    JOIN 
        addresses a ON p.address_id = a.address_id
    GROUP BY 
        a.neighborhood
),
top_agents AS (
    SELECT 
        a.neighborhood,
        emp_per.name AS agent_name,
        COUNT(t.transaction_id) AS total_transactions,
        SUM(t.price) AS total_transaction_value
    FROM 
        transactions t
    JOIN 
        properties p ON t.property_id = p.property_id
    JOIN 
        addresses a ON p.address_id = a.address_id
    JOIN 
        employees e ON t.agent_id = e.employee_id
    JOIN 
        person emp_per ON e.person_id = emp_per.person_id
    GROUP BY 
        a.neighborhood, emp_per.name
    ORDER BY 
        total_transaction_value DESC
),
neighborhood_top_agents AS (
    SELECT
        neighborhood,
        agent_name,
        total_transactions,
        total_transaction_value,
        ROW_NUMBER() OVER (PARTITION BY neighborhood ORDER BY total_transaction_value DESC) AS rank
    FROM
        top_agents
)
SELECT 
    np.neighborhood,
    np.average_price,
    np.min_price,
    np.max_price,
    np.total_properties,
    np.high_value_transactions,
    nta.agent_name,
    nta.total_transactions AS agent_transactions,
    nta.total_transaction_value AS agent_transaction_value
FROM 
    neighborhood_prices np
LEFT JOIN 
    neighborhood_top_agents nta ON np.neighborhood = nta.neighborhood AND nta.rank = 1
ORDER BY 
    np.average_price DESC
LIMIT 10;
