{{ config(
    materialized='table',
    partition_by={"field": "cohort_month", "data_type": "date"},
    cluster_by=["segment", "seller_name"]
) }}

WITH 
int_assets_pit AS (SELECT * FROM {{ ref('int_assets_pit') }}),
dim_rating AS (SELECT * FROM {{ ref('dim_rating') }}),

base AS (
    SELECT
        CAST(DATE_TRUNC(created_at, MONTH) AS DATE) AS cohort_month,
        seller_name,
        buyer_state AS segment,
        face_value,
        origin_rating,
        due_date,
        settled_at,

        CASE 
            WHEN settled_at IS NOT NULL THEN 1 
            ELSE 0 
        END AS settled_flag,

        CASE 
            WHEN settled_at IS NOT NULL AND DATE(settled_at) > due_date THEN 1
            ELSE 0
        END AS overdue_flag,

        CASE 
            WHEN settled_at IS NOT NULL 
                 AND DATE_DIFF(DATE(settled_at), due_date, DAY) > 30 
            THEN 1
            ELSE 0
        END AS default_flag

    FROM int_assets_pit
),

rated AS (
    SELECT
        b.*,
        dr.provision_rate AS base_rate
    FROM base AS b
    LEFT JOIN dim_rating AS dr
        ON b.origin_rating = dr.rating
),

logic AS (
    SELECT
        *,
        CASE
            WHEN settled_flag = 1 THEN 0.00
            WHEN default_flag = 1 THEN 1.00
            ELSE base_rate
        END AS provision_rate
    FROM rated
)

SELECT
    cohort_month,
    segment,
    seller_name,
    SUM(face_value) AS total_face_value,
    SUM(face_value * provision_rate) AS cost_of_risk,
    SAFE_DIVIDE(SUM(face_value * provision_rate), SUM(face_value)) AS avg_provision_rate,
    COUNT(*) AS n_assets,
    SUM(CASE WHEN settled_flag = 1 THEN face_value ELSE 0 END) AS settled_face_value,
    SUM(CASE WHEN overdue_flag = 1 THEN face_value ELSE 0 END) AS overdue_face_value,
    SUM(CASE WHEN default_flag = 1 THEN face_value ELSE 0 END) AS default_face_value
FROM logic
GROUP BY
    cohort_month,
    segment,
    seller_name
