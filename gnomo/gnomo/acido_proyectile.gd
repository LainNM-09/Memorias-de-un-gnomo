extends Area2D

@export var velocidad: float = 700

var direction: Vector2 = Vector2.RIGHT  # Valor por defecto que podría ser el problema
var velocity: Vector2 = Vector2.ZERO

func set_direction(new_direction: Vector2):
	direction = new_direction.normalized()
	velocity = direction * velocidad
	rotation = direction.angle()  # Opcional: gira el sprite

func _physics_process(delta):
	position += velocity * delta

func _on_body_entered(body):
	if body.is_in_group("player"):
		if body.has_method("daño"):
			body.daño()
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
	
