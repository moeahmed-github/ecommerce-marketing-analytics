# Required packages:
import pandas as pd
import pyodbc
import nltk
from nltk.sentiment.vader import SentimentIntensityAnalyzer


# Download VADER lexicon if not already available (needed for sentiment scoring)
nltk.download('vader_lexicon')


# Fetch review data from SQL Server
def fetch_data_from_sql():
    """
    Connect to SQL Server and retrieve customer review data.
    Returns a pandas DataFrame.
    """
    conn_str = (
        "Driver={ODBC Driver 17 for SQL Server};"
        "Server=DESKTOP-0AUK2KF\\SQLEXPRESS;"
        "Database=MarketingAnalytics;"
        "Trusted_Connection=yes;"
    )

    conn = pyodbc.connect(conn_str)
    query = """
        SELECT ReviewID, CustomerID, ProductID, ReviewDate, Rating, ReviewText
        FROM fact_customer_reviews
    """

    df = pd.read_sql(query, conn)
    conn.close()
    return df


# Load review dataset
customer_reviews_df = fetch_data_from_sql()


# Initialize VADER sentiment analyzer
sia = SentimentIntensityAnalyzer()


def calculate_sentiment(review_text):
    """
    Calculate VADER compound sentiment score for a review.
    Returns a value between -1 (negative) and 1 (positive).
    """
    scores = sia.polarity_scores(review_text)
    return scores['compound']


def categorize_sentiment(score, rating):
    """
    Combine VADER score and user rating to assign a sentiment label.
    Improves accuracy by blending text sentiment and numeric rating context.
    """
    if score > 0.05:  # text is positive
        if rating >= 4:
            return 'Positive'
        elif rating == 3:
            return 'Mixed Positive'
        else:
            return 'Mixed Negative'

    elif score < -0.05:  # text is negative
        if rating <= 2:
            return 'Negative'
        elif rating == 3:
            return 'Mixed Negative'
        else:
            return 'Mixed Positive'

    else:  # neutral text
        if rating >= 4:
            return 'Positive'
        elif rating <= 2:
            return 'Negative'
        else:
            return 'Neutral'


def sentiment_bucket(score):
    """
    Group sentiment scores into broader buckets
    to simplify visualization in dashboards.
    """
    if score >= 0.5:
        return '0.5 to 1.0'       # Strong positive
    elif 0.0 <= score < 0.5:
        return '0.0 to 0.49'      # Mild positive
    elif -0.5 <= score < 0.0:
        return '-0.49 to 0.0'     # Mild negative
    else:
        return '-1.0 to -0.5'     # Strong negative


# Apply sentiment score calculations
customer_reviews_df['SentimentScore'] = customer_reviews_df['ReviewText'].apply(calculate_sentiment)

# Label sentiment using both text score and rating
customer_reviews_df['SentimentCategory'] = customer_reviews_df.apply(
    lambda row: categorize_sentiment(row['SentimentScore'], row['Rating']),
    axis=1
)

# Assign score buckets for visualization
customer_reviews_df['SentimentBucket'] = customer_reviews_df['SentimentScore'].apply(sentiment_bucket)

# Preview the enriched dataset
print(customer_reviews_df.head())

# Export results for dashboard and further analysis
customer_reviews_df.to_csv(r'C:\Users\MAXNET\Desktop\Marketing Analytics Business Case\fact_customer_reviews_with_sentiment.csv', index=False)