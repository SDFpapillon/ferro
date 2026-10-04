extends Building
## Foreuse : extrait le minerai sous elle, inépuisable. Doit être posée sur
## une case de minerai (vérifié par BuildManager avant placement). Le titane
## nécessite can_mine_titanium=true (Foreuse Lourde).

@export var mine_interval: float = 1.6
@export var can_mine_titanium: bool = false

var ore_type: int = Constants.OreType.NONE
var _timer: float = 0.0

func _ready() -> void:
	super._ready()
	ore_type = WorldGen.get_ore_at(cell)
	if ore_type == Constants.OreType.TITANIUM and not can_mine_titanium:
		ore_type = Constants.OreType.NONE

func _process(delta: float) -> void:
	if ore_type == Constants.OreType.NONE:
		return
	if output_slot == -1:
		_timer += delta
		if _timer >= mine_interval:
			_timer = 0.0
			output_slot = Constants.ORE_TO_ITEM[ore_type]
	try_push_output()
