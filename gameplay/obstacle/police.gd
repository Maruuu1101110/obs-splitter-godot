extends CharacterBody2D

const SPEED = 150.0
const MAX_HP = 1500.0
const DAMAGE = 50.0

var curr_hp = MAX_HP
var is_dead = false

var in_pursuit = false

# ------ Death Animation ------
const DEATH_REPEATS = 5
var death_play_count = 0

@onready var sprite = $AnimatedSprite2D
@onready var popup = $PopupLocation

# --------------------------------------------------
#
func _ready() -> void:
	pass

# --------------------------------------------------

func _physics_process(delta: float) -> void:
	var target = $/root/Main/Gameplay/PlayerCar
	if target != null && curr_hp > 0 && in_pursuit:
		if position.distance_to(target.position) < 100:
			var direction = (target.position - position).normalized()
			velocity = direction * SPEED
			look_at(target.position)
			#print("Chasing at player")
			target.breadcrumb.clear()
		elif len(target.breadcrumb) > 0:
			var direction = (target.breadcrumb[0] - position).normalized()
			velocity = direction * SPEED
			look_at(target.breadcrumb[0])
			#print("Chasing at " + str(target.breadcrumb[0]))
		move_and_slide() 
		if len(target.breadcrumb) > 0:
			if position.distance_to(target.breadcrumb[0]) < 50:
				target.breadcrumb.pop_at(0)
	else:
		pass
		#print("NULLL")

# --------------------------------------------------

func take_damage(amount: float):
	if is_dead:
		return
		
	curr_hp -= amount
	print(curr_hp)
	if curr_hp <= 0:
		die()
		
	if amount > 0:
		popup.popup(str(amount))

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
	
func _exit_tree() -> void:
	if has_meta("spawnpoint"):
		var spawn = get_meta("spawnpoint")
		if is_instance_valid(spawn):
			spawn.set_meta("occupied", false)
