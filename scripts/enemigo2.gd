extends CharacterBody2D

@export var speed: float = 100
@export var patrol_distance: float = 100
@export var vidamaxima: int = 2
@onready var sprite = $AnimatedSprite2D
var vidaactual : int
var original_position: Vector2
var moving_up: bool = true

func _ready():
	original_position = global_position
	vidaactual = vidamaxima
func _physics_process(delta):
	# Movimiento vertical
	if moving_up:
		velocity.y = -speed
		if global_position.y <= original_position.y - patrol_distance:
			moving_up = false
	else:
		velocity.y = speed
		if global_position.y >= original_position.y + patrol_distance:
			moving_up = true
	
	sprite.play("caminar")
	move_and_slide()
	
func daño():
	if vidaactual > 0:
		vidaactual -= 1 
		sprite.modulate.a = 0.5
		await 0.5
		sprite.modulate.a = 1
		if vidaactual <= 0:
			queue_free()
# Daño al jugador
func _on_area_2d_body_entered(body: Node2D):
	if body.is_in_group("player"):
		body.daño()
