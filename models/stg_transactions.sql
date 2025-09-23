-- models/stg_transactions.sql

-- JOIN対象の郵便番号モデルを先にCTEとして定義
WITH zipcodes AS (
    SELECT * FROM {{ ref('stg_zipcodes') }}
),

source AS (
    SELECT * FROM {{ source('real_estate_bronze', 'raw_land') }}
    WHERE type NOT IN ('林地', '農地')
),

interim AS (
    SELECT
        type AS transaction_type,
        price_info_type,
        prefecture,
        city_name,
        district_name,
        station_name,
        SAFE_CAST(distance_to_station_min AS INT64) AS distance_to_station_min,
        SAFE_CAST(total_price AS INT64) AS total_price_jpy,
        SAFE_CAST(price_per_tsubo AS INT64) AS price_per_tsubo_jpy,
        floor_plan,
        SAFE_CAST(area_sq_m AS INT64) AS area_sq_m,
        SAFE_CAST(price_per_sq_m AS INT64) AS price_per_sq_m,
        land_shape,
        SAFE_CAST(frontage AS FLOAT64) AS frontage_m,
        SAFE_CAST(total_floor_area_sq_m AS INT64) AS total_floor_area_sq_m,
        building_structure,
        purpose,
        future_purpose,
        road_direction,
        road_type,
        SAFE_CAST(road_width_m AS FLOAT64) AS road_width_m,
        city_planning,
        SAFE_CAST(building_coverage_ratio_pct AS INT64) AS building_coverage_ratio_pct,
        SAFE_CAST(floor_area_ratio_pct AS INT64) AS floor_area_ratio_pct,
        CAST(
            REPLACE(REPLACE(REPLACE(REPLACE(transaction_period, '年第1四半期', '-01-01'), '年第2四半期', '-04-01'), '年第3四半期', '-07-01'), '年第4四半期', '-10-01')
        AS DATE) AS transaction_date,
        renovation,
        special_notes,

        CASE
            WHEN STARTS_WITH(built_year, '昭和') THEN 1925 + SAFE_CAST(REGEXP_EXTRACT(built_year, r'(\d+)') AS INT64)
            WHEN STARTS_WITH(built_year, '平成') THEN 1988 + SAFE_CAST(REGEXP_EXTRACT(built_year, r'(\d+)') AS INT64)
            WHEN STARTS_WITH(built_year, '令和') THEN 2018 + SAFE_CAST(REGEXP_EXTRACT(built_year, r'(\d+)') AS INT64)
            ELSE SAFE_CAST(REGEXP_EXTRACT(built_year, r'(\d+)') AS INT64)
        END AS built_year_ad,

        CASE
            WHEN floor_plan IN ('１Ｒ', '１Ｋ', 'スタジオ', 'オープンフロア') THEN '1 Room'
            WHEN floor_plan = '１ＤＫ' THEN '1DK'
            WHEN floor_plan = '１ＬＤＫ' THEN '1LDK'
            WHEN floor_plan IN ('２Ｋ', '２ＤＫ') THEN '2K/DK'
            WHEN floor_plan = '２ＬＤＫ' THEN '2LDK'
            WHEN floor_plan IN ('３Ｋ', '３ＤＫ') THEN '3K/DK'
            WHEN floor_plan = '３ＬＤＫ' THEN '3LDK'
            WHEN floor_plan LIKE '４%' OR floor_plan LIKE '５%' OR floor_plan LIKE '６%' OR floor_plan LIKE '７%' THEN '4 Rooms+'
            ELSE 'Other'
        END AS floor_plan_category,

        CASE
            WHEN building_structure = 'ＳＲＣ' THEN 'SRC'
            WHEN building_structure = 'ＲＣ' THEN 'RC'
            WHEN building_structure IN ('鉄骨造', '軽量鉄骨造') THEN '鉄骨造'
            WHEN building_structure = '木造' THEN '木造'
            WHEN building_structure LIKE '%ＳＲＣ%' OR building_structure LIKE '%ＲＣ%' THEN '複合SRC/RC'
            WHEN building_structure LIKE '%鉄骨%' THEN '複合鉄骨'
            WHEN building_structure LIKE '%木造%' THEN '複合木造'
            WHEN building_structure IS NULL THEN NULL
            ELSE 'その他'
        END AS building_structure_category,
        
        prefecture || city_name || district_name AS address_key

    FROM source
),

joined AS (
    SELECT
        interim.*,
        zipcodes.zipcode
    FROM
        interim
    LEFT JOIN zipcodes
        ON interim.address_key = zipcodes.address_key
)

-- 最終的な列の選択と順番の定義
SELECT
    transaction_type,
    price_info_type,
    zipcode, -- ★ 順番をここに移動
    prefecture,
    city_name,
    district_name,
    station_name,
    distance_to_station_min,
    total_price_jpy,
    price_per_tsubo_jpy,
    floor_plan,
    floor_plan_category,
    area_sq_m,
    price_per_sq_m,
    land_shape,
    frontage_m,
    total_floor_area_sq_m,
    built_year_ad AS built_year,
    EXTRACT(YEAR FROM transaction_date) - built_year_ad AS building_age_at_transaction,
    building_structure,
    building_structure_category,
    purpose,
    future_purpose,
    road_direction,
    road_type,
    road_width_m,
    city_planning,
    building_coverage_ratio_pct,
    floor_area_ratio_pct,
    transaction_date,
    renovation,
    special_notes
FROM
    joined