SELECT
    pe.name AS employee_name,
    COUNT(ci.interaction_id) AS total_interactions
FROM
    client_interactions ci
    JOIN employees e ON ci.employee_id = e.employee_id
    JOIN person pe ON e.person_id = pe.person_id
GROUP BY
    pe.name
ORDER BY
    total_interactions DESC;