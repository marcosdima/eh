extends Layout

class_name FlowLayout

var curr_row: FlowRow = FlowRow.new(Vector2.ZERO, Vector2.ZERO, 0)

func handle_element(e: Element):
	if !curr_row.fit(e):
		curr_row = curr_row.next(self.contenedor.get_space().y)
	
	self.curr_row.append_an_element(e)


func start():
	self.curr_row = FlowRow.new(
		self.contenedor.get_current_position(),
		self.contenedor.get_available_size(),
		self.contenedor.get_space().x,
	)
