extends Node

@export var websocket_url = "ws://localhost:9080"

var socket = WebSocketPeer.new()

func _ready() -> void:
	set_process(false)

func try_to_connect():
	# Initiate connection to the given URL.
	var err = socket.connect_to_url(websocket_url)
	if err == OK:
		get_node("Label").text += "connecting to" + str(websocket_url)
		print("Connecting to %s..." % websocket_url)
		# Wait for the socket to connect.
		await get_tree().create_timer(2).timeout
	
		# Send data.
		print("> Sending test packet.")
		socket.send_text("Test packet")
	else:
		get_node("Label").text = "unable to connect"
		push_error("Unable to connect.")
		set_process(false)

func _process(_delta):
	socket.poll()

	var state = socket.get_ready_state()
	
	if state == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count():
			var packet = socket.get_packet()
			if socket.was_string_packet():
				var packet_text = packet.get_string_from_utf8()
				get_node("Label").text = packet_text
				print("< Got text data from server: %s" % packet_text)
			else:
				print("< Got binary data from server: %d bytes" % packet.size())
	
	elif state == WebSocketPeer.STATE_CLOSING:
		pass

	# `WebSocketPeer.STATE_CLOSED` means the connection has fully closed.
	# It is now safe to stop polling.
	elif state == WebSocketPeer.STATE_CLOSED:
		# The code will be `-1` if the disconnection was not properly notified by the remote peer.
		var code = socket.get_close_code()
		print("WebSocket closed with code: %d. Clean: %s" % [code, code != -1])
		set_process(false) # Stop processing.


func _on_button_pressed() -> void:
	if is_processing():
		get_node("Label").text = "pokusaj slanja "
		socket.send_text(get_node("TextEdit").get_text())
	else:
		set_process(true)
		websocket_url = get_node("TextEdit").get_text()
		get_node("Label").text = "pokusaj spajanja "
		try_to_connect()
