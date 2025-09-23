-- models/stg_zipcodes.sql

WITH source AS (
    SELECT * FROM {{ source('real_estate_bronze', 'raw_zipcode') }}
)

SELECT
    zipcode,
    prefecture,
    city_name,
    district_name,
    -- JOINするための結合キーを作成
    prefecture || city_name || district_name AS address_key
FROM
    source