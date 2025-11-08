extends Label

func _ready():
	modulate.a = 1.0
	# Tween movement up and fade out over 1 second
	var tween = create_tween()
	tween.tween_property(self, "position:y", position.y - 50, 1.0)
	tween.tween_property(self, "modulate:a", 0.0, 1.0)
	tween.connect("finished", Callable(self, "queue_free"))
