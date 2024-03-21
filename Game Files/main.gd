extends Node

@export var snake_scene : PackedScene

var flag : bool = false

var score :int 
var game_started : bool = false

var cells : int = 20
var cell_size : int = 50

var food_pos : Vector2
var regen_food : bool = true

var old_data : Array
var snake_data : Array
var snake : Array

var start_pos = Vector2(9,9)
var up = Vector2(0,-1)
var down = Vector2(0,1)
var left = Vector2(-1,0)
var right = Vector2(1,0)
var move_direction: Vector2
var can_move : bool =false

# Called when the node enters the scene tree for the first time.
func _ready():
		new_game()
func new_game():
	get_tree().paused=false
	get_tree().call_group("segments","queue_free")
	$GameOverMenu.hide()
	score =0 
	$hud.get_node("ScoreLabel").text="SCORE : "+str(score)
	move_direction=up
	can_move = true
	generate_snake()
	move_food()
func generate_snake():
	old_data.clear()
	snake_data.clear()
	snake.clear()
	
	for i in range(3):
		add_segment(start_pos+Vector2(0,i))
func add_segment(pos):
	snake_data.append(pos)
	var SnakeSegment = snake_scene.instantiate()
	SnakeSegment.position = (pos * cell_size) + Vector2(0, cell_size)
	add_child(SnakeSegment)
	snake.append(SnakeSegment)

	# Calculate opacity based on segment index
	var opacity_step = 1.0 / len(snake)
	var opacity = 1.0

# Loop through all segments to set opacity
	for i in range(len(snake)):
		snake[i].modulate = Color(1, 1, 1, opacity)
		opacity -= opacity_step
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	move_snake()
	
func move_snake():
	if can_move:
		if Input.is_action_just_pressed("move_down") and move_direction != up:
			move_direction=down
			can_move=false
		if Input.is_action_just_pressed("move_up") and move_direction != down:
			move_direction=up
			can_move=false
		if Input.is_action_just_pressed("move_left") and move_direction != right:
			move_direction=left
			can_move=false
		if Input.is_action_just_pressed("move_right") and move_direction != left:
			move_direction=right
			can_move=false
		if not game_started:
			start_game()

func start_game():
	game_started = true
	$MoveTimer.start()


func _on_move_timer_timeout():
	can_move = true
	old_data = [] + snake_data
	snake_data[0] += move_direction

	# Wraparound logic
	if snake_data[0].x < 0:
		snake_data[0].x = cells - 1
	elif snake_data[0].x >= cells:
		snake_data[0].x = 0
	elif snake_data[0].y < 0:
		snake_data[0].y = cells - 1
	elif snake_data[0].y >= cells:
		snake_data[0].y = 0  

	# Update snake segments positions
	for i in range(len(snake_data)):
		if i > 0:
			snake_data[i] = old_data[i - 1]
		snake[i].position = (snake_data[i] * cell_size) + Vector2(0, cell_size)

	self_eaten()
	food_eaten()


func food_eaten():
	if snake_data[0]==food_pos:
		score+=1
		$hud.get_node("ScoreLabel").text = "SCORE : "+str(score)
		add_segment(old_data[-1])
		regen_food=true
		move_food()

#func out_of_bounds():
	#if snake_data[0].x<0 or snake_data[0].x>cells or snake_data[0].y<0 or snake_data[0].y >cells -1 :
		#end_game()
func self_eaten():
	for i in range (1,len(snake_data)):
		if(snake_data[0]==snake_data[i]):
			end_game()

func move_food():
	while regen_food:
		regen_food = false
		food_pos = Vector2(randi_range(0, cells - 1), randi_range(0, cells - 1))
		
		# Check if food position collides with any segment of the snake
		var collision = false
		for i in snake_data:
			if food_pos == i:
				collision = true
				break
		
		# If collision detected, regenerate food position
		if collision:
			regen_food = true
		else:
			$Food.position = (food_pos * cell_size) + Vector2(0, cell_size)

func end_game():
	$GameOverMenu.show()
	$MoveTimer.stop()
	game_started= false
	get_tree().paused = true



func _on_game_over_menu_restart():
	new_game()
