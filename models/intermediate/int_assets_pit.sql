{{ config(materialized='table') }}

WITH 
a AS (SELECT * FROM {{ ref('stg_assets')}}),
r AS (SELECT * FROM {{ ref('stg_ratings')}}),

joined AS (
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
        ON a.buyer_tax_id = r.buyer_tax_id
        AND a.created_at >= r.rating_created_at
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY a.buyer_tax_id, a.created_at
        ORDER BY r.valid_from DESC
    ) = 1
)

SELECT * FROM joined
