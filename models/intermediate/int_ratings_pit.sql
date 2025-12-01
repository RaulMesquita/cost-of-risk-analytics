{{ config(materialized='table') }}

WITH r AS (SELECT * FROM {{ ref('stg_ratings')}}),

ratings AS (
    SELECT
        buyer_tax_id,
        rating,
        rating_created_at
    FROM r
    WHERE rating != 'G'
),

windowed AS (
    SELECT
        buyer_tax_id,
        rating,
        rating_created_at AS valid_from,
        LEAD(rating_created_at) OVER (PARTITION BY buyer_tax_id ORDER BY rating_created_at) AS valid_to
    FROM ratings
),

enriched AS (
    SELECT
        buyer_tax_id,
        rating,
        valid_from,
        COALESCE(valid_to, TIMESTAMP '9999-12-31') AS valid_to
    FROM windowed
)

SELECT * FROM enriched
