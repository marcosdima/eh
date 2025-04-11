class_name GameHandler

var top = 100
var played_count = 0
var last_played = -1
var curr_values = []
var players = []
var lives = 3

func start_round(level: int) -> void:
	# If there are no lives, then does nothing.
	if self.lives <= 0:
		return
	
	# Restart round data.
	self.played_count = 0
	self.last_played = -1
	self.curr_values = []
	
	# For each player...
	for player in players:
		var curr_player_hand = []
		
		# ... will take threee random numbers...
		for i in range(level):
			var r = randi() % top + 1
			
			# If the game was already setted, then takes another.
			while !self.curr_values.filter(func(v): return v == r).is_empty():
				r = randi() % top + 1
		
			# ... and save it in player's hand.
			curr_player_hand.append(r)
			self.curr_values.append(r)
		
		# Set player's hand.
		player.set_hand(curr_player_hand)
	
	# At the end, sort curr_values.
	self.curr_values.sort()


func player_makes_a_play(id_target: int) -> bool:
	# A Player plays the lower element in hand.
	var played = players.filter(func(p): return p.player_id == id_target)[0].play()
	
	# Player has no elements...
	if played == -1:
		return true # Atado con alambre.
	
	
	if played != self.curr_values[self.played_count]:
		self.lives -= 1
		return false
	
	played_count += 1
	last_played = played
	
	return true


func add_player(player_id: int) -> void:
	self.players.append(Player.new(player_id))


func get_curr_value() -> int:
	if self.played_count > 0 && !self.ended() :
		return self.curr_values[self.played_count - 1]
	else:
		return 0


func get_player(player_id: int) -> Player:
	var f = func(p):
		if p.player_id == player_id:
			return p
	var player: Player = self.players[self.players.find(f)]
	return player


func reset() -> void:
	self.played_count = 0
	self.last_played = -1
	self.curr_values = []
	self.lives = 3


func ended() -> bool:
	return len(self.curr_values) <= self.played_count


func lost() -> bool:
	if ended() || self.played_count == 0:
		return false

	return self.last_played > 0 && self.curr_values[self.played_count - 1] != self.last_played


func dead() -> bool:
	return self.lives <= 0


func win() -> bool:
	return ended() && self.curr_values[len(self.curr_values) - 1] == last_played


func player_leave(player_id: int) -> void:
	var player = self.get_player(player_id)
	
	for n in player.hand.elements:
		curr_values.erase(n)
	
	self.players = self.players.filter(func (p): return p.player_id != player_id)
