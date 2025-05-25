extends CharacterBody2D

@export var velocidad: float = 200
@export var vida: int = 50
@export var rango_vision: float = 400
@export var rango_ataque: float = 250  # Rango para atacar a quemarropa
@export var cooldown_ataque: float = 0.75  # Tiempo entre ataques
@export var escena_proyectil: PackedScene  # Escena del proyectil a instanciar
@export var HeartScene: PackedScene

@onready var sprite = $AnimatedSprite2D
@onready var area_vision = $Area2D_vision
@onready var timer_ataque = $TimerAtaque
@onready var punto_disparo = $PuntoDisparo  # Nodo Marker2D para posición de disparo

var angulos_disparo = [-30, 0, 30]  # Ángulos más abiertos
var jugador: Node2D = null
var puede_atacar: bool = true
var jugador_detectado: bool = false
var ultima_direccion: Vector2 = Vector2.DOWN  # Para guardar la última dirección

func _ready():
	# Configurar el área de visión
	var forma_vision = $Area2D_vision/CollisionShape2D.shape
	if forma_vision is CircleShape2D:
		forma_vision.radius = rango_vision

	area_vision.body_entered.connect(_on_jugador_detectado)
	area_vision.body_exited.connect(_on_jugador_perdido)
	timer_ataque.timeout.connect(_on_TimerAtaque_timeout)
	
	if escena_proyectil == null:
		push_warning("Advertencia: No se ha asignado una escena de proyectil al enemigo")

func _physics_process(_delta):
	if jugador_detectado and jugador:
		var distancia = global_position.distance_to(jugador.global_position)
		var direccion: Vector2 = (jugador.global_position - global_position).normalized()
		
		if distancia > rango_ataque:
			# Perseguir al jugador
			velocity = direccion * velocidad
			_actualizar_animacion(direccion)
		else:
			# Detenerse y atacar a quemarropa
			velocity = Vector2.ZERO
			_actualizar_animacion_idle(direccion)
			if puede_atacar:
				_atacar(direccion)
	else:
		# Comportamiento cuando no detecta al jugador
		velocity = Vector2.ZERO
		_actualizar_animacion_idle(ultima_direccion)

	move_and_slide()

func _actualizar_animacion(direccion: Vector2):
	# Guardar la última dirección
	if direccion != Vector2.ZERO:
		ultima_direccion = direccion
	
	# Animaciones básicas (ajusta según tus sprites)
	if abs(direccion.y) > abs(direccion.x):
		if direccion.y < 0:
			sprite.play("up")
		else:
			sprite.play("down")
	else:
		sprite.play("default")
		sprite.flip_h = direccion.x < 0

func _actualizar_animacion_idle(direccion: Vector2):
	# Animación idle basada en la última dirección
		sprite.play("idle")
		sprite.flip_h = direccion.x < 0

func _on_jugador_detectado(body: Node2D):
	if body.is_in_group("player"):
		jugador = body
		jugador_detectado = true
		print("Jugador detectado!")

func _on_jugador_perdido(body: Node2D):
	if body == jugador:
		jugador_detectado = false
		print("Jugador perdido de vista")

func _on_TimerAtaque_timeout():
	puede_atacar = true
	
func _atacar(direccion: Vector2):
	if escena_proyectil == null or jugador == null:
		return
	
	puede_atacar = false
	timer_ataque.start(cooldown_ataque)
	
	# Crear 3 proyectiles con diferentes ángulo
	
	for angulo in angulos_disparo:
		var proyectil = escena_proyectil.instantiate()
		get_parent().add_child(proyectil)
		
		if punto_disparo:
			proyectil.global_position = punto_disparo.global_position
		else:
			proyectil.global_position = global_position
		
		# Rotar la dirección original según el ángulo
		var direccion_rotada = direccion.rotated(deg_to_rad(angulo))
		
		# Configurar dirección del proyectil
		if proyectil.has_method("set_direction"):
			proyectil.set_direction(direccion_rotada)
		elif "direction" in proyectil:
			proyectil.direction = direccion_rotada
		elif "velocity" in proyectil:
			proyectil.velocity = direccion_rotada * proyectil.speed
		
		# Rotación visual del proyectil (opcional)
		if "rotation" in proyectil:
			proyectil.rotation = direccion_rotada.angle()
		
func recibir_daño(cantidad: int):
	vida -= cantidad
	if vida <= 0:
		die()
		print("Enemigo eliminado")

func die():
	if HeartScene:
		var heart_instance = HeartScene.instantiate()
		get_tree().current_scene.add_child(heart_instance)
		heart_instance.global_position = global_position
	queue_free()
