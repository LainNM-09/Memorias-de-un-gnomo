extends HBoxContainer

@export var full_heart: Texture2D
@export var empty_heart: Texture2D
@export var player: NodePath  # Usar NodePath en lugar de string directo

var player_node: Node  # Referencia al nodo del jugador

func _ready():
	player_node = get_node(player)
	if player_node.has_signal("health_changed"):
		player_node.health_changed.connect(update_hearts)
	create_hearts(player_node.vidamaxima)  # Usar vidamaxima del jugador
	update_hearts(player_node.vidaactual)  # Sincronizar la vida actual
	
func create_hearts(amount: int):
	for child in get_children():
		child.queue_free()
	
	for i in range(amount):
		var heart = TextureRect.new()
		heart.texture = full_heart
		heart.expand_mode = TextureRect.EXPAND_FIT_WIDTH  # Ajusta al ancho disponible
		heart.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED  # Escala manteniendo aspecto
		heart.custom_minimum_size = Vector2(16, 16)  # Fuerza un tamaño mínimo
		add_child(heart)

func update_hearts(new_hearts: int):
	for i in range(get_child_count()):
		var heart = get_child(i)
		heart.texture = full_heart if i < new_hearts else empty_heart
