extends Node2D

const BULLET = preload("res://scenes/bullet.tscn")

func shoot_left():
	$enemy_left/AnimatedSprite2D.play('default')
	await get_tree().create_timer(1).timeout
	var bullet = BULLET.instantiate()
	bullet.side = "left"
	bullet.position = $bullet_spawner/Marker2D_Left.global_position
	bullet.z_index = 0
	add_child(bullet)

func shoot_right():
	$enemy_right/AnimatedSprite2D.play('default')
	await get_tree().create_timer(1).timeout
	var bullet = BULLET.instantiate()
	bullet.side = "right"
	bullet.position = $bullet_spawner/Marker2D_Right.global_position
	bullet.z_index = 0
	add_child(bullet)

func _process(delta):
	if Input.is_action_just_pressed("ui_select"):
		shoot_right()
		



