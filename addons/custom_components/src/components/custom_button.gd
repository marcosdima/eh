@tool
extends CustomComponent

class_name CustomButton

@export var label: String = ""
@export var font_size: int = 10
@export var font_color: Color
@export var font_path: FontFile

var label_node: CustomLabel

func _ready() -> void:
	self.set_label_node()
	super()


func set_label(s: String) -> void:
	self.label_node.text = s
	self.label_node.queue_redraw()
	self.label = s

func set_label_node():
	self.label_node = CustomLabel.new()
	self.label_node.set_values(self.label, self.font_path.resource_path, self.font_size)
	self.label_node.color = self.font_color
	self.label_node.curr_color = self.font_color
	self.label_node.font_size = self.font_size
	self.add_child(self.label_node)
