extends Layout

class_name RailLayout

var elements: Array[Element] = []

func handle_element(e: Element):
	self.elements.append(e)
	self.display_elements()
 

func start():
	pass


func display_elements() -> void:
	var elements_count = self.elements.size()
	var contenedor_size = self.contenedor.get_available_size()
	var space = self.contenedor.get_space().y
	var part = (contenedor_size.y - space * (elements_count - 1)) / elements_count
	var acc = self.contenedor.get_current_position()

	for child in self.contenedor.get_elements():
		child.set_element_position(acc)
		child.set_proportional_size(Vector2(contenedor_size.x, part))
		acc.y += part
		
		if self.contenedor.space_between:
			acc.y += space
