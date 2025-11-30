{{ config(
    materialized='table',
    partition_by={"field": "cohort_month", "data_type": "date"},
    cluster_by=["segment", "seller_name"]
) }}

WITH enriched AS (SELECT * FROM {{ ref('int_assets') }}),

provisioned AS (
    SELECT
        asset_id,
        cohort_month,
        seller_name,
        buyer_state AS segment,
        face_value,
        origin_rating,
        collection_status,
        settled_at,
        due_date,

        CASE
            WHEN LOWER(collection_status) LIKE '%settled%' THEN 0.0
            WHEN settled_at IS NULL AND DATE_DIFF(created_at, due_date, day) > 30 THEN 1.0
            WHEN origin_rating = 'A' THEN 0.01
            WHEN origin_rating = 'B' THEN 0.05
            WHEN origin_rating = 'C' THEN 0.10
            WHEN origin_rating = 'D' THEN 0.20
            WHEN origin_rating = 'E' THEN 0.30
            WHEN origin_rating = 'F' THEN 0.40
            ELSE NULL
        END AS provision_rate

    FROM enriched
)

SELECT
    cohort_month,
    segment,
    seller_name,
    SUM(face_value) AS total_face_value,
    SUM(face_value * provision_rate) AS cost_of_risk,
    AVG(provision_rate) AS avg_provision_rate,
    COUNT(*) AS n_assets
FROM provisioned
WHERE provision_rate IS NOT NULL
GROUP BY 
    cohort_month,
    segment,
    seller_name
ORDER BY cohort_month DESC;
