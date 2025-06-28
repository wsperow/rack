extends Node

@export var max_health: float
@onready var health:= max_health

func damage(ammount: float) -> bool: #Deal damage, return true if health <= 0 (dead)
	health -= ammount
	if health > 0:
		return false
	else: return true
	
func is_alive() -> bool: #Return false if health <= 0 (dead)
	if health > 0:
		return true
	else: return false
	
#func kill() -> void:
	#
	#pass
