@tool
extends CustomComponent

class_name CustomButton

@export var label: String = ""
@export var font_color: Color

var label_node: CustomLabel

func _ready():
	set_label_node()
	super()


func _draw() -> void:
	if Engine.is_editor_hint():
		self.set_label_node()
	super()


func set_label_node():
	if self.get_child_count() > 0:
		return
	
	self.label_node = CustomLabel.new()
	self.label_node.set_values(self.label, "res://addons/custom_componsts/static/fonts/CaviarDreams.ttf", 40)
	self.label_node.color = self.font_color
	self.label_node.curr_color = self.font_color
	self.add_child(self.label_node)
