connection: "snowflakelooker"

include: "/views/*.view.lkml"                # include all views in the views/ folder in this project
# include: "/**/view.lkml"                   # include all views in this project
# include: "my_dashboard.dashboard.lookml"   # include a LookML dashboard called my_dashboard

include: "/new_folder/testing.view"

include: "/snowflake_test/*.view"

# explore: order_items {
#   join: products {
#     relationship: many_to_one
#     sql_on: ${order_items.special_character_test_5} = ${products.special_character_test} ;;
#   }
# }

view: +order_items {
  dimension: new_dimension_test {
    type: string
    sql: 'new dimension' ;;
  }
}


explore: products_capitalization {}

explore: transpose_measures_dt {}

# explore: order_items {
# }

# Place in `model_2` model
explore: +order_items {
  aggregate_table: rollup__created_date__sale_price__status {
    query: {
      dimensions: [created_date, sale_price, status]
      # measures: [sum_sale_price_type_number]
      measures: [reference_sums_and_divide]
      timezone: "America/Los_Angeles"
    }

    materialization: {
      persist_for: "5 minutes"
    }
  }
}


explore: order_items {
  sql_always_where: {% condition products.category_parameter %} products.category {% endcondition %} ;;
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
}

explore: products {
  join: distribution_centers {
    type: left_outer
    sql_on: ${products.distribution_center_id} = ${distribution_centers.id} ;;
    relationship: many_to_one
  }
}



##### Customer's agg table

# explore: fw_agaw_static_operative_capacity_intl {
#   required_access_grants: [can_access_fw]
#   label: "FW Daily/Monthly Aggregated Explore"

#   aggregate_table: rollup__activity_date__new_property {
#     query: {
#       dimensions: [activity_date, new_property,international_audience,videoclicks,adviews]
#       measures: [ctr_simple_test]
#       filters: [
#         fw_agaw_static_operative_capacity_intl.activity_date: "2020/01/01 to 2020/12/31",
#         fw_agaw_static_operative_capacity_intl.international_audience: "Yes"
#       ]
#       timezone: "UTC"
#     }

#     materialization: {
#       datagroup_trigger: cnni_dvi_default_datagroup
#     }
#   }
# }