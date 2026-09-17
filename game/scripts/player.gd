extends CharacterBody3D

var camera: Camera3D
var look_pitch := 0.0
var sensitivity := 0.0023
var can_move := false
var head_motion := true
var walk_clock := 0.0
var foot_clock := 0.0
var qa_direction := Vector3.ZERO
var bear_anchor: Node3D
signal walked

func _ready() -> void:
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.24
	capsule.height = 1.6
	shape.shape = capsule
	shape.position.y = 0.8
	add_child(shape)
	camera = Camera3D.new()
	camera.position.y = 1.55
	camera.fov = 66
	camera.near = 0.045
	add_child(camera)
	camera.current = true
	bear_anchor = Node3D.new()
	bear_anchor.position = Vector3(0.36, -0.57, -0.75)
	bear_anchor.rotation.y = PI - 0.18
	camera.add_child(bear_anchor)

func _unhandled_input(event: InputEvent) -> void:
	if not can_move or Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	if event is InputEventMouseMotion:
		if event.relative.length() > 200: return
		rotation.y -= event.relative.x * sensitivity
		look_pitch = clampf(look_pitch - event.relative.y * sensitivity, -0.85, 0.7)
		camera.rotation.x = look_pitch

func _physics_process(delta: float) -> void:
	var direction := Vector3.ZERO
	if can_move:
		var axis := Vector2(float(Input.is_physical_key_pressed(KEY_D)) - float(Input.is_physical_key_pressed(KEY_A)), float(Input.is_physical_key_pressed(KEY_S)) - float(Input.is_physical_key_pressed(KEY_W)))
		direction = (transform.basis * Vector3(axis.x, 0, axis.y)).normalized()
		if Input.is_physical_key_pressed(KEY_LEFT): rotation.y += delta * 1.1
		if Input.is_physical_key_pressed(KEY_RIGHT): rotation.y -= delta * 1.1
	if qa_direction.length() > 0.01 and can_move: direction = qa_direction.normalized()
	var speed := 2.2
	if Input.is_physical_key_pressed(KEY_SHIFT): speed = 3.1
	velocity.x = move_toward(velocity.x, direction.x * speed, delta * 12.0)
	velocity.z = move_toward(velocity.z, direction.z * speed, delta * 12.0)
	velocity.y -= 12.0 * delta
	if is_on_floor(): velocity.y = -0.4
	move_and_slide()
	if direction.length() > 0.1 and can_move:
		walk_clock += delta * speed * 3.0
		foot_clock += delta
		if foot_clock > 0.55:
			foot_clock = 0.0
			walked.emit()
	var bob := sin(walk_clock) * 0.012 if head_motion and direction.length() > 0.1 else 0.0
	camera.position.y = lerpf(camera.position.y, 1.55 + bob, delta * 8.0)
