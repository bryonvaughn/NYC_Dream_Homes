SELECT
    expense_type,
    SUM(amount) AS total_amount
FROM
    business_expenses
GROUP BY
    expense_type
ORDER BY
    total_amount DESC;