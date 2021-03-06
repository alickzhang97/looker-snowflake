connection: "snowflakelooker"

# include all the views
include: "/views/**/*.view"
include: "/**/map_layers.lkml"

datagroup: snowflake_test_default_datagroup {
  sql_trigger: SELECT current_date() ;;
  max_cache_age: "1 hour"
}

persist_with: snowflake_test_default_datagroup

explore: distribution_centers {}

explore: etl_jobs {}

explore: pagination_test {}

explore: events {
  fields: [ALL_FIELDS*, -users.state_with_order_by_field]
  join: users {
    type: left_outer
    sql_on: ${events.user_id} = ${users.id} ;;
    relationship: many_to_one
  }
}

explore: inventory_items {
  join: products {
    type: left_outer
    sql_on: ${inventory_items.product_id} = ${products.id} ;;
    relationship: many_to_one
  }

  join: distribution_centers {
    type: left_outer
    sql_on: ${products.distribution_center_id} = ${distribution_centers.id} ;;
    relationship: many_to_one
  }
}

explore: order_items {
  fields: [ALL_FIELDS*, -users.state_with_order_by_field]
  join: users {
    type: left_outer
    sql_on: ${order_items.user_id} = ${users.id} ;;
    relationship: many_to_one
  }

  join: inventory_items {
    type: left_outer
    sql_on: ${order_items.inventory_item_id} = ${inventory_items.id} ;;
    relationship: many_to_one
  }

  join: products {
    type: left_outer
    sql_on: ${inventory_items.product_id} = ${products.id} ;;
    relationship: many_to_one
  }

  join: distribution_centers {
    type: left_outer
    sql_on: ${products.distribution_center_id} = ${distribution_centers.id} ;;
    relationship: many_to_one
  }

  join: rank_derived_table {
    type: left_outer
    sql_on: ${order_items.id} = ${rank_derived_table.id} ;;
    relationship: many_to_one
  }


  join: orders_by_quarter_derived_table {
    type: left_outer
    sql_on: ${order_items.created_quarter} = ${orders_by_quarter_derived_table.order_items_created_quarter} AND ${products.category} = ${orders_by_quarter_derived_table.products_category};;
    relationship: many_to_one
  }

  join: previous_day_with_lead_function_dt {
    type: inner
    sql_on: ${order_items.created_date} = ${previous_day_with_lead_function_dt.date} ;;
    relationship: many_to_one
  }
}

explore: products {
  join: distribution_centers {
    type: left_outer
    sql_on: ${products.distribution_center_id} = ${distribution_centers.id} ;;
    relationship: many_to_one
  }
}

explore: rank3 {}

explore: users {
  join: users_dt {
    type: left_outer
    sql_on: ${users.state} = ${users_dt.users_state} ;;
    relationship: many_to_one
  }
}
