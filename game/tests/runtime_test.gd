extends SceneTree

var failures := 0

func check(value: bool, message: String) -> void:
	if not value:
		push_error(message)
		failures += 1

func keypress(code: Key, physical: Key = KEY_NONE) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.physical_keycode = physical
	event.pressed = true
	Input.parse_input_event(event)
	event = InputEventKey.new()
	event.keycode = code
	event.physical_keycode = physical
	Input.parse_input_event(event)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var packed := load("res://main.tscn") as PackedScene
	var game := packed.instantiate()
	root.add_child(game)
	current_scene = game
	await process_frame
	check(game.title_ui.visible and not game.began, "入口应停在开场菜单")
	game._start()
	await process_frame
	keypress(KEY_Q)
	await process_frame
	check(game.story.calls == 1 and game.story.phase == WakingStory.Phase.DARK, "逻辑键码呼喊应生效且保持黑暗")
	keypress(KEY_P, KEY_F12)
	await process_frame
	check(game.paused and game.pause_ui.visible and not game.player.can_move, "暂停应释放移动并显示菜单")
	var frozen: float = game.story.elapsed
	await create_timer(0.15).timeout
	check(is_equal_approx(frozen, game.story.elapsed), "暂停时剧情时钟不得前进")
	keypress(KEY_P)
	await process_frame
	check(not game.paused and game.player.can_move, "继续应恢复移动")
	keypress(KEY_SPACE)
	await process_frame
	check(game.story.phase == WakingStory.Phase.GOLD, "逻辑空格输入应触发首次共振")
	game.player.position = Vector3(-0.8, 0.05, 0)
	game.player.velocity = Vector3.ZERO
	game.player.qa_direction = Vector3.FORWARD
	await create_timer(1.3).timeout
	check(game.player.position.z > -1.75 and game.player.position.z < -1.55, "角色应被绿色椅子挡住")
	game.player.position = Vector3(1.7, 0.05, 0)
	game.player.velocity = Vector3.ZERO
	await create_timer(1.5).timeout
	check(game.player.position.z > -2.30 and game.player.position.z < -2.10, "角色应被石板桌挡住")
	game.player.qa_direction = Vector3.ZERO
	game._restart()
	await process_frame
	await process_frame
	game = current_scene
	check(game.title_ui.visible and not game.began and game.story.events.is_empty(), "重玩应回到空白新场次")
	print("RUNTIME_TESTS ", "PASS" if failures == 0 else "FAIL", " failures=", failures)
	quit(failures)
