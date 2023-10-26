extends Button

var current_item : Item
onready var current_icon: TextureRect = $TextureRect as TextureRect
onready var current_label: Label = $Label as Label
var index
var inventory_node

signal on_button_click(index, item)


func _ready() -> void:
	pass # Replace with function body.

func update_item(item : Item, i : int):
	self.index = i
	current_item = item
	
	if current_item == null:
		current_icon.texture = null
		current_label.text = ""
	else:
		if item.quantity <= 0:
			current_icon.texture = null
			current_label.text = ""
		else:
			current_icon.texture = item.icon
			current_label.text = str(item.quantity)


func _on_InventoryButton_focus_entered() -> void:
	focus_entered()


func _on_InventoryButton_focus_exited() -> void:
	focus_exit()


func _on_InventoryButton_mouse_entered() -> void:
	focus_entered()


func _on_InventoryButton_mouse_exited() -> void:
	focus_exit()

func _on_InventoryButton_button_down() -> void:
	emit_signal("on_button_click",index,current_item)

func focus_entered():
	inventory_node = get_tree().get_nodes_in_group("Inventory")
	inventory_node[0].hovered_button = $"."

func focus_exit():
	inventory_node[0].hovered_button = null
