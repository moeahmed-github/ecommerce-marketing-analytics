-- Delete the old, broken view definition
IF OBJECT_ID('fact_customer_journey', 'V') IS NOT NULL
    DROP VIEW fact_customer_journey;
GO

-- Create the new, absolutely clean view

CREATE VIEW fact_customer_journey 
AS
SELECT 
    JourneyID, CustomerID, ProductID, VisitDate, Stage, Action,
    
    COALESCE(Duration, daily_avg, global_avg) AS Duration

FROM (
    SELECT 
        JourneyID, CustomerID, ProductID, VisitDate, UPPER(Stage) AS Stage, Action, Duration,
        
        -- Calculate the average duration for the specific VisitDate
        AVG(Duration) OVER (PARTITION BY VisitDate) AS daily_avg,
        
        -- Calculate the average duration for the entire table (the ultimate fallback)
        AVG(Duration) OVER () AS global_avg,
        
        -- Identify duplicate rows for removal
        ROW_NUMBER() OVER (
            PARTITION BY CustomerID, ProductID, VisitDate, UPPER(Stage), Action
            ORDER BY JourneyID
        ) AS row_num
    FROM customer_journey  
) AS subquery

-- Keeping only the first record of each duplicate group
WHERE row_num = 1;
GO


SELECT TOP 10 * FROM fact_customer_journey WHERE Duration IS NULL;