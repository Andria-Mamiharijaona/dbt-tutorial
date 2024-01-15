{{ config(materialized="table") }}

WITH source_cwv_prod AS (
  SELECT
    psi,
    device,
    date,
    tti,
    categorie,
    url
  FROM `molecule_science_pipelines.test_cwv_prod`
)

SELECT * FROM source_cwv_prod