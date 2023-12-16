extends Node2D

const MapConstants = preload("res://contexts/core/scripts/MapConstants.gd")

var data = {
	"current_health": 100,
	"speed": 5
}

var _next_move:Vector2i

"""
Returns true if picked a move; false if there are no valid moves.
"""
func pick_next_move() -> bool:
	# If the monster gets multiple moves, the baseline is their last move.
	# If this is the first move, the baseline is their current position.
	
	var all_directions = [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]
	var tile_position = \
		_next_move if _next_move != Vector2i.ZERO \
		else Vector2i(self.position / MapConstants.TILE_SIZE)
		
	var valid_directions = all_directions.filter(func(direction): return TileWalkabilityManager.is_available(tile_position + direction))
	
	if valid_directions.size() == 0:
		return false
	
	_next_move = tile_position + valid_directions.pick_random()
	TileWalkabilityManager.claim_other(self, _next_move)
	return true

func is_alive():
	return data["current_health"] > 0

func get_speed():
	return data["speed"]
