WITH interaction_stats AS (
    SELECT 
        client_id,
        COUNT(*) AS total_interactions,
        MAX(interaction_date) AS last_interaction_date,
        STRING_AGG(DISTINCT interaction_type, ', ') AS interaction_types
    FROM 
        client_interactions
    GROUP BY 
        client_id
),
employee_performance AS (
    SELECT 
        employee_id,
        COUNT(*) AS total_interactions,
        AVG(CURRENT_DATE - interaction_date) AS avg_days_since_interaction
    FROM 
        client_interactions
    GROUP BY 
        employee_id
),
client_transactions AS (
    SELECT 
        client_id,
        COUNT(*) AS transaction_count,
        SUM(price) AS total_transaction_value
    FROM 
        transactions
    GROUP BY 
        client_id
)
SELECT 
    ci.interaction_id,
    p.name AS client_name,
    ct.type_name AS client_type,
    ep.name AS employee_name,
    ci.interaction_date,
    ci.interaction_type,
    ci.notes,
    o.office_name,
    is_stats.total_interactions AS client_total_interactions,
    is_stats.last_interaction_date,
    is_stats.interaction_types AS client_interaction_types,
    emp_perf.total_interactions AS employee_total_interactions,
    ROUND(emp_perf.avg_days_since_interaction::numeric, 2) AS employee_avg_days_since_interaction,
    COALESCE(cl_trans.transaction_count, 0) AS client_transaction_count,
    COALESCE(cl_trans.total_transaction_value, 0) AS client_total_transaction_value,
    ROUND(COALESCE(cl_trans.total_transaction_value, 0) / NULLIF(is_stats.total_interactions, 0), 2) AS value_per_interaction,
    ROW_NUMBER() OVER (PARTITION BY o.office_id ORDER BY is_stats.total_interactions DESC) AS client_rank_in_office
FROM 
    client_interactions ci
JOIN 
    clients c ON ci.client_id = c.client_id
JOIN 
    person p ON c.person_id = p.person_id
JOIN 
    client_types ct ON c.client_type_id = ct.client_type_id
JOIN 
    employees e ON ci.employee_id = e.employee_id
JOIN 
    person ep ON e.person_id = ep.person_id
JOIN 
    offices o ON e.office_id = o.office_id
LEFT JOIN 
    interaction_stats is_stats ON c.client_id = is_stats.client_id
LEFT JOIN 
    employee_performance emp_perf ON e.employee_id = emp_perf.employee_id
LEFT JOIN 
    client_transactions cl_trans ON c.client_id = cl_trans.client_id
WHERE 
    ci.interaction_date >= CURRENT_DATE - INTERVAL '6 months'
    AND ct.type_name != 'VIP'
ORDER BY 
    value_per_interaction DESC NULLS LAST,
    ci.interaction_date DESC
LIMIT 
    100;