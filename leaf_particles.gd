extends TextureRect
@onready var sub_viewport: SubViewport = $SubViewport
@onready var gpu_particles_2d: GPUParticles2D = $SubViewport/GPUParticles2D

@export var amount: int = 150
@export var lifetime: float = 45.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sub_viewport.size = size
	gpu_particles_2d.process_material.emission_box_extents = Vector3(size.x, 1.0, 0.0)
	gpu_particles_2d.position.x = size.x/2
	gpu_particles_2d.amount = amount
	gpu_particles_2d.lifetime = lifetime



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
