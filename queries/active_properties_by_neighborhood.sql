SELECT
    a.neighborhood,
    COUNT(p.property_id) AS total_active_properties
FROM
    properties p
    JOIN addresses a ON p.address_id = a.address_id
    JOIN property_status ps ON p.status_id = ps.status_id
WHERE
    ps.is_active = TRUE
GROUP BY
    a.neighborhood
ORDER BY
    total_active_properties DESC;