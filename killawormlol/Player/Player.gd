extends KinematicBody2D

# Notes:
# Delta is time between frames? makes stuff smoother.
# 100 pixels per second, 100 * delta
# Yield allows pause of a function and resumes it later
# Condition met or specific amount of time passes ---> execute code

# Constants for player movement and behavior
export var ACCELERATION = 500
export var MAX_SPEED = 80
export var FRICTION = 500
export var ROLL_SPEED = 125

# Player state enum
enum {
	MOVE,
	ROLL,
	ATTACK,
}

# Player state variables
var state = MOVE
var velocity = Vector2.ZERO
var roll_vector = Vector2.LEFT
var stats = PlayerStats

# action queue to store player actions
var action_queue = []

# Other nodes and components
onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var hurtbox = $Hurtbox

func _ready():
	# Connect to the "no_health" signal of PlayerStats to trigger respawn
	stats.connect("no_health", self, "respawn_player")
	animationTree.active = true
	# Start processing the action queue
	process_queue()

func _physics_process(delta):
	# Handle player behavior based on current state
	match state:
		MOVE:
			move_state(delta)
		ROLL:
			roll_state(delta)
		ATTACK:
			attack_state(delta)

	# Check for additional input to add new actions to the queue
	if Input.is_action_just_pressed("ui_right"):
		action_queue.append(Vector2(1, 0))
	elif Input.is_action_just_pressed("ui_down"):
		action_queue.append(Vector2(0, 1))
	elif Input.is_action_just_pressed("ui_left"):
		action_queue.append(Vector2(-1, 0))
	elif Input.is_action_just_pressed("ui_up"):
		action_queue.append(Vector2(0, -1))

	# Esnure continuous processing of the queue
	if action_queue.size() > 0 and !is_processing_queue():
		process_queue()
# Pops front action from queue and sets the velocity
func process_queue():
	if action_queue.size() > 0:
		var action = action_queue.pop_front()
		# Turn action to velocity and execute it
		velocity = action * MAX_SPEED
		move_and_slide(velocity)
		# Schedule the next action to be processed after a delay
		yield(get_tree().create_timer(0.5), "timeout")
		process_queue()
	else:
		velocity = Vector2.ZERO
		print("No more actions in the queue")

func is_processing_queue():
	return get_tree().is_connected("idle_frame", self, "process_queue")

# Handle player movement state
func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()

	# Set animation blend position based on input vector
	if input_vector != Vector2.ZERO:
		roll_vector = input_vector
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Run/blend_position", input_vector)
		animationTree.set("parameters/Attack/blend_position", input_vector)
		animationTree.set("parameters/Roll/blend_position", input_vector)
		animationState.travel("Run")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	move()

	if Input.is_action_just_pressed("roll"):
		state = ROLL

	if Input.is_action_just_pressed("attack"):
		state = ATTACK

# Handle player roll state
func roll_state(delta):
	velocity = roll_vector * ROLL_SPEED
	animationState.travel("Roll")
	move()

# Handle player attack state
func attack_state(delta):
	velocity = Vector2.ZERO
	animationState.travel("Attack")

# Perform player movement with collision detection
func move():
	velocity = move_and_slide(velocity)

# Handle roll animation finished event
func roll_animation_finished():
	velocity = velocity / 2
	state = MOVE

# Handle attack animation finished event
func attack_animation_finished():
	state = MOVE

# Handle player taking damage when hurtbox area is entered
func _on_Hurtbox_area_entered(area):
	stats.health -= 1
	hurtbox.start_invincibility(0.5)
	hurtbox.create_hit_effect()

	# Check if player's health has reached zero (player dies)
	if stats.health <= 0:
		respawn_player()

# Respawn the player (reset position and other parameters)
func respawn_player():
	# Reset player position to a respawn point
	position = Vector2(100, 100)
	stats.health = stats.max_health  # Reset health to max
	velocity = Vector2.ZERO
	state = MOVE
	action_queue.clear()  # Clear the action queue upon respawn
