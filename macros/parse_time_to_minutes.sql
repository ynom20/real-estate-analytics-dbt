{% macro parse_time_to_minutes(time_str_expression) %}
    CAST(
        -- 'H'の前の数値 (時間) を分に変換
        COALESCE(SAFE_CAST(REGEXP_EXTRACT({{ time_str_expression }}, r'(\d+)H') AS INT64), 0) * 60 +
        -- 'H'の後の数値 (分) を取得
        COALESCE(SAFE_CAST(REGEXP_EXTRACT({{ time_str_expression }}, r'H(\d+)') AS INT64), 0) +
        -- 'H'が含まれない場合の数値 (分) を取得
        CASE
            WHEN NOT REGEXP_CONTAINS({{ time_str_expression }}, 'H') THEN COALESCE(SAFE_CAST(REGEXP_EXTRACT({{ time_str_expression }}, r'(\d+)') AS INT64), 0)
            ELSE 0
        END
    AS INT64)
{% endmacro %}