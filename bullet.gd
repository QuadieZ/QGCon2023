extends Area2D

var rng = RandomNumberGenerator.new()
var side = null
var y;

var hit = false
var t = 0.0
var player_position;

func _on_ready():
	player_position = get_parent().get_node("player").position
	y = rng.randf_range(0, 544)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	t += delta * 0.1
	if (!hit): position = position.lerp(player_position, t)
	else: 
		position = position.lerp(Vector2(-100 if side == "left" else 1000, y),t/2)
	
func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
