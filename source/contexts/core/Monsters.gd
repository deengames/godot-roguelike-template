extends Node

var _is_processing = false

@onready var _move_system = %MonsterMovementSystem

func _input(event):
	if not event is InputEventKey or not event.pressed:
		return
		
	if _is_processing:
		return
	
	# Used if the player passes a turn. Not sure why it's here, though.
	if event.is_action_pressed("ui_accept"):
		_is_processing = true
		_move_system.move_monsters()
		_is_processing = false
