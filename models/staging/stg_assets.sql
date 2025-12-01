{{ config(materialized='view') }}

WITH raw_assets AS (SELECT * FROM {{ ref('assets') }}),

assets AS (
    SELECT
        CAST(created_at AS TIMESTAMP) AS created_at,
        CAST(settled_at AS TIMESTAMP) AS settled_at,
        CAST(face_value AS NUMERIC) AS face_value,
        due_date,
        buyer_tax_id,
        seller_name,
        buyer_state,
        collection_status
    FROM raw_assets
),

dedup AS (
    SELECT
        created_at,
        settled_at,
        face_value,
        due_date,
        buyer_tax_id,
        seller_name,
        buyer_state,
        collection_status
    FROM assets
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY buyer_tax_id, created_at
        ORDER BY created_at DESC
    ) = 1
)

SELECT * FROM dedup
