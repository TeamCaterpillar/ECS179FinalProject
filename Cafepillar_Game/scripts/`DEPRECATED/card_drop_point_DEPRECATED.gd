class_name CardDropPoint
extends Marker2D

var slot_dimensions:Vector2 = Vector2(25.0, 35.0)
var slot_type : String
## Called when the node enters the scene tree for the first time.
## Draws the drop box visually for cards
func _draw() -> void:
	#draw_circle(Vector2.ZERO, 25.0, Color.WHITE)
	draw_rect(Rect2(-slot_dimensions / 2, slot_dimensions),Color.WHITE)


## Changes color to indicate the card has been dropped here, and all other card drop points are reset to default color
func select() -> void:
	for child in get_tree().get_nodes_in_group("CardZone"):
		child.deselect()
	#modulate = Color.RED
	modulate = Color8(211, 131, 114, 170)



## Changes color to default non-dropped color
func deselect() -> void:
	#modulate = Color.WHITE
	modulate =  Color8(211, 131, 114, 255)
