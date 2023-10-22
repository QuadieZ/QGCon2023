extends Area2D

var rng = RandomNumberGenerator.new()
var side = null
var color = null
const x_sides = ["right","left"]
const y_sides = ["up","down"]
var x;
var y;

var hit = false
var score = 0
var miss = false
var t = 0.0
var player_position;

func _on_ready():
	Global.total_bullet += 1
	if color == "black": Global.total_bullet_black += 1
	else: Global.total_bullet_white += 1
	
	player_position = get_parent().get_node("player").position
	$AnimatedSprite2D.play("black_beat" if color == "black" else "white_beat")
	x = rng.randf_range(100,300)
	y = rng.randf_range(0, 544)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	t += delta * (0.08 if x_sides.has(side) else 0.02)
	if (miss): $AnimatedSprite2D.play("miss")
	else:
		if (!hit): position = position.lerp(player_position, t)
		else: 
			$Score_Label.text = str(score)
			$Score_Label.visible = true
			$AnimatedSprite2D.play("destroyed")

func _on_animated_sprite_2d_animation_finished():
	if $AnimatedSprite2D.animation == "destroyed" or $AnimatedSprite2D.animation == "miss" :
		queue_free()
	if $AnimatedSprite2D.animation == "destroyed":
		Global.score += score
		Global.total_bullet_hit += 1
		if color == "black": Global.total_bullet_hit_black += 1
		else: Global.total_bullet_hit_white += 1
