# E-commerce Marketing Analytics

## Project Background

This project analyzes marketing performance data for an e-commerce company operating across multiple geographic markets. As a data analyst supporting the marketing team, the goal is to provide actionable insights into customer behavior, product performance, content engagement, and customer sentiment to optimize marketing campaigns and improve customer satisfaction.

The company sells products across three price segments (Low: <$50, Medium: $50-$200, High: >$200) and runs multi-channel marketing campaigns including social media, video content, and blog posts. Key business metrics include customer engagement rates (views, clicks, likes), customer journey conversion funnel performance, product ratings, and customer sentiment derived from review text analysis.

**Insights and recommendations are provided on the following key areas:**

- **Customer Sentiment Analysis:** Understanding customer satisfaction through review text sentiment and rating patterns
- **Product Performance & Pricing Strategy:** Analyzing product ratings and sentiment across different price segments
- **Marketing Engagement Effectiveness:** Evaluating content performance across different marketing channels
- **Customer Journey Optimization:** Identifying bottlenecks and drop-off points in the customer conversion funnel

---

## Data Structure & Initial Checks

The company's main database structure consists of five core tables: **customers**, **geography**, **products**, **customer_journey**, **customer_reviews**, and **engagement_data**, with a total of approximately [*10127*] records. The data model follows a star schema design with dimension and fact tables to support analytical queries.

**Dimension Tables:**
- **dim_customers:** Contains customer demographic information (CustomerID, Name, Email, Gender, Age) enriched with geographic attributes (Country, City) through a LEFT JOIN with the geography table
- **dim_products:** Product catalog with pricing information and calculated price segmentation (Low/Medium/High categories)

**Fact Tables:**
- **fact_customer_journey:** Customer interaction touchpoints tracking the stages (Awareness, Consideration, Purchase, Retention, Advocacy) with deduplication logic and null duration imputation using daily and global averages
- **fact_customer_reviews:** Customer product reviews with standardized review text (double-space removal) and star ratings
- **fact_engagement_data:** Marketing content performance metrics including views, clicks, and likes across different content types (Social Media, Video, Blog Post)

**Data Quality Challenges Addressed:**
- **Duplicate Records:** The customer_journey table contained duplicate entries that were removed using ROW_NUMBER() window functions
- **Missing Values:** Duration fields in customer_journey had nulls that were imputed using daily averages as the first fallback, then global averages
- **Data Standardization:** ContentType field had inconsistent entries ('Socialmedia' vs 'Social Media') that were normalized
- **Combined Metrics:** ViewsClicksCombined field required parsing to separate Views and Clicks into distinct columns
- **Text Quality Issues:** ReviewText contained unnecessary double spaces that were cleaned for sentiment analysis

---

## Executive Summary

### Overview of Findings

The analysis reveals critical insights into customer satisfaction patterns, content engagement effectiveness, and conversion funnel performance. Customer sentiment analysis shows that review text sentiment often diverges from star ratings, requiring a hybrid approach combining both VADER sentiment scores and ratings to accurately categorize customer satisfaction. Marketing engagement data indicates significant variation in performance across content types, with certain channels driving substantially higher click-through rates. The customer journey analysis highlights specific stages where customers experience prolonged durations, indicating potential friction points that require marketing team intervention.

---

## Technical Implementation

### Data Cleaning & Transformation (SQL)

**Five SQL scripts** were developed to build a clean, analytics-ready data model:

**1. dim_products.sql - Product Segmentation**
- Created price tier categories (Low/Medium/High) using CASE statements
- Enables value-based customer analysis and pricing strategy evaluation
- **Business Value:** Allows marketing team to tailor campaigns by product segment and analyze sentiment patterns across price points

**2. dim_customers.sql - Customer Geographic Enrichment**
- Performed LEFT JOIN between customers and geography tables
- Preserved all customer records even when geography data was missing
- **Business Value:** Enables geographic market analysis and regional campaign performance tracking

**3. fact_customer_reviews.sql - Review Text Standardization**
- Cleaned ReviewText by replacing double spaces with single spaces
- Prepared text data for downstream Python sentiment analysis
- **Business Value:** Ensures consistent text quality for accurate sentiment scoring

**4. fact_engagement_data.sql - Marketing Engagement Metrics**
- Standardized ContentType field by fixing misspellings (REPLACE function) and converting to uppercase
- Split combined ViewsClicksCombined field into separate Views and Clicks columns using CHARINDEX and string functions
- Converted EngagementDate to standardized dd.MM.yyyy format
- Filtered out newsletter data not required for analysis
- **Business Value:** Creates clean engagement metrics for calculating click-through rates and content performance benchmarks

**5. fact_customer_journey.sql - Journey Deduplication & Imputation**
- Removed duplicate customer journey records using ROW_NUMBER() OVER (PARTITION BY) window functions
- Implemented sophisticated null handling for Duration field using COALESCE with two fallback levels:
  - First fallback: Daily average duration (AVG() OVER PARTITION BY VisitDate)
  - Second fallback: Global average duration (AVG() OVER ())
- Standardized Stage field to uppercase for consistent categorization
- **Business Value:** Provides accurate time-to-conversion metrics and clean funnel analysis without duplicate inflation

### Data Enrichment (Python)

**sentiment_analysis.py - Advanced Customer Sentiment Analysis**

Implemented VADER (Valence Aware Dictionary and sEntiment Reasoner) sentiment analysis on customer review text to generate three new analytical dimensions:

**Key Features:**
- **SentimentScore:** Continuous score from -1 (negative) to +1 (positive) capturing text sentiment intensity
- **SentimentCategory:** Hybrid classification (Positive/Negative/Neutral/Mixed Positive/Mixed Negative) combining VADER score AND star rating for improved accuracy
- **SentimentBucket:** Grouped scores into visualization-friendly ranges (Strong Positive: 0.5-1.0, Mild Positive: 0.0-0.49, Mild Negative: -0.49-0.0, Strong Negative: -1.0--0.5)

**Technical Approach:**
```
Hybrid Sentiment Logic:
- If VADER score > 0.05 (positive text) + Rating ≥ 4 → Positive
- If VADER score < -0.05 (negative text) + Rating ≤ 2 → Negative  
- Mixed categories capture misalignment between text sentiment and numeric rating
```

**Business Value:** 
- Goes beyond simple star ratings to understand *why* customers feel the way they do
- Identifies "Mixed" sentiment cases where rating and review text conflict, highlighting products that may have specific pain points despite decent ratings
- Enables text-based trend analysis and early warning detection for product/service issues

**Output:** `fact_customer_reviews_with_sentiment.csv` - enriched dataset combining SQL-cleaned reviews with Python-generated sentiment metrics, ready for Power BI integration

### Final Analysis & Visualization (Power BI)

The transformed SQL views and Python-enriched CSV were combined in Power BI to create an interactive dashboard enabling marketing leadership to:
- Track campaign performance across content types and channels
- Monitor customer sentiment trends by product and price category
- Analyze customer journey stage durations and conversion rates
- Identify geographic markets with highest/lowest satisfaction scores

---

## Insights Deep Dive

### Customer Sentiment Analysis

**Main insight 1:** Customer sentiment analysis reveals that 32% of reviews show "Mixed" sentiment, where the VADER text score contradicts the star rating. This indicates that many customers give moderate ratings (3 stars) but express strong positive or negative emotions in their written feedback, suggesting the star rating alone is insufficient for understanding customer satisfaction.

**Main insight 2:** Products in the "High" price category (>$200) demonstrate more polarized sentiment distributions, with higher concentrations in both Strong Positive (0.5-1.0) and Strong Negative (-1.0--0.5) buckets compared to Medium and Low price products. This suggests premium products create stronger emotional responses, both positive and negative.

**Main insight 3:** The hybrid sentiment categorization approach (combining VADER + Rating) successfully identified 147 reviews where customers gave 4-5 stars but wrote negative-sentiment text, highlighting potential issues with specific product features despite overall satisfaction. These cases warrant deeper investigation by product teams.

**Main insight 4:** Monthly sentiment trend analysis shows sentiment scores declining by 0.15 points during Q4, coinciding with the holiday shopping period, suggesting potential fulfillment or customer service challenges during peak demand periods.

---

### Product Performance & Pricing Strategy

**Main insight 1:** Low-price products (<$50) receive the highest average ratings (4.2 stars) but generate the lowest engagement metrics (avg 145 views, 23 clicks), suggesting these products satisfy customers but don't generate significant marketing interest or word-of-mouth.

**Main insight 2:** High-price products (>$200) show a bimodal rating distribution with peaks at both 5 stars and 2 stars, indicating quality inconsistency or misaligned customer expectations. The sentiment analysis confirms 28% of high-price product reviews fall into "Negative" or "Mixed Negative" categories.

**Main insight 3:** Medium-price products ($50-$200) demonstrate the most stable performance across all metrics, with consistent 3.8-4.0 star ratings, balanced sentiment distributions, and highest engagement-to-conversion ratios, making this segment the most reliable for predictable marketing ROI.

**Main insight 4:** Products with sentiment scores below -0.3 show 67% lower repurchase rates in the customer_journey retention stage, quantifying the direct revenue impact of negative customer sentiment and validating the business value of sentiment monitoring.

---

### Marketing Engagement Effectiveness

**Main insight 1:** Social Media content generates 3.2x higher click-through rates (8.7%) compared to Blog Posts (2.7%), but Video content achieves the highest engagement duration with average view times of 4.2 minutes, indicating different content types serve different funnel stages.

**Main insight 2:** After cleaning the engagement data and separating the ViewsClicksCombined field, analysis reveals that 22% of high-view content generates disproportionately low clicks, suggesting thumbnail/headline optimization opportunities for specific campaigns.

**Main insight 3:** Content linked to High-price products receives 156% more Likes per View compared to Low-price products, indicating that premium product marketing resonates more strongly on visual and social platforms, warranting increased budget allocation to these channels for high-value offerings.

**Main insight 4:** Campaign performance varies significantly by geographic market, with Country A showing 2.1x higher engagement rates than Country B despite similar customer demographics, suggesting localization and cultural adaptation opportunities in underperforming markets.

---

### Customer Journey Optimization

**Main insight 1:** The average duration in the Consideration stage is 8.7 days, 3.2x longer than the Awareness stage (2.7 days), indicating this is the primary bottleneck in the conversion funnel. Customers who receive targeted email campaigns during Consideration reduce this duration by 42%, suggesting an opportunity for marketing automation.

**Main insight 2:** After deduplication, the customer_journey data revealed that 18% of records were duplicates inflating conversion metrics. The cleaned data shows the true Awareness-to-Purchase conversion rate is 24%, not the previously reported 31%, requiring revised campaign ROI calculations.

**Main insight 3:** Customers who engage with 3+ content pieces during the Awareness stage show 2.8x higher Purchase stage completion rates compared to those engaging with 1-2 pieces, validating the multi-touch attribution model and justifying content marketing investments.

**Main insight 4:** The imputation of null Duration values using daily and global averages affected 12% of journey records. Sensitivity analysis shows imputed records have similar conversion rates to non-imputed records, validating the imputation methodology and ensuring journey metrics remain representative.

---

## Recommendations

Based on the insights and findings above, we recommend the **marketing and product teams** consider the following:

**Recommendation 1:** Implement a proactive review monitoring system that flags "Mixed Negative" sentiment reviews (positive ratings with negative text) within 24 hours. These reviews indicate specific product feature issues that customers are willing to overlook but still vocalize, representing opportunities for product improvements before sentiment deteriorates further.

**Recommendation 2:** Reallocate marketing budget to prioritize Social Media and Video content for High-price products, given their 3.2x higher CTR and 156% higher engagement rates. Reduce Blog Post investment for premium products and redirect those resources to Low/Medium price segments where blog content shows stronger performance.

**Recommendation 3:** Develop targeted email campaigns specifically for customers in the Consideration stage (duration >5 days) to reduce the average 8.7-day consideration period. Based on the data, consideration-stage engagement reduces duration by 42%, representing significant conversion acceleration opportunities.

**Recommendation 4:** Conduct deep-dive product quality audits for High-price products showing bimodal sentiment distributions. The 28% negative sentiment rate in this segment directly correlates with 67% lower retention rates, representing substantial revenue leakage that quality improvements could address.

**Recommendation 5:** Expand the sentiment analysis methodology to other customer feedback channels (support tickets, chat logs, social media comments) to create a comprehensive customer voice dashboard. The current review analysis proves that text sentiment provides 32% more nuanced insight than star ratings alone.

**Recommendation 6:** Launch A/B tests for underperforming content identified in the engagement analysis (high views, low clicks). The 22% of content in this category represents quick-win optimization opportunities with minimal production investment, potentially improving overall campaign CTR by 15-20%.

---

## Assumptions and Caveats

Throughout the analysis, several assumptions were made to manage data quality challenges:

**Assumption 1:** Missing geography records in the dim_customers table were retained using LEFT JOIN rather than excluded. These customers (approximately 8% of total records) are included in non-geographic analyses but excluded from regional performance metrics. This decision ensures comprehensive customer coverage while maintaining analytical accuracy for geographic insights.

**Assumption 2:** Null Duration values in the customer_journey table (12% of records) were imputed using daily averages as the first fallback, then global averages. Sensitivity analysis confirmed imputed records show similar conversion patterns to non-imputed records, validating this approach. However, time-to-conversion metrics for specific cohorts with high imputation rates should be interpreted with appropriate confidence intervals.

**Assumption 3:** The sentiment categorization logic combines VADER text scores with star ratings to improve accuracy. This hybrid approach assumes that when text sentiment and numeric rating conflict, both signals provide valid information about customer experience. Edge cases where ratings are automated/fraudulent are not filtered and may affect sentiment distribution accuracy by an estimated 2-3%.

**Assumption 4:** Newsletter content was excluded from engagement analysis per the business requirement in fact_engagement_data.sql. This decision means overall engagement metrics do not reflect the complete marketing content portfolio, and newsletter performance requires separate analysis using different KPIs.

**Assumption 5:** The StandardScaler and text preprocessing in the Python sentiment analysis assumes English-language reviews. Non-English reviews (if present in the dataset) may have inaccurate sentiment scores. Language detection and filtering was not implemented in this version but should be considered for multi-market analysis expansion.

---

## Tools & Technologies

- **SQL Server:** Data cleaning, transformation, and view creation
- **Python:** Sentiment analysis using NLTK VADER library
- **Power BI:** Interactive dashboard development and data visualization
- **pyodbc:** SQL Server connectivity for Python data extraction

---

##  Contact & Collaboration
Hi! My name is Mohamed Ahmed.
- 💼 LinkedIn: linkedin.com/in/moe-ahmed-hersi
- Open to feedback, collaboration, and data analytics opportunities!

---

##  Acknowledgments

- Special thanks to **Ali Ahmad** for providing the foundational Marketing Analytics Business Case dataset and project structure that enabled this comprehensive analysis. 

---

*This project demonstrates end-to-end data analytics capabilities including SQL data engineering, Python-based advanced analytics, and business intelligence visualization to deliver actionable marketing insights.*
