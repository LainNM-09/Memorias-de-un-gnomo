extends CharacterBody2D

@export var speed: float = 100
@export var patrol_distance: float = 100

@onready var sprite = $AnimatedSprite2D
var vidaactual: int 
var original_position: Vector2
var moving_up: bool = true
var invensibilidad : bool
func _ready():
	original_position = global_position

func _physics_process(_delta):
	# Movimiento vertical
	if moving_up:
		velocity.y = -speed
		if global_position.y <= original_position.y - patrol_distance:
			moving_up = false
	else:
		velocity.y = speed
		if global_position.y >= original_position.y + patrol_distance:
			moving_up = true
	
	sprite.play("walk")
	move_and_slide()
	
func superinvensibilidad():
	invensibilidad = true
	sprite.modulate.a = 0.5
	await get_tree().create_timer(0.5).timeout
	invensibilidad = false
	sprite.modulate.a = 1

func recibir_daño(cantidad: int):
	if invensibilidad:
		return
		
	if vidaactual > 0:
		vidaactual -= cantidad 

		superinvensibilidad()
		if vidaactual <= 0:
			queue_free()
# Daño al jugador
func _on_area_2d_body_entered(body: Node2D):
	if body.is_in_group("player"):
		body.daño()
