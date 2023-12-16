extends Node

var _speed:int = 7

func _init(speed:int = 7):
	_speed = speed
	
func get_speed():
	return _speed

func is_alive():
	return true
