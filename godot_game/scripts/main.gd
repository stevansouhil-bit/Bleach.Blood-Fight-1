extends Node3D

var player: MeshInstance3D
var enemy: MeshInstance3D
var enemy_hp := 100
var player_hp := 100
var move_dir := 0.0
var attack_flash := 0.0
var status_label: Label

func _ready() -> void:
    make_arena()
    player = make_fighter(
        Vector3(-2.0, 1.0, 0.0),
        Color(0.12, 0.65, 1.0)
    )
    enemy = make_fighter(
        Vector3(2.0, 1.0, 0.0),
        Color(1.0, 0.12, 0.24)
    )
    make_camera()
    make_lights()
    make_ui()

func make_arena() -> void:
    var floor_mesh := MeshInstance3D.new()
    var plane := PlaneMesh.new()
    plane.size = Vector2(18, 12)
    floor_mesh.mesh = plane

    var material := StandardMaterial3D.new()
    material.albedo_color = Color(0.07, 0.065, 0.12)
    material.metallic = 0.25
    floor_mesh.material_override = material
    add_child(floor_mesh)

    for i in range(9):
        var line := MeshInstance3D.new()
        var box := BoxMesh.new()
        box.size = Vector3(0.025, 0.01, 12)
        line.mesh = box
        line.position = Vector3(-8 + i * 2, 0.02, 0)

        var glow := StandardMaterial3D.new()
        glow.albedo_color = Color(0.35, 0.08, 0.55)
        glow.emission_enabled = true
        glow.emission = Color(0.25, 0.025, 0.6)
        line.material_override = glow
        add_child(line)

func make_fighter(pos: Vector3, tint: Color) -> MeshInstance3D:
    var body := MeshInstance3D.new()
    var capsule := CapsuleMesh.new()
    capsule.radius = 0.42
    capsule.height = 1.8
    body.mesh = capsule
    body.position = pos

    var mat := StandardMaterial3D.new()
    mat.albedo_color = tint
    mat.metallic = 0.15
    mat.roughness = 0.35
    body.material_override = mat
    add_child(body)

    var head := MeshInstance3D.new()
    var sphere := SphereMesh.new()
    sphere.radius = 0.3
    sphere.height = 0.6
    head.mesh = sphere
    head.position = Vector3(0, 1.0, 0)
    head.material_override = mat
    body.add_child(head)

    return body

func make_camera() -> void:
    var camera := Camera3D.new()
    camera.position = Vector3(0, 7, 11)
    camera.rotation_degrees = Vector3(-28, 0, 0)
    camera.current = true
    add_child(camera)

func make_lights() -> void:
    var light := DirectionalLight3D.new()
    light.rotation_degrees = Vector3(-50, -25, 0)
    light.light_energy = 1.4
    add_child(light)

    var fill := OmniLight3D.new()
    fill.position = Vector3(0, 4, 0)
    fill.light_color = Color(0.35, 0.15, 1.0)
    fill.light_energy = 1.5
    fill.omni_range = 12
    add_child(fill)

func make_ui() -> void:
    var layer := CanvasLayer.new()
    add_child(layer)

    var panel := VBoxContainer.new()
    panel.position = Vector2(20, 18)
    panel.add_theme_constant_override("separation", 8)
    layer.add_child(panel)

    status_label = Label.new()
    status_label.add_theme_font_size_override("font_size", 24)
    panel.add_child(status_label)
    update_status()

    var controls := HBoxContainer.new()
    controls.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
    controls.offset_top = -100
    controls.offset_bottom = -18
    controls.offset_left = 20
    controls.offset_right = -20
    controls.add_theme_constant_override("separation", 12)
    layer.add_child(controls)

    add_button(controls, "◀", func(): move_dir = -1.0)
    add_button(controls, "STOP", func(): move_dir = 0.0)
    add_button(controls, "▶", func(): move_dir = 1.0)
    add_button(controls, "ENERGY", energy_attack)
    add_button(controls, "RESET", reset_round)

func add_button(parent: Control, caption: String, action: Callable) -> void:
    var button := Button.new()
    button.text = caption
    button.custom_minimum_size = Vector2(100, 58)
    button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    button.add_theme_font_size_override("font_size", 18)
    button.pressed.connect(action)
    parent.add_child(button)

func _process(delta: float) -> void:
    if player == null or enemy == null:
        return

    player.position.x = clampf(
        player.position.x + move_dir * delta * 3.0,
        -5.0, 5.0
    )

    if attack_flash > 0.0:
        attack_flash -= delta

func energy_attack() -> void:
    if enemy_hp <= 0:
        return

    if absf(player.position.x - enemy.position.x) <= 4.0:
        enemy_hp = maxi(0, enemy_hp - 20)
        attack_flash = 0.2
        enemy.scale = Vector3.ONE * 1.12
        get_tree().create_timer(0.15).timeout.connect(
            func():
                if is_instance_valid(enemy):
                    enemy.scale = Vector3.ONE
        )
    update_status()

func reset_round() -> void:
    player.position = Vector3(-2, 1, 0)
    enemy.position = Vector3(2, 1, 0)
    enemy_hp = 100
    player_hp = 100
    move_dir = 0.0
    update_status()

func update_status() -> void:
    if status_label:
        status_label.text = "PLAYER  %d HP     |     RIVAL  %d HP" % [
            player_hp, enemy_hp
        ]
        if enemy_hp <= 0:
            status_label.text += "\nROUND WON!"
