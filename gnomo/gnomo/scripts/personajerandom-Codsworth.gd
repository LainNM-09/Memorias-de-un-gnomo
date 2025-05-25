extends CharacterBody2D

"Las variables"

@onready var sprite = $animaated 
@onready var cuerpo = $Area2D

const SPEED = 150
#MUCHACHO
#MUCHACHO
#MUCHACHO
#MUCHACHO
#MUCHACHO
#MUCHACHO
#MUCHACHO
#MUCHACHO
#MUCHACHO
#MUCHACHO
#MUCHACHO
#MUCHACHO
func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("izquierda", "derecha")
	if direction: 
		velocity.x = direction * SPEED
		sprite.play("caminar")
		sprite.flip_h = direction <0 
	else: 
		velocity.x = move_toward(velocity.x, 0, SPEED )	
		sprite.play("quieto")
		
	move_and_slide()
