
WITH source_test_ranking_awr_prod AS (
  SELECT * FROM {{ source('bigquery', 'test_ranking_awr_prod') }}
),

final AS (
  SELECT * FROM source_test_ranking_awr_prod
)

SELECT * FROM final
