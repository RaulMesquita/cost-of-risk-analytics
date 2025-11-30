{{ config(materialized='table') }}

WITH 
a AS (SELECT * FROM {{ ref('stg_assets')}}),
r AS (SELECT * FROM {{ ref('stg_ratings')}}),

ratings_pit AS (
    SELECT
        a.created_at,
        a.face_value,
        a.settled_at,
        a.due_date,
        a.buyer_tax_id,
        a.seller_name,
        a.buyer_state,
        a.collection_status,
        r.rating as origin_rating,

        ROW_NUMBER() OVER (
            PARTITION BY a.buyer_tax_id
            ORDER BY r.rating_created_at DESC
        ) AS rn

    FROM a
    LEFT JOIN r
        ON a.buyer_tax_id = r.tax_id
        AND r.rating_created_at <= a.created_at
    QUALIFY rn = 1
)

SELECT
    created_at,
    face_value,
    settled_at,
    due_date,
    buyer_tax_id,
    seller_name,
    buyer_state,
    collection_status,
    origin_rating,
    CAST(DATE_TRUNC(created_at, MONTH) AS DATE) AS cohort_month
FROM ratings_pit