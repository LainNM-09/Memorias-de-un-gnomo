extends Area2D

@export var max_lifetime: float = 3.0
var body = null
@onready var time = $Timer
func _ready():
	time.wait_time = max_lifetime
	time.start()

func _on_timer_timeout() -> void:
	queue_free() # Replace with function body.


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.vidaactual < body.vidamaxima:
			body.gain_life()
			queue_free()
