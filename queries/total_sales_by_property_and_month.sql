SELECT 
    pt.type_name AS Property_Type,
    DATE_TRUNC('month', t.closing_date) AS Month,
    ROUND(SUM(t.price)::numeric, 2) AS Total_Sales
FROM 
    transactions t
JOIN 
    properties p ON t.property_id = p.property_id
JOIN 
    property_types pt ON p.type_id = pt.type_id
GROUP BY 
    pt.type_name, DATE_TRUNC('month', t.closing_date)
ORDER BY 
    Month DESC, Total_Sales DESC;
