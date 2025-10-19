-- Gold層モデル: 分析の元となるファクトテーブル
-- 更新日: 2025-01-19
-- 変更内容: transaction_idカラム（連番ユニークキー）を追加

WITH source AS (
    SELECT
        *
    FROM
        {{ ref('stg_transactions') }}
),

with_transaction_id AS (
    SELECT
        -- ★ 連番でユニークキーを生成
        ROW_NUMBER() OVER (
            ORDER BY 
                transaction_date,
                zipcode,
                station_name,
                total_price_jpy,
                area_sq_m,
                building_structure
        ) AS transaction_id,
        
        -- 既存の全カラム
        transaction_type,
        price_info_type,
        zipcode,
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
        built_year,
        building_age_at_transaction,
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
        renovation
    FROM source
)

SELECT * FROM with_transaction_id