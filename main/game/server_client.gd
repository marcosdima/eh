extends Control

@onready var peer = ENetMultiplayerPeer.new()
@onready var game: GameHandler = null
@onready var level = 3
var server_id = 1
var state: GameState = GameState.new()

signal update
signal end
signal close

func start() -> bool:
	if Global.is_server:
		return start_server()
	else:
		return await start_client()


func stop() -> void:
	self.emit_signal('close')
	self.peer.close()
	self.peer = ENetMultiplayerPeer.new()
	self.game = null
	self.level = 3
	self.state = GameState.new()
	multiplayer.multiplayer_peer = null


func start_server() -> bool:
	var error = peer.create_server(Global.port, 2)
	if error != OK:
		print("Error starting the server:", error)
		return false
	
	multiplayer.multiplayer_peer = peer
	print("Server started on port " + str(Global.port))
	
	game = GameHandler.new()
	game.add_player(multiplayer.get_unique_id())
	
	return true


func start_client() -> bool:
	print("Attempting to connect...")
	
	peer.create_client(Global.ip, Global.port) # TODO: Should I use Global?
	multiplayer.multiplayer_peer = peer
	
	# Waits to connect to server...
	await get_tree().create_timer(3).timeout
	
	# If after waiting 3 seconds it's not connected, then resets peer and return false.
	if !self.connected:
		self.peer = ENetMultiplayerPeer.new()
		return false
	
	multiplayer.multiplayer_peer = peer
	
	return true


func start_game():
	game.start_round(self.level)
	message_all.rpc_id(server_id, "Game starts! Level: " + str(level))
	update_state.rpc_id(server_id)


func play() -> void:
	make_a_play.rpc_id(server_id, multiplayer.get_unique_id())


var connected = false
func _on_peer_connected(id):
	if Global.is_server:
		say_welcome.rpc_id(id)
		game.add_player(id)
	else:
		self.connected = true


func _on_peer_disconnected(id):
	if Global.is_server:
		game.player_leave(id)


@rpc("authority", "call_local", "reliable")
func message_all(message: String):
	for p in game.players:
		send_message.rpc_id(p.player_id, message)


# Call local is required if the server is also a player.
@rpc("any_peer", "call_local", "reliable")
func say_welcome():
	print("Welcome!")


@rpc("any_peer", "call_local", "reliable")
func send_message(message: String):
	print("Message: ", message)
 

@rpc("any_peer", "call_local", "reliable")
func game_state(curr_level: int, lives: int, hand: Array, curr_value: int):
	self.state.curr_level = curr_level
	self.state.lives = lives
	self.state.curr_value = curr_value
	self.state.hand = hand
	self.state.ended = false
	self.emit_signal('update')


@rpc("any_peer", "call_local", "reliable")
func game_end_state(curr_level: int, lives: int, message: String, next: String):
	self.state.curr_level = curr_level
	self.state.lives = lives
	self.state.end_message = message
	self.state.next_restart_button = next
	self.state.ended = true
	self.emit_signal('end')


@rpc("authority", "call_local", "reliable")
func update_state():
	if game.win() or game.ended():
		level += 1
		end_round.rpc_id(server_id)
	else:
		for p in game.players:
			if p.hand.elements:
				game_state.rpc_id(
					p.player_id,
					level,
					game.lives,
					p.hand.elements,
					game.get_curr_value(),
				)
			else:
				game_state.rpc_id(
					p.player_id,
					level,
					game.lives,
					[-1],
					game.get_curr_value()
				)


@rpc("authority", "call_local", "reliable")
func end_round():
	if multiplayer.is_server():
		if game.win():
			game_end_state.rpc(
				self.level,
				game.lives,
				"You Won!",
				"Next"
			)
		else:
			game_end_state.rpc(self.level, game.lives, "You Missed", "Again")


@rpc("authority", "call_local", "reliable")
func end_game():
	if multiplayer.is_server():
		self.start_game()
		game_end_state.rpc(self.level, game.lives, "You Lost", "Restart")
		message_all.rpc_id(server_id, "YOU LOST!")
		self.game.reset()


@rpc("any_peer", "call_local", "reliable")
func make_a_play(player_id: int):
	if multiplayer.is_server():
		var played = self.game.player_makes_a_play(player_id)
		
		if played:
			for p in self.game.players:
				update_state.rpc_id(server_id)
		else:
			if self.game.dead():
				end_game.rpc()
			else:
				end_round.rpc()
				message_all.rpc_id(server_id, "Missed! Try again...")
				self.game.start_round(level)
				update_state.rpc_id(server_id)
				end_round.rpc()


func _ready() -> void:
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.server_disconnected.connect(stop)
