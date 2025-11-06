extends CharacterBody2D
var GRAVITY : int = 1000
const MAX_VELOCITY : int = 600
var FLAP_SPEED : = -400
var FLYING = false
var FALLING = false
const START_POS = Vector2(100, 400) 
var is_big: bool = false 
var normal_scale: Vector2
var is_small: bool = false
var is_intangible: bool = false
var has_shield: bool = false
@onready var roll_sound: AudioStreamPlayer = $rollSound
@onready var jump: AudioStreamPlayer = $jump

func _ready():
	reset()
	normal_scale = scale
	$shield.visible = false
func reset():
	FLYING = false
	FALLING = false
	position = START_POS

func _physics_process(delta):
	if FLYING or FALLING:
		velocity.y += GRAVITY * delta
		if velocity.y > MAX_VELOCITY:
			velocity.y = MAX_VELOCITY
		if FLYING:
			$AnimatedSprite2D.play()
			set_rotation(deg_to_rad(velocity.y * 0.05))
		elif FALLING:
			set_rotation(PI/2)
			$AnimatedSprite2D.stop()
		move_and_collide(velocity * delta)
	else:
		$AnimatedSprite2D.stop()
func flap():
	velocity.y = FLAP_SPEED
	jump.play()

func grow_temporary(duration: float = 5.0):
	if is_big:
		return
	is_big = true
	
	var tween = create_tween()
	tween.tween_property(self, "scale", normal_scale * 1.6, 0.3)
	
	
	await get_tree().create_timer(duration).timeout
	var shrink_tween = create_tween()
	shrink_tween.tween_property(self, "scale", normal_scale, 0.3)
	is_big = false
	


func shrink_temporary(duration: float = 5.0):
	if is_small:
		return
	is_small = true
	
	var tween = create_tween()
	tween.tween_property(self,"scale", normal_scale * 0.6, 0.3)
	
	await get_tree().create_timer(duration).timeout
	var regrow_tween = create_tween()
	regrow_tween.tween_property(self, "scale", normal_scale, 0.3)

func intangible(duration: float = 5.0):
	if is_intangible:
		return
	is_intangible = true
	
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.4, 0.3)
	set_collision_layer_value(1,false)
	await get_tree().create_timer(duration - 1.0).timeout
	
	for i in range(6):
		modulate.a = 0.75
		await get_tree().create_timer(0.1).timeout
		modulate.a = 0.4
		await get_tree().create_timer(0.1).timeout
	
	
	var tangible_tween = create_tween()
	tangible_tween.tween_property(self, "modulate:a", 1.0,0.3)
	set_collision_layer_value(1, true)
	is_intangible = false

func gravity_flip(duration: float = 5.0):
	GRAVITY = -GRAVITY
	FLAP_SPEED = - FLAP_SPEED
	$AnimatedSprite2D.flip_v = true
	
	await get_tree().create_timer(duration - 1.0).timeout
	
	for i in range(6):
		modulate.a = 0.1
		await get_tree().create_timer(0.1).timeout
		modulate.a = 1
		await get_tree().create_timer(0.1).timeout
	
	GRAVITY = - GRAVITY
	FLAP_SPEED = - FLAP_SPEED
	$AnimatedSprite2D.flip_v = false


func activate_shield(duration: float = 5.0):
	if has_shield:
		return
	has_shield = true
	
	$shield.visible = true
	
	await get_tree().create_timer(duration).timeout
	
	if has_shield:
		pass#deactivate_shield()
	
	
func deactivate_shield():
	has_shield = false
	$shield.visible = false
