@tool
extends CustomComponent

class_name CustomLabel

@export var text: String = ""
@export var font: Font
@export var font_size: int = 16

var text_area: Rect2


func _draw():
	super()
	
	var text_size = self.font.get_string_size(
		self.text,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		self.font_size
	)
	var contenedor_size = self.size
	
	# Calculate the center of the contenedor and moves it to the left half text_size.
	var pos_x = (contenedor_size.x - text_size.x) * 0.5
	
	# Caculate the right point to set the hight of the text.
	var metrics = self.font.get_ascent(self.font_size) - self.font.get_descent(self.font_size)
	var pos_y = (contenedor_size.y + metrics) * 0.5
	
	draw_string(
		self.font,
		Vector2(pos_x, pos_y),
		self.text,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		self.font_size,
		self.curr_color
	)
	
	self.text_area = Rect2(pos_x, (contenedor_size.y - metrics) * 0.5, text_size.x , text_size.y * 0.7)
	self.text_area.position += self.position


func has_point(point: Vector2) -> bool:
	return self.text_area.has_point(point)


func set_values(txt: String, path: String, f_size: int) -> void:
	self.text = txt
	self.font_size = f_size
	
	var f = FontFile.new()
	f.load_dynamic_font(path)
	
	self.font = f
