extends Node

# Game state variables
var golden_seeds : int                = 0
var kitchen_inventory: Array[Variant] = []
var active_orders: Array[Variant]     = []
var waiter_queue: Array[Variant]      = []

# Scene references
var current_scene           = null
const SCENE_KITCHEN: String = "res://scenes/kitchen.tscn"
const SCENE_DINER: String   = "res://scenes/diner.tscn"

# Signal for scene changes
signal scene_changed

# Called when the game starts
func _ready():
	# Load the first scene (kitchen by default)
	#change_scene(SCENE_KITCHEN)
	pass

# Function to change scenes
func change_scene(scene_path: String):
	if current_scene:
		current_scene.queue_free()
	
	var new_scene = load(scene_path).instantiate()
	get_tree().root.add_child(new_scene)
	current_scene = new_scene
	emit_signal("scene_changed", scene_path)

# Track golden seeds
func update_score(new_seeds: int):
	golden_seeds += new_seeds
	print("Total Golden Seeds updated:", golden_seeds)

# MANAGE ORDER QUEUE
func add_order_to_queue() -> void:
	pass


func remove_order_from_queue() -> void:
	pass



# HANDLE CURRENCY
func add_currency(amount: int) -> void:
	pass


func remove_currency(amount: int) -> void:
	pass





# Manage kitchen ingrediants storage
func add_to_storage(item: String): # ADD CARD OBJECT USING FACTORY TO INVENTORY
	kitchen_inventory.append(item)
	print("Added to inventory:", item)

func remove_from_storage(item: String):
	if item in kitchen_inventory:
		kitchen_inventory.erase(item)
		print("Removed from inventory:", item)

# Handle waiter actions
func assign_order_to_waiter(order):
	if waiter_queue:
		var waiter = waiter_queue.pop_front()
		waiter.take_order(order)
		print("Order assigned to waiter:", order)
	else:
		print("No waiters available!")

func add_waiter_to_queue(waiter):
	waiter_queue.append(waiter)
	print("Waiter added to queue:", waiter)

# Timer utilities for gameplay
func start_cooking_timer(duration: float, callback: Callable):
	var timer = Timer.new()
	timer.wait_time = duration
	timer.one_shot = true
	timer.connect("timeout", callback)
	add_child(timer)
	timer.start()