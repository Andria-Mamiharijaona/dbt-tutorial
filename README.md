Welcome to your new dbt project!

### Using the starter project

create enverinoment python for dbt:
 - python3 -m venv dbt_env
 - source dbt-env/bin/activate
 - python -m pip install dbt-core
 - python -m pip install dbt-biquery
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

Try running the following commands:
- dbt run
- dbt test


### Resources:
- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [chat](https://community.getdbt.com/) on Slack for live discussions and support
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices
