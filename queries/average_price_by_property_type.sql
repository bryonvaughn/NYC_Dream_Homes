SELECT
    pt.type_name AS property_type,
    TO_CHAR(AVG(p.price), 'FM$999,999,999,999.00') AS average_price
FROM
    properties p
    JOIN property_types pt ON p.type_id = pt.type_id
GROUP BY
    pt.type_name
ORDER BY
    average_price DESC;