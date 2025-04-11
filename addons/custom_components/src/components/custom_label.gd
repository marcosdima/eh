@tool
extends CustomComponent

class_name CustomLabel

@export var text: String = ""
@export var font: Font
@export var font_size: int = 16

var text_area: Rect2

func _draw():
	super()
	var f_size = self.get_font_size()
	
	if f_size <= 0:
		return
	
	var contenedor_size = self.size
	
	
	# Line size.
	var line_size = self.font.get_string_size(
		self.text,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		f_size
	)
	
	# Calculate the center of the contenedor and moves it to the left half text_size.
	var pos_x = (contenedor_size.x - line_size.x) * 0.5
	
	# Caculate the right point to set the hight of the text.
	var metrics = self.font.get_ascent(f_size) - self.font.get_descent(f_size)
	var pos_y = (contenedor_size.y + metrics) * 0.5
	
	draw_string(
		self.font,
		Vector2(pos_x, pos_y),
		self.text,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		f_size,
		self.curr_color
	)
	
	self.text_area = Rect2(pos_x, (contenedor_size.y - metrics) * 0.5, line_size.x , line_size.y * 0.7)
	# TODO: Get container position implementation. Maybe get_position at element?
	self.text_area.position += self.position + self.get_container_position()


func has_point(point: Vector2) -> bool:
	return self.text_area.has_point(point)


func set_values(txt: String, path: String, f_size: int) -> void:
	self.text = txt
	self.font_size = f_size
	
	self.font = load(path)


func get_font_size() -> int:
	return ((size.x + size.y) / 2 / 100) * self.font_size


func set_text(s: String) -> void:
	self.text = s
	self.queue_redraw()
