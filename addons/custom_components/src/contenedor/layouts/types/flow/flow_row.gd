class_name FlowRow

# Elements count.
var elements = 0

# Row starts at...
var start = Vector2.ZERO
# Size available.
var size = Vector2.ZERO

# How long has moved to the rigth.
var y_move = 0
# What was the tallest element in row
var x_move = 0

var space_between_rows = 0
var space_between_elements = 0

func _init(
	start_at: Vector2,
	s: Vector2,
	space_between: float,
	):

	self.start = start_at
	self.size = s
	self.space_between_elements = space_between


## Set [param obj] position.
func append_an_element(obj: Element):
	if !self.fit(obj):
		print("This row is full!")
	else:
		obj.set_element_position(self.start + Vector2(x_move, 0))

		var x = obj.size.x
		var y = obj.size.y
		
		if self.y_move < y:
			self.y_move = y
		
		self.x_move = self.x_move + x
		elements += 1


## Creates next [param FlowRow]
func next(sb_rows: float) -> FlowRow:
	var new_start = Vector2(self.start.x, self.start.y + self.y_move + sb_rows)
	return FlowRow.new(new_start, self.size, self.space_between_elements)


## Does [param obj] fit in row?
func fit(obj: Element):
	obj.set_proportional_size(self.size)
	return self.elements == 0 || self.start.x + self.x_move + obj.size.x <= self.size.x
