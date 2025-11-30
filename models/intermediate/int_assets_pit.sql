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
        r.rating as origin_rating
    FROM a
    LEFT JOIN r
        ON a.buyer_tax_id = r.tax_id
        AND r.created_at <= a.created_at
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY a.buyer_tax_id, a.created_at
        ORDER BY r.created_at DESC
    ) = 1
)

SELECT * FROM ratings_pit
