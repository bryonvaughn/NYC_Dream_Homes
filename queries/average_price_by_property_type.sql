SELECT
    pt.type_name AS property_type,
    ROUND(SUM(p.price)::numeric, 2) AS average_price
FROM
    properties p
    JOIN property_types pt ON p.type_id = pt.type_id
GROUP BY
    pt.type_name
ORDER BY
    average_price DESC;