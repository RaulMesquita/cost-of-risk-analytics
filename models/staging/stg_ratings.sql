{{ config(materialized='view') }}

WITH raw_ratings AS (SELECT * FROM {{ ref('ratings') }}),

ratings AS (
    SELECT
        CAST(created_at AS TIMESTAMP) AS rating_created_at,
        tax_id,
        rating
    FROM raw_ratings
    WHERE rating != 'G'
)

SELECT * FROM ratings
