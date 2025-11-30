{{ config(materialized='view') }}

WITH raw_ratings AS (SELECT * FROM {{ ref('ratings') }}),

ratings AS (
    SELECT
        buyer_tax_id,
        rating,
        CAST(created_at AS TIMESTAMP) AS rating_created_at
    FROM raw_ratings
    WHERE 
        rating IS NOT NULL
        AND created_at IS NOT NULL
)

SELECT * FROM ratings;
