class_name Fish
extends ItemPickup

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var float_component: FloatComponent = $FloatComponent

@export var should_flip: bool = false
@onready var sprite_2d: Sprite2D = $Sprite2D
@export var max_dist_from_origin_sqr: float = 100*100
@export var min_angle_turn_toward_origin_degrees: float = 20
@export var max_angle_turn_toward_origin_degrees: float = 40
var origin_global_pos: Vector2

func _ready():
	enter_idle()
	origin_global_pos = global_position

var target_rotation: float = 0
var actual_rotation: float = 0

func handle_water_changed(new_value: bool):
	float_component.set_in_water(new_value)
	gravity_scale = 0 if new_value else 1.0
	
func enter_idle():
	current_state = FishState.IDLE
	state_count = randf_range(min_idle_time, max_idle_time)
	animation_player.play("idle")
	linear_velocity *= .3
	linear_damp = 1.0

func enter_wind_up():
	current_state = FishState.WIND_UP
	state_count = wind_up_time
	if global_position.distance_squared_to(origin_global_pos) < max_dist_from_origin_sqr:
		target_rotation = randf_range(0,TAU)
	else:
		target_rotation = rotate_toward(target_rotation, global_position.angle_to_point(origin_global_pos), randf_range(deg_to_rad(min_angle_turn_toward_origin_degrees), deg_to_rad(max_angle_turn_toward_origin_degrees)))
	animation_player.play("wind_up")
	
func enter_thrust():
	linear_damp = 0.0
	current_state = FishState.THRUST
	state_count = thrust_anim_time
	apply_impulse(Vector2.from_angle(actual_rotation) * thrust_vel)
	animation_player.play("zoom")
	
	
		

var state_count: float = 0
@export var min_idle_time: float = 3.0
@export var max_idle_time: float = 6.0
@export var thrust_vel: float = 10
@export var wind_up_time: float = .3
@export_range(0.0,1.0) var turn_speed: float = .3
@export var thrust_anim_time: float = .3

enum FishState {
	IDLE, WIND_UP, THRUST
}

var current_state: FishState = FishState.IDLE

func _physics_process(delta: float) -> void:
	if not in_water or not is_spawned_currently:
		return
		
	match(current_state):
		FishState.IDLE:
			state_count -= delta
			if state_count <= 0:
				enter_wind_up()
			return
		FishState.WIND_UP:
			actual_rotation = lerp_angle(actual_rotation, target_rotation, turn_speed)
			if not should_flip:
				rotation = actual_rotation
			else:
				var currently_flipped = sprite_2d.scale.x == -1
				var dot_value = Vector2.RIGHT.dot(Vector2.from_angle(actual_rotation))
				var is_flipped = dot_value > 0.1 if not currently_flipped else dot_value > -.1
				sprite_2d.rotation = actual_rotation if is_flipped else actual_rotation + PI
				sprite_2d.scale.x = -1 if is_flipped else 1
			state_count -= delta
			if state_count <= 0:
				enter_thrust()
			return
		FishState.THRUST:
			state_count -= delta
			if state_count <= 0:
				enter_idle()
		
