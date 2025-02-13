extends Node


static var current_time = String(Time.get_datetime_string_from_system(false, true))
static var date_partition = current_time.split("T")[0]
static var sys_year = date_partition.split("-")[0]
static var sys_month = date_partition.split("-")[1]
static var month_year = sys_month + "/" + sys_year
