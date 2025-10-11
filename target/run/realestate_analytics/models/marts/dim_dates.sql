

  create or replace view `real-estate-project-2025`.`real_estate_gold`.`dim_dates`
  OPTIONS()
  as -- Gold層モデル: 日付ディメンションテーブル

WITH transactions AS (
    SELECT
        *
    FROM
        `real-estate-project-2025`.`real_estate_gold`.`fct_transactions`
),

-- fct_transactionsテーブルに存在する日付の最小値と最大値を取得
date_range AS (
    SELECT
        MIN(transaction_date) AS start_date,
        MAX(transaction_date) AS end_date
    FROM
        transactions
),

-- BigQueryのGENERATE_DATE_ARRAY関数で日付を生成
date_spine AS (
    SELECT
        date_day
    FROM
        UNNEST(
            GENERATE_DATE_ARRAY(
                (SELECT start_date FROM date_range),
                (SELECT end_date FROM date_range),
                INTERVAL 1 DAY
            )
        ) AS date_day
)
SELECT
    -- 日付の代理キー (主キー) を作成 (例: 20231026)
    CAST(FORMAT_DATE('%Y%m%d', date_day) AS INT64) AS date_id,
    
    -- 日付の各要素を抽出
    date_day AS full_date,
    EXTRACT(YEAR FROM date_day) AS year,
    EXTRACT(QUARTER FROM date_day) AS quarter,
    EXTRACT(MONTH FROM date_day) AS month,
    EXTRACT(WEEK FROM date_day) AS week_of_year,
    EXTRACT(DAY FROM date_day) AS day_of_month
    
FROM
    date_spine;

