extends CharacterBody2D

# Variables
@export var speed : float = 300.0  # Mayor velocidad para el kamikaze
@onready var sprite = $AnimatedSprite2D
@onready var vision_area = $VisionArea
@onready var explosion_timer = $ExplosionTimer
@onready var explosion_area = $ExplosionArea
@onready var collision_shape = $CollisionShape2D
@export var vida : int = 15

var moving_right: bool = true
var player_detected: bool = false
var player_ref: Node2D = null
var is_exploding: bool = false

func _physics_process(_delta) -> void:
	if is_exploding:
		return  # No hacer nada mientras explota
		
	if player_detected and player_ref:
		chase_player()
		
	else: 
		sprite.play("quieto")
	# Animación
	if not is_exploding:
		sprite.play("caminar")
	move_and_slide()
	
func chase_player():
	var direction = (player_ref.global_position - global_position).normalized()
	velocity = direction * speed
	sprite.flip_h = direction.x < 0
	vision_area.rotation = direction.angle()

func explode():
	if is_exploding:
		return
		
	is_exploding = true
	velocity = Vector2.ZERO
	
	# Cambiar a la animación de explosión
	sprite.play("ExplosionArea")  # Asegúrate de tener esta animación definida
	
	# Configurar el Tween para escalar el sprite
	var tween = create_tween()
	tween.set_parallel(true)  # Para animar múltiples propiedades simultáneamente
	
	# Escalar de 1 a 3 veces el tamaño original en 0.3 segundos
	tween.tween_property(sprite, "scale", Vector2(8, 8), 0.2).from(Vector2(1, 1))
	
	# Opcional: hacer que el sprite se desvanezca
	tween.tween_property(sprite, "modulate:a", 0.0, 0.6).from(1.0)
	

	
	# Lógica de daño y eliminación
	var bodies = explosion_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("player"):
			body.daño()
		# Esperar a que termine la animación
	await tween.finished
	queue_free()

func _on_vision_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_detected = true
		player_ref = body

func _on_vision_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_detected = false
		player_ref = null

func _on_explosion_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not is_exploding:
		explode()  # Explotar al hacer contacto con el jugador

func recibir_daño(cantidad: int):
	vida -= cantidad
	if vida <= 0:
		queue_free()
