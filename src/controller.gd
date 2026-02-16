extends Node2D

const ORIENTATION = "screenOrientation"
const LANDSCAPE = "landscape"
const PORTRAIT = "portrait"

var output:Dictionary={}

func _ready() -> void:
	
	Server.new_layout.connect(Callable(self, "setup_layout"))
	
	for i in range(5):
		await get_tree().create_timer(0.5).timeout
		if Server.layout!=null:
			setup_layout()
			break

func _process(_delta: float) -> void:
	
	if output.size()>0:
		Server.send(output)
		output = { }

func setup_layout():
	var layout = Server.layout
	Server.layout = null
	if !(layout is Dictionary):
		return
	
	output["A"] = " "
	for node in get_node("Input").get_children():
		node.queue_free()
	
	
	for elementID in layout.keys():
		var element = layout[elementID]
		
		if elementID==ORIENTATION:
			if element==LANDSCAPE:
				DisplayServer.screen_set_orientation(DisplayServer.SCREEN_LANDSCAPE)
			else:
				DisplayServer.screen_set_orientation(DisplayServer.SCREEN_PORTRAIT)
		elif element is Dictionary and element.has("type") and element["type"] is String:
			#print(str(elementID))
			#output["A"] += str(elementID) + " je usao u stvar\n"
			
			if element["type"]=="joystick":
				addJoystick(element, elementID)
			elif element["type"]=="button":
				addButton(element, elementID)


func addJoystick(info, value):
	var joy = Joystick.new_joystick()
	
	addElement(info, joy, value)

func addButton(info, value):
	var button = ImprovedButton.new_button()
	
	if info.has("text"):
		button.get_node("Text").text = info["text"]
	else:
		button.get_node("Text").text = value
	
	addElement(info, button, value)


func addElement(info, object, value):
	
	object.value = value
	
	object.global_position = Vector2.ZERO
	
	if info.has("scale"):
		if info["scale"] is float:
			object.scale.x=info["scale"]
			object.scale.y=info["scale"]
	if info.has("x") and info["x"] is float:
		object.global_position.x = info["x"]
	if info.has("y") and info["y"] is float:
		object.global_position.y = info["y"]
	
	get_node("Input").add_child(object)
