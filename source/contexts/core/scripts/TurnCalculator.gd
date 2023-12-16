extends Node

## Figures out who's turn is next, based on an energy/tick system. Requirements for entities:
##	- get_speed() function, which returns their speed (higher is faster)
##	- is_alive() function, which returns false if they're dead
## Each entity has a get_speed() function, and each turn, they get that many ticks.
## The winner is the one who reaches 100 first. (Unless speeds are over 100, then
## the winner is whoever reaches the next hundred first, e.g. 200, 300...)

var _entity_to_time = {}
var _max_time:int
var _next_entity:Node

# Singleton. Ish.
static var singleton

func _init(entities:Array, first:Node = null):
	if singleton != null:
		push_error("More than one instance of turn calculator created?!")
		return
	
	singleton = self
	
	if len(entities) == 0:
		push_error("Can't ge turn, no entities.")

	for e in entities:
		_entity_to_time[e] = 0

	var fastest_speed = _get_fastest_speed()
	# Rounds up to the nearest hundred, e.g. 137 => 200
	_max_time = int(fastest_speed / 100 * 100) + 100
	
	if first == null:
		advance_turn()
	else:
		_next_entity = first

func get_next_turn():
	return _next_entity

func advance_turn():
	_next_entity = null
	
	# Bring out yer dead ...
	for entity in _entity_to_time.keys():
		# get_parent check is for monsters: we remove from container on death.
		if not entity.is_alive() or entity.get_parent() == null: 
			_entity_to_time.erase(entity)
			
	# If there was a tie last turn, see if anyone's already over max_time this turn
	for entity in _entity_to_time.keys():
		if _entity_to_time[entity] >= _max_time:
			_entity_to_time[entity] -= _max_time
			_next_entity = entity
			return _next_entity
	
	# Add time, see who's done
	var time_to_turn = _max_time
	var whos_turn = null
	
	for entity in _entity_to_time.keys():
		var speed = entity.get_speed()
		var estimated_time = (_max_time - _entity_to_time[entity]) / speed
		estimated_time = int(ceil(estimated_time))
		
		if estimated_time < time_to_turn:
			# First to reach _max_time wins
			time_to_turn = estimated_time
			whos_turn = entity
		elif estimated_time == time_to_turn and (whos_turn == null or entity.get_speed() > whos_turn.get_speed()):
			# In a tie, the faster one wins
			time_to_turn = estimated_time
			whos_turn = entity
	
	# Increment time for everyone
	for entity in _entity_to_time.keys():
		var speed = entity.get_speed()
		_entity_to_time[entity] += (speed * time_to_turn)
		if entity == whos_turn:
			_entity_to_time[entity] -= _max_time
			
	if whos_turn == null:
		push_error("It's nobody's turn?!")
		
	_next_entity = whos_turn
	return _next_entity
	
func _get_fastest_speed():
	var speeds = _entity_to_time.keys().map(func(e): return e.get_speed())
	var fastest_speed = speeds.reduce(func(a, b): return max(a, b), 0)	
	return fastest_speed
