@tool
extends Contenedor

class_name Screen
## This [param Contenedor] variant sets variables with viewport data.

@export var bg: Color = Color.BLACK
@export var rect: Color = Color.TRANSPARENT
@export var rect_size: int = 0

func _ready():
	self.set_proportional_size(self.get_viewport().size)


func _draw() -> void:
	self.set_proportional_size(self.get_viewport().size)
	
	# Set position at (0, 0).
	self.position = Vector2(0, 0)
	
	# Draw bg.
	var background = Rect2(Vector2.ZERO, self.size) 
	draw_rect(background, self.bg, true)
	
	# Margin rect.
	var r = Vector2(self.rect_size, self.rect_size)
	
	# Draw margin
	var margin_rect = Rect2(r,  self.size - (r * 2)) 
	draw_rect(margin_rect, self.rect, false)
	
	super()
