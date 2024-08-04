SELECT 
    pt.type_name AS Property_Type,
    ROUND(AVG(t.closing_date - p.listing_date), 2) AS Avg_Days_Listed
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
    Avg_Days_Listed ASC;
