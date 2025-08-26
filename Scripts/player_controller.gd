extends CharacterBody2D
class_name Player

@onready var anim: AnimationPlayer = $AnimationPlayer

@export_category("Movement variables")
@export var gravity: float = 500.0
@export var move_speed: float = 120.0
@export var deceleration: float = 0.1

@export_category("Jump variables")
@export var jump_speed: float = 190.0
@export var acceleration: float = 290.0
@export var jump_amount: int = 2


func horizontal_movement() -> void:
	var direction: float = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed * deceleration)
		
func set_animation() -> void:
	if velocity.y < 0:
		anim.play("Jump")
	elif velocity.y > 0:
		anim.play("Fall")
	elif velocity.x != 0:
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
		
	jump_logic()
	
 
func jump_logic() -> void:
	if is_on_floor():
		jump_amount = 2
		if Input.is_action_just_pressed("ui_accept"):
			jump_amount -= 1			
			velocity.y -= lerp(jump_speed, acceleration, 0.1)			
	else:
		if jump_amount > 0:
			if Input.is_action_just_pressed("ui_accept"):
				jump_amount -= 1		
				velocity.y -= lerp(jump_speed, acceleration, 1)		
		if Input.is_action_just_released("ui_accept"):
				velocity.y = lerp(velocity.y, gravity, 0.2)		
				velocity.y *= 0.3
		
func _physics_process(delta: float) -> void:
	horizontal_movement() 
	vertical_movement(delta)	
	set_animation()
	flip()
	
	move_and_slide()
