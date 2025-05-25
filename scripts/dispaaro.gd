extends Area2D

var speed = 500
var direction = Vector2.RIGHT

func _physics_process(delta):
	position += direction * speed * delta


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


func _on_body_entered(body: Node2D):
	if body.is_in_group("enemigos"):
		body.daño()
	queue_free()
