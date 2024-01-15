SELECT ctr
FROM {{ ref('test_dbt_ranking_awr_prod') }}
WHERE ctr != 0