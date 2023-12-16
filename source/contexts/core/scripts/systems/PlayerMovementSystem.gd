extends Node
## Listens to the player's input, and moves the player character appropriately.

const MapConstants = preload("res://contexts/core/scripts/MapConstants.gd")
const TurnCalculator = preload("res://contexts/core/scripts/TurnCalculator.gd")

const _PLAYER_MOVE_TIME_SECONDS:float = 0.1

# used to tell which tiles are solid
@onready var _tilemap:TileMap = %Floor

var _player

# false if monsters are not yet done moving. Gotta wait for them to move so we
# know our turn is done and we can move again.
# Player can always take the first move, to start.
var _can_move = true 

func _ready():
	_player = get_tree().get_nodes_in_group("Player")[0]
	
	CoreEventBus.on_player_moved.connect(func(): _can_move = true)
	
	# Iterate over all layers
	for i in _tilemap.get_layers_count():
		# Iterate over all tiles on each layer
		for tile_coordinates in _tilemap.get_used_cells(i):
			var tile_data:TileData = _tilemap.get_cell_tile_data(i, tile_coordinates)
			if tile_data.get_collision_polygons_count(i) > 0:
				TileWalkabilityManager.claim_tile(tile_coordinates)
	
func _input(event):
	if not event is InputEventKey or not _can_move:
		return
		
	if not event is InputEventKey or not event.is_pressed():
		return

	var player_tile_position:Vector2i = _player.position / MapConstants.TILE_SIZE
	
	var turn_calculator = TurnCalculator.singleton
	if turn_calculator.get_next_turn() != _player:
		return

	TileWalkabilityManager.clear()
	
	var key_event = event as InputEventKey
	if key_event.is_action_pressed("ui_accept"):
		TileWalkabilityManager.claim(_player)
		turn_calculator.advance_turn()
	
	for monster in get_tree().get_nodes_in_group("Monster"):
		TileWalkabilityManager.claim(monster)

	var direction = _extract_direction(key_event)
	if direction != Vector2i.ZERO and TileWalkabilityManager.is_available(player_tile_position + direction):
		_can_move = false
		# player moving - stop monsters from moving there.
		TileWalkabilityManager.claim_other(_player, player_tile_position + direction)
		var tween = get_tree().create_tween()
		var player_destination:Vector2 = player_tile_position + direction
		tween.tween_property(_player, "position", player_destination * MapConstants.TILE_SIZE, _PLAYER_MOVE_TIME_SECONDS)
		tween.finished.connect(func(): CoreEventBus.on_player_moved.emit())
		turn_calculator.advance_turn()
		# Triggers monsters to move
		# Uncomment the line below to get monsters to all move AFTER the player
		#tween.connect("finished", func(): CoreEventBus.on_player_moving.emit())
		CoreEventBus.on_player_moving.emit()
	
func _extract_direction(key_event:InputEventKey) -> Vector2i:
	if key_event.is_action_pressed("move_up"):
		return Vector2i.UP
	elif key_event.is_action_pressed("move_right"):
		return Vector2i.RIGHT
	elif key_event.is_action_pressed("move_down"):
		return Vector2i.DOWN
	elif key_event.is_action_pressed("move_left"):
		return Vector2i.LEFT
	
	return Vector2i.ZERO

