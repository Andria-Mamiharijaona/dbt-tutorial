Welcome to your new dbt project!

### Using the starter project

create enverinoment python for dbt:
 - python3 -m venv dbt_env
 - source dbt-env/bin/activate
 - pip install -r requirements.txt
 - create file ~/.dbt/profiles.yml:

   ```
   dbt_poc_peakace:
    target: dev
    outputs:
      dev:
        type: bigquery
        method: service-account
        keyfile: /Users/nosytech/.dbt/peakace_access.json # replace this with the full path to your keyfile
        project: consultants-sf # Replace this with your project id
        dataset: molecule_science_pipelines # Replace this with dbt_your_name, e.g. dbt_bilbo
        threads: 1
        timeout_seconds: 300
        location: EU
        priority: interactive

   elementary:
     outputs:
       default:
         type: "bigquery"
         project: "consultants-sf"
         dataset: "molecule_science_pipelines_elementary"
         method: service-account # Configure your auth method and add the required fields according to https://docs.getdbt.com/reference/warehouse-setups/bigquery-setup#authentication-methods
         keyfile: /Users/nosytech/.dbt/peakace_access.json
         threads: 1
    ```
- dbt debug

Try running the following commands:
- dbt run --select elementary
- dbt run
- dbt test
- dbt deps (Install dbt packages specified.)


### Resources:
- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [chat](https://community.getdbt.com/) on Slack for live discussions and support
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices
- Learn more about elementary [in the docs](https://docs.elementary-data.com/introduction)
- Learn more about dbt-expectations [about dbt-expectations](https://hub.getdbt.com/calogica/dbt_expectations/latest/)

### How to :

### Configurer une source de données (BigQuery / Postgresql)

vous aurez besoin d'un fichier profiles.yml qui contient les détails de connexion pour votre plateforme de données. Lorsque vous exécutez dbt à partir de la ligne de commande, il lit votre fichier dbt_project.yml pour trouver le nom du profil, puis recherche un profil portant le même nom dans votre fichier profiles.yml. Ce profil contient toutes les informations dont dbt a besoin pour se connecter à votre plate-forme de données.

#### bigquery :

Dans votre fichier dbt_project.yml
```
name: 'nom_de_votre_projet_dbt'
profile: 'nom_de_votre_projet_dbt'
```

dbt recherche alors dans votre fichier profiles.yml un profil portant le même nom. Un profil contient tous les détails nécessaires pour se connecter à votre entrepôt de données.
Le fichier profiiles.yml doit se trouver dans le repertoire ~/.dbt.

Le contenu du fichier profiles.yml

 - methode de connexion oauth
```
nom_de_votre_projet_dbt:
  target: dev
  outputs:
    dev:
      type: bigquery
      method: oauth
      project: GCP_PROJECT_ID
      dataset: DBT_DATASET_NAME # You can also use "schema" here
      threads: 4 # Must be a value of 1 or greater
      OPTIONAL_CONFIG: VALUE
```

- methode de connexion oauth-secrets
```
nom_de_votre_projet_dbt:
  target: dev
  outputs:
    dev:
      type: bigquery
      method: oauth-secrets
      project: GCP_PROJECT_ID
      dataset: DBT_DATASET_NAME # You can also use "schema" here
      threads: 4 # Must be a value of 1 or greater
      refresh_token: TOKEN
      client_id: CLIENT_ID
      client_secret: CLIENT_SECRET
      token_uri: REDIRECT_URI
      OPTIONAL_CONFIG: VALUE
```

- methode de connexion service-account

```
nom_de_votre_projet_dbt:
  target: dev
  outputs:
    dev:
      type: bigquery
      method: service-account
      project: GCP_PROJECT_ID
      dataset: DBT_DATASET_NAME
      threads: 4 # Must be a value of 1 or greater
      keyfile: /PATH/TO/BIGQUERY/keyfile.json
      OPTIONAL_CONFIG: VALUE
```

#### postgres

Dans votre fichier dbt_project.yml
```
name: 'nom_de_votre_projet_dbt'
profile: 'nom_de_votre_projet_dbt'
```

Le contenu du fichier profiles.yml

```
company-name:
  target: dev
  outputs:
    dev:
      type: postgres
      host: [hostname]
      user: [username]
      password: [password]
      port: [port]
      dbname: [database name] # or database instead of dbname
      schema: [dbt schema]
      threads: [optional, 1 or more]
      keepalives_idle: 0 # default 0, indicating the system default. See below
      connect_timeout: 10 # default 10 seconds
      retries: 1  # default 1 retry on error/timeout when opening connections
      search_path: [optional, override the default postgres search_path]
      role: [optional, set the role dbt assumes when executing queries]
      sslmode: [optional, set the sslmode used to connect to the database]
      sslcert: [optional, set the sslcert to control the certifcate file location]
      sslkey: [optional, set the sslkey to control the location of the private key]
      sslrootcert: [optional, set the sslrootcert config value to a new file path in order to customize the file location that contain root certificates]
```

Pour verifier si la connexion est établie, executer la commande :

```
dbt debug
```

### Créer une transformation, ajouter un modèle et configurer des tests pour un models

La logique de transformation est construite à travers des modèles dbt constitués d'instructions SQL SELECT.

Ces modèles peuvent ensuite être référencés par d'autres modèles afin d'obtenir une modularité dans vos projets dbt. dbt comprend également des sources dbt qui sont des métadonnées pour les données brutes.

Les tests sont des expressions SQL qui valident les modèles, les sources et d'autres points de contrôle.

Dans un projet dbt, il y a deux fichiers principaux : .yml et .sql

- Les fichiers .yml définissent les sources, configurent les chemins et définissent les versions. Ils indiquent à dbt comment les modèles de données peuvent être construits dans l'environnement cible.
- Les fichiers .sql sont utilisés pour définir vos modèles de données. Ils se composent d'un bloc de configuration qui utilise Jinja, d'expressions de table communes et d'autres tables temporaires. Les fichiers .sql contiennent également une instruction select finale qui vous donne les données transformées.

Exemple d'un modèle:

```
{{ config(materialized="table") }}

WITH source_cwv_prod AS (
  SELECT
    *
  FROM `molecule_science_pipelines.test_cwv_prod`
)

final as (
  SELECT
    psi,
    device,
    date,
    tti,
    categorie,
    url
  FROM source_cwv_prod
  WHERE date IS NOT NULL
)

SELECT * FROM final
```

Exemple d'un test correspondant à ce modèle :

```
version: 2

models:
  - name: test_cwv_prod # c'est le nom du modèle à tester
    description: 'TEST quality data cwv_prod'
    columns:
      - name: psi
        tests:
          - not_null
      - name: device
        tests:
          - accepted_values:
              values: ['mobile', 'desktop']
          - not_null
      - name: date
      - name: tti
      - name: categorie
      - name: url
```

### Ajouter des tests génériques

Les tests génériques sont définis dans des fichiers SQL. Ces fichiers peuvent se trouver à deux endroits :

  - tests/generic/ : c'est-à-dire un sous-dossier spécial nommé generic dans vos chemins de test (tests/ par défaut)
  - macros/ : Pourquoi ? Les tests génériques fonctionnent beaucoup comme des macros, et historiquement, c'était le seul endroit où ils pouvaient être définis. Si votre test générique dépend d'une logique macro complexe, vous trouverez peut-être plus pratique de définir les macros et le test générique dans le même fichier.

Pour définir vos propres tests génériques, il vous suffit de créer un bloc de test appelé <nom_du_test>. Tous les tests génériques doivent accepter l'un des arguments standard ou les deux:

- model: La ressource sur laquelle le test est défini
- column_name: La colonne sur laquelle le test est défini. Tous les tests génériques n'opèrent pas au niveau de la colonne, mais s'ils le font, ils doivent accepter le nom de la colonne comme argument.

exemple de teste is_even:

tests/generic/test_is_even.sql

```
{% test is_even(model, column_name) %}

with validation as (

    select
        {{ column_name }} as even_field

    from {{ model }}

),

validation_errors as (

    select
        even_field

    from validation
    -- if this is true, then even_field is actually odd!
    where (even_field % 2) = 1

)

select *
from validation_errors

{% endtest %}
```

Si cette instruction select renvoie zéro enregistrement, alors chaque enregistrement de l'argument modèle fourni est pair ! Si un nombre non nul d'enregistrements est renvoyé à la place, alors au moins un enregistrement du modèle est impair et le test a échoué.

Pour utiliser ce test générique, spécifiez-le par son nom dans la propriété tests d'un modèle, source

```
version: 2

models:
  - name: test_cwv_prod # c'est le nom du modèle à tester
    description: 'TEST quality data cwv_prod'
    columns:
      - name: psi
        tests:
          - is_even
```

D'autres tests, comme les relations, nécessitent plus que le modèle et le nom de la colonne. Si vos tests personnalisés nécessitent plus que les arguments standard, incluez ces arguments dans la signature du test, comme field et to sont inclus ci-dessous

tests/generic/test_relationships.sql

```
{% test relationships(model, column_name, field, to) %}

with parent as (

    select
        {{ field }} as id

    from {{ to }}

),

child as (

    select
        {{ column_name }} as id

    from {{ model }}

)

select *
from child
where id is not null
  and id not in (select id from parent)

{% endtest %}
```

utilisation de test dans un modèle ou source :

```
version: 2

models:
  - name: people
    columns:
      - name: account_id
        tests:
          - relationships:
              to: ref('accounts')
              field: id
```

### Ajouter des "singular test"

La manière la plus simple de définir un test de données est d'écrire le code SQL exact qui renverra les enregistrements défaillants. Nous appelons ces tests de données "singuliers", car il s'agit d'assertions uniques utilisables dans un seul but.

Ces tests sont définis dans des fichiers .sql, typiquement dans votre répertoire de tests. Vous pouvez utiliser Jinja (y compris ref et source) dans la définition du test, tout comme vous pouvez le faire lors de la création de modèles. Chaque fichier .sql contient une instruction select et définit un test de données :

tests/assert_total_payment_amount_is_positive.sql

```
select
    order_id,
    sum(amount) as total_amount
from {{ ref('fct_payments' )}}
group by 1
having not(total_amount >= 0)
```

tests/order_value_test.sql
```
SELECT order_id, quantity, price_per_item, total_order_value

FROM {{ ref('orders') }}

WHERE total_order_value != ROUND(quantity * price_per_item, 2)

```

tests/customer_id_numeric_test.sql
```
SELECT customer_id

FROM {{ ref('merged_customers') }}

WHERE customer_id ~ '[^0-9]'
```

### Configurer et utiliser elementary

- Install elementary:
  - Add elementary to `packages.yml`

    ```
    packages:
    - package: elementary-data/elementary
      version: 0.13.0
      ## Docs: https://docs.elementary-data.com
    ```
  - Add to your `dbt_project.yml`
    ```
    models:
      ## see docs: https://docs.elementary-data.com/
      elementary:
        ## elementary models will be created in the schema '<your_schema>_elementary'
        +schema: "elementary"
        ## To disable elementary for dev, uncomment this:
        # enabled: "{{ target.name in ['prod','analytics'] }}"
    ```
  - Import the package and build Elementary models
    - execute command in terminal:

      ```
      dbt deps
      dbt run --select elementary
      ```
    - Run tests
      ```
      dbt test
      ```
- Install Elementary CLI

  Configuring the Elementary Profile

  Pour se connecter, Elementary a besoin d'un profil de connexion dans un fichier nommé profiles.yml. Ce profil sera utilisé par le CLI pour se connecter au DWH et trouver les tables du paquet dbt.

  La façon la plus simple de générer le profil est d'exécuter la commande suivante dans le projet dbt où vous avez déployé le paquetage dbt élémentaire.

  ```
  dbt run-operation elementary.generate_elementary_cli_profile
  ```

  Copiez la sortie, remplissez les champs manquants et ajoutez le profil à votre fichier profiles.yml.

  installer elementary cli

  ```
  pip install elementary-data
  ```
#### Comment le rapport est générer ?
Le rapport d'observabilité des données elementary peut être utilisé pour la visualisation et l'exploration des données des tables dbt-package. Cela inclut les résultats des tests dbt, les résultats de la détection des anomalies élémentaires, les artefacts dbt, les exécutions de tests, etc.

Pour generer un rapport, exécutez la commande :
```
edr report
```
La commande utilisera le profil de connexion fourni pour accéder à l'entrepôt de données, lire les tables élémentaires et générer le rapport sous forme de fichier HTML.

#### Où trouver le rapport ?
après la génération du rapport, les fichiers se trouvent dans le dossier edr_target de votre projet.

####  Partager le rapport

Elementary propose trois méthodes qui facilitent le partage du rapport avec d'autres personnes :

  - Send via Slack
  - Host on Amazon S3
  - Host on Google Cloud Storage (GCS)

#### Comment executer l’envoie de rapport sur slack
Vous pouvez partager le rapport via Slack en tant que pièce jointe html.

- Create a Slack app :
- Create a Slack token

  Allez sur la page "OAauth & Permissions" de votre application nouvellement créée, et ajoutez les scopes suivants sous "Bot Token Scopes" :
    - channels:join
    - channels:read
    - chat:write
    - files:write
    - users:read
    - users:read.email
    - groups:read
- Install app at your Workspace

  Sur la page "OAuth & Permissions", cliquez sur "Install to Workspace" afin de générer un jeton Slack

- Slack config as in config.yml
  Le CLI d'elementary vas lire l'intégration slack à partir d'un fichier config.yml. Créer le fichier dans un repertoire ~/.edr/config.yml.

  Contenu du config.yml
  ```
  slack:
    token: <your_slack_token>
    channel_name: <slack_channel_to_post_at>

  # optional #
  timezone: <optional_timezone_for_timestamps>
  ```

La commande qui envoie le report :

```
edr send-report
```

#### dbt Run partielle

La syntaxe de sélection des nœuds de dbt permet de n'exécuter que des ressources spécifiques lors d'une invocation donnée de dbt. Cette syntaxe de sélection est utilisée pour les sous-commandes suivantes:
- dbt run "--select, --exclude, --selector, --defer" model or source
- dbt test "--select, --exclude, --selector, --defer" model or source



