extends Node2D

class_name ImprovedButton

const buttonScene:PackedScene = preload("res://src/button/button.tscn")

@export var value:String

func _on_touch_screen_button_pressed() -> void:
	get_parent().get_parent().output[value] = 1


func _on_touch_screen_button_released() -> void:
	get_parent().get_parent().output[value] = 0

static func new_button() -> ImprovedButton:
	var button:ImprovedButton=buttonScene.instantiate()
	return button
