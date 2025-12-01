{% snapshot ratings_snapshot %}
{{
    config(
        target_schema='snapshots',
        unique_key='tax_id',
        strategy='timestamp',
        updated_at='rating_created_at'
    )
}}

SELECT
    created_at,
    tax_id,
    rating
FROM {{ ref('stg_ratings') }}

{% endsnapshot %}
