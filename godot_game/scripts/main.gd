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
var player_swing_time := 0.0
var enemy_swing_time := 0.0
var hit_flash_time := 0.0
var round_over := false
var wins := 0
var losses := 0
var character_index := 0
var character_names := ["ICHIGO", "BYAKUYA", "KENPACHI"]
var blocking := false
var dash_time := 0.0
var dash_cd := 0.0
var bankai_cd := 0.0
var dash_direction := 1.0

var status_label: Label
var message_label: Label
var player_bar: ProgressBar
var enemy_bar: ProgressBar

const PLAYER_START := Vector3(-2.0, 0.95, 0.0)
const ENEMY_START := Vector3(2.0, 0.95, 0.0)
const ARENA_LIMIT := 5.5

func _ready() -> void:
    randomize()
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

    var torso := CapsuleMesh.new()
    torso.radius = 0.34
    torso.height = 1.1
    part(fighter, torso, Vector3(0, 0, 0), armor, "Torso")

    var coat := BoxMesh.new()
    coat.size = Vector3(0.72, 0.72, 0.22)
    part(fighter, coat, Vector3(0, -0.14, 0.13), cloth, "Coat")

    var head := SphereMesh.new()
    head.radius = 0.27
    head.height = 0.54
    part(fighter, head, Vector3(0, 0.77, 0), skin, "Head")

    var hair_mesh := SphereMesh.new()
    hair_mesh.radius = 0.29
    hair_mesh.height = 0.34
    part(fighter, hair_mesh, Vector3(0, 0.96, -0.015), hair, "Hair")

    var eyes := BoxMesh.new()
    eyes.size = Vector3(0.22, 0.045, 0.035)
    part(fighter, eyes, Vector3(0, 0.79, 0.245), aura, "Eyes")

    var arm := CapsuleMesh.new()
    arm.radius = 0.105
    arm.height = 0.64
    var left_arm := part(fighter, arm, Vector3(-0.42, 0, 0), armor, "ArmLeft")
    left_arm.rotation.z = -0.2
    var right_arm := part(fighter, arm, Vector3(0.42, 0, 0), armor, "ArmRight")
    right_arm.rotation.z = 0.2

    var leg := CapsuleMesh.new()
    leg.radius = 0.13
    leg.height = 0.68
    part(fighter, leg, Vector3(-0.18, -0.56, 0), cloth, "LegLeft")
    part(fighter, leg, Vector3(0.18, -0.56, 0), cloth, "LegRight")

    var belt := BoxMesh.new()
    belt.size = Vector3(0.66, 0.09, 0.24)
    part(fighter, belt, Vector3(0, -0.34, 0.03), aura, "Belt")

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
    message_label.text = "SOUL ARENA | DEFEAT THE RIVAL"
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

    add_move_button(controls, "◀", -1.0)
    add_button(controls, "STOP", func(): move_dir = 0.0)
    add_move_button(controls, "▶", 1.0)
    add_button(controls, "SWORD", sword_attack)
    add_button(controls, "ENERGY", energy_attack)
    add_block_button(controls)
    add_button(controls, "DASH", dash_attack)
    add_button(controls, "BANKAI", bankai_attack)
    add_button(controls, "RESET", reset_round)
    add_button(controls, "CHAR", cycle_character)

func add_button(parent: Control, caption: String, action: Callable) -> void:
    var button := Button.new()
    button.text = caption
    button.custom_minimum_size = Vector2(70, 58)
    button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    button.add_theme_font_size_override("font_size", 14)
    button.pressed.connect(action)
    parent.add_child(button)

func add_move_button(parent: Control, caption: String, direction: float) -> void:
    var button := Button.new()
    button.text = caption
    button.custom_minimum_size = Vector2(70, 58)
    button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    button.add_theme_font_size_override("font_size", 18)
    button.button_down.connect(func(): move_dir = direction)
    button.button_up.connect(func():
        if move_dir == direction:
            move_dir = 0.0
    )
    parent.add_child(button)

func _process(delta: float) -> void:
    dash_cd = maxf(0.0, dash_cd - delta)
    bankai_cd = maxf(0.0, bankai_cd - delta)
    dash_time = maxf(0.0, dash_time - delta)
    if round_over:
        return

    player_attack_cd = maxf(0.0, player_attack_cd - delta)
    energy_cd = maxf(0.0, energy_cd - delta)
    enemy_attack_cd = maxf(0.0, enemy_attack_cd - delta)
    enemy_think_cd = maxf(0.0, enemy_think_cd - delta)
    player_swing_time = maxf(0.0, player_swing_time - delta)
    enemy_swing_time = maxf(0.0, enemy_swing_time - delta)
    hit_flash_time = maxf(0.0, hit_flash_time - delta)

    player.position.x = clampf(player.position.x + move_dir * delta * 3.2, -ARENA_LIMIT, ARENA_LIMIT)
    if dash_time > 0.0:
        player.position.x = clampf(player.position.x + dash_direction * delta * 8.0, -ARENA_LIMIT, ARENA_LIMIT)

    var distance := absf(player.position.x - enemy.position.x)
    var direction := signf(player.position.x - enemy.position.x)

    if enemy_think_cd <= 0.0:
        enemy_think_cd = randf_range(0.18, 0.38)
        if distance > 1.65:
            enemy.position.x += direction * randf_range(0.18, 0.42)
        elif distance < 1.05:
            enemy.position.x -= direction * randf_range(0.08, 0.22)
        enemy.position.x = clampf(enemy.position.x, -ARENA_LIMIT, ARENA_LIMIT)

    player_sword.rotation.z = -0.95 if player_swing_time > 0.0 else 0.0
    enemy_sword.rotation.z = -0.95 if enemy_swing_time > 0.0 else 0.0

    if distance <= 1.75 and enemy_attack_cd <= 0.0:
        enemy_attack()

    player.scale = Vector3(1.04, 1.04, 1.04) if hit_flash_time > 0.0 else Vector3.ONE
    update_status()

func sword_attack() -> void:
    if round_over or player_attack_cd > 0.0:
        return
    player_attack_cd = 0.48
    player_swing_time = 0.20

    if absf(player.position.x - enemy.position.x) <= 2.25:
        enemy_hp = maxi(0, enemy_hp - 12)
        hit_effect(enemy.position + Vector3(0, 0.2, 0), Color(0.2, 0.8, 1.0))
        message_label.text = "SWORD STRIKE! -12"
        enemy.position.x = clampf(enemy.position.x + signf(enemy.position.x - player.position.x) * 0.22, -ARENA_LIMIT, ARENA_LIMIT)
        if enemy_hp <= 0:
            finish_round(true)
    else:
        message_label.text = "TOO FAR! MOVE CLOSER"
    update_status()

func energy_attack() -> void:
    if round_over or energy_cd > 0.0:
        return
    energy_cd = 1.25
    message_label.text = "SPIRIT BLAST!"

    var orb := MeshInstance3D.new()
    var orb_mesh := SphereMesh.new()
    orb_mesh.radius = 0.19
    orb_mesh.height = 0.38
    orb.mesh = orb_mesh
    orb.material_override = material(Color(0.05, 0.65, 1.0), 0.1, true)
    orb.position = player.position + Vector3(0.5, 0.35, 0.1)
    add_child(orb)

    var tween := create_tween()
    tween.tween_property(orb, "position", enemy.position + Vector3(0, 0.25, 0), 0.24)
    tween.tween_callback(orb.queue_free)

    if absf(player.position.x - enemy.position.x) <= 4.8:
        enemy_hp = maxi(0, enemy_hp - 20)
        hit_effect(enemy.position + Vector3(0, 0.25, 0), Color(0.05, 0.55, 1.0))
        message_label.text = "SPIRIT BLAST! -20"
        if enemy_hp <= 0:
            finish_round(true)
    else:
        message_label.text = "TARGET OUT OF RANGE"
    update_status()

func enemy_attack() -> void:
    enemy_attack_cd = randf_range(1.0, 1.5)
    enemy_swing_time = 0.22
    if absf(player.position.x - enemy.position.x) <= 1.85:
        var damage := 3 if blocking else 9
        player_hp = maxi(0, player_hp - damage)
        hit_flash_time = 0.12
        hit_effect(player.position + Vector3(0, 0.2, 0), Color(1.0, 0.08, 0.22))
        message_label.text = "RIVAL STRIKE! -9 HP"
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

    var tween := create_tween()
    tween.tween_property(effect, "scale", Vector3(1.7, 1.7, 1.7), 0.18)
    tween.tween_callback(effect.queue_free)

func finish_round(won: bool) -> void:
    if round_over:
        return
    round_over = true
    move_dir = 0.0
    blocking = false
    if won:
        wins += 1
        message_label.text = "VICTORY! WINS: %d" % wins
    else:
        losses += 1
        message_label.text = "DEFEATED! LOSSES: %d" % losses

func reset_round() -> void:
    player.position = PLAYER_START
    enemy.position = ENEMY_START
    player.rotation = Vector3.ZERO
    enemy.rotation = Vector3.ZERO
    player.scale = Vector3.ONE
    enemy.scale = Vector3.ONE
    player_sword.scale = Vector3.ONE
    enemy_sword.scale = Vector3.ONE
    player_sword.rotation = Vector3.ZERO
    enemy_sword.rotation = Vector3.ZERO

    player_hp = 100
    blocking = false
    dash_time = 0.0
    dash_cd = 0.0
    bankai_cd = 0.0
    enemy_hp = 100
    move_dir = 0.0
    player_attack_cd = 0.0
    energy_cd = 0.0
    enemy_attack_cd = 0.8
    enemy_think_cd = 0.0
    player_swing_time = 0.0
    enemy_swing_time = 0.0
    hit_flash_time = 0.0
    round_over = false
    message_label.text = "SOUL ARENA | DEFEAT THE RIVAL"
    update_status()

func update_status() -> void:
    if not is_instance_valid(status_label):
        return
    status_label.text = "%s | YOU %d HP | RIVAL %d HP | W:%d L:%d" % [character_names[character_index], player_hp, enemy_hp, wins, losses]
    player_bar.value = player_hp
    enemy_bar.value = enemy_hp

func start_block() -> void:
    if not round_over:
        blocking = true
        message_label.text = "DEFENSE ACTIVE!"

func dash_attack() -> void:
    if round_over or dash_cd > 0.0:
        return
    dash_cd = 1.0
    dash_time = 0.18
    dash_direction = -1.0 if player.position.x > enemy.position.x else 1.0
    player.position.x = clampf(player.position.x + dash_direction * 0.8, -ARENA_LIMIT, ARENA_LIMIT)
    hit_effect(player.position + Vector3(0, 0.25, 0), Color(0.15, 0.75, 1.0))
    message_label.text = "FLASH STEP!"

func bankai_attack() -> void:
    if round_over or bankai_cd > 0.0:
        return
    bankai_cd = 5.0
    player_swing_time = 0.35
    hit_effect(player.position + Vector3(0, 0.5, 0), Color(0.1, 0.8, 1.0))
    if absf(player.position.x - enemy.position.x) <= 5.0:
        enemy_hp = maxi(0, enemy_hp - 35)
        hit_effect(enemy.position + Vector3(0, 0.4, 0), Color(0.55, 0.1, 1.0))
        message_label.text = "BANKAI! -35 HP"
        if enemy_hp <= 0:
            finish_round(true)
    else:
        message_label.text = "BANKAI: RIVAL TOO FAR"
    update_status()

func cycle_character() -> void:
    if round_over:
        return
    character_index = (character_index + 1) % character_names.size()
    var armor_color: Color
    var hair_color: Color
    var aura_color: Color
    match character_index:
        0:
            armor_color = Color(0.045, 0.09, 0.19)
            hair_color = Color(0.95, 0.25, 0.08)
            aura_color = Color(0.05, 0.8, 1.0)
        1:
            armor_color = Color(0.85, 0.85, 0.92)
            hair_color = Color(0.06, 0.05, 0.12)
            aura_color = Color(0.75, 0.25, 1.0)
        _:
            armor_color = Color(0.12, 0.04, 0.055)
            hair_color = Color(0.03, 0.025, 0.035)
            aura_color = Color(1.0, 0.06, 0.12)
    player.get_node("Torso").material_override = material(armor_color, 0.3)
    player.get_node("ArmLeft").material_override = material(armor_color, 0.3)
    player.get_node("ArmRight").material_override = material(armor_color, 0.3)
    player.get_node("Hair").material_override = material(hair_color)
    player.get_node("Eyes").material_override = material(aura_color, 0.1, true)
    player.get_node("Belt").material_override = material(aura_color, 0.1, true)
    player.get_node("Aura").material_override = material(aura_color, 0.15, true)
    player.get_node("SwordPivot/Blade").material_override = material(aura_color.lightened(0.35), 0.8, true)
    message_label.text = "CHARACTER: %s" % character_names[character_index]
    update_status()

func add_block_button(parent: Control) -> void:
    var button := Button.new()
    button.text = "BLOCK"
    button.custom_minimum_size = Vector2(70, 58)
    button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    button.button_down.connect(start_block)
    button.button_up.connect(func(): blocking = false)
    parent.add_child(button)
