{{ config(materialized='view') }}

WITH raw_ratings AS (SELECT * FROM {{ ref('ratings') }}),

ratings AS (
    SELECT
        CAST(created_at AS TIMESTAMP) AS rating_created_at,
        tax_id AS buyer_tax_id,
        rating
    FROM raw_ratings
),

dedup AS (
    SELECT
        rating_created_at,
        buyer_tax_id,
        rating
    FROM ratings
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY buyer_tax_id, rating_created_at
        ORDER BY rating_created_at DESC
    ) = 1
)

SELECT * FROM dedup
