@tool
extends Control

class_name Element 

# This flag will display some tests features.
@export var test: bool = false

# To handle element size.
@export var proportion_x: float = 1
@export var proportion_y: float = 1

var hit_area: Rect2 = Rect2(0,0,0,0)

# With this can persist its size in proportion to any view.
var view_proportion: Proportion = Proportion.new(1, 1)

## Set element's size accord its proportional size and the [param size_available].
func set_proportional_size(size_available: Vector2):
	if self.view_proportion:
		self.size = self.view_proportion.get_size_from(size_available)
		self.handle_resize()
		self.set_hit_area()


## Setter of [param view_proportion].
func update_proportion(p: Proportion):
	self.view_proportion = p


## [param point] exists in this element?
func has_point(point: Vector2) -> bool:
	return self.hit_area.has_point(point)


## Retrieves only the direct descendants.
func get_direct_children() -> Array[Node]:
	var children = self.get_children()
	
	var find_if_sub_child = func (target: Node) -> bool:
		for child in children:
			if child != target:
				if target in child.get_children():
					return true
	
		return false
	
	return children.filter(func(child): return not find_if_sub_child.call(child))


func set_element_position(p: Vector2) -> void:
	self.position = p


func set_hit_area():
	self.hit_area = Rect2(self.position.x, self.position.y, self.size.x, self.size.y)

##############################################################
## This functions will be overwritted by another sub-clases ##
##############################################################

func handle_resize():
	for child in self.get_direct_children():
		child.position = Vector2(0, 0)
	
		if child is Element:
			var c = child as Element
			c.set_proportional_size(self.size)


func handle_click(_pos: Vector2):
	pass


func handle_mouse_on():
	pass


func handle_on_mouse_out():
	pass


func handle_release_click():
	pass


signal on_mouse_on
signal on_mouse_out
signal on_click
signal on_click_released

var mouse_on = false
var click_on = false

func _input(event):
	if self.has_point(event.position):
		if event is InputEventMouseMotion and !self.click_on: ## Mouse on element.
			emit_signal("on_mouse_on")
			self.mouse_on = true
			self.handle_mouse_on()
		elif event is InputEventMouseButton and event.pressed: ## Mouse on clicked on element.
			emit_signal("on_click")
			self.click_on = true
			self.handle_click(event.position)
		elif event is InputEventMouseButton and event.is_released(): ## Mouse realesed click on element.
			emit_signal("on_click_released")
			self.click_on = false
			self.handle_release_click()
	else:
		if self.click_on:
			self.click_on = false
		
		if self.mouse_on:
			emit_signal("on_mouse_out")
			self.mouse_on = false
			self.handle_on_mouse_out()


func _draw():
	if self.test:
		var rect = Rect2(Vector2.ZERO, self.size) 
		var color = Color(1, 0, 0) 
		draw_rect(rect, color, true)


func _ready() -> void:
	self.view_proportion = Proportion.new(proportion_x, proportion_y)
	self.set_hit_area()


func _notification(what):
	if what == NOTIFICATION_EDITOR_POST_SAVE:
		self.queue_redraw()
