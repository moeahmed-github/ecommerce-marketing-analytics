-- Standardize review text by removing unnecessary double spaces
CREATE VIEW fact_customer_reviews
AS
SELECT 
    ReviewID,        -- Review identifier
    CustomerID,      -- Customer who submitted the review
    ProductID,       -- Product being reviewed
    ReviewDate,      -- Date the review was posted
    Rating,          -- Customer rating (e.g., 1–5 stars)
    
    -- Normalize text by replacing double spaces with single spaces
    REPLACE(ReviewText, '  ', ' ') AS ReviewText

FROM dbo.customer_reviews;   -- Source table containing customer review data