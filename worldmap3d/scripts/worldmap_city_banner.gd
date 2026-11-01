## EASTWAR WorldMap3D — city banner label (vertical faction banner + Korean name + crest + troop plate).
## The banner root is turned to face the camera every frame by worldmap3d_root.gd (screen-aligned layout,
## readable at both top-down and oblique zoom). All parts ignore depth so mountains never hide them.
class_name WorldMapCityBanner
extends Node3D

const UI := "res://worldmap3d/textures/ui/"
var city_id: String
var _body: Sprite3D
var _emblem: Sprite3D
var _name: Label3D
var _troops: Label3D

func _sprite(tex: String, height: float, y: float, prio: int, col := Color.WHITE, x := 0.0) -> Sprite3D:
	var s := Sprite3D.new()
	s.texture = load(UI + tex)
	s.pixel_size = height / float(s.texture.get_height())
	s.position = Vector3(x, y, 0)
	s.no_depth_test = true
	s.shaded = false
	s.double_sided = true
	s.render_priority = prio
	s.modulate = col
	s.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	add_child(s)
	return s

func _label(text: String, font: Font, size: int, height: float, pos: Vector3, prio: int, col: Color, outline: int) -> Label3D:
	var l := Label3D.new()
	l.text = text
	l.font = font
	l.font_size = size
	l.pixel_size = height / float(size)
	l.position = pos
	l.no_depth_test = true
	l.shaded = false
	l.double_sided = true
	l.render_priority = prio
	l.outline_render_priority = prio - 1
	l.modulate = col
	l.outline_modulate = Color(0.08, 0.06, 0.05, 0.9)
	l.outline_size = outline
	l.line_spacing = -size * 0.18
	l.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	add_child(l)
	return l

func build(city: Dictionary, faction_color: Color, font: Font) -> void:
	city_id = city.id
	var name_ko: String = city.name_ko
	var vertical := ""
	for k in name_ko.length():
		vertical += name_ko[k] + ("\n" if k < name_ko.length() - 1 else "")
	var pole := _sprite("pole.png", 0.36, 0.17, 1, Color(0.95, 0.85, 0.55, 0.9))
	pole.scale = Vector3(0.10, 1.0, 1.0)
	_body = _sprite("banner_body.png", 1.0, 1.08, 2, faction_color)
	_sprite("banner_trim.png", 1.0, 1.08, 3)
	_name = _label(vertical, font, 112, 0.215, Vector3(0, 1.10, 0), 6, Color(1, 1, 1), 26)
	_sprite("crest_base.png", 0.22, 0.56, 7)
	_emblem = _sprite("crest_emblem.png", 0.22, 0.56, 8, faction_color.darkened(0.05))
	_sprite("troop_plate.png", 0.13, 0.37, 9)
	_troops = _label(_fmt(int(city.get("troops", 0))), font, 80, 0.082, Vector3(0.034, 0.373, 0), 11, Color(1.0, 0.93, 0.75), 8)

static func _fmt(n: int) -> String:
	var s := str(n)
	var o := ""
	var c := 0
	for k in range(s.length() - 1, -1, -1):
		o = s[k] + o
		c += 1
		if c % 3 == 0 and k > 0:
			o = "," + o
	return o

func set_faction_color(c: Color) -> void:
	_body.modulate = c
	_emblem.modulate = c.darkened(0.05)

## v2.4: sideways offset (in banner heights) so close cities (kyoto/osaka, the Korean chain) do not cover each other
## at far zoom. markers.json -> "banner_dx". The castle stays on the real city position.
func set_offset_x(dx: float) -> void:
	for c in get_children():
		c.position.x += dx

func set_troops(n: int) -> void:
	_troops.text = _fmt(n)
