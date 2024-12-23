class_name Shop
extends Control

const ITEM_LIST = {
	1: ["honey", "strawberry", "milk", "flour"],
	2: ["rose_petal", "beef"]
}

const SHOP_ITEM_SCENE_PATH = "res://scenes/ui/shop_item.tscn"
const ITEM_PRICE = 20

# node references
@onready var shop_container = $ShopContainer
@onready var buy_button = $BuyButton
@onready var buying_status_label = $BuyingStatusLabel
@onready var nothing_in_shop_label = $NothingInShopLabel


# other variables
var shopping_cart = []


func _ready() -> void:
	nothing_in_shop_label.visible = false
	buying_status_label.text = ""
	# connect signals
	GameSignals.day_ended.connect(fill_shop)
	GameSignals.next_day_started.connect(clear_shop)
	GameSignals.item_selected.connect(add_item_to_cart)
	GameSignals.item_deselected.connect(remove_item_from_cart)
	buy_button.pressed.connect(checkout)


func fill_shop() -> void:
	if !ITEM_LIST.has(GameManager.current_day):
		nothing_in_shop_label.visible = true
		return
	
	var curr_day_items = ITEM_LIST[GameManager.current_day]
	
	for item in curr_day_items:
		create_shop_item(item)


func clear_shop() -> void:
	# remove the shop item components and reset labels to default
	for item in shop_container.get_children():
		item.queue_free()
	buying_status_label.text = ""
	nothing_in_shop_label.visible = false
	# clear shopping cart to ensure nothing carries over across days
	shopping_cart.clear()


func create_shop_item(item:String) -> void:
	var shop_item_scene = load(SHOP_ITEM_SCENE_PATH)
	var new_shop_item = shop_item_scene.instantiate()
	
	new_shop_item.shop_item_name = item
	
	shop_container.add_child(new_shop_item)


func add_item_to_cart(item:String) -> void:
	shopping_cart.append(item)
	print("added " + item + " to cart!")
	buying_status_label.text = "total cost: "\
								+ str(calc_total_cost())\
								+ " golden seeds"


func remove_item_from_cart(item:String) -> void:
	shopping_cart.erase(item)
	print("removed " + item + " from cart!")
	buying_status_label.text = "total cost: "\
								+ str(calc_total_cost())\
								+ " golden seeds"


func calc_total_cost() -> int:
	return shopping_cart.size() * ITEM_PRICE


func checkout() -> void:
	var total_cost = calc_total_cost()
	
	if shopping_cart.is_empty():
		buying_status_label.text = "no items selected!"
		return
	
	if GameManager.golden_seeds < total_cost:
		buying_status_label.text = "not enough golden seeds to buy!"
	else:
		buying_status_label.text = "purchased!"
		
		for item in shopping_cart:
			GameManager.add_to_storage(item)
		
		GameManager.remove_currency(total_cost)
	
