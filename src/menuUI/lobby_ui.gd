extends Control

signal joinLobby(address)

var IP_address:String


func _on_button_pressed() -> void:
	joinLobby.emit(IP_address)
