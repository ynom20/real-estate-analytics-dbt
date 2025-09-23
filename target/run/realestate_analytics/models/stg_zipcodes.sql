

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
    -- JOINするための結合キーを作成
    prefecture || city_name || district_name AS address_key
FROM
    source;

