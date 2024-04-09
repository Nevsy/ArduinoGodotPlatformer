extends CanvasLayer

@onready var heartsContainer = $HeartsContainer
@onready var player = $"../Player"

func _ready():
	heartsContainer.setMaxHearts(player.maxHealth)
	heartsContainer.updateHearts(player.hearts)
	player.healthChanged.connect(heartsContainer.updateHearts)

func _process(delta):
	pass
