-- models/stock_daily_metrics.sql
-- This model calculates daily metrics for each stock

WITH raw AS (
    SELECT
        date,
        ticker,
        open,
        high,
        low,
        close,
        volume
    FROM {{ source('stock_pipeline', 'raw_stock_prices') }}
),

metrics AS (
    SELECT
        date,
        ticker,
        close,
        high,
        low,
        volume,
        ROUND(((close - open) / open) * 100, 2)
            AS daily_change_pct,
        ROUND(((high - low) / low) * 100, 2)
            AS daily_range_pct,
        ROUND(AVG(close) OVER (
            PARTITION BY ticker
            ORDER BY date
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ), 2) AS moving_avg_7day,
        ROUND(AVG(volume) OVER (
            PARTITION BY ticker
            ORDER BY date
            ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
        ), 0) AS avg_volume_30day
    FROM raw
)

SELECT * FROM metrics
ORDER BY ticker, date