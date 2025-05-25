extends CharacterBody2D

@onready var sprite = $animated
@onready var cuerpo = $Area2D
@onready var timer = $Timer
@onready var dash_timer = $DashTimer
@onready var gun_position = $GunPosition

@export var vidamaxima: int = 10
@export var esquiva_velocidad: int = 800
@export var esquiva_duracion: float = 0.2
@export var esquiva_cooldown: float = 0.6
@export var attack_cooldown: float = 1.0

# Hechizos
@export var hechizo_1: PackedScene
@export var hechizo_2: PackedScene
@export var hechizo_3: PackedScene

var can_shoot = true
var invensibilidad = false
var vidaactual: int 
var puede_esquivar: bool = true
var esta_esquivando: bool = false
var last_move_direction = Vector2.RIGHT
var current_spell = 1  # 1, 2 o 3 para los diferentes hechizos

signal health_changed(vidaactual)
const SPEED = 200

func _ready():
	vidaactual = vidamaxima
	health_changed.emit(vidaactual)
	if not has_node("DashCooldownTimer"):
		dash_timer = Timer.new()
		dash_timer.name = "DashCooldownTimer"
		add_child(dash_timer)
		dash_timer.timeout.connect(_on_dash_timer_timeout)

func _input(event: InputEvent) -> void:
	# Cambiar hechizos con teclas 1, 2, 3
	if event.is_action_pressed("hechizo_1"):
		current_spell = 1
	elif event.is_action_pressed("hechizo_2"):
		current_spell = 2
	elif event.is_action_pressed("hechizo_3"):
		current_spell = 3
	
	if event.is_action_pressed("shoot") and can_shoot:
		fire_spell()

	if event.is_action_pressed("esquiva") and puede_esquivar:
		dash()

func fire_spell():
	var spell_scene: PackedScene
	match current_spell:
		1: spell_scene = hechizo_1
		2: spell_scene = hechizo_2
		3: spell_scene = hechizo_3
		_: spell_scene = hechizo_1  # Por defecto
	
	if spell_scene:
		var spell = spell_scene.instantiate()
		get_parent().add_child(spell)
		
		# Posición de disparo (usando gun_position o la posición del jugador)
		spell.position = gun_position.global_position if gun_position else global_position
		
		# Dirección hacia el mouse
		var mouse_pos = get_global_mouse_position()
		spell.direction = (mouse_pos - spell.position).normalized()
		
		# Rotar el sprite del hechizo para que mire hacia la dirección
		if spell.has_node("Sprite2D"):
			spell.get_node("Sprite2D").rotation = spell.direction.angle()
		
		can_shoot = false
		await get_tree().create_timer(attack_cooldown).timeout
		can_shoot = true

# [El resto de tus funciones permanecen igual...]

func _physics_process(_delta: float) -> void:
	var input_vector := Vector2(
		Input.get_axis("izquierda", "derecha"),
		Input.get_axis("arriba", "abajo")
	).normalized()
	
	if input_vector.length() > 0:
		last_move_direction = input_vector
	
	# Movimiento normal o dash
	if esta_esquivando:
		velocity = last_move_direction * esquiva_velocidad
	else:
		velocity = input_vector * SPEED
	
	update_animations(input_vector)
	move_and_slide()

func update_animations(input_vector: Vector2):
	if input_vector.y > 0.5:
		sprite.play("abajo")
		last_move_direction = Vector2.DOWN
	elif input_vector.y < -0.5:
		sprite.play("arriba")
		last_move_direction = Vector2.UP
	elif input_vector.x != 0:
		sprite.play("caminar")
		sprite.flip_h = input_vector.x < 0
		last_move_direction = Vector2.RIGHT if input_vector.x > 0 else Vector2.LEFT
	else:
		sprite.play("quieto")

func dash():
	if not puede_esquivar or esta_esquivando:
		return
	
	esta_esquivando = true
	puede_esquivar = false
	invensibilidad = true
	
	# Efecto visual durante el dash
	sprite.modulate.a = 0.7
	
	# Temporizador para la duración del dash
	await get_tree().create_timer(esquiva_duracion).timeout
	
	# Restaurar estado normal
	esta_esquivando = false
	sprite.modulate.a = 1.0
	invensibilidad = false
	
	# Iniciar cooldown
	dash_timer.start(esquiva_cooldown)

func _on_timer_timeout() -> void:
	invensibilidad = false
	sprite.modulate.a = 1

func _on_dash_timer_timeout() -> void:
	puede_esquivar = true
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemigos") and not invensibilidad:
		daño()
	
func daño():
	if invensibilidad:
		return
		
	vidaactual -= 1 
	health_changed.emit(vidaactual)
	superinvensibilidad()
	if vidaactual <= 0:
		print("Jugador muerto")
		get_tree().reload_current_scene()

func gain_life():
	if vidaactual < 10:
		vidaactual += 1
		health_changed.emit(vidaactual)

func superinvensibilidad():
	invensibilidad = true
	timer.start()
	sprite.modulate.a = 0.5
