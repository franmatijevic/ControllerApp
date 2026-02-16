extends Node

#signal scanned_server(data:JSON)
signal scanned(servers)

var client :PacketPeerUDP
var server :UDPServer


var scanned_servers := {}

var is_scanning := false
#var is_servering := false

var port = 9080
var scan_time = 1

func scan_lan_servers():
	
	#set_server()
	
	client = PacketPeerUDP.new()
	client.set_broadcast_enabled(true)
	client.set_dest_address("255.255.255.255", port)
	client.put_packet(JSON.stringify({'type':'server_data'}).to_utf8_buffer())
	
	get_tree().create_timer(scan_time).timeout.connect(_on_timer_timeout)

	scanned_servers = { }
	is_scanning = true

func _on_timer_timeout():
	is_scanning = false
	client.close()
	#close_server()
	scanned.emit(scanned_servers)

func set_server():
	server = UDPServer.new()
	#server.listen(port,'0.0.0.0')
	server.listen(port)
	#is_servering = true
	
func close_server():
	server.stop()
	#is_servering = false

func _process(_delta):
	if is_scanning:
		if client.get_available_packet_count() > 0:
			var data= client.get_packet().decode_var(0)
			
			if !data.has("server_data"): return
			
			#var server_ip = client.get_packet_ip()
			#data["server_ip"] = server_ip
			#data.erase("type")
			
			#get_parent().get_node("Control/Lobi").text += "\nimam: "
			#get_parent().get_node("Control/Lobi").text += str(server_ip) + "\n"
			
			#scanned_servers.append(data)
			var address = client.get_packet_ip() + ":" + str(client.get_packet_port())
			scanned_servers[address] = data["server_data"] 
			#scanned_server.emit(data)
	
	#if is_servering:
	#	server.poll()
	#	if server.is_connection_available():
	#		var peer: PacketPeerUDP = server.take_connection()
	#		get_parent().get_node("Control/Lobi").text += "\nIMAM: "
	#		get_parent().get_node("Control/Lobi").text += str(peer.get_packet_ip())
	#		if peer.get_packet().decode_var(0)["type"] == "get_server":
	#			get_parent().get_node("Control/Lobi").text += "!!!!!!!!!!!!!!!!!!!!!"
	#		get_parent().get_node("Control/Lobi").text += "\n"
