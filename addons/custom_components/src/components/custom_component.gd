@tool
extends Element

class_name CustomComponent

@export var back_ground: Color = Color.TRANSPARENT
@export var color: Color = Color.TRANSPARENT
@export var rounded: int = 8

@export_group("Border")
@export var border_color: Color = Color.TRANSPARENT
@export var border_width: float = 1.0

var curr_bg_color: Color
var curr_color: Color
var hover_l: float = 0.5
var click_l: float = 0.4

func _ready() -> void:
	self.curr_bg_color = self.back_ground
	self.curr_color = self.color


func _draw():
	if Engine.is_editor_hint():
		self.curr_bg_color = self.back_ground
		self.curr_color = self.color
	
	# Draw bg.
	var background = StyleBoxFlat.new()
	background.bg_color = self.curr_bg_color
	
	if self.border_color != Color.TRANSPARENT:
		background.border_width_bottom = 2
		background.border_width_right = 2
	
	if self.rounded:
		background.set_corner_radius_all(self.rounded)
	
	draw_style_box(background, Rect2(Vector2.ZERO, self.size))
	
	# Draw margin rect.
	var r = self.size * 0.1
	var rect = Rect2(r,  self.size - (r * 2))
	draw_rect(rect.grow(self.border_width), self.border_color, false)
	
	super()


func handle_mouse_on():
	self.curr_bg_color = self._color_from(self.curr_bg_color, self.hover_l)
	self.curr_color = self._color_from(self.curr_color, self.hover_l)
	queue_redraw()


func handle_on_mouse_out():
	self.curr_bg_color = self.back_ground
	self.curr_color = self.color
	queue_redraw()


func handle_click(_pos: Vector2):
	self.curr_bg_color = self._color_from(self.curr_bg_color, self.click_l)
	self.curr_color = self._color_from(self.curr_color, self.click_l)
	queue_redraw()


func handle_release_click():
	self.curr_bg_color = self._color_from(self.curr_bg_color, self.hover_l)
	self.curr_color = self._color_from(self.curr_color, self.hover_l)
	queue_redraw()


func _color_from(from: Color, l: float) -> Color:
	if from == Color.TRANSPARENT:
		return from
	
	return Color.from_hsv(self.curr_bg_color.h, self.curr_bg_color.s, l)
