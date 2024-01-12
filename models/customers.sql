{{ config(materialized='table') }}

with customers as (
  SELECT
    id as customer_id,
    first_name,
    last_name
  FROM `molecule_science_pipelines`.dbt_poc_peakace.customers
)

orders as (
  SELECT
    id as order_id
    user_id as customer_id
    order_date,
    status
  FROM `molecule_science_pipelines`.dbt_poc_peakace.orders
)

customer_orders as (
  SELECT
    customer_id,
    min(order_date) as first_order_date
    max(order_date) as most_recent_order_date
    count(order_id) as number_of_orders
  FROM orders

  GROUP BY 1
)

final as (
  SELECT
    customers.customer_id,
    customers.first_name,
    customers.last_name,
    customer_orders.first_order_date
    customer_orders.most_recent_order_date
    coalesce(customer_orders.number_of_orders) as number_of_orders
  FROM customers

  LEFT JOIN customer_orders USING (customer_id)
)

SELECT * FROM final

