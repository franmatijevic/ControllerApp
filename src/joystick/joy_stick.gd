extends Node2D

class_name Joystick

const joystickScene:PackedScene=preload("res://src/joystick/joy_stick.tscn")

const startIgnoring:float = 1.3

@export var handle:Node2D
@export var maxLength:float = 150
var pressing:bool=false

var output:Vector2=Vector2.ZERO

@export var value:String=""

func _ready() -> void:
	maxLength *= scale.x


var joyStickTouch
var touchEvent = -1

func _input(event):
	if event is InputEventScreenTouch:
		
		#var screen_position = event.position
		#var canvas_transform = get_viewport().get_canvas_transform()
		#var world_position = canvas_transform.affine_inverse() * screen_position
		
		#get_node("O").global_position = world_position
		
		if event.pressed and touchEvent == -1:
			var screen_position = event.position
			var canvas_transform = get_viewport().get_canvas_transform()
			var world_position = canvas_transform.affine_inverse() * screen_position
			if world_position.distance_to(global_position)<=maxLength:
				joyStickTouch = world_position
				touchEvent = event.index
		elif !event.pressed and event.index == touchEvent:
			joyStickTouch = null
			touchEvent = -1
			sendValue(Vector2.ZERO)
	elif event is InputEventScreenDrag and touchEvent == event.index:
		var screen_position = event.position
		var canvas_transform = get_viewport().get_canvas_transform()
		var world_position = canvas_transform.affine_inverse() * screen_position
		joyStickTouch = world_position

func _process(delta: float) -> void:

	if joyStickTouch:
		if joyStickTouch.distance_to(global_position)<=maxLength:
			handle.global_position = joyStickTouch
		else:
			var pos = joyStickTouch -  global_position
			pos = pos.normalized()
			handle.global_position = pos * maxLength + global_position
		
		sendValue((handle.global_position -  global_position) / maxLength)
	else:
		handle.global_position=lerp(handle.global_position, global_position, delta*10)


func sendValue(direction:Vector2):
	get_parent().get_parent().output[value] = direction



static func new_joystick() -> Joystick:
	var joy:Joystick=joystickScene.instantiate()
	return joy
