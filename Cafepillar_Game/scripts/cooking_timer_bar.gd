extends Control

@onready var start_button: TextureButton = $StartButton
@onready var done_button: TextureButton = $DoneButton
@onready var remove_button: TextureButton = $RemoveButton
@onready var timer_bar: ProgressBar = $ColorRect/TimerBar
@onready var color_rect: ColorRect = $ColorRect
@onready var status_label: Label = $Status
@onready var stove_slot: Slot = $"../Stove/StoveSlot"
@onready var card_factory: Node = $"../CardFactory"


# the tick mark at 70% is the time it takes to make the food according to the food card
const PERFECT_MIN_PERCENT = 0.70 
# player has a few seconds (until the tick mark at 80%) to collect the good food before it gets burnt
const PERFECT_MAX_PERCENT = 0.80
# foods between 50% and 70% are satisfactory
const SATISFACTORY_MIN_PERCENT = 0.50

# default value
var _time_it_takes_to_cook = 10.0
# calculates the total bar
var _timer_duration = _time_it_takes_to_cook / PERFECT_MIN_PERCENT
var _time_elapsed : float = 0.0
var cooking : bool = false
var tween
# default value
var _food_quality = "undercooked"
var recipe: String = ""


func _ready() -> void:
	$StartButton.connect("pressed", Callable(self, "_on_StartButton_pressed"))
	$DoneButton.connect("pressed", Callable(self, "_on_DoneButton_pressed"))
	$RemoveButton.connect("pressed", Callable(self, "_on_RemoveButton_pressed"))
	color_rect.visible = false
	done_button.visible = false


func _process(delta: float) -> void:
	if cooking:
		_time_elapsed += delta
		_update_timer_bar_color()
	else:
		# reset cooking timer to 0
		_time_elapsed = 0.0
		if tween != null:
			tween.kill()
			tween = null
			timer_bar.value = 0


func _update_timer_bar_color() -> void:
	# color is green; food is perfect
	if _time_elapsed >= _timer_duration * PERFECT_MIN_PERCENT and _time_elapsed <= _timer_duration * PERFECT_MAX_PERCENT:
		timer_bar.set_theme_type_variation("TimerBar")
		_food_quality = "perfect"
	# color is yellow; food is undercooked
	elif _time_elapsed < _timer_duration * SATISFACTORY_MIN_PERCENT:
		timer_bar.set_theme_type_variation("TimerBarMid")
		_food_quality = "undercooked"
	# color is blue; food is satisfactory
	elif _time_elapsed >= _timer_duration * SATISFACTORY_MIN_PERCENT and _time_elapsed < _timer_duration * PERFECT_MIN_PERCENT:
		timer_bar.set_theme_type_variation("SatisfactoryBar")
		_food_quality = "satisfactory"
	# color is red; food is burnt
	else:
		timer_bar.set_theme_type_variation("TimerBarLow")
		_food_quality = "burnt"

	
func _on_StartButton_pressed():
	recipe = stove_slot.check_recipe()
	if recipe != "Null":
		# put all the code below in the if statement checking for valid food
		cooking = true
		color_rect.visible = true
		done_button.visible = true
		start_button.visible = false
		remove_button.visible = false
		status_label.text = "Preparing " + recipe + "..."
		# animate cooking timer
		if tween == null:
			tween = create_tween()
			tween.tween_property(timer_bar, "value", 100.0, _timer_duration)
	else:
		status_label.text = "No Recipes Found..."


func _on_DoneButton_pressed():
	cooking = false
	start_button.visible = true
	color_rect.visible = false
	done_button.visible = false
	remove_button.visible = true
	
	# remove all cards on stove
	var children = stove_slot.get_children()
	for child in children:
		child.free()
		
	stove_slot.card_resources.clear()
	
	# add dish card on stove
	card_factory.create_card_for_stove(recipe.to_lower().replace(" ", "_"), "dishes")
	
	# spawn food card
	print("Spawn " + str(_food_quality) + " " + recipe)


func _on_RemoveButton_pressed():
	while !stove_slot.card_resources.is_empty():
		stove_slot.remove_child(stove_slot.get_child(0))
		# add back to hand
		card_factory.create_card(stove_slot.card_resources[0], "ingredients")
		stove_slot.card_resources.pop_front()
