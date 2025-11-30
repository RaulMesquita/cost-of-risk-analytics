{{ config(materialized='view') }}

WITH raw_assets AS (SELECT * FROM {{ ref('assets') }}),

assets AS (
    SELECT
        CAST(created_at AS TIMESTAMP) AS created_at,
        CAST(face_value AS NUMERIC) AS face_value,
        CAST(settled_at AS TIMESTAMP) AS settled_at,
        due_date,
        buyer_tax_id,
        seller_name,
        buyer_state,
        collection_status
    FROM raw_assets
    WHERE 
        face_value > 0
        AND due_date >= DATE(created_at) -- Fix data
)

SELECT * FROM assets
