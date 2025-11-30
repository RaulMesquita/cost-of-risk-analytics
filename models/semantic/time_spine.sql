{{ config(
    materialized="table",
    partition_by={"field": "date_day", "data_type": "date"},
    cluster_by=["date_month"]
) }}

WITH dates AS (
    SELECT
        DAY AS date_day,
        EXTRACT(MONTH FROM DAY) AS date_month,
        EXTRACT(YEAR FROM DAY) AS date_year
    FROM UNNEST(
        GENERATE_DATE_ARRAY(
            DATE("2015-01-01"),
            CURRENT_DATE(),
            INTERVAL 1 DAY
        )
    ) AS DAY
)

SELECT * FROM dates
