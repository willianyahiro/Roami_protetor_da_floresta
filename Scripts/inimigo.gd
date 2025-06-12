extends CharacterBody2D # CÓDIGO INIMIGO

# Configurações
@export var velocidade: float = 100.0
@export var vida: int = 60
@export var damage: int = 50 # Quantidade de dano que o inimigo causa no Raoni
@export var target: NodePath  # Caminho até Raoni
@onready var texture := $AnimatedSprite2D

# Variáveis internas
var perseguir: bool = false
var player: Node2D = null
var raoni: CharacterBody2D

# Inicialização
func _ready() -> void:
	add_to_group("inimigo")
	if target != null:
		raoni = get_node(target)

# Loop de física
func _physics_process(delta: float) -> void:
	# Aplica gravidade
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Perseguir jogador
	if perseguir and player != null:
		var direcao = (player.global_position - global_position).normalized()
		velocity.x = direcao.x * velocidade

		# Flip sprite na direção
		texture.flip_h = direcao.x < 0
		texture.play("correr")
	else:
		velocity.x = 0.0
		texture.play("idle")

	move_and_slide()

# Detecta entrada na área de perseguição
func _on_area_persiguir_body_entered(body: Node2D) -> void:
	if body.name == "Raoni":
		player = body
		perseguir = true

# Detecta saída da área de perseguição
func _on_area_persiguir_body_exited(body: Node2D) -> void:
	if body.name == "Raoni":
		player = null
		perseguir = false

# Hitbox de dano
func _on_Hitbox_body_entered(body: Node) -> void:
	if body.name == "Raoni" and body.has_method("take_damage"):
		body.take_damage(damage)

# Área de morte (ex.: flecha, espada, etc.)
func _on_morte_body_entered(body: Node2D) -> void:
	if body.is_in_group("ataque") and body.has_method("get_damage"):
		tomar_dano(body.get_damage())
		
func _on_morte_area_entered(area: Area2D) -> void:
	if area.is_in_group("ataque") and area.has_method("get_damage"):
		tomar_dano(area.get_damage())

# Sistema de vida
func tomar_dano(amount: int) -> void:
	vida -= amount
	print("Vida do inimigo: ", vida)  # Debug: Verificando a vida
	if vida <= 0:
		die()

# Função de morte
func die() -> void:
	print("Inimigo morreu!")  # Debug: Verificando se o inimigo morreu
	texture.play("morte")  # Se tiver animação de morte
	await get_tree().create_timer(1).timeout
	queue_free()
