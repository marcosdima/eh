@tool
extends Element

class_name Contenedor

enum LayoutType {
	Flow,
	Rail,
}
static var paths = {
	LayoutType.Flow: "res://src/contenedor/layouts/types/flow/flow_layout.gd",
	LayoutType.Rail: "res://src/contenedor/layouts/types/rail/rail_layout.gd",
}
@export var layout_type: LayoutType = LayoutType.Flow

@export_group("Margin")
@export var margin_top: int = 0
@export var margin_bottom: int = 0
@export var margin_left: int = 0
@export var margin_rigth: int = 0

@export var space_between: int = 0

var layout: Layout = null

## With [param layout_type] gets an script and instantiate a layout, to handle content moving.
func handle_resize():
	if self.paths:
		var script = load(self.paths[self.layout_type])
		
		if script:
			var instance = script.new()
		
			if instance is Layout:
				instance.set_contenedor(self)
				self.layout = instance
			else:
				push_error("Instance should be Layout!")
			
			self.layout.move_contenedor_elements()


## Set [param position].
func set_element_position(p: Vector2) -> void:
	self.position = p


## Elements getter.
func get_elements() -> Array[Element]:
	var result: Array[Element] = []
	
	for child in self.get_direct_children():
		if child is Element:
			result.append(child as Element)
	
	return result


## Retrieves margins.
func get_margin_start() -> Vector2:
	# Each margin unit represents a 100th part of the total size.
	var unit_y = self.size.y / 100
	var unit_x = self.size.x / 100
	
	var margin_y = self.margin_top * unit_y
	var margin_x = self.margin_left * unit_x
	
	return Vector2(margin_x, margin_y)


# TODO: Margin script.
## Retrieves margins.
func get_margin_size() -> Vector2:
	# Each margin unit represents a 100th part of the total size.
	var unit_y = self.size.y / 100
	var unit_x = self.size.x / 100
	
	var margin_b = self.margin_bottom * unit_y
	var margin_r = self.margin_rigth * unit_x
	
	return Vector2(margin_r, margin_b)


## Retrieves [params Contenedor] size minus margins.
func get_available_size() -> Vector2:
	return self.size -  self.get_margin_start() - self.get_margin_size()


## Retrieves [params Contenedor] position plus margins.
func get_current_position() -> Vector2:
	return self.position + self.get_margin_start()


## Retrieves space between elements.
func get_space() -> Vector2:
	# Each margin unit represents a 100th part of the total size.
	var space_y = (self.size.y / 100) * self.space_between
	var space_x = (self.size.x / 100) * self.space_between
	
	return Vector2(space_x, space_y)
