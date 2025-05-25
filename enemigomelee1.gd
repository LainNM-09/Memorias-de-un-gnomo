extends CharacterBody2D

@export var velocidad: float = 150
@export var vida: int = 100
@export var rango_vision: float = 200
@export var rango_ataque: float = 60
@export var distancia_patrulla: float = 150
@export var intervalo_ataque: float = 0.5  # Tiempo entre ataques en segundos
@export var HeartScene: PackedScene

@onready var sprite = $AnimatedSprite2D
@onready var area_vision = $Area2D_vision
@onready var area_ataque = $Area2D_ataque
@onready var timer_ataque = $TimerAtaque
@onready var colision_ataque = $Area2D_ataque/CollisionShape2D

var jugador: Node2D = null
var posicion_inicial: Vector2
var patrullando: bool = true
var moviendo_derecha: bool = true
var jugador_en_area_ataque: bool = false
var puede_atacar: bool = true

func _ready():
	posicion_inicial = global_position
	
	# Configurar áreas de colisión
	if area_vision.get_child_count() > 0 and area_vision.get_child(0) is CollisionShape2D:
		var forma_vision = area_vision.get_child(0).shape
		if forma_vision is CircleShape2D:
			forma_vision.radius = rango_vision
	
	if area_ataque.get_child_count() > 0 and area_ataque.get_child(0) is CollisionShape2D:
		var forma_ataque = area_ataque.get_child(0).shape
		if forma_ataque is CircleShape2D:
			forma_ataque.radius = rango_ataque

	# Conectar señales
	area_vision.body_entered.connect(_on_jugador_detectado)
	area_vision.body_exited.connect(_on_jugador_perdido)
	area_ataque.body_entered.connect(_on_area_ataque_body_entered)
	area_ataque.body_exited.connect(_on_area_ataque_body_exited)
	timer_ataque.timeout.connect(_on_timer_ataque_timeout)

func _physics_process(_delta):
	if jugador and is_instance_valid(jugador):
		var distancia = global_position.distance_to(jugador.global_position)
		
		if distancia <= rango_ataque:
			velocity = Vector2.ZERO
			if puede_atacar and jugador_en_area_ataque:
				_atacar()
			sprite.play("atacar")
		else:
			# Perseguir al jugador
			var direccion = (jugador.global_position - global_position).normalized()
			velocity = direccion * velocidad
			sprite.play("caminar")
			sprite.flip_h = direccion.x < 0
	else:
		# Patrullaje
		if patrullando:
			if moviendo_derecha:
				velocity.x = velocidad
				if global_position.x >= posicion_inicial.x + distancia_patrulla:
					moviendo_derecha = false
			else:
				velocity.x = -velocidad
				if global_position.x <= posicion_inicial.x - distancia_patrulla:
					moviendo_derecha = true
			sprite.play("caminar")
			sprite.flip_h = not moviendo_derecha
	
	move_and_slide()

func _atacar():
	if jugador and jugador.has_method("daño"):
		jugador.daño()
		puede_atacar = false
		timer_ataque.start(intervalo_ataque)

func _on_jugador_detectado(body: Node2D):
	if body.is_in_group("player"):
		jugador = body
		patrullando = false

func _on_jugador_perdido(body: Node2D):
	if body == jugador:
		jugador = null
		patrullando = true
		jugador_en_area_ataque = false

func _on_area_ataque_body_entered(body: Node2D):
	if body.is_in_group("player"):
		jugador_en_area_ataque = true
		if puede_atacar:
			_atacar()

func _on_area_ataque_body_exited(body: Node2D):
	if body.is_in_group("player"):
		jugador_en_area_ataque = false

func _on_timer_ataque_timeout():
	puede_atacar = true
	if jugador_en_area_ataque:
		_atacar()

func recibir_daño(cantidad: int):
	vida -= cantidad
	if vida <= 0:
		die()
		# Aquí podrías añadir efectos de muerte o sonidos
	
func die():
	if HeartScene:
		var heart_instance = HeartScene.instantiate()
		get_tree().current_scene.add_child(heart_instance)
		heart_instance.global_position = global_position
	queue_free()
