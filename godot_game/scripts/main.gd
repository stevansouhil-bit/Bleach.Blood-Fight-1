extends Node3D

var player: Node3D
var enemy: Node3D
var player_sword: Node3D
var enemy_sword: Node3D

var player_hp := 100
var enemy_hp := 100
var move_dir := 0.0
var player_attack_cd := 0.0
var energy_cd := 0.0
var enemy_attack_cd := 0.8
var enemy_think_cd := 0.0
var round_over := false

var status_label: Label
var message_label: Label
var player_bar: ProgressBar
var enemy_bar: ProgressBar

const PLAYER_START := Vector3(-2.0, 0.95, 0.0)
const ENEMY_START := Vector3(2.0, 0.95, 0.0)

func _ready() -> void:
    make_arena()
    player = make_fighter(PLAYER_START, Color(0.045, 0.09, 0.19), Color(0.05, 0.8, 1.0))
    enemy = make_fighter(ENEMY_START, Color(0.19, 0.025, 0.055), Color(1.0, 0.055, 0.19))
    player_sword = player.get_node("SwordPivot")
    enemy_sword = enemy.get_node("SwordPivot")
    make_camera()
    make_lights()
    make_ui()
    update_status()

func material(tint: Color, metal := 0.0, glow := false) -> StandardMaterial3D:
    var mat := StandardMaterial3D.new()
    mat.albedo_color = tint
    mat.metallic = metal
    mat.roughness = 0.36
    if glow:
        mat.emission_enabled = true
        mat.emission = tint
    return mat

func part(parent: Node3D, mesh: Mesh, pos: Vector3, mat: Material, part_name: String) -> MeshInstance3D:
    var node := MeshInstance3D.new()
    node.name = part_name
    node.mesh = mesh
    node.position = pos
    node.material_override = mat
    parent.add_child(node)
    return node

func make_arena() -> void:
    var floor := MeshInstance3D.new()
    var plane := PlaneMesh.new()
    plane.size = Vector2(18, 12)
    floor.mesh = plane
    floor.material_override = material(Color(0.025, 0.02, 0.055), 0.3)
    add_child(floor)

    for i in range(9):
        var line := part(self, BoxMesh.new(), Vector3(-8 + i * 2, 0.018, 0), material(Color(0.24, 0.035, 0.65), 0.2, true), "ArenaLine")
        (line.mesh as BoxMesh).size = Vector3(0.025, 0.018, 12)

    for side in [-1.0, 1.0]:
        var pillar := part(self, BoxMesh.new(), Vector3(side * 7.6, 1.25, -2.8), material(Color(0.08, 0.12, 0.4), 0.4, true), "ArenaPillar")
        (pillar.mesh as BoxMesh).size = Vector3(0.24, 2.5, 0.24)

func make_fighter(pos: Vector3, tint: Color, aura_color: Color) -> Node3D:
    var fighter := Node3D.new()
    fighter.position = pos
    add_child(fighter)

    var cloth := material(Color(0.018, 0.018, 0.035))
    var armor := material(tint, 0.25)
    var skin := material(Color(0.76, 0.53, 0.4))
    var hair := material(Color(0.035, 0.025, 0.055))
    var aura := material(aura_color, 0.15, true)
    var steel := material(Color(0.7, 0.86, 1.0), 0.85, true)

    var torso_mesh := CapsuleMesh.new()
    torso_mesh.radius = 0.34
    torso_mesh.height = 1.1
    part(fighter, torso_mesh, Vector3(0, 0.0, 0), armor, "Torso")

    var coat_mesh := BoxMesh.new()
    coat_mesh.size = Vector3(0.72, 0.72, 0.22)
    part(fighter, coat_mesh, Vector3(0, -0.14, 0.13), cloth, "Coat")

    var head_mesh := SphereMesh.new()
    head_mesh.radius = 0.27
    head_mesh.height = 0.54
    part(fighter, head_mesh, Vector3(0, 0.77, 0), skin, "Head")

    var hair_mesh := SphereMesh.new()
    hair_mesh.radius = 0.29
    hair_mesh.height = 0.34
    part(fighter, hair_mesh, Vector3(0, 0.96, -0.015), hair, "Hair")

    var eye_mesh := BoxMesh.new()
    eye_mesh.size = Vector3(0.22, 0.045, 0.035)
    part(fighter, eye_mesh, Vector3(0, 0.79, 0.245), aura, "Eyes")

    var arm_mesh := CapsuleMesh.new()
    arm_mesh.radius = 0.105
    arm_mesh.height = 0.64
    var arm_left := part(fighter, arm_mesh, Vector3(-0.42, 0.0, 0), armor, "ArmLeft")
    arm_left.rotation.z = -0.2
    var arm_right := part(fighter, arm_mesh, Vector3(0.42, 0.0, 0), armor, "ArmRight")
    arm_right.rotation.z = 0.2

    var leg_mesh := CapsuleMesh.new()
    leg_mesh.radius = 0.13
    leg_mesh.height = 0.68
    part(fighter, leg_mesh, Vector3(-0.18, -0.56, 0), cloth, "LegLeft")
    part(fighter, leg_mesh, Vector3(0.18, -0.56, 0), cloth, "LegRight")

    var belt_mesh := BoxMesh.new()
    belt_mesh.size = Vector3(0.66, 0.09, 0.24)
    part(fighter, belt_mesh, Vector3(0, -0.34, 0.03), aura, "Belt")

    var pivot := Node3D.new()
    pivot.name = "SwordPivot"
    pivot.position = Vector3(0.42, 0.05, 0.05)
    fighter.add_child(pivot)

    var blade := BoxMesh.new()
    blade.size = Vector3(0.9, 0.065, 0.075)
    part(pivot, blade, Vector3(0.48, 0, 0), steel, "Blade")

    var guard := BoxMesh.new()
    guard.size = Vector3(0.09, 0.2, 0.12)
    part(pivot, guard, Vector3(0.02, 0, 0), aura, "Guard")

    var handle := BoxMesh.new()
    handle.size = Vector3(0.24, 0.07, 0.08)
    part(pivot, handle, Vector3(-0.13, 0, 0), cloth, "Handle")

    var aura_mesh := SphereMesh.new()
    aura_mesh.radius = 0.72
    aura_mesh.height = 1.55
    var aura_part := part(fighter, aura_mesh, Vector3(0, 0, -0.12), aura, "Aura")
    aura_part.scale = Vector3(0.82, 0.9, 0.42)

    return fighter

func make_camera() -> void:
    var camera := Camera3D.new()
    camera.position = Vector3(0, 5.0, 10.5)
    camera.rotation_degrees = Vector3(-23, 0, 0)
    camera.current = true
    add_child(camera)

func make_lights() -> void:
    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-48, -25, 0)
    sun.light_energy = 1.5
    add_child(sun)

    var fill := OmniLight3D.new()
    fill.position = Vector3(0, 3.5, 0)
    fill.light_color = Color(0.32, 0.16, 1.0)
    fill.light_energy = 1.6
    fill.omni_range = 14
    add_child(fill)

func make_ui() -> void:
    var layer := CanvasLayer.new()
    add_child(layer)

    var panel := VBoxContainer.new()
    panel.position = Vector2(14, 12)
    panel.add_theme_constant_override("separation", 4)
    layer.add_child(panel)

    status_label = Label.new()
    status_label.add_theme_font_size_override("font_size", 20)
    status_label.add_theme_color_override("font_color", Color(0.65, 0.9, 1.0))
    panel.add_child(status_label)

    player_bar = ProgressBar.new()
    player_bar.custom_minimum_size = Vector2(230, 17)
    player_bar.max_value = 100
    panel.add_child(player_bar)

    enemy_bar = ProgressBar.new()
    enemy_bar.custom_minimum_size = Vector2(230, 17)
    enemy_bar.max_value = 100
    panel.add_child(enemy_bar)

    message_label = Label.new()
    message_label.text = "SOUL ARENA  |  DEFEAT THE RIVAL"
    message_label.add_theme_font_size_override("font_size", 14)
    message_label.add_theme_color_override("font_color", Color(0.9, 0.7, 1.0))
    panel.add_child(message_label)

    var controls := HBoxContainer.new()
    controls.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
    controls.offset_top = -86
    controls.offset_bottom = -12
    controls.offset_left = 8
    controls.offset_right = -8
    controls.add_theme_constant_override("separation", 5)
    layer.add_child(controls)

    add_button(controls, "◀", func(): move_dir = -1.0)
    add_button(controls, "STOP", func(): move_dir = 0.0)
    add_button(controls, "▶", func(): move_dir = 1.0)
    add_button(controls, "SWORD", sword_attack)
    add_button(controls, "ENERGY", energy_attack)
    add_button(controls, "RESET", reset_round)

func add_button(parent: Control, caption: String, action: Callable) -> void:
    var button := Button.new()
    button.text = caption
    button.custom_minimum_size = Vector2(70, 58)
    button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    button.add_theme_font_size_override("font_size", 14)
    button.pressed.connect(action)
    parent.add_child(button)

func _process(delta: float) -> void:
    if round_over:
        return

    player_attack_cd = maxf(0.0, player_attack_cd - delta)
    energy_cd = maxf(0.0, energy_cd - delta)
    enemy_attack_cd = maxf(0.0, enemy_attack_cd - delta)
    enemy_think_cd = maxf(0.0, enemy_think_cd - delta)

    player.position.x = clampf(player.position.x + move_dir * delta * 3.2, -5.5, 5.5)

    if player_attack_cd > 0.0 and player_attack_cd < 0.18:
        player_sword.rotation.z = -0.85
    else:
        player_sword.rotation.z = 0.0

    if enemy_attack_cd > 0.55 and enemy_attack_cd < 0.8:
        enemy_sword.rotation.z = -0.8
    else:
        enemy_sword.rotation.z = 0.0

    # Computer-controlled rival: approach, keep distance, and attack.
    var distance := absf(player.position.x - enemy.position.x)
    var direction := signf(player.position.x - enemy.position.x)

    if distance > 1.55:
        enemy.position.x += direction * delta * 1.45
    elif distance < 1.05:
        enemy.position.x -= direction * delta * 0.65

    enemy.position.x = clampf(enemy.position.x, -5.5, 5.5)

    if direction != 0.0:
        enemy.rotation.y = 0.0 if direction > 0.0 else PI
        player.rotation.y = 0.0 if player.position.x < enemy.position.x else PI

    if distance <= 1.7 and enemy_attack_cd <= 0.0:
        enemy_attack()

    if enemy_think_cd <= 0.0:
        enemy_think_cd = 0.25
        update_status()

func sword_attack() -> void:
    if round_over or player_attack_cd > 0.0:
        return

    player_attack_cd = 0.38
    player_sword.rotation.z = -0.85

    if absf(player.position.x - enemy.position.x) <= 2.6:
        enemy_hp = maxi(0, enemy_hp - 12)
        hit_effect(enemy.position + Vector3(0, 0.2, 0), Color(0.2, 0.8, 1.0))
        message_label.text = "SWORD STRIKE!  -12"
        enemy.position.x = clampf(enemy.position.x + signf(enemy.position.x - player.position.x) * 0.25, -5.5, 5.5)
        if enemy_hp <= 0:
            finish_round(true)
    else:
        message_label.text = "TOO FAR! MOVE CLOSER"
    update_status()

func energy_attack() -> void:
    if round_over or energy_cd > 0.0:
        return

    energy_cd = 1.0
    hit_effect((player.position + enemy.position) / 2.0 + Vector3(0, 0.3, 0), Color(0.05, 0.55, 1.0))

    if absf(player.position.x - enemy.position.x) <= 4.5:
        enemy_hp = maxi(0, enemy_hp - 20)
        message_label.text = "SPIRIT BLAST!  -20"
        if enemy_hp <= 0:
            finish_round(true)
    else:
        message_label.text = "TARGET OUT OF RANGE"
    update_status()

func enemy_attack() -> void:
    enemy_attack_cd = 1.15
    enemy_sword.rotation.z = -0.8
    if absf(player.position.x - enemy.position.x) <= 1.85:
        player_hp = maxi(0, player_hp - 9)
        hit_effect(player.position + Vector3(0, 0.2, 0), Color(1.0, 0.08, 0.22))
        message_label.text = "RIVAL STRIKE!  -9 HP"
        if player_hp <= 0:
            finish_round(false)
    update_status()

func hit_effect(pos: Vector3, tint: Color) -> void:
    var effect := MeshInstance3D.new()
    var sphere := SphereMesh.new()
    sphere.radius = 0.38
    sphere.height = 0.76
    effect.mesh = sphere
    effect.position = pos
    effect.material_override = material(tint, 0.2, true)
    add_child(effect)

    var timer := get_tree().create_timer(0.22)
    timer.timeout.connect(func():
        if is_instance_valid(effect):
            effect.queue_free()
    )

func finish_round(won: bool) -> void:
    round_over = true
    move_dir = 0.0
    message_label.text = "VICTORY! ROUND WON!" if won else "DEFEATED! TRY AGAIN"

func reset_round() -> void:
    player.position = PLAYER_START
    enemy.position = ENEMY_START
    player.rotation.y = 0.0
    enemy.rotation.y = PI
    player.scale = Vector3.ONE
    enemy.scale = Vector3.ONE
    player_sword.rotation.z = 0.0
    enemy_sword.rotation.z = 0.0
    player_hp = 100
    enemy_hp = 100
    move_dir = 0.0
    player_attack_cd = 0.0
    energy_cd = 0.0
    enemy_attack_cd = 0.8
    enemy_think_cd = 0.0
    round_over = false
    message_label.text = "SOUL ARENA  |  DEFEAT THE RIVAL"
    update_status()

func update_status() -> void:
    if not is_instance_valid(status_label):
        return
    status_label.text = "PLAYER %d HP  |  RIVAL %d HP" % [player_hp, enemy_hp]
    player_bar.value = player_hp
    enemy_bar.value = enemy_hp
