extends RefCounted
class_name WakingStory

enum Phase { DARK, GOLD, RAIN, CHASE, EXCHANGE, CARE, END }
var phase := Phase.DARK
var phase_age := 0.0
var elapsed := 0.0
var events: Array[Dictionary] = []
var energy := 0.0
var exchanged := false
var calls := 0
var approach_time := 0.0
var epoch := 0
var memory_kind := "hug"
var memory_event_id := ""
var rhythm: Array[float] = [0.6, 0.6, 1.2]
var held_seconds := 0.0
signal changed(value: int)

func tick(delta: float, distance: float) -> void:
	elapsed += delta
	phase_age += delta
	if phase == Phase.GOLD and phase_age > 3.5 and energy > 0.65:
		go(Phase.RAIN)
	if phase == Phase.RAIN and phase_age > 8.0 and distance < 3.1:
		go(Phase.CHASE)
	if phase == Phase.CHASE:
		if distance < 3.0: approach_time += delta
		if approach_time > 6.0 or phase_age > 24.0: go(Phase.EXCHANGE)

func gesture(kind: String, position: Vector3) -> Dictionary:
	if phase >= Phase.END: return {}
	var event := {"id": "m%d" % (events.size() + 1), "who": "A", "kind": kind, "at": elapsed, "position": [position.x, position.y, position.z]}
	events.append(event)
	if kind == "call":
		calls += 1
	else:
		energy += 0.3 if kind == "stomp" else 0.4
		if phase < Phase.CARE:
			memory_kind = kind
			memory_event_id = event.id
		if phase == Phase.DARK: go(Phase.GOLD)
	return event

func hold(delta: float, position: Vector3) -> bool:
	held_seconds += delta
	energy += delta * 0.18
	if held_seconds >= 1.5:
		held_seconds = 0.0
		gesture("hug", position)
		return true
	return false

func swap_bears() -> bool:
	if phase != Phase.EXCHANGE or exchanged: return false
	exchanged = true
	_update_rhythm()
	go(Phase.CARE)
	return true

func _update_rhythm() -> void:
	var timings: Array[float] = []
	for e in events:
		if e.kind == memory_kind: timings.append(e.at)
	if timings.size() > 1:
		rhythm.clear()
		for i in range(maxi(1, timings.size() - 3), timings.size()):
			rhythm.append(clampf(timings[i] - timings[i - 1], 0.35, 1.8))

func finish() -> bool:
	if phase != Phase.CARE or phase_age < 14.0: return false
	go(Phase.END)
	return true

func remember_event(event_id: String) -> bool:
	for event in events:
		if event.id == event_id and event.kind != "call":
			memory_kind = event.kind
			memory_event_id = event.id
			_update_rhythm()
			return true
	return false

func go(value: int) -> void:
	phase = value
	phase_age = 0.0
	epoch += 1
	changed.emit(value)

func memory_line() -> String:
	match memory_kind:
		"stomp": return "先是那个节奏，然后慢下来。\n那是我刚才留在地上的节奏。"
		"sing": return "他随着那段旋律，轻轻晃着小熊。\n我认出了那个停顿。"
		"sleeve": return "他把左袖拉平，又摸了摸那道补线。\n我也这样摸过。"
		_: return "他把小熊抱近了一点。\n就像刚才，我抱着它的那样。"
