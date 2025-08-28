extends CharacterBody2D
class_name Player

@onready var anim: AnimationPlayer = $AnimationPlayer


@export_category("Movement variables")
@export var gravity: float = 900.0
@export var move_speed: float = 140.0
@export var deceleration: float = 0.1

@export_category("Jump variables")
@export var jump_speed: float = 330.0
@export var acceleration: float = 430.0
@export var jump_amount: int = 2

@export_category("Wall jump variables")
@export var wall_slide: float = 10.0
@export var wall_x_forse_settings: float = 300.0
@export var wall_y_forse_settings: float = -320.0
var wall_x_forse: float = wall_x_forse_settings
var wall_y_forse: float = wall_y_forse_settings
@onready var left_ray: RayCast2D = $raycast/left_ray
@onready var right_ray: RayCast2D = $raycast/right_ray
var is_wall_jumping: bool = false 

@export_category("Dash variables")
@export var dash_speed: float = 400.0
@export var facing_right: bool = true
@export var dash_gravity: float = 0
@export var dash_number = 1
var dash_key_pressed: int = 0
var is_dashing: bool = false
var dash_timer: Timer

func horizontal_movement() -> void:
	if not is_wall_jumping and not is_dashing:		
		var direction: float = Input.get_axis("ui_left", "ui_right")
		if direction:
			velocity.x = direction * move_speed
		else:
			velocity.x = move_toward(velocity.x, 0, move_speed * deceleration)
			
	if Input.is_action_just_pressed("ui_dash") and dash_key_pressed == 0 and dash_number > 0:
		dash_number -= 1
		dash_key_pressed = 1
		dash()
		
func set_animation() -> void:
	if velocity.y < 0:
		anim.play("Jump")
	elif velocity.y > 0:
		anim.play("Fall")
	elif velocity.x != 0:
		anim.play("Move")
	elif is_on_wall_only():
		anim.play("Fall")
	else:
		anim.play("Idle")	
	
		
func flip() -> void:
	if velocity.x > 0.0:
		scale.x = scale.y * 1
		wall_x_forse = wall_x_forse_settings
		facing_right = true
	if velocity.x < 0.0:
		scale.x = scale.y * -1
		wall_x_forse = -wall_x_forse_settings
		facing_right = false

func vertical_movement(delta: float) -> void:
	if not is_on_floor():
		if not is_dashing:
			velocity.y += gravity * delta
		else:
			velocity.y = dash_gravity
		
	jump_logic()
	wall_logic()
	
 
func jump_logic() -> void:
	if is_on_floor():
		dash_number = 1
		jump_amount = 2
		if Input.is_action_just_pressed("ui_accept"):
			jump_amount -= 1			
			velocity.y -= lerp(jump_speed, acceleration, 0.1)			
	else:
		if jump_amount > 0:
			if Input.is_action_just_pressed("ui_accept"):
				jump_amount -= 1
				velocity.y = 0
				velocity.y -= lerp(jump_speed, acceleration, 1)		
		if Input.is_action_just_released("ui_accept"):
				velocity.y = lerp(velocity.y, gravity, 0.2)		
				velocity.y *= 0.3
				
func wall_logic() -> void:
	if is_on_wall_only():
		velocity.y = 10
		if Input.is_action_just_pressed("ui_accept"):
			#if left_ray.is_colliding():
			#	velocity = Vector2(wall_x_forse, wall_y_forse)
			#	wall_jumping()
			if right_ray.is_colliding():
				jump_amount = 2
				velocity = Vector2(-wall_x_forse, wall_y_forse)
				wall_jumping()

func wall_jumping():
	is_wall_jumping = true
	await  get_tree().create_timer(0.12).timeout		
	is_wall_jumping = false
		
func dash():
	if dash_key_pressed == 1:
		is_dashing = true
	else:
		is_dashing = false
		
	if facing_right:
		velocity.x = dash_speed
		dash_started()
	else:
		velocity.x = -dash_speed
		dash_started()

func dash_started():
	if is_dashing:
		dash_key_pressed = 1
		await  get_tree().create_timer(0.2).timeout
		is_dashing = false
		dash_key_pressed = 0
	else:
		return		

func _physics_process(delta: float) -> void:
	#print("fps=", Engine.get_frames_per_second())
	horizontal_movement() 
	vertical_movement(delta)	
	set_animation()
	flip()
	
	move_and_slide()
