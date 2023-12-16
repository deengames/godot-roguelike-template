extends Node2D

const MapConstants = preload("res://contexts/core/scripts/MapConstants.gd")
const TurnCalculator = preload("res://contexts/core/scripts/TurnCalculator.gd")

@onready var _monsters = $Monsters.get_children()
@onready var _player = %Player

@onready var _fog_tiles = %FogTiles

# It's either this, or a global variable ...
var _turn_calculator:TurnCalculator

func _ready():
	_fog_tiles.update_fov(_player.position / MapConstants.TILE_SIZE)
	CoreEventBus.on_player_moving.connect(func(): _fog_tiles.update_fov(_player.position / MapConstants.TILE_SIZE))
	
	var all_entities = _monsters.duplicate()
	all_entities.append(_player)
	_turn_calculator = TurnCalculator.new(all_entities, _player)
	
