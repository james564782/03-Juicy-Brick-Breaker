extends StaticBody2D

var score = 0
var new_position = Vector2.ZERO
var dying = false
export var time_appear = 1.0 #0.5
export var time_fall = 1.5 #0.8
export var time_rotate = 1.0 #1.0
export var time_a = 1.2 #0.8
export var time_s = 1.0 #1.2
export var time_v = 1.0 #1.5

export var fall_distance = 100

var powerup_prob = 0.1

var color_index = 0
var color_distance = 0
var color_completed = true
var color_initial_position = Vector2.ZERO
var color_randomizer = Vector2.ZERO

var colors = [
	Color8(245,79,79),
	Color8(250,107,90),
	Color8(255,135,102),
	Color8(255,153,114),
	Color8(255,172,127),
	Color8(255,191,145),
	Color8(255,211,163),
	Color8(243,187,163)
]

export var sway_amplitude = 0.5 #3.0

func _ready():
	randomize()
	position.x = new_position.x
	position.y = new_position.y - 500
	z_index = new_position.y
	$Tween.interpolate_property(self, "position", position, new_position, time_appear + randf()/2, Tween.TRANS_QUINT, Tween.EASE_IN)
	$Tween.start()
	if score >= 100: color_index = 0
	elif score >= 90: color_index = 1
	elif score >= 80: color_index = 2
	elif score >= 70: color_index = 3 
	elif score >= 60: color_index=  4
	elif score >= 50: color_index = 5
	elif score >= 40: color_index = 6
	else: color_index = 7
	$Sprites/Flower.modulate = colors[color_index]
	color_initial_position = $Sprites/Lilypad.position
	color_randomizer = Vector2(randf()*6-3.0, randf()*6-3.0)
	$Sprites/Lilypad.frame = randi() % 2
	if randi() % 2 >= 0.5:
		$Sprites/Lilypad.flip_h = true
		$Sprites/Flower.flip_h = true

func _physics_process(_delta):
	if dying and not $Confetti.emitting and not $Tween.is_active():
		queue_free()
	elif not $Tween.is_active() and not get_tree().paused:
		color_distance = Global.color_position.distance_to(global_position)  / 100
		if Global.color_rotate >= 0:
			$Sprites/Flower.modulate = colors[(int(floor(color_distance + Global.color_rotate))) % len(colors)]
			color_completed = false
		elif not color_completed:
			$Sprites/Flower.modulate = colors[color_index]
			color_completed = true
		var pos_x = (sin(Global.sway_index)*(sway_amplitude + color_randomizer.x))
		var pos_y = (cos(Global.sway_index)*(sway_amplitude + color_randomizer.y))
		$Sprites/Lilypad.position = Vector2(color_initial_position.x + pos_x, color_initial_position.y + pos_y)
		$Sprites/Flower.position = Vector2(color_initial_position.x + pos_x, color_initial_position.y + pos_y)

func hit(_ball):
	Global.color_rotate = Global.color_rotate_amount
	Global.color_position = _ball.global_position
	die()

func die():
	dying = true
	collision_layer = 0
	collision_mask = 0
	Global.update_score(score)
	if not Global.feverish:
		Global.update_fever(score)
	get_parent().check_level()
	$Confetti.emitting = true
	$Tween.interpolate_property(self, "position", position, Vector2(position.x, position.y + fall_distance), time_fall, Tween.TRANS_EXPO, Tween.EASE_IN)
	$Tween.interpolate_property(self, "rotation", rotation, randf()*PI/30, time_rotate, Tween.TRANS_QUAD, Tween.EASE_IN)
	$Tween.interpolate_property($Sprites/Flower, "modulate:a", $Sprites/Flower.modulate.a, 0, time_a, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($Sprites/Flower, "modulate:s", $Sprites/Flower.modulate.s, 0, time_s, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	#$Tween.interpolate_property($Sprites/Flower, "modulate:v", $Sprites/Flower.modulate.v, 0, time_v, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.interpolate_property($Sprites/Lilypad, "modulate:a", $Sprites/Lilypad.modulate.a, 0, time_a, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($Sprites/Lilypad, "modulate:s", $Sprites/Lilypad.modulate.s, 0, time_s, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	#$Tween.interpolate_property($Sprites/Lilypad, "modulate:v", $Sprites/Lilypad.modulate.v, 0, time_v, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()
	if randf() < powerup_prob:
		var Powerup_Container = get_node_or_null("/root/Game/Powerup_Container")
		if Powerup_Container != null:
			var Powerup = load("res://Powerups/Powerup.tscn")
			var powerup = Powerup.instance()
			powerup.position = position
			Powerup_Container.call_deferred("add_child", powerup)
	var brick_audio = get_node_or_null("/root/Game/Brick_Audio")
	if brick_audio != null:
		brick_audio.play()
