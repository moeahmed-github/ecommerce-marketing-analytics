-- Enrich customer records with geographic attributes by joining the Customers and Geography tables
SELECT 
    c.CustomerID,        
    c.CustomerName,      
    c.Email,             
    c.Gender,            
    c.Age,               
    
    g.Country,           
    g.City               

FROM dbo.customers AS c   -- Base customer table

-- LEFT JOIN ensures all customers are kept even if some have missing geography records
LEFT JOIN dbo.geography AS g  
    ON c.GeographyID = g.GeographyID;  
    -- Join key that links each customer to their corresponding geographic location