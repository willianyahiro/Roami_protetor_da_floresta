extends Area2D

@export var speed: float = 1000.0
@export var lifetime: float = 2.0
@export var damage: int = 30

var direction: Vector2 = Vector2.ZERO
var shooter: Node = null

func _ready() -> void:
	add_to_group("ataque")
	rotation = direction.angle()
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_body_entered(body: Node) -> void:
	if body == shooter:
		return
	if body.is_in_group("inimigo"):
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area == shooter:
		return
	if area.is_in_group("inimigo"):
		queue_free()

func get_damage() -> int:
	return damage
