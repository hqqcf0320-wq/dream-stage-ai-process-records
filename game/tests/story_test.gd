extends SceneTree

var failures := 0

func check(value: bool, message: String) -> void:
	if not value:
		push_error(message)
		failures += 1

func _initialize() -> void:
	var quiet := WakingStory.new()
	quiet.gesture("call", Vector3.ZERO)
	check(quiet.phase == WakingStory.Phase.DARK, "呼喊不能唤醒房间")
	for i in range(80):
		quiet.hold(0.1, Vector3.ZERO)
		quiet.tick(0.1, 8.0)
	check(quiet.phase == WakingStory.Phase.RAIN, "安静抱熊应能唤醒房间")
	check(not quiet.swap_bears(), "不得在交换段之前交换")
	quiet.go(WakingStory.Phase.EXCHANGE)
	check(quiet.swap_bears(), "交换段可以交换")
	check(not quiet.swap_bears(), "不得重复交换")
	check(not quiet.finish(), "照顾需要停留")
	quiet.tick(15, 4)
	check(quiet.finish(), "照顾后可完成")
	var warm := WakingStory.new()
	for i in range(3):
		warm.gesture("stomp", Vector3(i, 0, 0))
		warm.tick(0.6, 8.0)
	warm.tick(4, 8)
	check(warm.phase == WakingStory.Phase.RAIN, "踏步路径可以唤醒")
	warm.gesture("call", Vector3.ZERO)
	check(warm.memory_kind == "stomp", "呼喊不能覆盖已有身体记忆")
	check(not warm.remember_event("invented"), "AI不可引用不存在的经历")
	check(warm.remember_event(warm.events[0].id), "AI回调绑定真实动作")
	check(warm.memory_kind == "stomp", "回应方式不改写玩家原动作")
	check(warm.memory_event_id == warm.events[0].id, "回调位置绑定被选中的真实事件")
	warm.go(WakingStory.Phase.EXCHANGE)
	warm.swap_bears()
	check(absf(warm.rhythm[0] - 0.6) < 0.01, "回调保留实际动作间隔")
	check(warm.events[0].position != warm.events[1].position, "事件保留各自空间来源")
	print("STORY_TESTS ", "PASS" if failures == 0 else "FAIL", " failures=", failures)
	quit(failures)
