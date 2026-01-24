extends CharacterBody2D

const MAX_HP = 30.0
const DAMAGE = 30.0

var curr_hp = MAX_HP
var is_dead = false

# ------ Death Animation ------
const DEATH_REPEATS = 5
var death_play_count = 0

@onready var target = $/root/Main/Gameplay/PlayerCar
@onready var sprite = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	pass

# --------------------------------------------------

func take_damage(amount: int):
	if is_dead:
		return
		
	curr_hp -= amount
	if curr_hp <= 0:
		die()

# --------------------------------------------------

func die():
	if is_dead:
		return
	is_dead = true
	
	collision_layer = 0
	collision_mask = 0
	
	sprite.play_backwards()
	_on_death_animation_finished()

# --------------------------------------------------

func _on_death_animation_finished():
	death_play_count += 1
	print(death_play_count)
	
	if death_play_count < DEATH_REPEATS:
		await get_tree().create_timer(1).timeout
		sprite.play("death")
		_on_death_animation_finished()
	else:
		queue_free()
	
