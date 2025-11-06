extends Area2D

signal hit
signal scored
@onready var crash: AudioStreamPlayer = $crash
@onready var score_point: AudioStreamPlayer = $scorePoint

@export var Move_speed: float = 8.0
@export var amplitude: float = 100.0
@export var frequency: float = 5.0
@export var is_moving: bool = false 
@export var is_disappering: bool = false
@export var diasppering_time: float = 2.0
@export var invisible_time : float = 1.0

@export_enum("normal", "opening", "closing") var pipe_type := "normal"
@export var normal_gap: float = 200
@export var closed_gap: float = 0.0
@export var open_gap: float = 400
@export var gap_tween_time: float = 0.25
@export var action_delay: float = 3.0

@onready var upper: Sprite2D = $upper
@onready var lower: Sprite2D = $lower


var base_y: float
var time_passed: float = 0.0
var visible_timer: float = 0.0
var is_visible_phase: bool = true

var top_base_y: float
var bottom_base_y: float

func _ready ():
	base_y = position.y
	visible = true
	
	top_base_y = upper.position.y
	bottom_base_y = lower.position.y
	
	
	match pipe_type:
		"normal":
			_set_gap_immediate(normal_gap)
		"opening":
			_set_gap_immediate(closed_gap)
			_open_after_delay()
		"closing":
			_set_gap_immediate(open_gap)
			_close_after_delay()
func _process(delta):
	time_passed += delta 
	if is_moving:
		position.y = base_y + sin(time_passed * frequency ) * amplitude
	
	
	if is_disappering:
		visible_timer += delta
		if is_visible_phase and visible_timer >= diasppering_time:
			is_visible_phase = false
			visible_timer = 0.0
			var tween = create_tween()
			tween.tween_property(self, "modulate:a", 0.0, 0.5)
		elif not is_visible_phase and visible_timer >= invisible_time:
			is_visible_phase = true
			visible_timer = 0.0
			var tween = create_tween()
			tween.tween_property(self, "modulate:a", 1.0, 40 )
		
		
func _set_gap_immediate(gap: float):
	upper.position.y = top_base_y - (gap - normal_gap) / 2
	lower.position.y = bottom_base_y + (gap - normal_gap)/2

func _tween_gap(gap: float):
	var t = create_tween()
	t.set_parallel(true)
	
	t.tween_property(upper, "position:y", top_base_y - (gap - normal_gap) / 2, gap_tween_time)
	t.tween_property(lower, "position:y", bottom_base_y + (gap - normal_gap)/2, gap_tween_time)
	
	
func _open_after_delay():
	await get_tree().create_timer(action_delay).timeout
	_tween_gap(normal_gap)
	
func _close_after_delay():
	await get_tree().create_timer(action_delay).timeout
	_tween_gap(normal_gap)


func _on_body_entered(body: Node2D) -> void:
	hit.emit()
	crash.play()


func _on_score_area_body_entered(body: Node2D) -> void:
	scored.emit()
	score_point.play()
