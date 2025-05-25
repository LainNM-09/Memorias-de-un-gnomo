extends CharacterBody2D

@export var speed := 60
var direction := Vector2.UP

@onready var wall_detector := $wallDetector
@onready var sprite := $Sprite2D

func _ready():
	randomize()

func _physics_process(_delta):
	velocity = direction * speed
	move_and_slide()

	if wall_detector.is_colliding():
		# Elegir una nueva dirección aleatoria (izquierda, derecha, arriba, abajo)
		var directions = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
		directions.erase(direction)  # evita repetir la misma dirección inmediatamente
		direction = directions.pick_random()

		update_sprite_flip()
		flip_raycast()

func update_sprite_flip():
	# Solo reflejamos horizontalmente si hay movimiento en X
	sprite.flip_h = direction.x > 0

func flip_raycast():
	# Cambia la dirección del raycast a la nueva dirección
	wall_detector.target_position = direction.normalized() * wall_detector.target_position.length()
	wall_detector.force_raycast_update()
