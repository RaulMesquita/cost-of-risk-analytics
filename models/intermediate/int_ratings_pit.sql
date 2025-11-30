{{ config(materialized='table') }}

WITH r AS (SELECT * FROM {{ ref('stg_ratings')}}),

ratings AS (
    SELECT
        buyer_tax_id,
        rating,
        rating_created_at,
        LEAD(rating_created_at) OVER (PARTITION BY buyer_tax_id ORDER BY rating_created_at) AS next_rating_ts
    FROM r
)

SELECT * FROM ratings