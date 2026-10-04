extends Control
## Joystick virtuel tactile. `value` donne un Vector2 dans [-1,1] par axe.

@export var max_distance: float = 50.0
@onready var knob: Control = $Knob

var value: Vector2 = Vector2.ZERO
var _touch_index: int = -1

func _ready() -> void:
	_reset_knob()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and _touch_index == -1:
			_touch_index = event.index
			_update_knob(event.position)
		elif not event.pressed and event.index == _touch_index:
			_touch_index = -1
			value = Vector2.ZERO
			_reset_knob()
	elif event is InputEventScreenDrag and event.index == _touch_index:
		_update_knob(event.position)

func _update_knob(local_pos: Vector2) -> void:
	var center: Vector2 = size / 2.0
	var offset: Vector2 = local_pos - center
	if offset.length() > max_distance:
		offset = offset.normalized() * max_distance
	knob.position = center + offset - knob.size / 2.0
	value = offset / max_distance

func _reset_knob() -> void:
	knob.position = size / 2.0 - knob.size / 2.0
