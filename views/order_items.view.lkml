view: order_items {
  sql_table_name: "PUBLIC"."ORDER_ITEMS"
    ;;
  # drill_fields: [id]

  measure: median_sale_price {
    type: median
    sql: ${sale_price} ;;
  }

parameter: data_as_of {
  type:  date
}

parameter: number_selection {
  group_label: "parameterizing date dimension"
  type: number
}

###########################################
parameter: last_x_days_number {
  type: unquoted
    allowed_value: { label: "7 Days" value: "7" }
    allowed_value: { label: "30 Days" value: "30" }
  }

  parameter: last_x_days {
    type: date
    allowed_value: { label: "7 Days" value: "2021/06/04 for 7 days" }
    allowed_value: { label: "30 Days" value: "2021/05/11 for 30 days" }
  }

  dimension: last_x_days_yesno {
    type: yesno
    sql: {% condition last_x_days %} ${created_date} {% endcondition %} ;;
  }

  measure: average_sale_price_of_last_x_days{
    type: average
    sql: ${sale_price} ;;
    filters: [last_x_days_yesno: "yes"]
    value_format_name: decimal_2
  }

dimension: last_x_days_input {
  type: string
  hidden: yes
  sql:
  {% if last_x_days._parameter_value == '7' %}
  '2021/06/04 for 7 days'
  {% elsif last_x_days._parameter_value == '30' %}
  '2021/05/11 for 30 days'
  {% else %}
  null
  {% endif %};;
}

measure: last_7_days {
  type: count
  filters: [created_date: "2021/06/04 for 7 days"]
}

measure: last_30_days {
  type: count
  filters: [created_date: "2021/05/11 for 30 days"]
}


measure: avg_of_last_x_days {
  type: number
  sql:
  {% if last_x_days._parameter_value == '7' %}
      ${last_7_days}/{{ last_x_days._parameter_value }}
    {% else %}
      ${last_30_days}/{{ last_x_days._parameter_value }}
    {% endif %} ;;
  value_format_name: decimal_3
}
##########################################


parameter: timeframe_selection {
  group_label: "parameterizing date dimension"
  type: string
  allowed_value: { label: "Day" value: "day" }
  allowed_value: { label: "Week" value: "week" }
  allowed_value: { label: "Month" value: "month" }
  allowed_value: { label: "Year" value: "year" }
}

dimension: dynamic_timeframe_test_for_agg_table {
  type: date
  sql: CASE WHEN {% parameter timeframe_selection %} = 'day' THEN ${created_raw}::varchar
WHEN {% parameter timeframe_selection %} = 'week' THEN date_trunc('week',${created_raw})::varchar
WHEN {% parameter timeframe_selection %} = 'month' THEN date_trunc('month',${created_raw})::varchar
WHEN {% parameter timeframe_selection %} = 'year' THEN date_trunc('year',${created_raw})::varchar
END;;
allow_fill: no
}


  dimension: dynamic_timeframe_test_for_agg_table_2 {
    type: date
    sql: CASE WHEN {% parameter timeframe_selection %} = 'day' THEN ${created_date}
      WHEN {% parameter timeframe_selection %} = 'week' THEN ${created_week}
      WHEN {% parameter timeframe_selection %} = 'month' THEN ${created_month}
      WHEN {% parameter timeframe_selection %} = 'year' THEN ${created_year}
      END;;
    allow_fill: no
  }

dimension: parameterized_date_field {
  group_label: "parameterizing date dimension"
type: date
  sql: CASE WHEN
  ${created_date} >= DATEADD({{ timeframe_selection._parameter_value }}, -1*( {{ number_selection._parameter_value}} - 1), DATE_TRUNC({{ timeframe_selection._parameter_value }}, CURRENT_TIMESTAMP()))
  THEN ${created_date}
  ELSE NULL
  END ;;
}

dimension: parameterized_date_field_yesno {
  group_label: "parameterizing date dimension"
  description: "filter this for yes in the query or in a sql_always_where and then we can pull in any of our created_date timeframes that will be governed by our parameter filter selections"
  type: yesno
  sql: ${created_date} >= DATEADD({{ timeframe_selection._parameter_value }}, -1*( {{ number_selection._parameter_value}} - 1), DATE_TRUNC({{ timeframe_selection._parameter_value }}, CURRENT_TIMESTAMP()));;
}

############################################## end parameterized date dimension test

  dimension: status2 {
    type: string
    sql: case when ${TABLE}."STATUS" is null then 'static string' else ${TABLE}."STATUS" end;;
}

  filter: date_filter_1 {
    type: date
    # default_value: "today"
    # default_value: "35 months ago for 1 month"
    sql: {% condition date_filter_1 %} ${created_date} {% endcondition %} ;;
    # suggest_dimension: created_month
  }

  filter: number {
    type: number
  }

  filter: number_as_string {
    type: string
  }

  filter: string_filter_with_sql_and_suggest_dim {
    type: string
    sql: concat({% condition date_filter_1 %} ${created_date_month} {% endcondition %}, '-01') ;;
    suggest_dimension: created_date_month
  }

  parameter: number_parameter {
    type: number
    default_value: "25"
  }

  parameter: string_parameter {
    type: string
    default_value: "50"
  }

  dimension: sale_price_with_number_param {
    type: number
    sql: case when {% parameter number_parameter %} = ${sale_price} then ${sale_price} else null end ;;
  }

  dimension: sale_price_with_string_param {
    type: number
    sql: case when {% parameter string_parameter %} = ${sale_price} then ${sale_price} else null end ;;
  }

  dimension: templated_filter_test_with_filter {
    type: number
    sql: case when {% condition number_as_string %} ${sale_price} {% endcondition %} then ${sale_price} else null end ;;
  }

#   dimension: html_drill_test {
#     group_label: "html testing"
#     type: string
#     sql: 1=1 ;;
#     html: <a style="color: #EA4335; border: solid 1px #EA4335; float: left; font-weight: 400; text-align: center; vertical-align: middle; cursor: pointer; user-select: none; padding: 10px; margin: 5px;  font-size: 1rem; line-height: 1.5;  border-radius: 5px;"
# href="https://dcl.dev.looker.com/dashboards-next/856?Department+Test={{ _filters['products.department'] | url_encode }}" target="_blank">Day</a> ;;
#   }


  dimension: user_attribute_test {
    type: number
    sql: {{ _user_attributes['danielle_number_test'] }} ;;
  }

  dimension: sale_price_filtered {
    type: number
    sql: case when {% condition number %} ${sale_price} {% endcondition %} then ${sale_price} else null end;;
  }

  dimension: 45_date_range {
    type: number
    sql: DATEDIFF(day, {% date_start date_filter_1 %}, {% date_end date_filter_1 %});;
  }

  dimension: 45_date_range_dim_ref {
    type: yesno
    sql: DATEDIFF(day, {% date_start create_test_date %}, {% date_end create_test_date %}) <= 45;;
  }

  dimension_group: time_between_created_and_returned {
    type: duration
    intervals: [second, minute, hour, day, week]
    sql_start: ${TABLE}.created_at ;;
    sql_end: ${TABLE}.returned_at ;;
  }

  dimension: templated_filter_on_date {
    type: date
    sql: {% condition date_filter_1 %} ${created_raw}::timestamp_ntz {% endcondition %};;
  }

  dimension: create_test_date {
    type: date
    sql: ${created_date} ;;
  }

  dimension_group: current {
    group_label: "Now"
    label: "Now"
    type: time
    timeframes: [date, week, day_of_week_index, day_of_week]
    sql: current_date() ;;
  }

  dimension: current_time {
    group_label: "Current Date"
    type: date_time
    sql: current_timestamp();;
  }

  measure: total_sale_price_2020_test {
    # group_label: "Total Sale Price - Specific Years"
    label: "total sale price for {{ order_items.current_date._value }}"
    type: sum
    sql: ${sale_price};;
    value_format_name: usd_0
    filters: [created_year: "2020"]
  }

  measure: status_list {
    type: list
    list_field: status
  }

  ###### HTML IMAGES ###########
  dimension: aon_logo {
    group_label: "html testing"
    type: string
    sql: 1 ;;
    html: <img src="https://cdn.filestackcontent.com/fMVx1x2rQb5oHLv0QA4l" height=60% width=60% /> ;;
  }

  dimension: aon_logo_div_tags {
    group_label: "html testing"
    type: string
    sql: 1 ;;
    html: <div class="single-value"><img src="https://cdn.filestackcontent.com/fMVx1x2rQb5oHLv0QA4l" height=60% width=60% /> </div> ;;
  }

  dimension: html_spacing_test {
    group_label: "html testing"
    type: string
    sql: 'here is some text' ;;
    html:
    <p style="font-size:25px; text-align:center; font-weight: bold">{{ order_items.status._value }}</p>
    <p style="color: black; background-color: gold; font-size:30px; text-align:center">{{ rendered_value }}</p>
    <p style="font-size:15px; text-align:center">The Warehouse load has not yet competed<br>Looks or Dashboards using this Wareouse<br>will not yet return data</p> ;;
  }

  dimension: html_spacing_test_2 {
    group_label: "html testing"
    type: string
    sql: 'here is some text' ;;
    html: <p style="font-size:25px; text-align:center; font-weight: bold; line-height: 1.5">{{ order_items.status._value }}</p>
          <p class="small" style="color: black; background-color: crimson; font-size:30px; text-align:center; line-height: 1.5">{{ rendered_value }}<br><span style="font-size:25px; line-height: 1.5">{{ order_items.created_date._value }}</span></p>
          <p class="small" style="font-size:15px; text-align:center; line-height: 1.5">The updated date is listed above</p>
          ;;
  }

  ##########

  parameter: is_large_order {
    description: "parameter of type number"
    type: number
    allowed_value: {
      label: "Yes"
      value: "1"
    }
    allowed_value: {
      label: "No"
      value: "0"
    }
    allowed_value: {
      label: "All Results"
      value: ""
    }
  }

  dimension: is_big_order {
    type: yesno
    sql: ${sale_price}>=200 ;;
  }

  dimension: string_test  {
    type: string
    sql: case when ${is_big_order} then 'Big' else 'Small' end ;;
  }

  dimension: large_order_flag {
    type: number
    sql: case when ${sale_price}>=200 then 1 else 0 end;;
  }

  measure: count_big_orders {
    type: count_distinct
    sql: case when ${is_big_order} then ${order_id} else null end;;
  }

  measure: count_small_orders {
    type: count_distinct
    sql: case when NOT(${is_big_order}) then ${order_id} else null end;;
  }

  measure: count_small_orders_filters_param {
    type: count_distinct
    sql: ${order_id} ;;
    filters: [is_big_order: "false"]
  }

  dimension: status_lookml_case_when {
    case: {
      when: {
        label: "Complete"
        sql: ${status} = 'Complete' ;;
      }
      when: {
        label: "Cancelled"
        sql: ${status} = 'Cancelled' ;;
      }
      when: {
        label: "Returned"
        sql: ${status} = 'Returned' ;;
      }
      when: {
        label: "Shipped"
        sql: ${status} = 'Shipped' ;;
      }
      when: {
        label: "Processing"
        sql: ${status} = 'Processing' ;;
      }
      when: {
        label: "Total"
        sql: 1=1 ;;
      }
    }
  }

  dimension: dummy_case {
    case: {
      when: {
        label: "Count"
        sql: 1=1 ;;
      }
      when: {
        label: "Average Sale Price"
        sql: 1=1 ;;
      }
      when: {
        label: "Median Sale Price"
        sql: 1=1 ;;
      }
    }
  }

###############################################################

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ID" ;;
  }

  dimension_group: created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      day_of_week_index,
      day_of_year,
      day_of_month,
      week,
      week_of_year,
      month,
      month_name,
      month_num,
      quarter,
      year
    ]
    sql: ${TABLE}."CREATED_AT" ;;
  }

  dimension: created_date_month {
    type: string
    sql: to_char(${created_month}) ;;
  }

  dimension_group: created_test {
    type: time
    timeframes: [
      date, time_of_day,
      hour_of_day
    ]
    sql: ${TABLE}."CREATED_AT" ;;
  }

  dimension: time_of_day_number {
    type: number
    sql: to_number(${created_test_time_of_day}) ;;
    # value_format_name: decimal_2
  }

  dimension: year {
    # type: string
    type: number
    sql: TO_NUMBER(${created_year}) ;;
    # datatype: date
  }

######### End of year with weeks testing
  dimension: year_of_week {
    group_label: "end of year testing"
    # type: number
    sql: YEAROFWEEKISO(${created_raw}) ;;
  }

  dimension: weekofyear_snowflake {
    group_label: "end of year testing"
    # type: number
    sql: WEEKOFYEAR(${created_raw}) ;;
  }

  dimension: isoweekofyear_snowflake {
    group_label: "end of year testing"
    # type: number
    sql: WEEKISO(${created_raw}) ;;
  }

  dimension: mod {
    type: number
    sql:  mod(${created_day_of_year},52) ;;
  }

  dimension: case_when_week {
    group_label: "end of year testing"
    type: number
    sql:
    case when (${created_week_of_year} = 52 AND ${mod} = 0) then ${created_week_of_year}
    when (${created_week_of_year} <= 53 AND ${created_week_of_year} >= 52 AND ${mod} > 0 AND ${created_month_name} = 'December') then (${created_week_of_year})
    when (${created_week_of_year} <= 53 AND ${created_week_of_year} >= 52 AND ${mod} > 0 AND ${created_month_name} = 'January') then 1
    else ${created_week_of_year} end;;
  }

  dimension: case_when_week_of_year {
    group_label: "end of year testing"
    type: number
    sql:
    case
    when (${created_week_of_year} = 1 AND ${created_month_name} = 'December') then 53
    when (${created_week_of_year} <= 53 AND ${created_week_of_year} >= 52 AND ${created_month_name} = 'January') then 1
    else ${created_week_of_year} end;;
  }

  # dimension: week_test {
  #   group_label: "end of year testing"
  #   type: number
  #   sql:  CASE WHEN (${created_week} < 52 AND mod = 0) THEN ${created_day_of_year}/52
  #         WHEN (${created_week_of_year} < 52 AND mod(${created_day_of_year}/52) >0) THEN ${created_week_of_year} + 1
  #         ELSE 52
  #         END ;;
  # }

#   CASE WHEN (week < 52 AND mod = 0) THEN day_of_year/52
# WHEN (week < 52 AND mod > 0) THEN ${week} + 1,
# ELSE 52
# END

  dimension: week_of_year {
    group_label: "end of year testing"
    type: number
    sql: TO_NUMBER(${created_week_of_year}) ;;
  }


###########. End test

  dimension_group: delivered {
    type: time
    timeframes: [
      raw,
      time,
      time_of_day,
      date,
      day_of_week,
      day_of_week_index,
      week,
      day_of_month,
      month,
      month_name,
      quarter,
      year
    ]
    sql: ${TABLE}."DELIVERED_AT" ;;
    # convert_tz: no
    # html: {% if delivered_html_test_day_of_week_index == 5 %} <font color="green">{{ value }}</font>
    # {% else %} {{value}}
    # {% endif %};;
  }

  dimension: concat_date_dimension_test {
    type: string
    sql: ${delivered_day_of_week} || ', ' || to_char(${delivered_day_of_month}) || ' ' || ${delivered_month_name} || ' ' || ${delivered_time_of_day} ;;
    order_by_field: delivered_time
  }

  dimension: inventory_item_id {
    type: number
    hidden: yes
    sql: ${TABLE}."INVENTORY_ITEM_ID" ;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}."ORDER_ID" ;;
  }

  dimension_group: returned {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."RETURNED_AT" ;;
  }

  dimension: sale_price {
    type: number
    sql: ${TABLE}."SALE_PRICE" ;;
    html: <b>{{value}}<b> <br> {{value}};;
  }

  #########
  dimension: sale_price_with_negatives {
    type: number
    sql: case when (${products.category}= 'Leggings') then -1*${sale_price} else ${sale_price} end;;
    value_format_name: usd_0
  }

  measure: total_sale_price_with_negatives {
    type: sum
    sql: ${sale_price_with_negatives} ;;
    value_format_name: usd_0
  }

#############

  dimension: sale_price_tiers {
    type: tier
    tiers: [0, 10, 20, 30, 40, 50, 60, 100, 150, 200, 250, 300]
    style: integer
    sql: ${sale_price} ;;
  }

  dimension: sale_price_value_format_id_type {
    type: string
    sql: CONCAT('\'',${TABLE}."SALE_PRICE"*12345678987650000::VARCHAR);;
    # value_format: "id"
  }

  dimension: sale_price_value_format_id_type_2 {
    type: string
    sql: ${sale_price_value_format_id_type};;
    # sql: CONCAT('\'',${TABLE}."SALE_PRICE"*12345678987650000);;
    value_format_name: id
  }

  dimension_group: shipped {
    type: time
    # datatype: datetime
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."SHIPPED_AT" ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
    # html: <b>{{value}}<b> <br> {{value}};;
#     html: <div class="btn-group btn-group-toggle" data-toggle="buttons">
# <label class="btn btn-secondary active">
# <input type="radio" name="options" id="option1" autocomplete="off" checked>
# <a class="btn btn-lg btn-light" href="https://dcl.dev.looker.com/dashboards/112">
# <i class="fa fa-globe fa-2x"></i>
# <br />
# {{value}}
# </a>
# </label>
# <label class="btn btn-secondary">
# <input type="radio" name="options" id="option2" autocomplete="off">
# <a class="btn btn-lg btn-light" href="https://dcl.dev.looker.com/dashboards/113">
# <i class="fa fa-pencil fa-2x" aria-hidden="true"></i>
# <br />
# Usage
# </a>
# </label>
# <label class="btn btn-secondary">
# <input type="radio" name="options" id="option3" autocomplete="off">
# <a class="btn btn-lg btn-light" href="https://dcl.dev.looker.com/dashboards/114">
# <i class="fa fa-check-square-o fa-2x" aria-hidden="true"></i>
# <br />
# Performance
# </a>
# </label>
# </div> ;;
  }

  dimension: user_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: special_character_test {
    label: "Curly Braces Test"
    type: string
    sql: case when ${status} ='Complete' then 'https://company.com/test=$\{testing\}'
          else ${TABLE}."STATUS" end;;
  }

  dimension: sale_price_times_100 {
    type: number
    # sql: case when ${sale_price} <50 then ${sale_price}*-1 else ${sale_price} end;;
    sql: ${TABLE}.sale_price * 100 ;;
    # value_format_name: decimal_2
    # value_format: "[>=1000000000]0.00,,,\"B\";[>=1000000]0.00,,\"M\";[>=1000]0.00,\"K\";0.00"
    # value_format: "[>=1000000]$0.0,,\" M\";[>=1000]$0.0,\" K\";[<1000]$0.0"
    # value_format: "[>=1000000]$0.0,,\" M\";[>=1000]$0.0,\" K\";[<1000]$0.00"
    # value_format: "$#.00;($#.00)"
  }

  dimension: sale_price_times_negative_10 {
    type: number
    sql: ${TABLE}.sale_price * -10 ;;
    value_format_name: decimal_2
  }

  measure: count {
    description: "total count of order items"
    type: count
    # drill_fields: [detail*]
  }

  measure: percentile_75_test {
    type: percentile
    percentile: 75
    sql: ${sale_price} ;;
  }

  # measure: day_over_day_percent_change {
  #   type: number
  #   sql: COALESCE(((${count}-${previous_day_with_lead_function_dt.previous_days_count})/${previous_day_with_lead_function_dt.previous_days_count}),0) ;;
  #   value_format_name: percent_2
  #   drill_fields: [detail*]
  # }

  measure: count_complete {
    type: count
    filters: [status: "Complete"]
    value_format_name: decimal_0
  }

  dimension: within_date_range {
    type: yesno
    sql: ${shipped_date} > ${created_date} ;;
  }

  measure: count_within_date_range {
    type: count
    filters: [within_date_range: "yes"]
  }

  measure: total_sale_price {
    type: sum
    sql: ${sale_price} ;;
    value_format_name: usd_0
    # html: {%if total_sale_price < 0 %}
    # {{value}}
    # {% else %}
    # {% endif %};;
  }

  measure: total_sale_price_negative {
    type: sum
    sql: ${sale_price_times_negative_10} ;;
    value_format_name: decimal_2
  }

  measure: test {
    type: number
    sql: ${total_sale_price} / ${count} ;;
  }

  measure: percent_of_total_sale_price {
    type: percent_of_total
    sql: ${total_sale_price};;
    value_format_name: percent_2
  }

  measure: average_sale_price {
    type: average
    sql: ${sale_price} ;;
    value_format_name: usd
      link: {
        label: "Relative Link Drill with Param Test"
        url: "/explore/snowflake_test/order_items?fields=order_items.count,order_items.created_date,users.first_name,users.last_name,users.state&f[order_items.is_big_order]=Yes&f[order_items.data_as_of]={{ _filters['order_items.data_as_of'] }}&f[users.country]=USA&f[users.state]={{ _filters['users.state'] }}&sorts=orders.created_date"
      }

    link: {
      label: "Relative Drill Link"
      url: "/explore/snowflake_test/order_items?fields=order_items.count,order_items.created_date,users.first_name,users.last_name&f[order_items.is_big_order]=Yes&f[order_items.created_date]={{ _filters['order_items.created_quarter'] }}&f[users.country]=USA&f[users.state]={{ _filters['users.state'] }}&sorts=order_items.created_date+desc"
    }

    link: {
      label: "Absolute Drill Link with Param"
      url: "https://dcl.dev.looker.com/explore/snowflake_test/order_items?fields=order_items.count,order_items.created_date,users.first_name,users.last_name,users.state&f[order_items.is_big_order]=Yes&f[order_items.data_as_of]={{ _filters['order_items.data_as_of'] }}&f[users.country]=USA&f[users.state]={{ _filters['users.state'] }}&sorts=orders.created_date"
    }
  }

  # measure: average_sale_price_filtered_measure_1 {
  #   type: average
  #   sql: ${sale_price} ;;
  #   filters: [percent_rank_dt.percentile_buckets: "1"]
  # }

  measure: order_count_decimal_value_format_html {
    type: count_distinct
    sql: ${order_id} ;;
    value_format_name: usd_0
    html: <b> €{{ value | round }} </b> ;;
  }

  dimension: date_html {
    type: string
    sql: '('||${created_date}||' - '||${returned_date}||') '||${users.first_name} ;;
    html: ( {{ created_raw._value | date: "%b %d, %y" }} - {{ created_raw._value | date: "%b %d, %y" }} )  {{ users.id._value }} ;;
    #- {{ returned_raw._rendered_value | date: "%b %d, %y" }}) {{ users.first_name._rendered_value }} ;;
  }

  measure: filtering_on_measure_test {
    type: number
    sql: case when ${total_sale_price} > 100 then count(distinct ${id}) else null end ;;
  }

############ Total Sale Price per Year Parameter Test ##############

parameter: year_selector {
  type: string
  allowed_value: { value: "2018" }
  allowed_value: { value: "2019" }
  allowed_value: { value: "2020" }
}

  measure: dynamic_total_sale_price_by_year {
    type: number
    label_from_parameter: year_selector
    sql:
      CASE
        WHEN {% parameter year_selector %} = '2018' THEN ${total_sale_price_2018}
        WHEN {% parameter year_selector %} = '2019' THEN ${total_sale_price_2019}
        WHEN {% parameter year_selector %} = '2020' THEN ${total_sale_price_2020}
        ELSE NULL
        END ;;
    value_format_name: usd_0
  }

  filter: year_selector_filter {
    type: string
    suggest_dimension: created_year
  }

  measure: total_sale_price_2020 {
    group_label: "Total Sale Price - Specific Years"
    type: sum
    sql: ${sale_price};;
    value_format_name: usd_0
    filters: [created_year: "2020"]
  }

  measure: total_sale_price_2019 {
    group_label: "Total Sale Price - Specific Years"
    type: sum
    sql: ${sale_price};;
    value_format_name: usd_0
    filters: [created_year: "2019"]
  }

  measure: total_sale_price_2018 {
    group_label: "Total Sale Price - Specific Years"
    type: sum
    sql: ${sale_price};;
    value_format_name: usd_0
    filters: [created_year: "2018"]
  }

###############

  measure: count_orders_2020 {
    type: count
    filters: [created_year: "2020"]
    link: {
      label: "Drill into count orders 2020"
      url: "
      {% if _explore._name == 'order_items' %}
      {{ dummy_2._link }}
      {% endif %}"
    }

    link: {
      label: "Drill with totals and row totals"
      url: "{{ dummy_2._link }}&pivots=order_items.created_month&total=on&row_total=right"
    }

    link: {
      label: "Monthly Trend"
      url: "
      {% assign vis_config = '{
      \"type\" : \"looker_line\",
      \"x_axis_label\" : \"Month\"
      }' %}
      {{ dummy_2._link }}&fields=count_orders_2020,created_month&vis_config={{ vis_config | encode_uri }}&limit=20"
    }
    }

  measure: dummy_2 {
    type: number
    drill_fields: [users.state,count_orders_2020,created_month]
    sql: 1 ;;
    hidden: yes
  }

  measure: count_orders_2019 {
    type: count
    filters: [created_year: "2019"]
  }

  measure: yoy_percent_change_order_items{
    type: number
    sql: (${count_orders_2020}-${count_orders_2019})/nullif(${count_orders_2019},0) ;;
    value_format_name: percent_2
  }

###### Drill Test ########
  measure: drill_test_measure {
    type: average
    sql: ${sale_price} ;;
    value_format_name: decimal_0
    link: {
      label: "Drill Details"
      url: "{{drill_fields_dummy_measure._link}}&f[order_items.is_big_order]=Yes&f[order_items.created_quarter]={{ _filters['order_items.created_quarter'] }}&f[users.country]=USA&f[users.state]={{ _filters['users.state'] }}&sorts=order_items.created_date+desc"
    }
  }

  measure: drill_fields_dummy_measure {
    type: number
    sql: 1 ;;
    drill_fields: [order_items.count,order_items.created_date,users.first_name,users.last_name]
  }

  ######## example reported in bug #########

#   link: {
#     label: "See Labor Detail"
#     url: "/explore/dw/jcdetail_all?fields=jcdetail_all.effective_date,employee_info.teammate_number,employee_info.first_name,employee_info.last_name,jcdetail_reference.class,jcdetail_all.quantity,hqunits_of_measure.unit_of_measure,jctask.task_name,jctask.task_description,jcdetail_all.total_labor&f[jccost_types.cost_type_group_description]=Labor&f[jcjob.master_project_number]={{ _filters['jcjob.master_project_number'] }}&f[effectivedate.data_as_of]={{ _filters['effectivedate.data_as_of'] }}&f[jcdetail_all.is_trans_type_cost]=Yes&sorts=jcdetail_all.effective_date" }
# }

  measure: average_order_price_value_format {
    type: average
    sql: ${sale_price} ;;
    # value_format: "[mod 0]0;[mod 1]0.#;[mod 2]0.##"
  }

  measure: running_total {
    type: running_total
    sql: ${count} ;;
    direction: "column"
  }

##### Aggregate table test using measures of type: number

  # measure: sum_sale_price_type_number {
  #   type: number
  #   sql: sum(${sale_price}) ;;
  # }

  measure: max_sale_price_type_number {
    type: number
    sql: max(${sale_price}) ;;
  }

  measure: count_sale_price_type_number {
    type: number
    sql: count(${sale_price}) ;;
  }

  measure: total_sale_price_type_number {
    description: "references the total_sale_price measure of type: sum"
    type: number
    sql: ${total_sale_price} ;;
  }

  measure: reference_sums_and_divide {
    type: number
    sql: 1.0*${total_sale_price}/nullif(${total_sale_price},${total_sale_price}+2) ;;
  }

  measure: test_with_required_fields {
    type: yesno
    # sql: min(${created_date}) < current_date() ;;
    # sql: min(${inventory_items.created_date}) OVER (PARTITION BY ${status}, ${shipped_date}) = ${inventory_items.created_date};;
    sql: min(${created_date}) OVER (PARTITION BY ${status}, ${most_recent_shipped_date}) = ${created_date};;
    # required_fields: [inventory_items.created_date, status, shipped_date]
    required_fields: [created_date, status, most_recent_shipped_date]
  }

  measure: most_recent_shipped_date {
    type: date
    sql: max(${shipped_date}) ;;
  }

  # sql: (MIN(${fact_scan_event_filtered.created_at_date}) OVER (PARTITION BY ${schema_id_mhu}, ${finding_sub_type}, ${first_appearance_date}) = ${fact_scan_event_filtered.created_at_date});;


######## Rank test for CJ

  # measure: rank_calculation_test_with_case_statement {
  #   type: number
  #   sql: ${total_sale_price} * (case when ${rank_derived_table.rank} > 8400 then 0 else 1 end) ;;
  # }

  # measure: test_with_measure_rank {
  #   type: number
  #   sql: ${total_sale_price} * (case when ${sum_rank} > 150 then 0 else 1 end) ;;
  # }

  # measure: sum_rank {
  #   type: sum
  #   sql:${rank_derived_table.rank} ;;
  # }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      id,
      users.first_name,
      users.last_name,
      users.id,
      inventory_items.id,
      inventory_items.product_name
    ]
  }
}
