{% snapshot ratings_snapshot %}
{{
    config(
        target_schema='snapshots',
        unique_key='buyer_tax_id',
        strategy='timestamp',
        updated_at='created_at'
    )
}}

SELECT
    rating_created_at,
    buyer_tax_id,
    rating
FROM {{ ref('stg_ratings') }}

{% endsnapshot %}
