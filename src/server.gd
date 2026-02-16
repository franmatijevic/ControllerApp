extends Node

signal new_data(data)
signal new_layout()

signal goToController()

@export var websocket_url = "ws://localhost:9080"

var socket = WebSocketPeer.new()

var layout #= {"screenOrientation":"landscape","joystick":{"type":"joystick"}}

func _ready() -> void:
	set_process(false)

func send(message):
	if socket.get_ready_state()!=WebSocketPeer.STATE_OPEN:
		return
	
	socket.send_text(JSON.stringify(message))

func try_to_connect():
	var err = socket.connect_to_url(websocket_url)
	if err == OK:
		print("Connecting to %s..." % websocket_url)
		
		emit_signal("goToController")
		#get_tree().change_scene_to_file("res://src/controller.tscn")
		
		await get_tree().create_timer(2).timeout
		set_process(true)
	else:
		push_error("Unable to connect.")
		set_process(false)
		
		get_tree().change_scene_to_file("res://src/main.tscn")

func _process(_delta):
	socket.poll()
	
	
	var state = socket.get_ready_state()
	
	if state == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count():
			var packet = socket.get_packet()
			
			
			if socket.was_string_packet():
				var packet_text = packet.get_string_from_utf8()
				
				check_data(packet_text)
	
	elif state == WebSocketPeer.STATE_CLOSING:
		pass
	elif state == WebSocketPeer.STATE_CLOSED:
		set_process(false)
		
		get_tree().change_scene_to_file("res://src/main.tscn")


func check_data(data):
	#send(str({"error":"testiram error"}))
	var json_res = JSON.parse_string(data)
	if json_res == null:
		printerr("ERROR in parsing data")
		#send( str({"error":"json_res je null"}))
		
	if !(json_res is Dictionary): 
		return
	
	if (json_res.has("layout")):
		if json_res["layout"] is Dictionary:
			layout = json_res["layout"]
			emit_signal("new_layout")
	
	emit_signal("new_data", json_res)
