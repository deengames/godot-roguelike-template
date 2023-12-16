extends GdUnitTestSuite

const MonsterStub = preload("res://tests/stubs/MonsterStub.gd")
const TurnCalculator = preload("res://contexts/core/scripts/TurnCalculator.gd")

func test__max_for_small_numbers__is_100():
	# Arrange/act
	var calc = TurnCalculator.new([
		_get_creature(41), _get_creature(13), _get_creature(2)
	])
	
	# Assert
	assert_int(calc._max_time).is_equal(100)
	
func test__max_for_bigger_numbers_round_up_to_nearest_100__when_speed_is_over_100():
	# Arrange/act
	var calc = TurnCalculator.new([
		_get_creature(210), _get_creature(137), _get_creature(21)
	])
	
	# Assert
	assert_int(calc._max_time).is_equal(300)
	

func test__get_next_turn_with_two_to_one_ratio__returns_turns_in_correct_ratio():
	# Arrange
	var rabbit = _get_creature(11)
	var snail = _get_creature(5)

	# Act
	var calc = TurnCalculator.new([rabbit, snail])
	
	# Assert
	assert_object(calc.get_next_turn()).is_equal(rabbit)
	assert_object(calc.get_next_turn()).is_equal(rabbit)
	assert_object(calc.get_next_turn()).is_equal(snail)
	assert_object(calc.get_next_turn()).is_equal(rabbit)
	assert_object(calc.get_next_turn()).is_equal(rabbit)
	assert_object(calc.get_next_turn()).is_equal(snail)

func test_get_next_turn_with_equal_speeds__returns_turns_in_correct_ratio():
		# Arrange
	var rabbit = _get_creature(10)
	var snail = _get_creature(5)

	# Act
	var calc = TurnCalculator.new([rabbit, snail])
	
	# Assert
	assert_object(calc.get_next_turn()).is_equal(rabbit)
	assert_object(calc.get_next_turn()).is_equal(rabbit)
	assert_object(calc.get_next_turn()).is_equal(snail)
	assert_object(calc.get_next_turn()).is_equal(rabbit)
	assert_object(calc.get_next_turn()).is_equal(rabbit)
	assert_object(calc.get_next_turn()).is_equal(snail)

func _get_creature(speed:int):
	var creature = MonsterStub.new(speed)
	add_child(creature)
	return creature
