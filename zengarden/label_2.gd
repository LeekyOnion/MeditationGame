extends Label

func _process(delta):
	if Global.sys_month == "12" or "01" or "02":
		self.text = "Winter"
	elif Global.sys_month == "03" or "04" or "05":
		self.text = "Spring"
	elif Global.sys_month == "06" or "07" or "08":
		self.text = "Summer"
	elif Global.sys_month == "09" or "10" or "11":
		self.text = "Fall"
