extends ProgressBar

var parent
var max_value_amount
var min_value_amount
# Called when the node enters the scene tree for the first time.
func _ready():
	parent = get_parent()
	max_value_amount = parent.Maxhealth
	min_value_amount = parent.Minhealth
 # Replace with function body.
	self.max_value = max_value_amount
	self.min_value = min_value_amount

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.value = parent.health 
	if parent.health != max_value_amount:
		self.visible = true
		if parent.health == min_value_amount:
			self.visible = false
	else:
		self.visible = false
