class_name Player

var player_id: int
var hand: Hand


func _init(id: int):
	self.player_id = id
	self.hand = Hand.new()


func set_hand(new_hand: Array) -> void:
	self.hand.update(new_hand)


func play() -> int:
	return hand.play()
