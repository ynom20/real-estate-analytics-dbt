

  create or replace view `real-estate-project-2025`.`real_estate_silver`.`stg_zipcodes`
  OPTIONS()
  as -- models/stg_zipcodes.sql

WITH source AS (
    SELECT * FROM `real-estate-project-2025`.`real_estate_bronze`.`raw_zipcode`
)

SELECT
    zipcode,
    prefecture,
    city_name,
    district_name,
     -- ★★★ 最終版の対称クリーニングロジック ★★★
    prefecture || city_name ||
        REPLACE(
            REPLACE(
                REGEXP_REPLACE(district_name, r'（.*?）', ''), -- 1. 括弧を除去
            'ケ', 'ヶ'), -- 2. ケをヶに統一
        '澤', '沢') -- 3. 澤を沢に統一
    AS address_key
FROM
    source;

