extends Area2D
@onready var sprite = $AnimatedSprite2D
@onready var timer = $Timer

var speed = 600
var damage = 20
var direction = Vector2.RIGHT  # Dirección normalizada (debe ser configurada al crear la bola)
var lifetime = 2.0

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
	
	explode()  # Lógica de explosión direccional

func explode():
	speed = 0  # Detener el movimiento
	set_deferred("monitoring", false)  # Opcional: Desactiva detección de colisiones
	
	# Ajustar flip según dirección
	#sprite.flip_h = direction.x < 0  # Si va hacia la izquierda, voltear horizontalmente
	#sprite.flip_v = direction.y > 0  # Si va hacia abajo, voltear verticalmente
	sprite.rotation = direction.angle()  # Opcional: Rota el sprite completamente
	
	sprite.play("final")  # Reproducir la misma animación para todas direcciones
	await sprite.animation_finished
	queue_free()

func _on_timer_timeout():
	queue_free()  # Por si no choca con nada
