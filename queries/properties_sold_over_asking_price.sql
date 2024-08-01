SELECT
    p.property_id,
    a.address,
    a.city,
    a.state,
    a.zipcode,
    pt.type_name AS property_type,
    ps.status_name AS property_status,
    p.price AS asking_price,
    t.price AS transaction_price,
    t.price - p.price AS amount_over_asking,
    t.date AS transaction_date,
    t.commission,
    t.contract_signed_date,
    t.closing_date
FROM
    transactions t
JOIN properties p ON t.property_id = p.property_id
JOIN addresses a ON p.address_id = a.address_id
JOIN property_types pt ON p.type_id = pt.type_id
JOIN property_status ps ON p.status_id = ps.status_id
WHERE
    t.price > p.price
AND
    t.transaction_type_id = (
        SELECT type_id
        FROM transaction_types
        WHERE type_name = 'Sale'
    )
ORDER BY
    t.date DESC;
