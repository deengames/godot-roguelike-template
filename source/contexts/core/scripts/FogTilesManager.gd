extends Node

const MAP_SIZE:Vector2i = Vector2i(60, 34) # arbitrary
const _FOG_FLOOR_TILE_ID:int = 0 # I guessed

@onready var _fog_tile_map = self

func _ready():
	_fill_with_fog()
	
func update_fov(player_tile_position:Vector2i, player_sight_radius:int = 5) -> void:
	var player_fov = _get_player_fov(player_tile_position, player_sight_radius)

	BetterTerrain.set_cells(_fog_tile_map, 0, player_fov, -1)
	BetterTerrain.update_terrain_cells(_fog_tile_map, 0, player_fov)
	
func _get_player_fov(player_tile_position:Vector2i, player_sight_radius:int = 5) -> Array[Vector2i]:
	var cells:Array[Vector2i] = []
	for y in range(-player_sight_radius, player_sight_radius):
		for x in range(-player_sight_radius, player_sight_radius):
			var coordinates:Vector2i = player_tile_position + Vector2i(x, y)
			if (coordinates - player_tile_position).length_squared() <= player_sight_radius:
				cells.append(coordinates)
				
	return cells
	
func _fill_with_fog() -> void:
	# Note: because of how Fog of War tiles are drawn, we cover up to (-1, -1) in the fog tile.
	var cells = []
	for y in range(-1, MAP_SIZE.y):
		for x in range(-1, MAP_SIZE.x):
			cells.append(Vector2i(x, y))
			
	BetterTerrain.set_cells(_fog_tile_map, 0, cells, _FOG_FLOOR_TILE_ID)
	BetterTerrain.update_terrain_cells(_fog_tile_map, 0, cells)
