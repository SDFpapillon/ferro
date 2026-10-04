extends Node
## Autoload: génération procédurale déterministe du monde infini.
## Rien n'est stocké en mémoire pour le minerai : tout est recalculé à partir
## de la position via du bruit, donc le monde est infini et cohérent entre
## deux visites de la même zone.

const SEED: int = 1337
const SAFE_ZONE_RADIUS_CHUNKS: int = 2 # aucun nid autour du spawn
const THRESHOLD := 0.45
const TITANIUM_THRESHOLD := 0.58 # plus rare : nécessite une Foreuse Lourde

var iron_noise := FastNoiseLite.new()
var copper_noise := FastNoiseLite.new()
var coal_noise := FastNoiseLite.new()
var sand_noise := FastNoiseLite.new()
var titanium_noise := FastNoiseLite.new()
var ground_noise := FastNoiseLite.new()

func _ready() -> void:
	iron_noise.seed = SEED
	iron_noise.frequency = 0.045
	iron_noise.noise_type = FastNoiseLite.TYPE_PERLIN

	copper_noise.seed = SEED + 1
	copper_noise.frequency = 0.045
	copper_noise.noise_type = FastNoiseLite.TYPE_PERLIN

	coal_noise.seed = SEED + 3
	coal_noise.frequency = 0.05
	coal_noise.noise_type = FastNoiseLite.TYPE_PERLIN

	sand_noise.seed = SEED + 4
	sand_noise.frequency = 0.05
	sand_noise.noise_type = FastNoiseLite.TYPE_PERLIN

	titanium_noise.seed = SEED + 5
	titanium_noise.frequency = 0.022 # tâches plus grandes et plus rares
	titanium_noise.noise_type = FastNoiseLite.TYPE_PERLIN

	ground_noise.seed = SEED + 2
	ground_noise.frequency = 0.08
	ground_noise.noise_type = FastNoiseLite.TYPE_PERLIN

## Minerai à une cellule donnée. Inépuisable : toujours la même réponse.
func get_ore_at(cell: Vector2i) -> int:
	var candidates := {
		Constants.OreType.IRON: iron_noise.get_noise_2d(cell.x, cell.y) - THRESHOLD,
		Constants.OreType.COPPER: copper_noise.get_noise_2d(cell.x, cell.y) - THRESHOLD,
		Constants.OreType.COAL: coal_noise.get_noise_2d(cell.x, cell.y) - THRESHOLD,
		Constants.OreType.SAND: sand_noise.get_noise_2d(cell.x, cell.y) - THRESHOLD,
		Constants.OreType.TITANIUM: titanium_noise.get_noise_2d(cell.x, cell.y) - TITANIUM_THRESHOLD,
	}
	var best_type: int = Constants.OreType.NONE
	var best_margin: float = 0.0
	for ore_type in candidates:
		var margin: float = candidates[ore_type]
		if margin > best_margin:
			best_margin = margin
			best_type = ore_type
	return best_type

## Variation purement visuelle du sol (0..3), pour casser la monotonie.
func get_ground_variant(cell: Vector2i) -> int:
	var v: float = ground_noise.get_noise_2d(cell.x, cell.y)
	return int(clamp((v + 1.0) * 2.0, 0, 3))

static func _hash_chunk(chunk: Vector2i, salt: int) -> int:
	var h: int = chunk.x * 374761393 + chunk.y * 668265263 + salt * 2246822519
	h = (h ^ (h >> 13)) * 1274126177
	h = h ^ (h >> 16)
	return abs(h)

## Un nid par chunk éligible, environ 1 chance sur 5, jamais près du spawn.
func chunk_has_nest(chunk: Vector2i) -> bool:
	if abs(chunk.x) <= SAFE_ZONE_RADIUS_CHUNKS and abs(chunk.y) <= SAFE_ZONE_RADIUS_CHUNKS:
		return false
	return _hash_chunk(chunk, 11) % 5 == 0

## Position (en cellules, coordonnées monde) du nid dans ce chunk.
func get_nest_cell(chunk: Vector2i) -> Vector2i:
	var ox: int = _hash_chunk(chunk, 22) % Constants.CHUNK_SIZE
	var oy: int = _hash_chunk(chunk, 33) % Constants.CHUNK_SIZE
	return Vector2i(chunk.x * Constants.CHUNK_SIZE + ox, chunk.y * Constants.CHUNK_SIZE + oy)

## Facteur de difficulté lié à l'éloignement du noyau (0 au centre, croît ensuite).
func distance_factor(world_pos: Vector2) -> float:
	var dist: float = world_pos.length() / Constants.CELL_SIZE
	return clamp(dist / 40.0, 0.0, 6.0)
