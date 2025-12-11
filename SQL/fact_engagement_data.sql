-- Clean and normalize engagement data to ensure consistent content types and separate engagement metrics
CREATE VIEW fact_engagement_data
AS
SELECT 
    EngagementID,     -- Unique engagement record ID
    ContentID,        -- Identifier for the content asset
    CampaignID,       -- Marketing campaign associated with the engagement
    ProductID,        -- Product linked to the content
    
    -- Standardize content type: fix misspelling and convert to uppercase for uniform categorization
    UPPER(REPLACE(ContentType, 'Socialmedia', 'Social Media')) AS ContentType,
    
    -- Split the combined "views-clicks" field into separate numeric metrics
    LEFT(ViewsClicksCombined, CHARINDEX('-', ViewsClicksCombined) - 1) AS Views,   -- Extract value before the dash
    RIGHT(ViewsClicksCombined, LEN(ViewsClicksCombined) - CHARINDEX('-', ViewsClicksCombined)) AS Clicks,  -- Extract value after the dash
    
    Likes,             -- Number of likes received
    
    -- Convert engagement date to standardized dd.MM.yyyy format
    FORMAT(CONVERT(DATE, EngagementDate), 'dd.MM.yyyy') AS EngagementDate

FROM dbo.engagement_data    -- Raw engagement dataset

-- Exclude newsletter data (not required for this analysis)
WHERE ContentType != 'Newsletter';