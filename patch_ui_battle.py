import re

with open("scenes/battle/battle_scene.tscn", "r") as f:
    content = f.read()

winloss_node = """
[node name="WinLossPanel" type="PanelContainer" parent="."]
unique_name_in_owner = true
visible = false
z_index = 20
custom_minimum_size = Vector2(360, 240)
layout_mode = 1
anchors_preset = 8
anchor_left = 0.5
anchor_top = 0.5
anchor_right = 0.5
anchor_bottom = 0.5
offset_left = -180.0
offset_top = -120.0
offset_right = 180.0
offset_bottom = 120.0
grow_horizontal = 2
grow_vertical = 2
theme_override_styles/panel = SubResource("StyleBoxFlat_winloss")

[node name="VBox" type="VBoxContainer" parent="WinLossPanel"]
layout_mode = 2
theme_override_constants/separation = 16
alignment = 1

[node name="LblWinLossTitle" type="Label" parent="WinLossPanel/VBox"]
unique_name_in_owner = true
layout_mode = 2
theme_override_fonts/font = ExtResource("4_font")
theme_override_font_sizes/font_size = 18
text = "VICTORY!"
horizontal_alignment = 1
vertical_alignment = 1

[node name="BtnContinue" type="Button" parent="WinLossPanel/VBox"]
unique_name_in_owner = true
custom_minimum_size = Vector2(200, 36)
layout_mode = 2
size_flags_horizontal = 4
mouse_default_cursor_shape = 2
theme_override_fonts/font = ExtResource("4_font")
theme_override_font_sizes/font_size = 11
theme_override_styles/normal = SubResource("StyleBoxFlat_btn")
theme_override_styles/hover = SubResource("StyleBoxFlat_btn_hover")
text = "Lanjutkan"

[node name="BtnWinLossRestart" type="Button" parent="WinLossPanel/VBox"]
unique_name_in_owner = true
custom_minimum_size = Vector2(200, 36)
layout_mode = 2
size_flags_horizontal = 4
mouse_default_cursor_shape = 2
theme_override_fonts/font = ExtResource("4_font")
theme_override_font_sizes/font_size = 11
theme_override_styles/normal = SubResource("StyleBoxFlat_btn")
theme_override_styles/hover = SubResource("StyleBoxFlat_btn_hover")
text = "Ulang Level"

[node name="BtnWinLossExit" type="Button" parent="WinLossPanel/VBox"]
unique_name_in_owner = true
custom_minimum_size = Vector2(200, 36)
layout_mode = 2
size_flags_horizontal = 4
mouse_default_cursor_shape = 2
theme_override_fonts/font = ExtResource("4_font")
theme_override_font_sizes/font_size = 11
theme_override_styles/normal = SubResource("StyleBoxFlat_btn")
theme_override_styles/hover = SubResource("StyleBoxFlat_btn_hover")
text = "Keluar ke Menu"
"""

pause_panel_node = """
[node name="BtnPause" type="Button" parent="."]
unique_name_in_owner = true
custom_minimum_size = Vector2(40, 40)
layout_mode = 1
anchors_preset = 0
offset_left = 16.0
offset_top = 16.0
offset_right = 56.0
offset_bottom = 56.0
mouse_default_cursor_shape = 2
theme_override_fonts/font = ExtResource("4_font")
theme_override_font_sizes/font_size = 20
theme_override_styles/normal = SubResource("StyleBoxFlat_btn")
theme_override_styles/hover = SubResource("StyleBoxFlat_btn_hover")
text = "⚙"

[node name="PausePanel" type="PanelContainer" parent="."]
unique_name_in_owner = true
visible = false
z_index = 20
custom_minimum_size = Vector2(360, 200)
layout_mode = 1
anchors_preset = 8
anchor_left = 0.5
anchor_top = 0.5
anchor_right = 0.5
anchor_bottom = 0.5
offset_left = -180.0
offset_top = -100.0
offset_right = 180.0
offset_bottom = 100.0
grow_horizontal = 2
grow_vertical = 2
theme_override_styles/panel = SubResource("StyleBoxFlat_winloss")

[node name="VBox" type="VBoxContainer" parent="PausePanel"]
layout_mode = 2
theme_override_constants/separation = 16
alignment = 1

[node name="LblPauseTitle" type="Label" parent="PausePanel/VBox"]
layout_mode = 2
theme_override_fonts/font = ExtResource("4_font")
theme_override_font_sizes/font_size = 18
text = "PENGATURAN"
horizontal_alignment = 1

[node name="BtnPauseResume" type="Button" parent="PausePanel/VBox"]
unique_name_in_owner = true
custom_minimum_size = Vector2(200, 36)
layout_mode = 2
size_flags_horizontal = 4
mouse_default_cursor_shape = 2
theme_override_fonts/font = ExtResource("4_font")
theme_override_font_sizes/font_size = 11
theme_override_styles/normal = SubResource("StyleBoxFlat_btn")
theme_override_styles/hover = SubResource("StyleBoxFlat_btn_hover")
text = "Kembali ke Game"

[node name="BtnPauseRestart" type="Button" parent="PausePanel/VBox"]
unique_name_in_owner = true
custom_minimum_size = Vector2(200, 36)
layout_mode = 2
size_flags_horizontal = 4
mouse_default_cursor_shape = 2
theme_override_fonts/font = ExtResource("4_font")
theme_override_font_sizes/font_size = 11
theme_override_styles/normal = SubResource("StyleBoxFlat_btn")
theme_override_styles/hover = SubResource("StyleBoxFlat_btn_hover")
text = "Ulang Level"

[node name="BtnPauseExit" type="Button" parent="PausePanel/VBox"]
unique_name_in_owner = true
custom_minimum_size = Vector2(200, 36)
layout_mode = 2
size_flags_horizontal = 4
mouse_default_cursor_shape = 2
theme_override_fonts/font = ExtResource("4_font")
theme_override_font_sizes/font_size = 11
theme_override_styles/normal = SubResource("StyleBoxFlat_btn")
theme_override_styles/hover = SubResource("StyleBoxFlat_btn_hover")
text = "Keluar ke Menu"
"""

# Replace WinLossPanel
old_winloss = re.search(r'\[node name="WinLossPanel" type="PanelContainer".*?text = "Lanjutkan"\n', content, re.DOTALL)
if old_winloss:
    content = content.replace(old_winloss.group(0), winloss_node + "\n" + pause_panel_node)

# Add resources at top
resources = """
[sub_resource type="StyleBoxFlat" id="StyleBoxFlat_winloss"]
bg_color = Color(0.12, 0.1, 0.14, 0.95)
border_width_left = 3
border_width_top = 3
border_width_right = 3
border_width_bottom = 3
border_color = Color(0.8, 0.6, 0.2, 0.9)
corner_radius_top_left = 8
corner_radius_top_right = 8
corner_radius_bottom_right = 8
corner_radius_bottom_left = 8
shadow_color = Color(0, 0, 0, 0.5)
shadow_size = 8

[sub_resource type="StyleBoxFlat" id="StyleBoxFlat_btn"]
bg_color = Color(0.2, 0.15, 0.25, 1)
border_width_left = 2
border_width_top = 2
border_width_right = 2
border_width_bottom = 2
border_color = Color(0.6, 0.4, 0.15, 1)
corner_radius_top_left = 4
corner_radius_top_right = 4
corner_radius_bottom_right = 4
corner_radius_bottom_left = 4

[sub_resource type="StyleBoxFlat" id="StyleBoxFlat_btn_hover"]
bg_color = Color(0.25, 0.2, 0.3, 1)
border_width_left = 2
border_width_top = 2
border_width_right = 2
border_width_bottom = 2
border_color = Color(0.8, 0.6, 0.2, 1)
corner_radius_top_left = 4
corner_radius_top_right = 4
corner_radius_bottom_right = 4
corner_radius_bottom_left = 4
"""

content = content.replace("[node name=\"BattleScene\"", resources + "\n[node name=\"BattleScene\"")

with open("scenes/battle/battle_scene.tscn", "w") as f:
    f.write(content)

