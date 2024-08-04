SELECT 
    a.agent_id,
    p.name AS Agent_Name,
    COUNT(t.transaction_id) AS Total_Transactions,
    ROUND(SUM(t.price)::numeric, 2) AS Total_Sales,
    ROUND(SUM(t.commission)::numeric, 2) AS Total_Commissions
FROM 
    transactions t
JOIN 
    agents a ON t.agent_id = a.employee_id
JOIN 
    person p ON a.employee_id = p.person_id
--WHERE 
    --t.date BETWEEN '2023-01-01' AND '2023-12-31'
GROUP BY 
    a.agent_id, p.name
ORDER BY 
    Total_Sales DESC, Total_Commissions DESC;
