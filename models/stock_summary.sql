-- models/stock_summary.sql
-- Summary statistics per stock across the full period

WITH daily AS (
    SELECT * FROM {{ ref('stock_daily_metrics') }}
),

summary AS (
    SELECT
        ticker,
        COUNT(*)                           AS total_trading_days,
        ROUND(AVG(close), 2)               AS avg_close_price,
        ROUND(MAX(close), 2)               AS highest_price,
        ROUND(MIN(close), 2)               AS lowest_price,
        ROUND(MAX(close) - MIN(close), 2)  AS price_range,
        ROUND(AVG(daily_change_pct), 2)    AS avg_daily_change_pct,
        ROUND(AVG(moving_avg_7day), 2)     AS avg_7day_moving_avg,
        ROUND(AVG(avg_volume_30day), 0)    AS avg_30day_volume,
        MIN(date)                          AS first_date,
        MAX(date)                          AS last_date
    FROM daily
    GROUP BY ticker
)

SELECT
    ticker,
    total_trading_days,
    avg_close_price,
    highest_price,
    lowest_price,
    price_range,
    avg_daily_change_pct,
    avg_7day_moving_avg,
    avg_30day_volume,
    first_date,
    last_date,
    ROUND((price_range / lowest_price) * 100, 2) AS volatility_pct
FROM summary
ORDER BY avg_daily_change_pct DESC