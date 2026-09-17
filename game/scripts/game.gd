extends Node3D

const PLAYER_SCRIPT = preload("res://scripts/player.gd")
const BEAR = preload("res://assets/bear.glb")
const GRANDPA = preload("res://assets/grandpa.glb")
const ROOM = preload("res://assets/room.glb")
const FONT = preload("res://assets/NotoSansSC-Regular.ttf")
var story := WakingStory.new()
var player: CharacterBody3D
var room: Node3D
var room_set: Node3D
var grandpa: Node3D
var lap_bear: Node3D
var large_bear: Node3D
var carried: Node3D
var environment: Environment
var warm_light: DirectionalLight3D
var actor_light: OmniLight3D
var window_material: ShaderMaterial
var rain: MultiMeshInstance3D
var rain_seeds: Array[Vector3] = []
var paths: Array[Dictionary] = []
var elapsed := 0.0
var warmth := 0.0
var singing := 0.0
var hug_amount := 0.0
var call_flash := 0.0
var began := false
var paused := false
var main_ui: Control
var title_ui: Control
var pause_ui: Control
var end_ui: Control
var operator_ui: Control
var subtitle: Label
var subtitle_until := 0.0
var prompt: Label
var chapter_label: Label
var tiny_hint: Label
var diagnostics: Label
var show_diagnostics := false
var end_text: Label
var audio: Dictionary = {}
var interaction_hint := ""
var memory_pulse := 0.0
var memory_index := 0
var care_announced := false
var proximity_noted := false
var pending_ai: Dictionary = {}
var ai_text: Label
var ai_request: HTTPRequest
var api_available := false
var ai_busy := false
var ai_action_override := ""
var qa_mode := ""
var qa_step := 0
var qa_clock := 0.0
var qa_saved: Dictionary = {}
var hand_targets: Dictionary = {}

func _ready() -> void:
	DisplayServer.window_set_title("醒来之前 · Before Waking")
	story.changed.connect(_on_phase)
	_build_world()
	_build_ui()
	_build_audio()
	_setup_ai()
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--qa="): qa_mode = arg.trim_prefix("--qa=")
	if not qa_mode.is_empty():
		print("QA_START ", qa_mode)
		_start()

func find_named(root: Node, name_part: String) -> Node3D:
	if root.name == name_part: return root as Node3D
	for child in root.get_children():
		var found := find_named(child, name_part)
		if found: return found
	return null

func flat_material(color: Color, unshaded := false) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = 0.85
	if unshaded: m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	if color.a < 1.0:
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		m.cull_mode = BaseMaterial3D.CULL_DISABLED
	return m

func box_mesh(size: Vector3, at: Vector3, material: Material, parent: Node = self) -> MeshInstance3D:
	var box := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	box.mesh = mesh
	box.material_override = material
	box.position = at
	parent.add_child(box)
	return box

func collider(size: Vector3, at: Vector3) -> StaticBody3D:
	var body := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	body.position = at
	body.add_child(shape)
	add_child(body)
	return body

func _build_world() -> void:
	var env_node := WorldEnvironment.new()
	environment = Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("050907")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("a8b8aa")
	environment.ambient_light_energy = 0.07
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env_node.environment = environment
	add_child(env_node)
	box_mesh(Vector3(28, 0.2, 30), Vector3(0, -0.16, 0), flat_material(Color("050907"), true))
	collider(Vector3(28, 0.3, 30), Vector3(0, -0.18, 0))
	for x in [-5.5, 5.5]: collider(Vector3(0.5, 4, 20), Vector3(x, 1.8, 0))
	for z in [-5.0, 8.5]: collider(Vector3(12, 4, 0.4), Vector3(0, 1.8, z))
	collider(Vector3(1.15, 1.5, 1.1), Vector3(-0.8, 0.75, -2.5))
	var table_body := collider(Vector3(2.3, 1.1, 1.2), Vector3(1.7, 0.5, -3.1))
	collider(Vector3(1.6, 0.5, 1.6), Vector3(-3, 0.22, 0.3))
	room = ROOM.instantiate()
	add_child(room)
	room_set = find_named(room, "RoomSet")
	table_body.reparent(room_set, true)
	room_set.visible = false
	find_named(room, "ExchangePedestal").visible = false
	grandpa = GRANDPA.instantiate()
	grandpa.position = Vector3(-0.8, 0, -2.5)
	add_child(grandpa)
	lap_bear = BEAR.instantiate()
	lap_bear.scale = Vector3.ONE * 0.58
	lap_bear.position = Vector3(1.15, 1.02, -3.1)
	add_child(lap_bear)
	find_named(lap_bear, "BearGarment").visible = false
	lap_bear.visible = false
	large_bear = BEAR.instantiate()
	large_bear.scale = Vector3.ONE * 1.7
	large_bear.position = Vector3(-3, 0.38, 0.3)
	large_bear.rotation.y = 0.3
	large_bear.visible = false
	add_child(large_bear)
	player = CharacterBody3D.new()
	player.set_script(PLAYER_SCRIPT)
	player.position = Vector3(0, 0.05, 6.2)
	add_child(player)
	carried = BEAR.instantiate()
	carried.scale = Vector3.ONE * 0.42
	player.bear_anchor.rotation.y = -0.2
	player.bear_anchor.add_child(carried)
	warm_light = DirectionalLight3D.new()
	warm_light.rotation_degrees = Vector3(-33, -158, 0)
	warm_light.light_color = Color("ffd49a")
	warm_light.light_energy = 0.0
	warm_light.shadow_enabled = true
	warm_light.directional_shadow_max_distance = 24
	warm_light.shadow_bias = 0.05
	add_child(warm_light)
	actor_light = OmniLight3D.new()
	actor_light.position = Vector3(-1.8, 2.8, -1.8)
	actor_light.light_color = Color("b3c6b1")
	actor_light.light_energy = 1.0
	actor_light.omni_range = 5.5
	add_child(actor_light)
	var front_fill := OmniLight3D.new()
	front_fill.position = Vector3(1.5, 3, 4)
	front_fill.omni_range = 12
	front_fill.light_color = Color("dbbd8a")
	front_fill.light_energy = 0.22
	add_child(front_fill)
	var pane := MeshInstance3D.new()
	var plane := QuadMesh.new()
	plane.size = Vector2(5.5, 4.23)
	pane.mesh = plane
	pane.position = Vector3(0, 2.65, -5.06)
	window_material = ShaderMaterial.new()
	window_material.shader = preload("res://shaders/window.gdshader")
	pane.material_override = window_material
	room_set.add_child(pane)
	_build_rain()
	_build_dust()

func _build_rain() -> void:
	rain = MultiMeshInstance3D.new()
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.instance_count = 450
	var drop := BoxMesh.new()
	drop.size = Vector3(0.007, 0.09, 0.004)
	mm.mesh = drop
	rain.multimesh = mm
	rain.material_override = flat_material(Color(0.95, 0.81, 0.57, 0.40), true)
	rain.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	for i in range(450): rain_seeds.append(Vector3(randf_range(-2.7, 2.7), randf_range(0.6, 4.7), randf_range(-5.0, -4.89)))
	room_set.add_child(rain)

func _build_dust() -> void:
	var dust := MultiMeshInstance3D.new()
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.instance_count = 150
	var mesh := SphereMesh.new()
	mesh.radius = 0.007
	mesh.height = 0.014
	mesh.radial_segments = 4
	mesh.rings = 2
	mm.mesh = mesh
	for i in range(150): mm.set_instance_transform(i, Transform3D(Basis(), Vector3(randf_range(-5, 5), randf_range(0.2, 4.5), randf_range(-4, 6))))
	dust.multimesh = mm
	dust.material_override = flat_material(Color(0.55, 0.43, 0.24, 0.35), true)
	dust.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(dust)

func label(text: String, at: Vector2, size: Vector2, font_size: int, parent: Control, color := Color("ece2c9")) -> Label:
	var l := Label.new()
	l.text = text
	l.position = at
	l.size = size
	l.add_theme_font_override("font", FONT)
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", color)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(l)
	return l

func button(text: String, at: Vector2, size: Vector2, parent: Control, action: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.position = at
	b.size = size
	b.add_theme_font_override("font", FONT)
	b.add_theme_font_size_override("font_size", 18)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.105, 0.085, 0.9)
	style.border_color = Color("8d845f")
	style.set_border_width_all(1)
	style.set_corner_radius_all(3)
	style.content_margin_left = 20
	b.add_theme_stylebox_override("normal", style)
	var hover := style.duplicate()
	hover.bg_color = Color("284338")
	b.add_theme_stylebox_override("hover", hover)
	b.add_theme_stylebox_override("focus", hover)
	b.pressed.connect(action)
	parent.add_child(b)
	return b

func overlay(parent: Control, alpha := 0.90) -> ColorRect:
	var r := ColorRect.new()
	r.color = Color(0.016, 0.03, 0.025, alpha)
	r.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	parent.add_child(r)
	return r

func _build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	main_ui = Control.new()
	main_ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main_ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(main_ui)
	chapter_label = label("", Vector2(44, 34), Vector2(650, 48), 16, main_ui, Color("b5aa8e"))
	subtitle = label("", Vector2(210, 606), Vector2(860, 110), 25, main_ui)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
	subtitle.add_theme_constant_override("shadow_offset_x", 2)
	subtitle.add_theme_constant_override("shadow_offset_y", 2)
	prompt = label("", Vector2(300, 545), Vector2(680, 44), 19, main_ui)
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var dot := label("·", Vector2(623, 374), Vector2(34, 34), 25, main_ui, Color(0.9, 0.88, 0.73, 0.5))
	dot.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tiny_hint = label("", Vector2(44, 745), Vector2(1140, 30), 13, main_ui, Color("969480"))
	diagnostics = label("", Vector2(920, 32), Vector2(320, 70), 13, main_ui)
	diagnostics.visible = false
	title_ui = Control.new()
	title_ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main_ui.add_child(title_ui)
	overlay(title_ui, 0.30)
	label("B E F O R E   W A K I N G", Vector2(80, 170), Vector2(560, 44), 16, title_ui, Color("c5b98c"))
	label("醒来之前", Vector2(74, 218), Vector2(650, 110), 66, title_ui)
	label("他看不见我们。\n但他的手，还记得怎样照顾一只小熊。", Vector2(82, 360), Vector2(620, 100), 22, title_ui)
	button("进入这个下午     →", Vector2(82, 515), Vector2(330, 58), title_ui, _start)
	button("离开", Vector2(82, 588), Vector2(150, 44), title_ui, func(): get_tree().quit())
	label("一段可亲自走入的梦  /  建议打开声音", Vector2(82, 698), Vector2(850, 34), 14, title_ui, Color("a7a087"))
	pause_ui = Control.new()
	pause_ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main_ui.add_child(pause_ui)
	overlay(pause_ui)
	label("让这个下午等一等", Vector2(390, 145), Vector2(620, 75), 35, pause_ui)
	button("继续", Vector2(390, 245), Vector2(500, 54), pause_ui, func(): _pause(false))
	label("声音", Vector2(390, 324), Vector2(150, 36), 17, pause_ui)
	var volume := HSlider.new()
	volume.position = Vector2(555, 330)
	volume.size = Vector2(330, 30)
	volume.min_value = 0
	volume.max_value = 1
	volume.step = 0.05
	volume.value = 0.7
	volume.value_changed.connect(func(value: float): AudioServer.set_bus_volume_db(0, linear_to_db(maxf(value, 0.001))))
	pause_ui.add_child(volume)
	label("视角灵敏度", Vector2(390, 377), Vector2(160, 36), 17, pause_ui)
	var sens := HSlider.new()
	sens.position = Vector2(555, 382)
	sens.size = Vector2(330, 30)
	sens.min_value = 0.001
	sens.max_value = 0.004
	sens.step = 0.0002
	sens.value = 0.0023
	sens.value_changed.connect(func(value: float): player.sensitivity = value)
	pause_ui.add_child(sens)
	var motion := CheckButton.new()
	motion.text = "轻微步行起伏"
	motion.position = Vector2(390, 427)
	motion.size = Vector2(500, 40)
	motion.button_pressed = true
	motion.add_theme_font_override("font", FONT)
	motion.toggled.connect(func(value: bool): player.head_motion = value)
	pause_ui.add_child(motion)
	button("重新开始", Vector2(390, 500), Vector2(242, 50), pause_ui, _restart)
	button("离开梦境", Vector2(648, 500), Vector2(242, 50), pause_ui, func(): get_tree().quit())
	label("WASD 行走 · 鼠标看向四周 · E 触碰\n空格 踏地 · F 抱熊 · H 哼唱 · J 理袖 · Q 呼喊\nEsc 暂停 · 左右方向键也可转身", Vector2(390, 598), Vector2(600, 120), 15, pause_ui, Color("afa78d"))
	pause_ui.visible = false
	end_ui = Control.new()
	end_ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main_ui.add_child(end_ui)
	overlay(end_ui, 0.88)
	label("他的手，还记得。", Vector2(235, 198), Vector2(880, 85), 47, end_ui)
	end_text = label("", Vector2(240, 325), Vector2(820, 140), 25, end_ui)
	label("我们没有走到同一个世界。\n但有一个动作，从这边，到了那边。", Vector2(240, 483), Vector2(850, 100), 20, end_ui, Color("bcb49e"))
	button("再走进一次", Vector2(240, 634), Vector2(250, 54), end_ui, _restart)
	button("把这个下午留在这里", Vector2(510, 634), Vector2(360, 54), end_ui, func(): get_tree().quit())
	end_ui.visible = false
	_build_operator()

func _build_operator() -> void:
	operator_ui = Control.new()
	operator_ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main_ui.add_child(operator_ui)
	overlay(operator_ui)
	label("排练后台 / F8 返回", Vector2(130, 80), Vector2(950, 60), 28, operator_ui)
	label("正式舞台：姥爷由真人扮演。这里的角色供走位与动作预演。\nAI只提出带来源的动作；接纳不会自动换场。", Vector2(130, 155), Vector2(1000, 100), 19, operator_ui)
	ai_text = label("规则共振随游戏运行。正在检查本机AI服务。", Vector2(130, 288), Vector2(1000, 200), 20, operator_ui)
	button("准备AI动作提议", Vector2(130, 540), Vector2(300, 54), operator_ui, _propose_ai)
	button("演员接纳", Vector2(450, 540), Vector2(230, 54), operator_ui, _accept_ai)
	button("暂不采用", Vector2(700, 540), Vector2(230, 54), operator_ui, func(): pending_ai.clear(); ai_text.text = "演员保留当前演法。")
	button("返回游戏", Vector2(130, 634), Vector2(300, 54), operator_ui, _toggle_operator)
	operator_ui.visible = false

func _build_audio() -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(0.7))
	for name in ["memory", "rain", "step", "hum", "thunder"]:
		var p := AudioStreamPlayer.new()
		p.stream = load("res://assets/%s.wav" % name)
		add_child(p)
		audio[name] = p
		if name in ["memory", "rain"]:
			p.finished.connect(func(): p.play())
			p.volume_db = -30 if name == "rain" else -17
	player.walked.connect(func():
		audio.step.volume_db = -25
		audio.step.pitch_scale = randf_range(0.9, 1.1)
		audio.step.play())

func _start() -> void:
	began = true
	title_ui.visible = false
	player.can_move = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	chapter_label.text = "01  /  一个停住的下午"
	tiny_hint.text = "W A S D  行走     鼠标  看向四周     Q  呼喊     Esc  暂停"
	say("姥爷。", 4.0)
	audio.memory.play()

func _restart() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().reload_current_scene()

func _pause(value: bool) -> void:
	paused = value
	pause_ui.visible = value
	player.can_move = began and not value and story.phase != WakingStory.Phase.END
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if value else Input.MOUSE_MODE_CAPTURED
	for name in audio: audio[name].stream_paused = value

func _toggle_operator() -> void:
	operator_ui.visible = not operator_ui.visible
	player.can_move = began and not operator_ui.visible and not paused
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if operator_ui.visible else Input.MOUSE_MODE_CAPTURED

func say(text: String, duration := 6.0) -> void:
	subtitle.text = text
	subtitle_until = elapsed + duration

func _input(event: InputEvent) -> void:
	if event is InputEventKey and OS.get_cmdline_user_args().has("--input-trace"):
		var path := "user://input-trace.txt"
		var file := FileAccess.open(path, FileAccess.READ_WRITE if FileAccess.file_exists(path) else FileAccess.WRITE)
		file.seek_end()
		file.store_line("%s physical=%s logical=%s pressed=%s" % [event.as_text(), event.physical_keycode, event.keycode, event.pressed])
		file.close()

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo: return
	var supported := [KEY_F3, KEY_F8, KEY_ESCAPE, KEY_P, KEY_SPACE, KEY_H, KEY_J, KEY_Q, KEY_E, KEY_R]
	var key: int = event.physical_keycode if event.physical_keycode in supported else event.keycode
	if key == KEY_F3:
		show_diagnostics = not show_diagnostics
		diagnostics.visible = show_diagnostics
	if key == KEY_F8 and began:
		_toggle_operator()
		return
	if key in [KEY_ESCAPE, KEY_P] and began and story.phase != WakingStory.Phase.END:
		if operator_ui.visible: _toggle_operator()
		else: _pause(not paused)
		return
	if not began or paused or operator_ui.visible or story.phase == WakingStory.Phase.END: return
	match key:
		KEY_SPACE: _gesture("stomp")
		KEY_H: _gesture("sing")
		KEY_J: _gesture("sleeve")
		KEY_Q: _gesture("call")
		KEY_E: _interact()
		KEY_R: _look_at_grandpa()

func _look_at_grandpa() -> void:
	var toward := grandpa.position - player.position
	player.rotation.y = atan2(-toward.x, -toward.z)
	player.look_pitch = 0.0
	player.camera.rotation.x = 0.0

func _gesture(kind: String) -> void:
	var event := story.gesture(kind, player.position)
	if event.is_empty(): return
	if kind != "call": _trace(player.position + Vector3(0, 0.022, 0), false)
	match kind:
		"stomp":
			audio.step.volume_db = -6
			audio.step.play()
		"sing":
			singing = 1.0
			audio.hum.play()
		"sleeve":
			hug_amount = 0.65
			say("左袖上，有一道细细的补线。", 4)
		"call":
			if story.phase < WakingStory.Phase.RAIN:
				say("姥爷……你怎么又坐在这里。" if story.calls == 1 else "声音过去了。\n他没有回头。", 5)
			else:
				call_flash = 1.0
				audio.thunder.play()
				say("我的声音，成了他窗外的一声雷。", 5)

func _interact() -> void:
	if story.phase == WakingStory.Phase.EXCHANGE and player.position.distance_to(Vector3(-3, 0, 0.3)) < 2.15:
		if story.swap_bears():
			say("我把小熊放下，抱起了它。\n窗那边的小熊，轻轻动了一下。", 8)
	elif story.phase == WakingStory.Phase.CARE:
		if story.finish(): _show_end()
	elif story.phase == WakingStory.Phase.DARK:
		_gesture("sleeve")

func _on_phase(value: int) -> void:
	pending_ai.clear()
	var names := ["一个停住的下午", "地面记住了我", "我们成为天气", "近在眼前，无法抵达", "另一种靠近", "他的手还记得", "醒来之前"]
	chapter_label.text = "0%d  /  %s" % [value + 1, names[value]]
	match value:
		WakingStory.Phase.GOLD:
			say("我动了一下。\n地面先回答了我。", 5)
			tiny_hint.text = "空格  踏地     按住 F  轻轻抱熊     H  哼唱     J  理袖"
		WakingStory.Phase.RAIN:
			say("原来，我可以让这个下午动起来。", 6)
			audio.rain.play()
			tiny_hint.text = "可以继续试一试，也可以慢慢走近。     空格 / F / H / J / Q     Esc  暂停"
		WakingStory.Phase.CHASE:
			say("……姥爷！\n这次你先别走。", 7)
			tiny_hint.text = "靠近，或者停一会儿。"
		WakingStory.Phase.EXCHANGE:
			say("左边，有一只更大的小熊。\n它的左袖，也有那道补线。", 7)
			tiny_hint.text = "走向小熊。     E  放下手里的小熊"
			_trace(Vector3(-3, 0.03, 0.3), true)
		WakingStory.Phase.CARE:
			tiny_hint.text = "转身看看姥爷。     R  看向他     也可以再抱一会儿。"
			carried.scale = Vector3.ONE * 0.50
			memory_pulse = 0.0
			care_announced = false

func _show_end() -> void:
	end_ui.visible = true
	end_text.text = story.memory_line()
	player.can_move = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_save_session()

func _trace(start: Vector3, returning: bool) -> void:
	var line := MeshInstance3D.new()
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var end := Vector3(-0.8, 0.028, -2.3)
	if story.phase <= WakingStory.Phase.GOLD and not returning:
		end = start.lerp(end, clampf(0.25 + story.energy * 0.85, 0.3, 1.0))
	var previous := start
	for i in range(1, 45):
		var a := float(i) / 44.0
		var point := start.lerp(end, a)
		point.x += sin(float(i) * 1.4 + paths.size()) * 0.045 * sin(a * PI)
		var width := 0.008 if not returning else 0.014
		var side := Vector3(-(point - previous).z, 0, (point - previous).x).normalized() * width
		var vertices := [previous - side, point - side, point + side, previous - side, point + side, previous + side]
		for j in range(6):
			st.set_uv(Vector2(float(i - 1) / 44.0 if j in [0, 3, 5] else a, 0))
			st.add_vertex(vertices[j])
		previous = point
	line.mesh = st.commit()
	var gold := ShaderMaterial.new()
	gold.shader = preload("res://shaders/gold.gdshader")
	line.material_override = gold
	line.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(line)
	paths.append({"node": line, "born": elapsed, "returning": returning})
	if paths.size() > 32:
		paths[0].node.queue_free()
		paths.pop_front()

func _process(delta: float) -> void:
	if paused: return
	elapsed += delta
	var distance := player.position.distance_to(Vector3(-0.8, 0, -2.5))
	if began and not operator_ui.visible:
		story.tick(delta, distance)
		if Input.is_physical_key_pressed(KEY_F) and story.phase < WakingStory.Phase.END:
			hug_amount = move_toward(hug_amount, 1.0, delta * 2)
			if story.hold(delta, player.position): _trace(player.position + Vector3(0, 0.028, 0), false)
		else:
			hug_amount = move_toward(hug_amount, 0.0, delta * 0.8)
			story.held_seconds = 0.0
		if story.phase == WakingStory.Phase.DARK and story.phase_age > 9:
			prompt.text = "试着踏一下地面  [空格]    或轻轻抱住它  [按住 F]"
		elif story.phase == WakingStory.Phase.EXCHANGE:
			prompt.text = "[ E ]  放下小熊，抱起它" if player.position.distance_to(Vector3(-3, 0, 0.3)) < 2.15 else ""
		elif story.phase == WakingStory.Phase.CARE and story.phase_age > 14:
			prompt.text = "[ E ]  在这里，再坐一会儿"
		else: prompt.text = ""
	if elapsed > subtitle_until: subtitle.modulate.a = move_toward(subtitle.modulate.a, 0, delta)
	else: subtitle.modulate.a = move_toward(subtitle.modulate.a, 1, delta * 3)
	var warm_target := 1.0 if story.phase >= WakingStory.Phase.RAIN else 0.0
	warmth = move_toward(warmth, warm_target, delta * 0.20)
	room_set.visible = warmth > 0.002
	lap_bear.visible = warmth > 0.1
	window_material.set_shader_parameter("weather", warmth)
	window_material.set_shader_parameter("song", singing)
	warm_light.light_energy = warmth * (1.20 + call_flash * 1.5)
	environment.ambient_light_energy = 0.07 + warmth * 0.22
	actor_light.light_energy = 0.9 + warmth * 0.25
	singing = maxf(0, singing - delta * 0.018)
	call_flash = move_toward(call_flash, 0, delta * 1.2)
	if story.phase == WakingStory.Phase.CHASE:
		var retreat := clampf((3.2 - distance) * 0.8, 0.0, 1.6)
		room_set.position.z = lerpf(room_set.position.z, -retreat, delta * 1.5)
		room_set.rotation.y = lerp_angle(room_set.rotation.y, sin(story.phase_age * 0.18) * 0.20, delta)
	else:
		room_set.position.z = lerpf(room_set.position.z, 0, delta * 0.5)
		room_set.rotation.y = lerp_angle(room_set.rotation.y, 0, delta)
	large_bear.visible = story.phase >= WakingStory.Phase.EXCHANGE and not story.exchanged
	find_named(room, "ExchangePedestal").visible = story.phase >= WakingStory.Phase.EXCHANGE
	large_bear.position.y = 0.38 + sin(elapsed * 0.8) * 0.008
	grandpa.rotation.y = lerp_angle(grandpa.rotation.y, 0.95 if story.phase >= WakingStory.Phase.CARE else (0.55 if story.phase >= WakingStory.Phase.RAIN else 0.0), delta * 0.7)
	var held_position := Vector3(0.50, -0.74, -0.90) if story.exchanged else Vector3(0.36, -0.57, -0.75)
	player.bear_anchor.position = held_position + Vector3(-hug_amount * 0.08, hug_amount * 0.12, hug_amount * 0.10)
	carried.rotation.z = sin(elapsed * 1.2) * 0.025 + hug_amount * 0.04
	_update_care(delta)
	for i in range(rain_seeds.size()):
		var pos := rain_seeds[i]
		pos.y = fposmod(pos.y - elapsed * (1.5 + float(i % 7) * 0.1), 4.05) + 0.58
		pos.x += sin(elapsed * 0.8 + pos.y) * 0.028
		rain.multimesh.set_instance_transform(i, Transform3D(Basis(Vector3.FORWARD, -0.08), pos))
	rain.multimesh.visible_instance_count = 120 if story.phase >= WakingStory.Phase.CARE else 450
	for p in paths:
		var age: float = elapsed - p.born
		p.node.material_override.set_shader_parameter("reveal", clampf(age / 1.4, 0, 1.03))
		p.node.material_override.set_shader_parameter("fade", clampf(1.0 - age * 0.013, 0.2, 0.9))
	if show_diagnostics:
		diagnostics.text = "%d FPS  /  %s\n%.1fs  /  %d 个动作" % [Engine.get_frames_per_second(), "Compatibility", story.elapsed, story.events.size()]
	if not qa_mode.is_empty(): _qa(delta)

func _update_care(delta: float) -> void:
	if not story.exchanged: return
	var local_lap := Vector3(0, 0.94, -0.40).rotated(Vector3.UP, grandpa.rotation.y)
	lap_bear.position = lap_bear.position.lerp(grandpa.position + local_lap, delta * 1.6)
	var rhythm_time: float = story.rhythm[memory_index % story.rhythm.size()]
	memory_pulse += delta
	if memory_pulse > rhythm_time * (1.5 if story.phase_age > 12 else 1.0):
		memory_pulse = 0
		memory_index += 1
		if memory_index < 8:
			var remembered := Vector3(0, 0.025, 4.5)
			for event in story.events:
				if event.id == story.memory_event_id:
					var p: Array = event.position
					remembered = Vector3(p[0], 0.025, p[2])
			_trace(remembered, true)
	var motion_kind: String = {"rock": "sing", "sleeve": "sleeve", "cheek": "hug", "pat": "stomp"}.get(ai_action_override, story.memory_kind)
	match motion_kind:
		"stomp":
			lap_bear.rotation.z = exp(-pow((memory_pulse - 0.18) / 0.13, 2)) * 0.018
		"sleeve":
			lap_bear.rotation.z = 0.04
		"sing": lap_bear.rotation.z = sin(elapsed * 1.3) * 0.08
		_: lap_bear.position.y += sin(elapsed * 0.6) * 0.012
	# Targets follow the actual bear transform, including its rocking and pickup motion.
	var left_target := Vector3(-0.16, 0.28, 0.04)
	var right_target := Vector3(0.15, 0.70, 0.12)
	if motion_kind == "stomp": right_target.y = 0.51 + exp(-pow((memory_pulse - 0.18) / 0.13, 2)) * 0.06
	if motion_kind == "sleeve":
		right_target = Vector3(-0.22, 0.43 + sin(elapsed * 0.8) * 0.02, 0.12)
	if story.phase_age > 7.5 and story.phase_age < 11:
		right_target = Vector3(0.16, lerpf(0.30, 0.53, clampf((story.phase_age - 7.5) / 3.5, 0, 1)), 0.16)
	_pose_arm("L", lap_bear.to_global(left_target), delta)
	_pose_arm("R", lap_bear.to_global(right_target), delta)
	find_named(lap_bear, "BearGarment").visible = story.phase_age > 7.5
	audio.rain.volume_db = lerpf(audio.rain.volume_db, -35, delta * 0.25)
	if story.phase_age > 8 and not care_announced:
		care_announced = true
		say(story.memory_line(), 9)

func _pose_arm(side: String, target_world: Vector3, delta: float) -> void:
	hand_targets[side] = target_world
	var arm := find_named(grandpa, "GrandpaArm" + side)
	var elbow := find_named(grandpa, "GrandpaElbow" + side)
	var hand := find_named(grandpa, "GrandpaHand" + side)
	var shoulder := arm.position
	var target: Vector3 = arm.get_parent().to_local(target_world)
	var upper := elbow.position
	var lower := hand.position
	var span := target - shoulder
	var distance := clampf(span.length(), 0.10, upper.length() + lower.length() - 0.015)
	var direction := span.normalized()
	var bend := Vector3(-1 if side == "L" else 1, -0.65, 0.20)
	bend = (bend - direction * bend.dot(direction)).normalized()
	var along := (upper.length_squared() - lower.length_squared() + distance * distance) / (2 * distance)
	var height := sqrt(maxf(0, upper.length_squared() - along * along))
	var elbow_at := shoulder + direction * along + bend * height
	var upper_rotation := Quaternion(upper.normalized(), (elbow_at - shoulder).normalized())
	var forearm_direction := upper_rotation.inverse() * (target - elbow_at).normalized()
	var lower_rotation := Quaternion(lower.normalized(), forearm_direction)
	arm.quaternion = arm.quaternion.slerp(upper_rotation, clampf(delta * 3.5, 0, 1))
	elbow.quaternion = elbow.quaternion.slerp(lower_rotation, clampf(delta * 3.5, 0, 1))

func _save_session() -> void:
	var file := FileAccess.open("user://last-dream.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify({"version": "0.2", "events": story.events, "memory_kind": story.memory_kind, "memory_event_id": story.memory_event_id, "rhythm": story.rhythm, "input": "keyboard / mouse", "live_actor": false}, "  "))

func _setup_ai() -> void:
	ai_request = HTTPRequest.new()
	ai_request.timeout = 30
	add_child(ai_request)
	ai_request.request_completed.connect(_ai_done)
	var status := HTTPRequest.new()
	status.timeout = 2
	add_child(status)
	status.request_completed.connect(func(_result: int, code: int, _headers: PackedStringArray, body: PackedByteArray):
		if code == 200:
			var data = JSON.parse_string(body.get_string_from_utf8())
			api_available = data is Dictionary and data.get("available", false)
		ai_text.text = "本机AI服务可用。只有点击提议才调用。" if api_available else "本机AI服务未连接。规则共振可完整运行；连接既有排练服务后可再试。"
		status.queue_free())
	status.request("http://127.0.0.1:4173/api/status")

func _propose_ai() -> void:
	if ai_busy: return
	if story.events.is_empty():
		ai_text.text = "先在游戏中留下一个动作。"
		return
	var events: Array[Dictionary] = []
	for e in story.events.slice(-24):
		if e.kind != "call": events.append({"id": e.id, "who": "A", "kind": e.kind, "note": "本次动作时间 %.2f 秒；保留节奏与停顿" % e.at})
	if events.is_empty():
		ai_text.text = "先留下一个身体动作，再准备共振。"
		return
	var phase_names := ["dark", "gold", "rain", "chase", "exchange", "care", "end"]
	var data := {"epoch": story.epoch, "chapter": phase_names[story.phase], "events": events, "responded": []}
	ai_busy = true
	ai_text.text = "AI正在准备动作建议。你可以返回游戏，继续表演。"
	var error := ai_request.request("http://127.0.0.1:4173/api/propose", ["Content-Type: application/json"], HTTPClient.METHOD_POST, JSON.stringify(data))
	if error != OK:
		ai_busy = false
		ai_text.text = "请求没有发出，规则共振保持运行。"

func _ai_done(_result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	ai_busy = false
	var data = JSON.parse_string(body.get_string_from_utf8())
	if code != 200 or not data is Dictionary:
		ai_text.text = "AI暂不可用，当前演法继续。"
		return
	if data.get("epoch", -1) != story.epoch:
		ai_text.text = "段落已经改变；迟到提议已丢弃。"
		return
	var found := false
	for e in story.events:
		if e.id == data.get("sourceEvent", "") and data.get("who", "") == "A": found = true
	if not found:
		ai_text.text = "来源无法核实，未采用。"
		return
	pending_ai = data
	ai_text.text = "来源 %s / 真实生成\n\n%s\n\n%s" % [data.sourceEvent, data.actorCue, data.visualCue]
	if qa_mode == "ai":
		print("NATIVE_AI_VERIFIED source=", data.sourceEvent, " provider=", data.get("provider", ""))
		_accept_ai()

func _accept_ai() -> void:
	if pending_ai.is_empty() or pending_ai.get("epoch", -1) != story.epoch:
		ai_text.text = "没有可接纳的当前提议。"
		return
	if not story.remember_event(pending_ai.sourceEvent):
		ai_text.text = "来源动作不可用于回调，未改变记忆。"
		pending_ai.clear()
		return
	ai_action_override = pending_ai.action
	ai_text.text = "演员已接纳：\n" + pending_ai.actorCue + "\n\n游戏只执行相应动作类别，文字细节由真人演绎。"
	pending_ai.clear()

func _qa(delta: float) -> void:
	qa_clock += delta
	if qa_mode == "collision":
		player.qa_direction = Vector3.RIGHT
		if qa_clock > 7.0:
			var passed: bool = player.position.x > 4.8 and player.position.x < 5.3
			print("COLLISION_TEST ", "PASS" if passed else "FAIL", " position=", player.position)
			get_tree().quit(0 if passed else 2)
		return
	# Automated complete-flow checks are separate from manual play. Movement still uses collision physics.
	if qa_step == 0 and qa_clock > 2:
		_gesture("call")
		print("QA_CALL_DARK ", story.phase == WakingStory.Phase.DARK)
		qa_step = 1
	if qa_step == 1 and qa_clock > 3:
		_gesture("hug" if qa_mode == "quiet" else "stomp")
		qa_step = 2
	if qa_step == 2 and qa_clock > 4.2:
		_gesture("hug" if qa_mode == "quiet" else "stomp")
		qa_step = 3
	if qa_step == 3 and qa_clock > 5.5:
		_gesture("sleeve" if qa_mode == "quiet" else "stomp")
		qa_step = 4
	if story.phase == WakingStory.Phase.RAIN and story.phase_age > 9:
		player.qa_direction = Vector3(0, 0, -1) if player.position.z > 0.3 else Vector3.ZERO
	if qa_mode == "ai" and story.phase == WakingStory.Phase.RAIN and story.phase_age > 3 and not qa_saved.has("ai_requested"):
		qa_saved["ai_requested"] = true
		_propose_ai()
	if story.phase == WakingStory.Phase.CHASE: player.qa_direction = Vector3.ZERO
	if story.phase == WakingStory.Phase.EXCHANGE:
		player.qa_direction = Vector3(-3, player.position.y, 1.9) - player.position
		if player.position.distance_to(Vector3(-3, 0, 0.3)) < 1.9: _interact()
	if story.phase == WakingStory.Phase.CARE:
		player.qa_direction = Vector3.ZERO
		_look_at_grandpa()
		if story.phase_age > 17: _interact()
	if DisplayServer.get_name() != "headless" and story.phase == WakingStory.Phase.CARE and story.phase_age > 12 and not qa_saved.has("dressed"):
		qa_saved["dressed"] = true
		for side in ["L", "R"]:
			var error := find_named(grandpa, "GrandpaHand" + side).global_position.distance_to(hand_targets[side])
			print("QA_HAND_CONTACT ", side, " error_metres=", error)
			if error > 0.09: push_error("Hand contact exceeded prototype tolerance")
		await RenderingServer.frame_post_draw
		var care_dir := OS.get_environment("BEFORE_WAKING_QA_OUT")
		if care_dir.is_empty(): care_dir = OS.get_user_data_dir() + "/qa"
		DirAccess.make_dir_recursive_absolute(care_dir)
		get_viewport().get_texture().get_image().save_png(care_dir + "/game-%s-dressed.png" % qa_mode)
	if DisplayServer.get_name() != "headless" and story.phase_age > 5 and story.phase in [WakingStory.Phase.RAIN, WakingStory.Phase.CARE] and not qa_saved.has(story.phase):
		qa_saved[story.phase] = true
		await RenderingServer.frame_post_draw
		var output_dir := OS.get_environment("BEFORE_WAKING_QA_OUT")
		if output_dir.is_empty(): output_dir = OS.get_user_data_dir() + "/qa"
		DirAccess.make_dir_recursive_absolute(output_dir)
		get_viewport().get_texture().get_image().save_png(output_dir + "/game-%s-%s.png" % [qa_mode, story.phase])
	if story.phase == WakingStory.Phase.END and qa_step != 99:
		qa_step = 99
		print("QA_COMPLETE ", qa_mode, " memory=", story.memory_kind, " events=", story.events.size(), " fps=", Engine.get_frames_per_second())
		await get_tree().create_timer(1).timeout
		get_tree().quit()
	if qa_clock > 100:
		push_error("QA_TIMEOUT phase=%s" % story.phase)
		get_tree().quit(2)
