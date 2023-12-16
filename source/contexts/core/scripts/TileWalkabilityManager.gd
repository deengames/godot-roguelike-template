extends Node
"""
Sadly, must be cognizent of monsters and the player; otherwise, in cases where
one moves faster than the other, clearing clears tiles that are occupied!
"""

const MapConstants = preload("res://contexts/core/scripts/MapConstants.gd")

# Map of who's planning to move where. Keeps things O(1) regardless of number of entities.
# Clears between turns.
var _coordinates_to_entities = {}
# Map of where we can't walk. Doesn't clear between turns.
var _unwalkable_tiles = {}

func is_available(tile_coordinates:Vector2i) -> bool:
	var result = not _unwalkable_tiles.has(tile_coordinates) and \
		not _coordinates_to_entities.has(tile_coordinates)
	return result

""" A tile claims this spot as (permanently) unwalkable """
func claim_tile(tile_coordinates:Vector2i) -> void:
	_unwalkable_tiles[tile_coordinates] = "!"
	
""" An entity claims this spot as (temporarily) unwalkable """
func claim(who:Node2D) -> void:
	var tile_coordinates:Vector2i = who.position / MapConstants.TILE_SIZE
	_coordinates_to_entities[tile_coordinates] = who

func claim_other(who:Node2D, where:Vector2i) -> void:
	_coordinates_to_entities[where] = who

func clear():
	_coordinates_to_entities.clear()
