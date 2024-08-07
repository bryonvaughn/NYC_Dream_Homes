WITH high_value_properties AS (
    SELECT 
        p.property_id,
        a.address,
        a.city,
        a.state,
        a.zipcode,
        a.neighborhood,
        pt.type_name AS property_type,
        p.price,
        p.square_feet,
        p.number_of_bedrooms,
        p.number_of_bathrooms,
        p.year_built,
        p.description,
        p.amenities,
        p.listing_date,
        e.employee_id AS agent_id,
        emp_per.name AS agent_name,
        AVG(p.price) OVER (PARTITION BY a.neighborhood) AS avg_neighborhood_price
    FROM 
        properties p
    JOIN 
        addresses a ON p.address_id = a.address_id
    JOIN 
        property_types pt ON p.type_id = pt.type_id
    JOIN 
        agents ag ON p.agent_id = ag.agent_id
    JOIN 
        employees e ON ag.employee_id = e.employee_id
    JOIN 
        person emp_per ON e.person_id = emp_per.person_id
),
top_agents AS (
    SELECT
        agent_id,
        agent_name,
        COUNT(p.property_id) AS total_properties,
        SUM(p.price) AS total_transaction_value,
        AVG(p.price) AS average_property_price
    FROM 
        high_value_properties p
    GROUP BY 
        agent_id, agent_name
    ORDER BY 
        total_transaction_value DESC
),
ranked_agents AS (
    SELECT 
        agent_id,
        agent_name,
        total_properties,
        total_transaction_value,
        average_property_price,
        ROW_NUMBER() OVER (ORDER BY total_transaction_value DESC) AS agent_rank
    FROM 
        top_agents
)
SELECT 
    hvp.property_id,
    hvp.address,
    hvp.city,
    hvp.state,
    hvp.zipcode,
    hvp.neighborhood,
    hvp.property_type,
    hvp.price,
    hvp.square_feet,
    hvp.number_of_bedrooms,
    hvp.number_of_bathrooms,
    hvp.year_built,
    hvp.description,
    hvp.amenities,
    hvp.listing_date,
    ra.agent_name,
    ra.total_properties AS agent_properties,
    ra.total_transaction_value AS agent_total_value,
    ra.average_property_price AS agent_avg_price,
    ra.agent_rank
FROM 
    high_value_properties hvp
JOIN 
    ranked_agents ra ON hvp.agent_id = ra.agent_id
WHERE 
    ra.agent_rank <= 10
ORDER BY 
    hvp.price DESC
LIMIT 
    10;
