extends TileMapLayer
## Charge/décharge les chunks de terrain autour du joueur et fait apparaître
## les nids d'ennemis quand leur chunk devient actif. Le minerai n'est jamais
## stocké : il est recalculé à la volée (inépuisable, cf. WorldGen).

const GROUND_SOURCE_ID := 0
const ATLAS_GROUND := Vector2i(0, 0)
const ATLAS_IRON := Vector2i(1, 0)
const ATLAS_COPPER := Vector2i(2, 0)
const ATLAS_COAL := Vector2i(3, 0)
const ATLAS_SAND := Vector2i(4, 0)
const ATLAS_TITANIUM := Vector2i(5, 0)

var _loaded_chunks: Dictionary = {} # Vector2i -> true
var _nest_spawned: Dictionary = {} # Vector2i -> true
var _check_timer: float = 0.0

func _ready() -> void:
	_build_tileset()
	_update_chunks() # charge immédiatement la zone de départ

func _process(delta: float) -> void:
	_check_timer -= delta
	if _check_timer > 0.0:
		return
	_check_timer = 0.4
	_update_chunks()

const COLS := 6

func _build_tileset() -> void:
	var tile_px: int = Constants.CELL_SIZE
	var img := Image.create(tile_px * COLS, tile_px, false, Image.FORMAT_RGBA8)
	_blit_tile(img, load("res://assets/tiles/tuile_herbe.png"), 0, tile_px)
	_blit_tile(img, load("res://assets/tiles/tuile_fer.png"), 1, tile_px)
	_blit_tile(img, load("res://assets/tiles/tuile_cuivre.png"), 2, tile_px)
	# Placeholders procéduraux en attendant les vraies textures charbon/sable/titane.
	_placeholder_tile(img, 3, tile_px, Color(0.13, 0.13, 0.14), Color(0.03, 0.03, 0.04))
	_placeholder_tile(img, 4, tile_px, Color(0.78, 0.68, 0.45), Color(0.9, 0.82, 0.6))
	_placeholder_tile(img, 5, tile_px, Color(0.35, 0.38, 0.42), Color(0.75, 0.78, 0.82))

	var tex := ImageTexture.create_from_image(img)
	var tileset := TileSet.new()
	tileset.tile_size = Vector2i(tile_px, tile_px)
	var source := TileSetAtlasSource.new()
	source.texture = tex
	source.texture_region_size = Vector2i(tile_px, tile_px)
	for x in range(COLS):
		source.create_tile(Vector2i(x, 0))
	tileset.add_source(source, GROUND_SOURCE_ID)
	tile_set = tileset

func _blit_tile(img: Image, tex: Texture2D, col: int, size: int) -> void:
	var src: Image = tex.get_image()
	if src.get_format() != Image.FORMAT_RGBA8:
		src = src.duplicate()
		src.convert(Image.FORMAT_RGBA8)
	img.blit_rect(src, Rect2i(0, 0, size, size), Vector2i(col * size, 0))

func _placeholder_tile(img: Image, col: int, size: int, base_color: Color, speckle_color: Color) -> void:
	for x in range(size):
		for y in range(size):
			img.set_pixel(col * size + x, y, base_color)
	var border := base_color.darkened(0.4)
	for x in range(size):
		img.set_pixel(col * size + x, 0, border)
		img.set_pixel(col * size + x, size - 1, border)
	for y in range(size):
		img.set_pixel(col * size, y, border)
		img.set_pixel(col * size + size - 1, y, border)
	var rng := RandomNumberGenerator.new()
	rng.seed = col * 7919 + 104729
	for i in range(16):
		var sx: int = rng.randi_range(3, size - 5)
		var sy: int = rng.randi_range(3, size - 5)
		for dx in range(2):
			for dy in range(2):
				img.set_pixel(col * size + sx + dx, sy + dy, speckle_color)

func _update_chunks() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player == null:
		return
	var player_cell: Vector2i = Constants.world_to_cell(player.global_position)
	var player_chunk: Vector2i = Constants.cell_to_chunk(player_cell)

	for dx in range(-Constants.LOAD_RADIUS_CHUNKS, Constants.LOAD_RADIUS_CHUNKS + 1):
		for dy in range(-Constants.LOAD_RADIUS_CHUNKS, Constants.LOAD_RADIUS_CHUNKS + 1):
			var c := Vector2i(player_chunk.x + dx, player_chunk.y + dy)
			if not _loaded_chunks.has(c):
				_load_chunk(c)

	for c in _loaded_chunks.keys().duplicate():
		if Vector2(c - player_chunk).length() > Constants.UNLOAD_RADIUS_CHUNKS:
			_unload_chunk(c)

	for dx in range(-Constants.UNLOAD_RADIUS_CHUNKS, Constants.UNLOAD_RADIUS_CHUNKS + 1):
		for dy in range(-Constants.UNLOAD_RADIUS_CHUNKS, Constants.UNLOAD_RADIUS_CHUNKS + 1):
			var c := Vector2i(player_chunk.x + dx, player_chunk.y + dy)
			if not _nest_spawned.has(c) and WorldGen.chunk_has_nest(c):
				_spawn_nest(c)

func _load_chunk(chunk: Vector2i) -> void:
	_loaded_chunks[chunk] = true
	var base_x := chunk.x * Constants.CHUNK_SIZE
	var base_y := chunk.y * Constants.CHUNK_SIZE
	for lx in range(Constants.CHUNK_SIZE):
		for ly in range(Constants.CHUNK_SIZE):
			var cell := Vector2i(base_x + lx, base_y + ly)
			var ore: int = WorldGen.get_ore_at(cell)
			var atlas: Vector2i
			match ore:
				Constants.OreType.IRON:
					atlas = ATLAS_IRON
				Constants.OreType.COPPER:
					atlas = ATLAS_COPPER
				Constants.OreType.COAL:
					atlas = ATLAS_COAL
				Constants.OreType.SAND:
					atlas = ATLAS_SAND
				Constants.OreType.TITANIUM:
					atlas = ATLAS_TITANIUM
				_:
					atlas = ATLAS_GROUND
			set_cell(cell, GROUND_SOURCE_ID, atlas)

func _unload_chunk(chunk: Vector2i) -> void:
	_loaded_chunks.erase(chunk)
	var base_x := chunk.x * Constants.CHUNK_SIZE
	var base_y := chunk.y * Constants.CHUNK_SIZE
	for lx in range(Constants.CHUNK_SIZE):
		for ly in range(Constants.CHUNK_SIZE):
			erase_cell(Vector2i(base_x + lx, base_y + ly))

func _spawn_nest(chunk: Vector2i) -> void:
	_nest_spawned[chunk] = true
	var cell: Vector2i = WorldGen.get_nest_cell(chunk)
	if BuildingGrid.is_occupied(cell):
		return
	var nest_scene: PackedScene = load("res://scenes/enemies/Nest.tscn")
	var nest := nest_scene.instantiate()
	nest.global_position = Constants.cell_to_world(cell)
	var root := get_tree().get_first_node_in_group("enemies_root")
	if root:
		root.add_child(nest)
