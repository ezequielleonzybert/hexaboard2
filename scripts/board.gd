#@tool
extends Node3D

const SQRT3: float = 1.732050807568877
const TILE_RADIUS: float = 0.5

#region Exports
@export_group("Geometry")
@export var radius: int = 30
@export var max_height: float = 1.0
@export var frequency: float = 0.1
@export_range(0.0,1.0) var water_level: float = 0.3
@export_range(0.0,1.0) var stone_level: float = 0.6

@export_group("Colors")
@export var color_grass:= Color(.4,.7,.3)
@export var color_stone:= Color(.9,.8,.6)
@export var color_water:= Color(.5,.7,1.0)
#endregion

#region Globals

var mmi = MultiMeshInstance3D
var colliders: Array[CollisionPolygon3D]
var _material: ShaderMaterial
var body: StaticBody3D
var tiles: Array[Tile]

#endregion

func _ready() -> void:
	var mm = get_multimesh()
	mmi = MultiMeshInstance3D.new()
	mmi.multimesh = mm
	add_child(mmi)
	
	body = StaticBody3D.new()
	for collider in colliders:
		body.add_child(collider)
	add_child(body)


@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	var i = Inputs.tile_hovered
	var pi = Inputs.previous_tile_hovered
	if i != pi:
		mmi.multimesh.mesh.material.set_shader_parameter("tile_hovered", i)


func get_multimesh() -> MultiMesh:
	var mm = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_colors = true
	mm.mesh = get_mesh()
	
	set_tiles(mm)
	
	return mm
	
	
func get_mesh() -> CylinderMesh:
	var mesh = CylinderMesh.new()
	mesh.rings = 0
	mesh.radial_segments = 6
	mesh.top_radius = TILE_RADIUS
	mesh.bottom_radius = TILE_RADIUS
	_material = get_material()
	mesh.material = _material
	return mesh


func set_tiles(mm:MultiMesh) -> void:
	var tiles_positions = get_tiles_positions()
	mm.instance_count = tiles_positions.size()
	var noise = get_noise()
	var color: Color
	
	for i in range (tiles_positions.size()):
		var pos = tiles_positions[i]
		var h = (noise.get_noise_2d(pos.x, pos.z) + 1.0) * 0.5 * max_height
		var tile = Tile.new(pos, h)
		
		set_tile_type(tile)
		
		var trans = Transform3D()
		trans = trans.scaled(Vector3(1.0, tile.height, 1.0))
		trans = trans.translated(Vector3(tile.position.x, tile.height, tile.position.z))
		
		mm.set_instance_transform(i, trans)
		mm.set_instance_color(i, tile.color)
		
		tiles.append(tile)
		colliders.append(get_tile_collider(tile.height, tile.position))


func get_tile_collider(height:float, pos:Vector3) -> CollisionPolygon3D:
	var collider = CollisionPolygon3D.new()
	var corners: PackedVector2Array
	for i in range(6):
		corners.insert(i, Vector2(TILE_RADIUS, 0).rotated(i*PI/3.0))
	collider.set_polygon(corners)
	collider.set_depth(height*2)
	collider.position = Vector3(pos.x, height, pos.z)
	collider.rotate_x(PI/2)
	collider.rotate_y(PI/6)
	return collider


func get_tiles_positions() -> Array[Vector3]:
	var positions: Array[Vector3]
	
	for q in range(-radius, radius + 1):
		var r1 = max(-radius, -q - radius)
		var r2 = min(radius,  -q + radius)
		for r in range(r1, r2 + 1):
			var x = TILE_RADIUS * SQRT3 * (q + r / 2.0)
			var y = TILE_RADIUS * 1.5 * r
			positions.append(Vector3(x, 0.0, y))
	
	return positions


func get_material() -> ShaderMaterial:
	_material = ShaderMaterial.new()
	_material.shader = load("res://shaders/flat.gdshader")
	return _material


func get_noise() -> FastNoiseLite:
	var noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.frequency = frequency
	noise.seed = randi()
	return noise


func set_tile_type(tile: Tile):
	if tile.height/max_height < water_level:
		tile.type = tile.Type.WATER
		tile.color = color_water
		tile.height = water_level * max_height
	elif tile.height/max_height > stone_level:
		tile.type = tile.Type.STONE
		tile.color = color_stone
	else:
		tile.type = tile.Type.GRASS
		tile.color = color_grass
