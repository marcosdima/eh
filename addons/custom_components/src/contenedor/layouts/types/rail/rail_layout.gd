extends Layout

class_name RailLayout

var vertical: bool = true
var elements: Array[Element] = []

func _init():
	self.vertical = false


func handle_element(e: Element):
	self.elements.append(e)
	self.display_elements()
 

# To prevent error messages...
func start():
	self.elements = []


func display_elements() -> void:
	var elements_count = self.elements.size()
	var contenedor_size = self.contenedor.get_available_size()
	
	var space = Vector2.ZERO # Space between elemnts.
	var acc = Vector2.ZERO # Accumulator of the previus elements movement.
	var part = Vector2.ZERO # Part size
	var acc_addition = Vector2.ZERO # Part heigth
	
	if self.vertical:
		space = Vector2(0, self.contenedor.get_space().y)
		var part_h = (contenedor_size.y - space.y * (elements_count - 1)) / elements_count
		acc_addition.y = + part_h
		part = Vector2(contenedor_size.x, part_h)
		acc = self.contenedor.get_margin_start()
	else:
		space = Vector2(self.contenedor.get_space().x, 0)
		var part_w = (contenedor_size.x - space.x * (elements_count - 1)) / elements_count
		acc_addition.x = + part_w
		part = Vector2(part_w, contenedor_size.y)
		acc = self.contenedor.get_margin_start()
	
	for child in self.contenedor.get_elements():
		child.set_element_position(acc)
		child.set_proportional_size(part)
		acc += acc_addition
	
		if self.contenedor.space_between:
			acc += space
