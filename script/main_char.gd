extends Node2D

@onready var _animated_sprite = $AnimatedSprite2D;
@onready var _wheel = $Sprite2D
var wheel;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_animated_sprite.play("default")
	
	if Input.is_action_pressed("ui_right"):
		_wheel.rotation_degrees += 0.5
		_animated_sprite.flip_h = false
	if Input.is_action_pressed("ui_left"):
		_wheel.rotation_degrees -= 0.5
		_animated_sprite.flip_h = true
	pass

func _on_reflector_black_area_entered(area):
	area.hit = true

func _on_reflector_white_area_entered(area):
	area.hit = true
		
func _on_area_2d_area_entered(area):
	Global.player_health -= 1
	print(Global.player_health)
	area.queue_free()
	pass # Replace with function body.
