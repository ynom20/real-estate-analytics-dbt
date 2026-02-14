-- 例: 2025年11月9日更新: Tableau用マート
WITH transactions AS (
    SELECT
        *
    FROM
        {{ ref('stg_transactions') }}
)

SELECT
    -- 日付情報
    transaction_date,

    -- 住所情報（stg_transactionsに既に存在）※zipcode単位では粒度が細かいため、city_nameまで
    prefecture,
    city_name,
    transaction_type,
    
    -- 集約メトリクス
    APPROX_QUANTILES(price_per_sq_m, 100)[SAFE_OFFSET(50)] AS median_price_per_sq_m,
    COUNT(*) AS transaction_count,
    
    APPROX_QUANTILES(area_sq_m, 100)[SAFE_OFFSET(50)] AS median_area_sq_m,
    APPROX_QUANTILES(building_age_at_transaction, 100)[SAFE_OFFSET(50)] AS median_building_age,
    APPROX_QUANTILES(distance_to_station_min, 100)[SAFE_OFFSET(50)] AS median_distance_to_station
    
FROM
    transactions
GROUP BY
    transaction_date, prefecture, city_name, transaction_type
HAVING
    COUNT(*) >= 5  -- 最低取引件数の閾値
ORDER BY
    transaction_date, prefecture, city_name, transaction_type