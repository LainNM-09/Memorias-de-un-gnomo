extends CharacterBody2D

@export var velocidad: float = 200
@export var vida: int = 40
@export var rango_vision: float = 350
@export var rango_ataque: float = 250
@export var rango_huida: float = 180
@export var cooldown_ataque: float = 1.0  # Tiempo entre ataques
@export var escena_proyectil: PackedScene  # Escena del proyectil a instanciar
@export var HeartScene: PackedScene

@onready var sprite = $AnimatedSprite2D
@onready var area_vision = $Area2D_vision
@onready var timer_ataque = $TimerAtaque
@onready var punto_disparo = $PuntoDisparo  # Nodo Marker2D para posición de disparo

var jugador: Node2D = null
var puede_atacar: bool = true
var jugador_visible: bool = false  
var ultima_direccion: Vector2 = Vector2.DOWN  # Para guardar la última dirección

func _ready():
	var forma_vision = $Area2D_vision/CollisionShape2D.shape
	if forma_vision is CircleShape2D:
		forma_vision.radius = rango_vision

	area_vision.body_entered.connect(_on_jugador_detectado)
	area_vision.body_exited.connect(_on_jugador_perdido)
	timer_ataque.timeout.connect(_on_TimerAtaque_timeout)
	
	# Asegurarse que tenemos la escena del proyectil
	if escena_proyectil == null:
		push_warning("No se ha asignado una escena de proyectil al enemigo")

func _physics_process(_delta):
	if jugador_visible and jugador:
		var distancia = global_position.distance_to(jugador.global_position)
		var direccion: Vector2 = Vector2.ZERO

		if distancia < rango_huida:
			# huir
			direccion = (global_position - jugador.global_position).normalized()
			velocity = direccion * velocidad
			_actualizar_animacion(direccion)
			timer_ataque.stop()
			puede_atacar = true
		elif distancia > rango_ataque:
			# perseguir
			direccion = (jugador.global_position - global_position).normalized()
			velocity = direccion * velocidad
			_actualizar_animacion(direccion)
		else:
			# atacar
			velocity = Vector2.ZERO
			direccion = (jugador.global_position - global_position).normalized()
			if puede_atacar:
				_atacar(direccion)
	else:
		velocity = Vector2.ZERO
		_actualizar_animacion_idle(ultima_direccion)

	move_and_slide()

func _actualizar_animacion(direccion: Vector2):
	# Guardar la última dirección para cuando se detenga
	if direccion != Vector2.ZERO:
		ultima_direccion = direccion
	
	# Determinar si el movimiento es principalmente vertical u horizontal
	if abs(direccion.y) > abs(direccion.x):
		# Movimiento vertical
		if direccion.y < 0:
			sprite.play("up")
		else:
			sprite.play("down")
	else:
		# Movimiento horizontal
		sprite.play("caminar")
		# Ajustar flip_h según la dirección
		sprite.flip_h = direccion.x < 0

func _actualizar_animacion_idle(direccion: Vector2):
	# Usar la última animación de movimiento pero en idle
	if abs(direccion.y) > abs(direccion.x):
		if direccion.y < 0:
			sprite.play("up")
		else:
			sprite.play("down")
	else:
		sprite.play("caminar")
		sprite.flip_h = direccion.x < 0

func _on_jugador_detectado(body: Node2D):
	if body.is_in_group("player"):
		jugador = body
		jugador_visible = true
		print("Jugador detectado por enemigo")

func _on_jugador_perdido(body: Node2D):
	if body == jugador:
		jugador_visible = false
		print("Jugador perdido por enemigo")

func _on_TimerAtaque_timeout():
	puede_atacar = true
	
func _atacar(direccion: Vector2):
	if escena_proyectil == null or jugador == null:
		return
	
	puede_atacar = false
	timer_ataque.start(cooldown_ataque)
	
	# Debug: Imprime la dirección calculada
	print("Dirección de ataque calculada: ", direccion)
	
	var proyectil = escena_proyectil.instantiate()
	get_parent().add_child(proyectil)
	
	if punto_disparo:
		proyectil.global_position = punto_disparo.global_position
	else:
		proyectil.global_position = global_position
	
	# Asegúrate de normalizar la dirección (por si acaso)
	direccion = direccion.normalized()
	
	# Diferentes formas de configurar el movimiento del proyectil
	if proyectil.has_method("set_direction"):
		proyectil.set_direction(direccion)
	elif proyectil.has_method("set_velocity"):
		proyectil.set_velocity(direccion * 300) # 300 o la velocidad que uses
	elif "direction" in proyectil:
		proyectil.direction = direccion
	else:
		# Si el proyectil tiene un script con una variable 'velocity'
		proyectil.velocity = direccion * proyectil.speed
	
	# Rotación visual del proyectil (opcional)
	if "rotation" in proyectil:
		proyectil.rotation = direccion.angle()
		
func recibir_daño(cantidad: int):
	vida -= cantidad
	if vida <= 0:
		die()


func die():
	if HeartScene:
		var heart_instance = HeartScene.instantiate()
		get_tree().current_scene.add_child(heart_instance)
		heart_instance.global_position = global_position
	queue_free()
