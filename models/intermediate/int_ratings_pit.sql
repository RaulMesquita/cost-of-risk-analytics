{{ config(materialized='table') }}

WITH r AS (SELECT * FROM {{ ref('stg_ratings')}}),

ratings AS (
    SELECT
        tax_id,
        rating,
        created_at,
        LEAD(created_at) OVER (PARTITION BY tax_id ORDER BY created_at) AS next_rating_ts
    FROM r
)

SELECT * FROM ratings