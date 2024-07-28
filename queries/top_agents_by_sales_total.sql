SELECT
    p.name AS agent_name,
    e.sales_total AS total_sales,
    COUNT(t.transaction_id) AS total_transactions
FROM
    agents a
    JOIN employees e ON a.employee_id = e.employee_id
    JOIN person p ON e.person_id = p.person_id
    JOIN transactions t ON t.agent_id = e.employee_id
GROUP BY
    p.name, e.sales_total
ORDER BY
    e.sales_total DESC
LIMIT 10;