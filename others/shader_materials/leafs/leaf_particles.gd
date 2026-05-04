extends TextureRect
@onready var sub_viewport: SubViewport = $SubViewport
@onready var gpu_particles_2d: GPUParticles2D = $SubViewport/GPUParticles2D

@export var amount: int = 150
@export var lifetime: float = 45.0
@export var viewport_fill_in := Vector2(1.0, 1.0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sub_viewport.size.x = size.x / viewport_fill_in.x
	sub_viewport.size.y = size.y / viewport_fill_in.y
	gpu_particles_2d.process_material.emission_box_extents = Vector3(sub_viewport.size.x, 1.0, 0.0)
	gpu_particles_2d.position.x = sub_viewport.size.x/2.0
	gpu_particles_2d.amount = amount
	gpu_particles_2d.lifetime = lifetime



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
