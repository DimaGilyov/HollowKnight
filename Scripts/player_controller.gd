extends CharacterBody2D
class_name Player

@onready var anim: AnimationPlayer = $AnimationPlayer

@export var gravity: float = 500.0
@export var move_speed: float = 120.0
@export var deceleration: float = 0.1

func horizontal_movement() -> void:
	var direction: float = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed * deceleration)
		
func set_animation() -> void:
	if velocity.x != 0:
		anim.play("Move")
	else:
		anim.play("Idle")	
		
func flip() -> void:
	if velocity.x > 0.0:
		scale.x = scale.y * 1
	if velocity.x < 0.0:
		scale.x = scale.y * -1
		
func vertical_movement(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
		
func _physics_process(delta: float) -> void:
	horizontal_movement()
	vertical_movement(delta)	
	set_animation()
	flip()
	
	move_and_slide()
