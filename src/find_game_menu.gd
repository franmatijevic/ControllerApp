extends Node2D

const LobbyUI = preload("res://src/menuUI/lobby_ui.tscn")

@onready var search=get_node("Search")
@onready var main = get_node("Lobbies")
@onready var discovery = get_node("ServerDiscovery")

@export var list:VBoxContainer

func _ready() -> void:
	Server.goToController.connect(Callable(self, "goToController"))
	DisplayServer.screen_set_orientation(DisplayServer.SCREEN_PORTRAIT)

func setLobbyUI(servers) -> void:
	
	#get_node("Lobbies/Label").text = str(get_node("ServerDiscovery").scanned_servers)
	
	for i in list.get_children():
		i.queue_free()
	
	if servers.size()==0:
		#servers["wss://echo.websocket.org"]={"Name":"LobbyPoseban", "Game":"Testing"}
		return
	
	
	
	for address in servers.keys():
		var server = servers[address]
		#get_node("Lobbies/Label").text += str(address) + "\n"
		
		if !(server.has("Name") and server.has("Game") and server["Name"] is String and server["Game"] is String): 
			continue
		
		
		var serverUI = LobbyUI.instantiate()
		serverUI.get_node("LobbyName").text = "Lobby Name: " +  str(server["Name"])
		serverUI.get_node("Game").text = "Game: " + str(server["Game"])
		serverUI.IP_address = address
		
		serverUI.joinLobby.connect(Callable(self, "try_to_connect"))
		
		
		if server.has("PlayerCount") and server["PlayerCount"] is int:
			var count = str(server["PlayerCount"])
			if server.has("MaxPlayerCount") and server["MaxPlayerCount"] is int:
				count += "/" + str(server["MaxPlayerCount"])
			server.get_node("Players").text = count
		
		list.add_child(serverUI)

func goToController():
	var controller = load("res://src/controller.tscn").instantiate()
	get_parent().add_child(controller)
	call_deferred("queue_free")

func try_to_connect(ip:String):
	Server.websocket_url = ip
	Server.try_to_connect()

func _on_button_pressed() -> void:
	Server.websocket_url = get_node("Control/IP").get_text() + ":" + get_node("Control/Port").get_text()
	Server.try_to_connect()


func _on_search_button_pressed() -> void:
	search.visible = false
	main.visible = true
	discovery.scan_lan_servers()


func _on_server_discovery_scanned(servers) -> void:
	setLobbyUI(servers)
