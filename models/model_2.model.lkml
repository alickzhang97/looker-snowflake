connection: "snowflakelooker"

include: "/views/*.view.lkml"                # include all views in the views/ folder in this project
# include: "/**/view.lkml"                   # include all views in this project
# include: "/*/alert_test_dashboard.dashboard"   # include a LookML dashboard called my_dashboard
include: "/**/map_layers.lkml"

include: "/new_folder/testing.view"

include: "/snowflake_test/*.view"

include: "/drill_link_lookml_dash.dashboard"

# explore: order_items {
#   join: products {
#     relationship: many_to_one
#     sql_on: ${order_items.special_character_test_5} = ${products.special_character_test} ;;
#   }
# }

datagroup: snowflake_test_default_datagroup {
  sql_trigger: SELECT current_date() ;;
  max_cache_age: "1 hour"
}

persist_with: snowflake_test_default_datagroup

explore: blah {
  extension: required
}


explore: products_capitalization {}

# explore: transpose_measures_dt {}

explore: running_total_derived_table {}

explore: running_total_ndt {}

explore: tiers_on_measure {
  cancel_grouping_fields: []
}

explore: order_items {
# view_label: ""
fields: [ALL_FIELDS*, -users.state_with_order_by_field]

  # always_filter: {
  #   filters: [order_items.created_date: "last 7 days", order_items.status: "Returned"]
  # }

  #   always_filter: {
  #   filters: [order_items.created_date: "last 7 days", order_items.status: ""]
  # }

  # symmetric_aggregates:  no
  # sql_always_where: ${order_items.is_big_order} ;;

  # sql_always_where: {%condition order_items.is_large_order%} ${order_items.large_order_flag} {%endcondition%};;
  # {% condition products.category_parameter %} products.category {% endcondition %} AND
  # sql_always_where: {% if order_items.date_filter_1._is_filtered %} ${order_items.created_test_date} BETWEEN ifnull({% date_start order_items.date_filter_1 %},to_date('2000-01-01')) AND ifnull({% date_end order_items.date_filter_1 %},to_date('2100-01-01')) {%else%} 1=1 {%endif%} ;;
  # sql_always_where: {% if order_items.create_test_date._is_filtered %} ${45_date_range_dim_ref} {% else %} 1=1 {% endif %} ;;
  # sql_always_where: ${45_date_range_dim_ref} ;;

# access_filter: {
#   field: order_items.status
#   user_attribute: status
# }



  join: users {
    view_label: ""
    type: left_outer
    sql_on: ${order_items.user_id} = ${users.id} ;;
    relationship: many_to_one
  }

  join: inventory_items {
    view_label: "InventoryItems"
    type: left_outer
    sql_on: ${order_items.inventory_item_id} = ${inventory_items.id} ;;
    relationship: many_to_one
  }

  join: products {
    type: left_outer
    sql_on: ${inventory_items.product_id} = ${products.id} ;;
    relationship: one_to_many
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

  join: running_total_derived_table {
    type: left_outer
    sql_on: ${order_items.created_month} = ${running_total_derived_table.created_month} ;;
    relationship: many_to_one
  }

  join: percent_rank_dt {
    type: left_outer
    sql_on: ${products.brand} = ${percent_rank_dt.brand} ;;
    relationship: many_to_one
  }

  join: previous_day_with_lead_function_dt {
    type: inner
    sql_on: ${order_items.created_date} = ${previous_day_with_lead_function_dt.date} ;;
    relationship: many_to_one
  }

#   join: rank_city_state {
#     type: left_outer
#     sql_on: ${order_items.created_date} = ${rank_city_state.order_items_created_date} AND ${rank_city_state.rank} = 1 ;;
#   }

#   join: ndt_test {
#     type: cross
#     sql: 1=1 ;;
#   }
}


explore: products {
  join: distribution_centers {
    type: left_outer
    sql_on: ${products.distribution_center_id} = ${distribution_centers.id} ;;
    relationship: many_to_one
  }
  join: inventoryitems {
    from: inventory_items
    view_label: "Inventoryitems"
    type: left_outer
    sql_on: ${inventoryitems.product_id} = ${products.id} ;;
    relationship: many_to_one
  }
}


explore: inventory_items {
  symmetric_aggregates: no
  fields: [ALL_FIELDS*, -order_items.sale_price_with_negatives, -users.state_with_order_by_field]
  join: order_items {
    type: left_outer
    # relationship: many_to_one
    relationship: one_to_many
    sql_on: ${order_items.inventory_item_id} = ${inventory_items.id} ;;
  }

  #comment

  join: users {
    type: left_outer
    sql_on: ${order_items.user_id} = ${users.id} ;;
    relationship: many_to_one
  }
}

explore: +order_items {
  aggregate_table: rollup__created_date__products_brand__products_category__products_department__users_age__users_city__users_country__users_first_name__users_gender__users_id__users_last_name__users_state {
    query: {
      dimensions: [
        created_date,
        products.brand,
        products.category,
        products.department,
        users.age,
        users.city,
        users.country,
        users.first_name,
        users.gender,
        users.id,
        users.last_name,
        users.state
      ]
      measures: [average_sale_price, count, products.count, total_sale_price, users.count]
      filters: [
        order_items.created_date: "7 days",
        users.country: "USA"
      ]
    }

    materialization: {
      persist_for: "24 hours"
    }
  }
}

view: +order_items {
  dimension: new_dimension_test {
    type: string
    sql: 'new dimension' ;;
  }
}
