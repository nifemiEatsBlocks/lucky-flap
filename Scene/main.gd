extends Node



@export var pipe_scene : PackedScene
var game_running : bool
var game_over : bool
var scroll
var score
const SCROLL_SPEED : int = 4
var screen_size : Vector2i
var ground_height : int
var pipes : Array
const PIPE_DELAY : int = 100
const PIPE_RANGE : int = 200

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ground_height = $Ground.get_node("Sprite2D").texture.get_height()
	screen_size = get_window().size
	new_game()
func new_game():
	game_running = false 
	game_over = false 
	score = 0
	scroll = 0
	$score.text = "SCORE:" + str(score)
	$gameOver.hide()
	get_tree().call_group("Pipes", "queue_free")
	pipes.clear()
	generate_pipes()
	$bird.reset()
	
	
func _input(event):
	if game_over == false :
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed :
				if game_running == false:
					start_game()
				else:
					if $bird.FLYING:
						$bird.flap()
						check_top()
						
func start_game() :
	game_running = true
	$bird.FLYING = true
	$bird.flap()
	$PipeTimer.start()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if game_running:
		scroll += SCROLL_SPEED
		if scroll >= (screen_size.x/2):
			scroll = 0
		$Ground.position.x = -scroll
		$background.position.x = -scroll 
		$background2.position.x = -scroll
		for pipe in pipes:
			pipe.position.x -=  SCROLL_SPEED


func _on_pipe_timer_timeout() -> void:
	generate_pipes()
	
func generate_pipes():
	var pipe = pipe_scene.instantiate()
	pipe.position.x = screen_size.x + PIPE_DELAY
	pipe.position.y = (screen_size.y - ground_height) / 2 + randi_range(-PIPE_RANGE, PIPE_RANGE)
	
	var roll = randf()
	
	if roll < 0.2:
		pipe.is_moving = true
		pipe.amplitude = randf_range(50, 70.0)
		pipe.frequency = randf_range(3, 3)
	elif roll < 0.35:
		pipe.is_disappering = true
		pipe.diasppering_time = 2.0
		pipe.invisible_time = 1
	elif roll < 0.5:
		pipe.pipe_type = "opening"
	elif roll < 0.65:
		pipe.pipe_type = "closing"
	else:
		pipe.is_moving = false
	pipe.hit.connect(bird_hit)
	pipe.scored.connect(scored)
	add_child(pipe)
	pipes.append(pipe)
func scored():
	score += 1
	$score.text = "SCORE:" + str(score)
func check_top():
	if $bird.position.y < 75:
		$bird.FALLING = true
		stop_game()
		


func stop_game():
	$PipeTimer.stop()
	$bird.FLYING = false
	game_over = true
	game_running = false
	$gameOver.show()
	
func bird_hit ():
	$bird.FALLING = true
	if $bird.has_shield:
		$bird.deactivate_shield()
		return
	else:
		stop_game()


func _on_ground_hit() -> void:
	$bird.FALLING = false
	$bird.velocity = Vector2.ZERO
	$bird.move_and_slide()
	bird_hit()
	


func _on_game_over_restart() -> void:
	new_game()
