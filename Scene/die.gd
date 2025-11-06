extends Control

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var roll_sound: AudioStreamPlayer = $rollSound


#@onready var bird: CharacterBody2D = $"."
@export var player_node_path: NodePath
@onready var bird: CharacterBody2D = $"../bird"

var player: CharacterBody2D
var is_rolling = false

func ready():
	player = get_node(player_node_path)
	
func _input(event):
	if event.is_action_pressed("roll") and not is_rolling:
		roll_die()

func roll_die():
	if is_rolling:
		return
		
	is_rolling = true
	roll_sound.play()
	var power_ups = [
			func(): bird.gravity_flip(7.0),
			func(): bird.activate_shield(7.0),
			func(): bird.shrink_temporary(7.0),
			func(): bird.grow_temporary(7.0),
			func(): bird.intangible(7.0)
		]
		
	var final_index = randi_range(0, power_ups.size() - 1)
	
	var timer = 0.0
	var roll_duration = 0.8
	var roll_speed = 0.05
	
	while timer <  roll_duration :
		animated_sprite_2d.frame = randi_range(0, power_ups.size() - 1)
		animated_sprite_2d.play("roll")
		await get_tree().create_timer(roll_speed).timeout
		timer += roll_speed
	#animated_sprite_2d.play("roll")
		animated_sprite_2d.stop()
	animated_sprite_2d.frame = final_index
	
	power_ups[final_index].call()
	is_rolling = false
	#await get_tree().create_timer(0.8).timeout
	
