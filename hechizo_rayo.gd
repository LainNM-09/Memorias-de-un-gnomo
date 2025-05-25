extends Area2D

@onready var sprite = $AnimatedSprite2D
@onready var timer = $Timer

var speed = 1200
var direction = Vector2.RIGHT
var lifetime = 2.0
var damage = 15
func _ready():
	timer.start(lifetime)
	sprite.play("default")
	# Opcional: Rotar el sprite según la dirección (si usas un sprite que apunta a la derecha por defecto)
	rotation = direction.angle()

func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	if body.is_in_group("enemigos"):
		body.recibir_daño(damage)
	queue_free()

func _on_timer_timeout():
	queue_free()  # Por si no choca con nada
