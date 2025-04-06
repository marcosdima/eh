class_name Proportion

var values = Vector2(0, 0)

func _init(xp: float, yp: float):
	self.update_values(xp, yp)


func update_values(xp: float, yp: float):
	if (xp > 1 || yp > 1) || (xp < 0 || yp < 0) :
		push_error("Proportion values should be numbers between 0 and 1.")
	self.values = Vector2(xp, yp)


func get_size_from(v: Vector2):
	return v * values
