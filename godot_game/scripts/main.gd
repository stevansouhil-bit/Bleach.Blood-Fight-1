extends Node3D

var player: Node3D
var enemy: Node3D
var player_sword: Node3D
var enemy_sword: Node3D
var enemy_hp := 100
var player_hp := 100
var move_dir := 0.0
var attack_time := 0.0
var energy_time := 0.0
var status_label: Label
var message_label: Label
var player_home := Vector3(-2.0, 0.95, 0.0)
var enemy_home := Vector3(2.0, 0.95, 0.0)

func _ready() -> void:
    make_arena()
    player = make_fighter(player_home, Color(0.08, 0.12, 0.22), Color(0.05, 0.8, 1.0), false)
    enemy = make_fighter(enemy_home, Color(0.22, 0.035, 0.08), Color(1.0, 0.08, 0.22), true)
    player_sword = player.get_node("SwordPivot")
    enemy_sword = enemy.get_node("SwordPivot")
    make_camera()
    make_lights()
    make_ui()
    update_status()

func make_arena() -> void:
    var floor_mesh := MeshInstance3D.new()
    var plane := PlaneMesh.new()
    plane.size = Vector2(18, 12)
    floor_mesh.mesh = plane
    var floor_mat := StandardMaterial3D.new()
    floor_mat.albedo_color = Color(0.035, 0.025, 0.075)
    floor_mat.metallic = 0.35
    floor_mat.roughness = 0.45
    floor_mesh.material_override = floor_mat
    add_child(floor_mesh)

    for i in range(9):
        var line := MeshInstance3D.new()
        var box := BoxMesh.new()
        box.size = Vector3(0.025, 0.015, 12)
        line.mesh = box
        line.position = Vector3(-8 + i * 2, 0.015, 0)
        line.material_override = glow_material(Color(0.32, 0.05, 0.8))
        add_child(line)

    for side in [-1.0, 1.0]:
        var pillar := MeshInstance3D.new()
        var shape := BoxMesh.new()
        shape.size = Vector3(0.22, 2.8, 0.22)
        pillar.mesh = shape
        pillar.position = Vector3(side * 7.8, 1.4, -2.5)
        pillar.material_override = glow_material(Color(0.1, 0.25, 0.8))
        add_child(pillar)

func glow_material(tint: Color) -> StandardMaterial3D:
    var mat := StandardMaterial3D.new()
    mat.albedo_color = tint
    mat.emission_enabled = true
    mat.emission = tint
    mat.metallic = 0.3
    return mat

func solid_material(tint: Color, metal := 0.0) -> StandardMaterial3D:
    var mat := StandardMaterial3D.new()
    mat.albedo_color = tint
    mat.metallic = metal
    mat.roughness = 0.35
    return mat

func add_part(parent: Node3D, mesh: Mesh, pos: Vector3, mat: Material, part_name: String) -> MeshInstance3D:
    var part := MeshInstance3D.new()
    part.name = part_name
    part.mesh = mesh
    part.position = pos
    part.material_override = mat
    parent.add_child(part)
    return part

func make_fighter(pos: Vector3, tint: Color, aura: Color, facing_left: bool) -> Node3D:
    var fighter := Node3D.new()
    fighter.position = pos
    if facing_left:
        fighter.rotation.y = PI
    add_child(fighter)

    var dark := solid_material(tint, 0.2)
    var cloth := solid_material(Color(0.025, 0.025, 0.045))
    var skin := solid_material(Color(0.78, 0.58, 0.45))
    var hair_mat := solid_material(Color(0.025, 0.02, 0.04))
    var metal := solid_material(Color(0.68, 0.78, 0.9), 0.8)
    var accent := glow_material(aura)

    var torso_mesh := CapsuleMesh.new()
    torso_mesh.radius = 0.34
    torso_mesh.height = 1.15
    add_part(fighter, torso_mesh, Vector3(0, 0.0, 0), dark, "Torso")

    var coat_mesh := BoxMesh.new()
    coat_mesh.size = Vector3(0.72, 0.75, 0.2)
    add_part(fighter, coat_mesh, Vector3(0, -0.12, 0.2), cloth, "Coat")

    var head_mesh := SphereMesh.new()
    head_mesh.radius = 0.28
    head_mesh.height = 0.56
    add_part(fighter, head_mesh, Vector3(0, 0.78, 0), skin, "Head")

    var hair_mesh := SphereMesh.new()
    hair_mesh.radius = 0.3
    hair_mesh.height = 0.35
    add_part(fighter, hair_mesh, Vector3(0, 0.99, -0.015), hair_mat, "Hair")

    var eye_mesh := BoxMesh.new()
    eye_mesh.size = Vector3(0.24, 0.045, 0.035)
    add_part(fighter, eye_mesh, Vector3(0, 0.8, 0.255), accent, "Eyes")

    var arm_mesh := CapsuleMesh.new()
    arm_mesh.radius = 0.105
    arm_mesh.height = 0.68
    var arm_l := add_part(fighter, arm_mesh, Vector3(-0.43, 0.02, 0), dark, "ArmLeft")
    arm_l.rotation.z = -0.22
    var arm_r := add_part(fighter, arm_mesh, Vector3(0.43, 0.02, 0), dark, "ArmRight")
    arm_r.rotation.z = 0.22

    var leg_mesh := CapsuleMesh.new()
    leg_mesh.radius = 0.13
    leg_mesh.height = 0.72
    var leg_l := add_part(fighter, leg_mesh, Vector3(-0.19, -0.57, 0), cloth, "LegLeft")
    leg_l.rotation.z = -0.08
    var leg_r := add_part(fighter, leg_mesh, Vector3(0.19, -0.57, 0), cloth, "LegRight")
    leg_r.rotation.z = 0.08

    var belt_mesh := BoxMesh.new()
    belt_mesh.size = Vector3(0.68, 0.09, 0.25)
    add_part(fighter, belt_mesh, Vector3(0, -0.35, 0.02), accent, "Belt")

    var pivot := Node3D.new()
    pivot.name = "SwordPivot"
    pivot.position = Vector3(0.42, 0.08, 0.05)
    fighter.add_child(pivot)

    var blade_mesh := BoxMesh.new()
    blade_mesh.size = Vector3(0.88, 0.075, 0.09)
    add_part(pivot, blade_mesh, Vector3(0.48, 0.0, 0), metal, "Blade")

    var guard_mesh := BoxMesh.new()
    guard_mesh.size = Vector3(0.1, 0.22, 0.14)
    add_part(pivot, guard_mesh, Vector3(0.02, 0, 0), accent, "Guard")

    var handle_mesh := BoxMesh.new()
    handle_mesh.size = Vector3(0.25, 0.07, 0.08)
    add_part(pivot, handle_mesh, Vector3(-0.14, 0, 0), cloth, "Handle")

    var aura_mesh := SphereMesh.new()
    aura_mesh.radius = 0.8
    aura_mesh.height = 1.7
    var aura_mat := StandardMaterial3D.new()
    aura_mat.albedo_color = Color(aura.r, aura.g, aura.b, 0.12)
    aura_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    aura_mat.emission_enabled = true
    aura_mat.emission = aura * 0.35
    var aura_part := add_part(fighter, aura_mesh, Vector3(0, 0, -0.12), aura_mat, "Aura")
    aura_part.scale = Vector3(0.8, 0.9, 0.45)

    return fighter

func make_camera() -> void:
    var camera := Camera3D.new()
    camera.position = Vector3(0, 5.2, 10.5)
    camera.rotation_degrees = Vector3(-23, 0, 0)
    camera.current = true
    add_child(camera)

func make_lights() -> void:
    var light := DirectionalLight3D.new()
    light.rotation_degrees = Vector3(-48, -25, 0)
    light.light_energy = 1.5
    add_child(light)

    var fill := OmniLight3D.new()
    fill.position = Vector3(0, 3.5, 0)
    fill.light_color = Color(0.35, 0.16, 1.0)
    fill.light_energy = 1.6
    fill.omni_range = 13
    add_child(fill)

func make_ui() -> void:
    var layer := CanvasLayer.new()
    add_child(layer)

    var panel := VBoxContainer.new()
    panel.position = Vector2(18, 14)
    panel.add_theme_constant_override("separation", 5)
    layer.add_child(panel)

    status_label = Label.new()
    status_label.add_theme_font_size_override("font_size", 22)
    status_label.add_theme_color_override("font_color", Color(0.5, 0.9, 1.0))
    panel.add_child(status_label)

    message_label = Label.new()
    message_label.text = "SOUL ARENA  |  SWORD DUEL"
    message_label.add_theme_font_size_override("font_size", 15)
    message_label.add_theme_color_override("font_color", Color(0.9, 0.65, 1.0))
    panel.add_child(message_label)

    var controls := HBoxContainer.new()
    controls.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
    controls.offset_top = -92
    controls.offset_bottom = -14
    controls.offset_left = 12
    controls.offset_right = -12
    controls.add_theme_constant_override("separation", 7)
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
    button.custom_minimum_size = Vector2(80, 58)
    button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    button.add_theme_font_size_override("font_size", 16)
    button.pressed.connect(action)
    parent.add_child(button)

func _process(delta: float) -> void:
    if player == null or enemy == null:
        return

    player.position.x = clampf(player.position.x + move_dir * delta * 3.0, -5.0, 5.0)

    if attack_time > 0.0:
        attack_time -= delta
        player_sword.rotation.z = -0.9 if attack_time > 0.12 else 0.0
    else:
        player_sword.rotation.z = 0.0

    if energy_time > 0.0:
        energy_time -= delta

func sword_attack() -> void:
    if enemy_hp <= 0 or attack_time > 0.0:
        return

    attack_time = 0.28
    player_sword.rotation.z = -0.9
    var distance := absf(player.position.x - enemy.position.x)

    if distance <= 3.2:
        enemy_hp = maxi(0, enemy_hp - 12)
        hit_effect(enemy.position, Color(0.25, 0.85, 1.0))
        enemy.position.x = clampf(enemy.position.x + 0.35, -5.0, 5.0)
        enemy.scale = Vector3(1.12, 0.9, 1.0)
        get_tree().create_timer(0.18).timeout.connect(func():
            if is_instance_valid(enemy):
                enemy.scale = Vector3.ONE
        )
        message_label.text = "SWORD HIT!  -12 HP"
    else:
        message_label.text = "MOVE CLOSER TO STRIKE"
    update_status()

func energy_attack() -> void:
    if enemy_hp <= 0 or energy_time > 0.0:
        return

    energy_time = 0.55
    if absf(player.position.x - enemy.position.x) <= 4.5:
        enemy_hp = maxi(0, enemy_hp - 20)
        hit_effect((player.position + enemy.position) / 2.0, Color(0.15, 0.65, 1.0))
        message_label.text = "SPIRIT BLAST!  -20 HP"
    else:
        message_label.text = "TARGET OUT OF RANGE"
    update_status()

func hit_effect(pos: Vector3, tint: Color) -> void:
    var effect := MeshInstance3D.new()
    var sphere := SphereMesh.new()
    sphere.radius = 0.35
    sphere.height = 0.7
    effect.mesh = sphere
    effect.position = pos + Vector3(0, 0.2, 0)
    effect.material_override = glow_material(tint)
    add_child(effect)
    var timer := get_tree().create_timer(0.22)
    timer.timeout.connect(func():
        if is_instance_valid(effect):
            effect.queue_free()
    )

func reset_round() -> void:
    player.position = player_home
    enemy.position = enemy_home
    player.rotation.y = 0.0
    enemy.rotation.y = PI
    player.scale = Vector3.ONE
    enemy.scale = Vector3.ONE
    player_sword.rotation.z = 0.0
    enemy_sword.rotation.z = 0.0
    enemy_hp = 100
    player_hp = 100
    move_dir = 0.0
    attack_time = 0.0
    energy_time = 0.0
    message_label.text = "SOUL ARENA  |  SWORD DUEL"
    update_status()

func update_status() -> void:
    if status_label:
        status_label.text = "PLAYER  %d HP     |     RIVAL  %d HP" % [player_hp, enemy_hp]
        if enemy_hp <= 0:
            message_label.text = "VICTORY!  ROUND WON!"
