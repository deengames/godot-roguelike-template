extends Node
## Handles moves for monsters.
## That is: iterates monster by monster, picks the move, and then moves.
## If they all pick moves at once, that also works, without collisions.
const MapConstants = preload("res://contexts/core/scripts/MapConstants.gd")
const TurnCalculator = preload("res://contexts/core/scripts/TurnCalculator.gd")

const _MOVE_TIME_SECONDS:float = 0.1

var _monsters:Array[Node]

func _ready():
	_monsters = get_tree().get_nodes_in_group("Monster")
	CoreEventBus.on_player_moving.connect(func(): move_monsters())
	
	for monster in _monsters:
		TileWalkabilityManager.claim(monster)

func move_monsters() -> void:
	var turn_calculator = TurnCalculator.singleton
	
	var next = turn_calculator.get_next_turn()
	var num_moves = {}
	
	# Pick moves if you need to. Then, move.
	while next.is_in_group("Monster"):
		# Each monster will claim each intermediate and final spot they move to.
		# This is good. Sort of. Those spots are all blocked...
		if next.pick_next_move():
			if not next in num_moves:
				num_moves[next] = 0
			num_moves[next] += 1
		
		turn_calculator.advance_turn()
		next = turn_calculator.get_next_turn()
	
	for monster in num_moves.keys():
		move_monster(monster)
		
	TileWalkabilityManager.clear()
	CoreEventBus.all_monsters_done_moving.emit()

func move_monster(monster) -> void:
	if monster._next_move == Vector2i.ZERO:
		return
		
	# TODO: belongs in Movement System ig?
	var tween = get_tree().create_tween()
	var target_position:Vector2 = monster._next_move * MapConstants.TILE_SIZE
	tween.tween_property(monster, "position", target_position, _MOVE_TIME_SECONDS)
	monster._next_move = Vector2i.ZERO
	CoreEventBus.any_monster_moved.emit()
