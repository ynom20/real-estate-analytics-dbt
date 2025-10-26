

  create or replace view `real-estate-project-2025`.`real_estate_gold`.`mart_avg_price_by_city`
  OPTIONS()
  as -- Gold層モデル: 市区町村ごとの不動産取引サマリー

WITH transactions AS (
    SELECT
        *
    FROM
        `real-estate-project-2025`.`real_estate_silver`.`stg_transactions`
)
SELECT
    -- 集計単位 (キー)
    prefecture,
    city_name,

    -- 集計値 (メトリクス)
    -- 平均平米単価 (小数点以下を切り上げ)
    CAST(CEILING(AVG(price_per_sq_m)) AS INT64) AS avg_price_per_sq_m,
    -- 平米単価の中央値
    APPROX_QUANTILES(price_per_sq_m, 2)[SAFE_OFFSET(0)] AS median_price_per_sq_m,
    -- 取引時の平均築年数 (小数点以下を切り上げ)
    CAST(CEILING(AVG(building_age_at_transaction)) AS INT64) AS avg_building_age,
    -- 駅からの平均距離 (分) (小数点以下を切り上げ)
    CAST(CEILING(AVG(distance_to_station_min)) AS INT64) AS avg_distance_to_station,
    -- 取引件数
    COUNT(*) AS transaction_count
FROM
    transactions
GROUP BY
    1, 2 -- prefecture, city_name
ORDER BY
    transaction_count DESC;

