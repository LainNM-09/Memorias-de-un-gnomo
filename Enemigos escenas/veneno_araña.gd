extends Area2D

@export var velocidad_inicial: float = 150
@export var aceleracion: float = 300  # Cuánto acelera por segundo
@export var velocidad_maxima: float = 600  # Velocidad límite
@export var crecimiento_por_segundo: float = 1.5
@export var escala_maxima: float = 4.0

var direction: Vector2 = Vector2.RIGHT
var velocity: Vector2 = Vector2.ZERO
var tiempo_vida: float = 0.0
var velocidad_actual: float = 0.0

func set_direction(new_direction: Vector2):
	direction = new_direction.normalized()
	velocidad_actual = velocidad_inicial
	velocity = direction * velocidad_actual
	rotation = direction.angle()

func _physics_process(delta):
	# Aumentar velocidad con el tiempo
	tiempo_vida += delta
	velocidad_actual = min(velocidad_actual + aceleracion * delta, velocidad_maxima)
	velocity = direction * velocidad_actual
	
	position += velocity * delta
	
	# Aumentar el tamaño con el tiempo
	var nueva_escala = 1.0 + (crecimiento_por_segundo * tiempo_vida)
	nueva_escala = min(nueva_escala, escala_maxima)
	scale = Vector2(nueva_escala, nueva_escala)


func _on_body_entered(body):
	if body.is_in_group("player"):
		if body.has_method("daño"):
			body.daño()
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
