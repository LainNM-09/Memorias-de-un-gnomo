extends Node2D

# Configuración exportable
@export var kamikaze_scene: PackedScene
@export var spawn_radius: float = 50.0
@export var max_spawned_enemies: int = 3
@export var spawn_cooldown: float = 5.0
@export var detection_radius: float = 300.0
@export var vida :int = 70 
@export var HeartScene: PackedScene

@onready var detection_area = $DetectionArea
@onready var spawn_timer = $SpawnTimer

var player_in_range: bool = false
var current_spawned_enemies: int = 0

func _ready():
	# Configurar el área de detección
	var collision_shape = CircleShape2D.new()
	collision_shape.radius = detection_radius
	detection_area.get_node("CollisionShape2D").shape = collision_shape
	
	# Configurar el timer
	spawn_timer.wait_time = spawn_cooldown

func _process(_delta):
	if player_in_range && current_spawned_enemies < max_spawned_enemies && spawn_timer.is_stopped():
		spawn_kamikaze()
		spawn_timer.start()

func spawn_kamikaze():
	if kamikaze_scene == null:
		push_error("Kamikaze scene not assigned in nest!")
		return
	
	var kamikaze = kamikaze_scene.instantiate()
	
	# Calcular posición aleatoria alrededor del nido
	var spawn_pos = global_position + Vector2.RIGHT.rotated(randf_range(0, TAU)) * spawn_radius
	
	# Configurar el kamikaze
	kamikaze.global_position = spawn_pos
	kamikaze.connect("tree_exited", _on_kamikaze_destroyed)
	
	get_parent().add_child(kamikaze)
	current_spawned_enemies += 1

func _on_kamikaze_destroyed():
	current_spawned_enemies -= 1

func _on_detection_area_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true

func _on_detection_area_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false

func _on_spawn_timer_timeout():
	spawn_timer.stop()

func recibir_daño(cantidad: int):
	vida -= cantidad
	if vida <= 0:
		die()
func die():
	if HeartScene:
		var heart_instance = HeartScene.instantiate()
		get_tree().current_scene.add_child(heart_instance)
		heart_instance.global_position = global_position
	queue_free()
