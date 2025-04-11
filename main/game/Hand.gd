class_name Hand

var elements: Array

func _init():
	self.elements = []


func update(arr: Array):
	self.elements = arr


func play() -> int:
	if len(self.elements) == 0:
		return -1
	
	var lower = elements.min()
	var index = elements.find(lower)
	elements.remove_at(index)
	
	return lower
