extends Control

enum Screens {
	MainMenu,
	SelectionMenu,
	CreateServer,
	EnterServer,
	Game,
}

@onready var play = $Game/GamePanel/PlayMargin/Play
@onready var next = $Game/GamePanel/NextPlay
@onready var curr = $Game/Current
@onready var error = $Error
@onready var error_display = $Error/Display
@onready var server_client = $ServerClient
@onready var click_sound = $Sonido/Click
@onready var loop_sound = $Sonido/Loop
@onready var exit_server_button = $ExitServer

func _ready() -> void:
	for child in self.get_direct_children():
		if !child.visible:
			self.set_children_visible(child, false)


func get_component(s: Screens) -> Node:
	match s:
		Screens.MainMenu: return $MainMenu
		Screens.SelectionMenu: return $SelectionMenu
		Screens.CreateServer: return $CreateServer
		Screens.EnterServer: return $EnterServer
		Screens.Game: return $Game
		_: return null


func spot_on(from: Screens, s: Screens):
	if !self.check_visibility(from):
		return
	
	var c = self.get_component(s)
	
	for child in self.get_children():
		if child == c:
			self.set_children_visible(child, true)
		else:
			self.set_children_visible(child, false)
	
	if s == Screens.Game:
		self.handle_exit_button()


func get_direct_children() -> Array[Node]:
	var children = self.get_children()
	
	var find_if_sub_child = func (target: Node) -> bool:
		for child in children:
			if child != target:
				if target in child.get_children():
					return true
	
		return false
	
	return children.filter(func(child): return not find_if_sub_child.call(child))


func check_visibility(from: Screens) -> bool:
	var curr_c = self.get_component(from)
	return curr_c.visible


func set_children_visible(node: Node, to: bool) -> void:
	# ACA situation.
	if node is AudioStreamPlayer:
		return
	
	node.visible = to
	
	for child in node.get_children():
		self.set_children_visible(child, to)

var game_started_flag = false
func _on_make_a_play() -> void:
	self.click_sound.play()
	
	var ended = self.server_client.state.ended
	if ended and Global.is_server:
		self.handle_restart()
	elif !ended and self.game_started_flag:
		self.handle_make_a_play()


func _on_server_client_update() -> void:
	self.game_started_flag = true
	self.handle_update_round()


func _on_server_client_end() -> void:
	self.handle_end_round()


func _on_mute_on_click() -> void:
	self.click_sound.play()
	
	var unmute = "Unmute"
	var mute = "Mute"
	
	if $MainMenu/Buttons/Mute.label == mute:
		self.loop_sound.stop()
		$MainMenu/Buttons/Mute.set_label(unmute)
	else:
		self.loop_sound.play()
		$MainMenu/Buttons/Mute.set_label(mute)


func _on_server_client_close() -> void:
	if Global.is_server:
		Global.is_server = false
	else:
		self.spot_on(Screens.Game, Screens.EnterServer)
		self.handle_error("Server closed")
	
	# Hide exit server button.
	self.set_children_visible(self.exit_server_button, false)


############################################
############ REDIRECT BUTTONS ##############
############################################

func _on_return_button_on_click() -> void:
	self.click_sound.play()

	if self.check_visibility(Screens.EnterServer):
		self.spot_on(Screens.EnterServer, Screens.SelectionMenu)
	elif self.check_visibility(Screens.SelectionMenu):
		self.spot_on(Screens.SelectionMenu, Screens.MainMenu)


# Go from MainMenu to SelectionMenu.
func _on_play_on_click() -> void:
	self.click_sound.play()
	self.spot_on(Screens.MainMenu, Screens.SelectionMenu)


# Exit Game.
func _on_exit_on_click() -> void:
	self.click_sound.play()
	if check_visibility(Screens.MainMenu):
		self.get_tree().quit()


# Go from SelectionMenu to EnterServer.
func _on_enter_server_on_click() -> void:
	self.click_sound.play()
	self.spot_on(Screens.SelectionMenu, Screens.EnterServer)


# Go from SelectionMenu to CreateServer.
func _on_create_server_on_click() -> void:
	self.click_sound.play()
	Global.is_server = true
	
	if await self.handle_start():
		self.spot_on(Screens.SelectionMenu, Screens.CreateServer)


# Go from CreateServer to Game.
func _on_start_server_on_click() -> void:
	self.click_sound.play()
	
	if self.check_visibility(Screens.CreateServer):
		self.handle_start_game()
		self.spot_on(Screens.CreateServer, Screens.Game)


# Go from EnterServer to Game.
var enter_flag = false
func _on_enter_on_click() -> void:
	self.click_sound.play()
	Global.is_server = false
	
	if !enter_flag:
		self.enter_flag = true
		
		var ip_text = $EnterServer/Buttons/Ip.text
		if ip_text != '':
			Global.ip = ip_text
		
		var port_text = $EnterServer/Buttons/Port.text
		if port_text != '':
			Global.port = port_text
		
		print("Ip:Port -> " + str(Global.ip) + ":" + str(Global.port))
		self.handle_notification("Connecting... ")
		if await self.handle_start():
			self.spot_on(Screens.EnterServer, Screens.Game)
		
		self.enter_flag = false
	else:
		self.handle_notification("Connecting... Wait a minute!")


func _on_close_on_click() -> void:
	if self.check_visibility(Screens.CreateServer):
		self.spot_on(Screens.CreateServer, Screens.SelectionMenu)
		self.server_client.stop()


func _on_exit_server_on_click() -> void:
	if Global.is_server:
		self.spot_on(Screens.Game, Screens.SelectionMenu)

	self.server_client.stop()
	self.game_started_flag = false

#####################################
############ Handlers ###############
#####################################


func handle_start() -> bool:
	var start = await self.server_client.start()

	if !start and Global.is_server:
		self.handle_error("Can not create server")
		return false
	elif !start:
		self.handle_error("Can not enter a game")
		return false
	else:
		return true


func handle_start_game():
	$ServerClient.start_game()
	self.handle_update_round()


func handle_update_round():
	var curr_state = self.server_client.state
	var aux_hand = curr_state.hand.duplicate()
	var min_v = aux_hand.min()
	
	if min_v > 0:
		self.play.set_label(str(min_v))
	else:
		self.play.set_label("-")
	
	aux_hand.erase(min_v)
	
	if len(curr_state.hand) > 1:
		self.next.set_text(str(aux_hand.min()))
	else:
		self.next.set_text("Empty")
	
	self.curr.set_text(str(curr_state.curr_value))
	
	self.curr.queue_redraw()


func handle_end_round():
	var curr_state = self.server_client.state
	var b_label = curr_state.next_restart_button
	var l_label = curr_state.end_message
	var lives = curr_state.lives
	
	self.play.set_label(b_label)
	self.curr.set_text(l_label)
	self.next.set_text("Lives: " + str(lives))
	
	$Game/GamePanel.handle_resize()


func handle_make_a_play():
	self.server_client.play()


func handle_restart():
	#Global.ended = false
	self.next.visible = true
	self.server_client.start_game()
	$Game/GamePanel.handle_resize()


func handle_error(msg: String):
	self.handle_notification("Error: " + msg)


func handle_notification(msg):
	self.set_children_visible(self.error, true)
	self.error_display.set_text(msg)


func handle_exit_button():
	self.set_children_visible(self.exit_server_button, true)
