extends CharacterBody2D

# Configurações
const SPEED = 500.0
const JUMP_VELOCITY = -800.0

@export var bullet_scene: PackedScene
@export var fire_cooldown: float = 0.5
@export var max_health: int = 100

# Estado interno
var current_health: int = max_health
var can_fire: bool = true
var ataque: bool = false
var ataque_curto: bool = false

# Física e movimento
func _physics_process(delta: float) -> void:
	# Gravidade
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Pulo
	if Input.is_action_just_pressed("pular") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Disparo
	if Input.is_action_pressed("fire") and can_fire:
		shoot()
		can_fire = false
		await get_tree().create_timer(fire_cooldown).timeout
		can_fire = true

	# Movimento lateral
	var move_direction = Input.get_axis("andar esquerda", "andar direita")
	if move_direction:
		velocity.x = move_direction * SPEED
		$Sprite2D.flip_h = move_direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Animações
	if ataque:
		if ataque_curto:
			_play_safe("atack.2")
			await get_tree().create_timer(0.1).timeout
			ataque_curto = false
		else:
			_play_safe("atack.1")
			await get_tree().create_timer(0.4).timeout
		ataque = false
	elif velocity.x != 0:
		_play_safe("run")
	else:
		_play_safe("idle")

	move_and_slide()

# Ataque à distância
func shoot() -> void:
	var flecha = bullet_scene.instantiate()
	flecha.global_position = global_position
	var mouse_pos = get_global_mouse_position()
	var direction = (mouse_pos - global_position).normalized()
	flecha.direction = direction
	flecha.shooter = self
	get_tree().current_scene.add_child(flecha)
	ataque = true

# Entrada de ataque
func _input(event: InputEvent) -> void:
	if Input.is_action_pressed("ataque curto"):
		ataque = true
		ataque_curto = true

# Dano recebido
func take_damage(amount: int) -> void:
	current_health -= amount
	if current_health <= 0:
		die()

func die() -> void:
	get_tree().change_scene_to_file("res://cenas/game_over.tscn")
	call_deferred("queue_free")

# Cura
func heal(amount: int) -> void:
	current_health = min(current_health + amount, max_health)

# Proteção contra animação inexistente
func _play_safe(anim_name: String) -> void:
	if $Sprite2D.sprite_frames.has_animation(anim_name):
		$Sprite2D.play(anim_name)
	else:
		print("⚠️ Animação não encontrada: ", anim_name)
