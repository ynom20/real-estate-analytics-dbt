

  create or replace view `real-estate-project-2025`.`real_estate_gold`.`dim_addresses`
  OPTIONS()
  as -- Gold層モデル: 住所ディメンションテーブル

WITH source AS (
    SELECT DISTINCT
        zipcode,
        prefecture,
        city_name,
        district_name
    FROM
        `real-estate-project-2025`.`real_estate_silver`.`stg_transactions`
    WHERE
        zipcode IS NOT NULL
        AND prefecture IS NOT NULL
        AND city_name IS NOT NULL
        AND district_name IS NOT NULL
)
SELECT
    -- 住所の代理キー (主キー) を作成
    -- FARM_FINGERPRINT関数で、各住所コンポーネントを組み合わせてユニークなIDを生成
    FARM_FINGERPRINT(
        CONCAT(
            CAST(zipcode AS STRING),
            prefecture,
            city_name,
            district_name
        )
    ) AS address_id,
    
    -- 住所の各コンポーネント
    zipcode,
    prefecture,
    city_name,
    district_name
FROM
    source;

