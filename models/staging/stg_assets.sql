{{ config(materialized='view') }}

WITH raw_assets AS (SELECT * FROM {{ ref('assets') }}),

assets AS (
    SELECT
        asset_id,
        CAST(created_at AS TIMESTAMP) AS created_at,
        CAST(face_value AS NUMERIC) AS face_value,
        CAST(settled_at AS TIMESTAMP) AS settled_at,
        CAST(due_date AS DATE) AS due_date,
        buyer_tax_id,
        seller_name,
        buyer_state,
        collection_status
    FROM raw_assets
    WHERE 
        face_value IS NOT NULL
        AND face_value != 0
)

SELECT * FROM assets;
