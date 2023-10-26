extends Control

onready var grid_container: GridContainer = $ScrollContainer/GridContainer
var inventory_slot : int = 8 #capacity
var inventory_item : Array
var hovered_button : Node
var grabbed_button : Node
var last_hovered : Node
export var can_drag_empty : bool

func _ready() -> void:
	populateButton()
	$Button.grab_focus()

func _process(delta: float) -> void:
	if hovered_button != null:
		if can_drag_empty:
			check_for_drag()
		else:
			if hovered_button.get("current_item"):
				if hovered_button.current_item != null:
					check_for_drag()

func check_for_drag():
	if Input.is_action_just_pressed("ui_accept"):
			grabbed_button = hovered_button
			last_hovered = hovered_button
		
	if last_hovered != hovered_button:
		if Input.is_action_just_released("ui_accept"):
			swap_button(grabbed_button, hovered_button)

func populateButton():
	for i in (inventory_slot):
		var packed_scene = ResourceLoader.load("res://addons/BasicInventory/basic_inventory_godot_3.5/scene/InventoryButton.tscn")
		var item_button : Button = packed_scene.instance()
		item_button.connect("on_button_click", self, "on_button_click")
		grid_container.add_child(item_button)

func swap_button(button1, button2):
	var button1_i = button1.get_index()
	var button2_i = button2.get_index()
	grid_container.move_child(button1, button2_i)
	grid_container.move_child(button2, button1_i)
	

func add(item : Item)-> bool:
	var current_item = item.duplicate()
	for i in grid_container.get_children():
		if i.current_item != null:
			if i.current_item.id == item.id:
				if i.current_item.id == current_item.id && i.current_item.quantity != i.current_item.stack_size:
					if i.current_item.quantity + current_item.quantity > i.current_item.stack_size:
						i.current_item.quantity = current_item.stack_size
						current_item.quantity = -(current_item.quantity - i.current_item.stack_size)
						update_button(i.get_index(), i.current_item)
					else:
						i.current_item.quantity += current_item.quantity
						current_item.quantity = 0
						update_button(i.get_index(), i.current_item)
						
	if current_item.quantity > 0:
		if current_item.quantity < current_item.stack_size:
			for i in grid_container.get_children():
				if i.current_item == null:
					inventory_item.append(current_item)
					update_button(i.get_index(), current_item)
					break
		else:
			for i in grid_container.get_children():
				if i.current_item == null:
					var temp_item = current_item.duplicate()
					temp_item.quantity = current_item.stack_size
					inventory_item.append(temp_item)
					update_button(i.get_index(), current_item)
					current_item.quantity -= current_item.stack_size
					add(current_item)
					break
		return true
	else:
		return false

func remove(item : Item) -> bool:
	if can_affort(item):
		var current_item = item
		for i in grid_container.get_children():
			if i.current_item != null:
				if i.current_item.id == current_item.id:
					if i.current_item.quantity - current_item.quantity < 0 :
						current_item.quantity -= i.current_item.quantity
						i.current_item.quantity = 0
						update_button(i.get_index(), i.current_item)
					else:
						i.current_item.quantity -= current_item.quantity
						current_item.quantity = 0
						update_button(i.get_index(), i.current_item)
			
			if current_item.quantity <= 0:
				break
		var temp_inventory = inventory_item.duplicate()
		var offset = 0
		for i in temp_inventory.size():
			if inventory_item[i - offset].quantity == 0:
				inventory_item.remove(i - offset)
				offset += 1
		reflowbutton()
		return true
	return false

func can_affort(item : Item):
	var count : int
	for i in grid_container.get_children():
		if i.current_item != null:
			if i.current_item.id == item.id:
				count += item.quantity
	return count >= item.quantity

func reflowbutton():
	for i in grid_container.get_children():
		if i.current_item == null:
			update_button(i.get_index())
		else:
			if i.current_item.quantity > 0:
				update_button(i.get_index(), i.current_item)
			else :
				update_button(i.get_index())

func update_button(index : int, item : Item = null):
	if grid_container.get_child(index) == null:
		print("Error: child at index" + str(index) + "is null")
		return
	grid_container.get_child(index).update_item(item, index)


func on_button_click(index, current_item : Item):
	print("1")


func _on_Button_button_down() -> void:
	print(add(ResourceLoader.load("res://item/TestItem.tres")))


func _on_Button2_button_down() -> void:
	print(remove(ResourceLoader.load("res://item/TestItem.tres")))
