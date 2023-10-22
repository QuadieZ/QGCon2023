extends Node2D

@onready var unicorn_position = {
	1: $unicorn_bottom_left,
	2: $unicorn_bottom_right,
	3: $unicorn_top_left,
	4: $unicorn_top_right
}

@onready var unicorn_animation = {
	1: $unicorn_bottom_left/AnimatedSprite2D,
	2: $unicorn_bottom_right/AnimatedSprite2D,
	3: $unicorn_top_left/AnimatedSprite2D,
	4: $unicorn_top_right/AnimatedSprite2D
}

const BULLET = preload("res://scenes/bullet.tscn")
var rng = RandomNumberGenerator.new()
@onready var enemy_right = $enemy_right/AnimatedSprite2D
@onready var enemy_left = $enemy_left
var gameStart = false

func wait(time=0.3):
	await get_tree().create_timer(time).timeout
	
func shoot_left(n=1, wait_time=0.3, color="white"):
	$enemy_left/AnimatedSprite2D.play('shoot_start')
	await wait()
	for i in range(n):
		var bullet = BULLET.instantiate()
		bullet.side = "left"
		bullet.position = $bullet_spawner/Marker2D_Left.global_position
		bullet.z_index = 0
		bullet.color = color
		add_child(bullet)
		await wait(wait_time)
	$enemy_left/AnimatedSprite2D.play('shoot_end')

func shoot_right(n=1, wait_time=0.3,color="white"):
	$enemy_right/AnimatedSprite2D.play('shoot_start')
	await wait()
	for i in range(n):
		var bullet = BULLET.instantiate()
		bullet.side = "right"
		bullet.position = $bullet_spawner/Marker2D_Right.global_position
		bullet.z_index = 0
		bullet.color = color
		add_child(bullet)
		await wait(wait_time)
	$enemy_right/AnimatedSprite2D.play('shoot_end')

func shoot_up(lower_bound, upper_bound,n=1,wait_time=0.3,color="white"):
	for i in range(n):
		var bullet = BULLET.instantiate()
		bullet.side = "up"
		bullet.color = color
		bullet.position = Vector2(rng.randf_range(lower_bound,upper_bound),0)
		add_child(bullet)
		await wait(wait_time)

func shoot_down(lower_bound, upper_bound, n=1, wait_time=0.3,color="white"):
	for i in range(n):
		var bullet = BULLET.instantiate()
		bullet.side = "down"
		bullet.color = color
		bullet.position = Vector2(rng.randf_range(lower_bound,upper_bound),544)
		add_child(bullet)
		await wait(wait_time)

func shoot_up_lock(position, wait_time=0.2,color="white"):
	shoot_up(position, position,1,0.3,color)
	await wait(wait_time)

func shoot_down_lock(position, wait_time=0.2,color="white"):
	shoot_down(position,position,1,0.3,color)
	await wait(wait_time)
	
func pattern_l2_r3(wait_time=0.5):
	shoot_left(2,0.3,"black")
	await wait(wait_time)
	shoot_right(3, 0.2)
	await wait(1 + wait_time)
	
func pattern_double(color="white"):
	shoot_left(1,0.3,color)
	shoot_right(1,0.3,"black" if color == "white" else "white")
	await wait(0.6)
	
func pattern_wave_top_lr(color="white"):
	var i = 100
	while i < 800:
		await shoot_up_lock(i,0.2,color)
		i += 120

func pattern_wave_top_rl(color="white"):
	var i = 800
	while i > 100:
		await shoot_up_lock(i,0.2,color)
		i -= 120
	
func pattern_wave_bottom_lr(color="white"):
	var i = 100
	while i < 800:
		await shoot_down_lock(i,0.2,color)
		i += 120

func pattern_wave_bottom_rl(color="white"):
	var i = 800
	while i > 100:
		await shoot_down_lock(i,0.2,color)
		i -= 120

func pattern_wave_lr(color="white"):
	pattern_wave_top_lr(color)
	pattern_wave_bottom_rl("black" if color == "white" else "white")
	await wait(1)

func pattern_wave_rl(color="white"):
	pattern_wave_top_rl(color)
	pattern_wave_bottom_lr("black" if color == "white" else "white")
	await wait(1)

func pattern_swap(n,wait_time=0.3,color="white"):
	for i in range(n):
		shoot_left(1,0.3,color)
		await wait(wait_time)
		shoot_right(1,0.3,"black" if color == "white" else "white")
		await wait(wait_time)
	
func start_song():
	await wait(0.5)
	$AudioStreamPlayer2D.play()

func spawn_unicorn():
	var index = rng.randi_range(1,4)
	var color = "white" if index == 2 or index == 4 else "black"
	var unicorn = unicorn_position[index]
	unicorn.visible = true
	unicorn_animation[index].play("unicorn")
	await wait(1)
	for i in range(5):
		var bullet = BULLET.instantiate()
		bullet.side = "left"
		bullet.color = color
		bullet.position = unicorn.global_position
		bullet.z_index = 0
		add_child(bullet)
		await wait(0.2)
	unicorn.visible = false
	unicorn_animation[index].frame = 0 
	
func _process(delta):
	if gameStart:
		$song_bar.set_size(Vector2($AudioStreamPlayer2D.get_playback_position()/$AudioStreamPlayer2D.stream.get_length() * 960,10))
		
	if Input.is_action_just_pressed("ui_select") and !gameStart:	
		gameStart = true
		$Label.visible = false
		$Score.visible = false
		
		start_song()
		$player/Sprite2D.rotation_degrees = -30
		
		# 15 secs
		await pattern_l2_r3()
		await shoot_left(2, 0.3,"black")
		await shoot_right(2, 0.3)
		await pattern_l2_r3(0.7)
		await wait(1)
		await pattern_l2_r3()
		await shoot_left(2, 0.3,"black")
		await shoot_right(2, 0.3)
		await pattern_l2_r3(0.7)
		await wait(1.5)
		
		# 29 sec
		await pattern_wave_top_lr("black")
		await wait(0.6)
		await pattern_wave_bottom_lr()
		await wait(0.6)
		await pattern_wave_lr("black")
		await wait(0.6)
		await pattern_wave_rl("black")
		await wait(0.8)
		await pattern_wave_top_rl()
		await wait(0.6)
		await pattern_wave_bottom_lr()
		await wait(0.6)
		await pattern_wave_top_lr("black")
		await wait(0.6)
		await pattern_wave_bottom_rl("black")
		await wait(1)
	
		await shoot_left(3, 0.3,"black")
		await shoot_right(3, 0.3)
		await shoot_up(600,800,3)
		await shoot_down(200,400,3,0.3,"black")
		await wait(0.5)
		await shoot_left(3, 0.3,"black")
		await shoot_right(3, 0.3)
		await shoot_up(200,400,3,0.3,"black")
		await shoot_down(600,800,3)
		await wait(0.5)
		await shoot_left(3, 0.3,"black")
		await shoot_right(3, 0.3)
		await shoot_up(600,800,3)
		await shoot_down(200,400,3,0.3,"black")
	
		# 58 sec
		await wait(1)
		await pattern_wave_top_lr("black")
		await wait(0.5)
		await pattern_wave_bottom_lr()
		await wait(0.5)
		await pattern_wave_bottom_rl()
		await wait(0.5)
		await pattern_wave_top_rl("black")
		await wait(0.8)
		await pattern_wave_lr("black")
		await wait(0.8)
		await pattern_wave_rl("black")
		await wait(0.8)
		await pattern_wave_lr("black")
		await wait(0.8)
		await pattern_wave_rl("black")
		
		
		# 1.14 sec
		await wait(0.7)
		await shoot_left(2,0.4,"black")
		await shoot_right(1,0.2)
		await shoot_left(1,0.2,"black")
		await shoot_right(1,0.2)
		
		await wait(1)
		await shoot_right(2,0.4)
		await shoot_left(1,0.2,"black")
		await shoot_right(1,0.2)
		await shoot_left(1,0.2,"black")
		
		await wait(1.2)
		await shoot_left(2,0.4,"black")
		await shoot_right(1,0.2)
		await shoot_left(1,0.2,"black")
		await shoot_right(1,0.1)
		await shoot_up_lock(100,0.2,"black")
		await shoot_up_lock(300,0.2,"black")
		await shoot_up_lock(500,0.2,"black")

		await wait(0.8)
		await shoot_right(2,0.3,"black")
		await shoot_left(1,0.2)
		await shoot_right(1,0.2,"black")
		await shoot_left(1,0.1)
		await shoot_down_lock(100)
		await shoot_down_lock(300)
		await shoot_down_lock(500)
		await wait(0.8)
		
		# 1.28 sec
		await pattern_wave_top_lr("black")
		await wait(0.5)
		await pattern_wave_bottom_lr()
		await wait(0.5)
		await pattern_wave_bottom_rl()
		await wait(0.5)
		await pattern_wave_top_rl("black")
		await wait(0.8)
		await pattern_wave_lr("black")
		await wait(0.8)
		await pattern_wave_rl("black")
		await wait(0.8)
		await pattern_wave_lr("black")
		await wait(0.8)
		await pattern_wave_rl("black")
		
		await wait(0.8)
		shoot_left(1,0.3,"black")
		await wait(0.3)
		shoot_right()
		await wait(0.3)
		shoot_left(1,0.3,"black")
		await wait(0.3)
		shoot_right()
		await wait(0.3)
		shoot_left(1,0.3,"black")
		await wait(0.3)
		shoot_right()
		await wait(0.3)
		shoot_left(1,0.3,"black")
		
		await wait(2)
		shoot_right(1,0.3,"black")
		await wait(0.3)
		shoot_left()
		await wait(0.3)
		shoot_right(1,0.3,"black")
		await wait(0.3)
		shoot_left()
		await wait(0.3)
		shoot_right(1,0.3,"black")
		await wait(0.3)
		shoot_left()
		await wait(0.3)
		shoot_right(1,0.3,"black")
		
		await wait(2)
		shoot_left(1,0.3,"black")
		await wait(0.3)
		shoot_right()
		await wait(0.3)
		shoot_left(1,0.3,"black")
		await wait(0.3)
		shoot_right()
		await wait(0.3)
		shoot_left(1,0.3,"black")
		await wait(0.3)
		shoot_right()
		await wait(0.3)
		shoot_left(1,0.3,"black")
		await wait(0.3)
		await pattern_wave_lr("black")
		
		await wait(0.7)
		shoot_right(1,0.3,"black")
		await wait(0.3)
		shoot_left()
		await wait(0.3)
		shoot_right(1,0.3,"black")
		await wait(0.3)
		shoot_left()
		await wait(0.3)
		shoot_right(1,0.3,"black")
		await wait(0.3)
		shoot_left()
		await wait(0.3)
		shoot_right(1,0.3,"black")
		await wait(0.3)
		await pattern_wave_rl("black")
		
		### ---- 1.42 ---- ## 
		
		await wait(1)
		await shoot_left(1,0.3,"black")
		await shoot_right()
		
		await wait(2.5)
		await shoot_left(1,0.3,"black")
		await shoot_right()
		
		await wait(2.5)
		await shoot_left(1,0.3,"black")
		await shoot_right()
		
		await wait(2.5)
		await shoot_left(1,0.3,"black")
		await shoot_right()
		
		await wait(1)
		await shoot_left(1,0.3,"black")
		await shoot_right()
		await shoot_left(1,0.3,"black")
		
		await wait(3.5)
		await shoot_left(1,0.3,"black")
		await shoot_right()
		
		await wait(2.5)
		await shoot_left(1,0.3,"black")
		await shoot_right()
		
		await wait(2.5)
		await shoot_left(1,0.3,"black")
		await shoot_right()
	
		await wait(1)
		await pattern_wave_top_lr("black")
		await wait(0.5)
		await pattern_wave_bottom_rl("black")
		await pattern_wave_bottom_lr("black")
		await pattern_wave_bottom_rl("black")
		await pattern_wave_top_rl()
		# $player/Sprite2D.rotation_degrees = 180
		
		await wait(0.3)
		await shoot_left(3)
		await shoot_right(3,0.3,"black")
		await pattern_wave_bottom_rl("black")
		await pattern_wave_top_rl()
		await wait(0.3)
		await shoot_left(3)
		await pattern_wave_bottom_lr()
		await wait(0.3)
		await shoot_right(3)
		await pattern_wave_top_rl()
		await wait(0.3)
		await pattern_wave_lr()
		await wait(0.1)
		await pattern_wave_rl()
		await wait(0.1)
		await pattern_wave_lr()
		await wait(0.1)
		await pattern_wave_rl()
		await wait(0.8)
		await shoot_left(3,0.3)
		await pattern_wave_bottom_lr()
		await wait(0.3)
		await shoot_right(3,0.3)
		### 2.41 ###
		
		await wait(1.5)
		await shoot_left(2,0.1,"black")
		await wait(0.3)
		await shoot_right(3,0.2)
		await pattern_swap(8,0.2,"black")
		await shoot_left(4,0.3,"black")
		await shoot_right(3)
		
		await wait(1)
		await shoot_up_lock(100,0.2,"black")
		await wait(0.3)
		await shoot_up_lock(300,0.2,"black")
		await wait(0.3)
		await shoot_up_lock(500,0.2,"black")
		await wait(0.3)
		await shoot_up_lock(700,0.2,"black")
		await wait(2)
		
		await shoot_down_lock(700,0.2,"black")
		await wait(0.3)
		await shoot_down_lock(500,0.2,"black")
		await wait(0.3)
		await shoot_down_lock(300,0.2,"black")
		await wait(0.3)
		await shoot_down_lock(100,0.2,"black")
		await wait(0.6)
		await pattern_wave_lr("black")
		await wait(0.6)
		await pattern_double()
		await pattern_double()
		await pattern_double()
		
		# $player/Sprite2D.rotation_degrees = 180
		
		## 2.58 ##
		await wait(0.8)
		await pattern_double()
		await shoot_up_lock(900,0.3,"black")
		await shoot_up_lock(800,0.3,"black")
		await shoot_up_lock(700,0.3,"black")
		await wait(0.2)
		await pattern_swap(3,0.2)
		await wait(0.8)
		await pattern_wave_lr()
	
		
		await wait(1.5)
		await spawn_unicorn()
		await spawn_unicorn()
		await pattern_wave_lr("black")
		await wait(0.5)
		await pattern_wave_rl("black")
		await wait(0.3)
		await pattern_wave_lr("black")
		await wait(0.3)
		await pattern_wave_rl("black")
		await spawn_unicorn()
		await spawn_unicorn()
		
		## 3.20 ##
		await wait(0.3)
		await shoot_left(2, 0.3,"black")
		await wait(0.3)
		await pattern_swap(3,0.3,"black")
		await shoot_left(2, 0.3,"black")
		await shoot_right(2, 0.3)
		
		await pattern_wave_lr("black")
		await wait(0.5)
		await pattern_swap(2)
		await shoot_left(2, 0.3)
		await wait(0.3)
		await pattern_swap(6)
		
		await wait(1)
		await pattern_wave_lr()
		await wait(0.3)
		await pattern_swap(3,0.3,"black")
		await wait(0.3)
		
		await spawn_unicorn()
		await spawn_unicorn()
	
		## 3.40 ##
		
		await shoot_left(4,0.1,"black")
		await shoot_right(4,0.1)
		await shoot_left(4,0.1,"black")
		await wait(0.3)
		
		await pattern_wave_top_lr("black")
		await pattern_wave_top_rl("black")
		await pattern_wave_top_lr("black")
		
		await wait(0.3)
		
		await pattern_wave_bottom_lr()
		await pattern_wave_bottom_rl()
		await pattern_wave_bottom_lr()
		
		await wait(1)
		
		await shoot_left(2, 0.3,"black")
		await shoot_right(2, 0.3)
		await pattern_swap(2,0.3,"black")
		
		await pattern_wave_lr("black")
		await wait(0.5)
		await pattern_swap(3)
	

		## 3.58 ##
		await wait(1)
		await shoot_left()
		await shoot_right(1,0.3,"black")
		await pattern_swap(4)
		
		await wait(1)
		await pattern_wave_lr()
		await wait(0.3)
		await spawn_unicorn()
		await spawn_unicorn()
		
		await pattern_wave_rl()
		
		await wait(1)
		await shoot_left(1,0.2)
		await shoot_right(1,0.2,"black")
		await shoot_left(1,0.2)
		await shoot_right(1,0.2,"black")
		await shoot_left(1,0.2)
		await shoot_right(1,0.2,"black")
		await shoot_left(1,0.2)
		await shoot_right(1,0.2,"black")
		await shoot_left(1,0.2)
		await shoot_right(1,0.2,"black")
		await shoot_left(1,0.2)
		await shoot_right(1,0.2,"black")
		await shoot_left(1,0.2)
		await shoot_right(1,0.2,"black")
		await shoot_left(1,0.2)
		await shoot_right(1,0.2,"black")
		await shoot_left(1,0.2)
		await shoot_right(1,0.2,"black")
		await shoot_left(1,0.2)
		await shoot_right(1,0.2,"black")
		await shoot_left(1,0.2)
		await shoot_right(1,0.2,"black")
		await shoot_left(1,0.2)
		await shoot_right(1,0.2,"black")
		await shoot_left(1,0.2)
		await shoot_right(1,0.2,"black")
		await shoot_left(1,0.2)
		await shoot_right(1,0.2,"black")
		await shoot_left(1,0.2)
		await shoot_right(1,0.2,"black")
		await shoot_left(1,0.2)
		await shoot_right(1,0.2,"black")
		await shoot_left(1,0.2)
		await shoot_right(1,0.2,"black")
		await shoot_left(1,0.2)
		await shoot_right(1,0.2,"black")
		await shoot_left(1,0.2)
		await shoot_right(1,0.2,"black")
		await shoot_left(1,0.2)
		await shoot_right(1,0.2,"black")
		await shoot_left(1,0.2)
		await shoot_right(1,0.2,"black")
		await shoot_left(1,0.2)
		await shoot_right(1,0.2,"black")
				
		await wait(0.2)
		await pattern_wave_lr()
		await wait(0.8)
		await pattern_wave_lr("black")
		await wait(0.8)
		await pattern_wave_lr()
		await wait(0.8)
		await pattern_wave_lr("black")
		
		await wait(0.5)
		await pattern_double()
		
		gameStart = false
		$Score.text = "Score: %s\nHit(B/W/Total): %s/%s/%s of %s/%s/%s\nPress Spacebar to play again" \
			% [Global.score, Global.total_bullet_hit_black, Global.total_bullet_hit_white, Global.total_bullet_hit, Global.total_bullet_black, Global.total_bullet_white, Global.total_bullet]
		$Score.visible = true
		
		
