class_name Layout

var contenedor: Contenedor = null

## Handle elements placement.
func move_contenedor_elements():
	self.start()
	for element in self.contenedor.get_elements():
		self.handle_element(element)


## Handle [param Element] placement.
func handle_element(e: Element):
	push_error("This function should be implemented in a sub-class: ", e)


## Action prior elements placement.
func start():
	push_error("This function should be implemented in a sub-class")


## [param contenedor] setter.
func set_contenedor(c: Contenedor):
	self.contenedor = c
