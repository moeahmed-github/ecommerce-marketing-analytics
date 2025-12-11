-- Assign products to price segments (Low, Medium, High) to support value-based customer and marketing analysis
CREATE VIEW dim_products
AS
SELECT 
    ProductID,       -- Unique identifier for each product
    ProductName,     -- Name of the product
    Price,           -- Product price used to determine its value tier
    
    -- Create a new price segmentation column for analytical grouping
    CASE 
        WHEN Price < 50 THEN 'Low'              -- Products priced under 50 are classified as low-value
        WHEN Price BETWEEN 50 AND 200 THEN 'Medium'  -- Mid-range products fall between 50 and 200
        ELSE 'High'                              -- Products priced above 200 are considered high-value
    END AS PriceCategory   -- Output column representing the calculated price tier

FROM dbo.products;   -- Source table containing the product catalog
