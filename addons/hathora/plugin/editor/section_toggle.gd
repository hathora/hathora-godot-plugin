@tool
extends Button

@export var node_to_show: Control

func _ready() -> void:
	toggle_mode = true
	icon = get_theme_icon("CodeFoldedRightArrow", "EditorIcons")
	toggled.connect(_on_button_toggled)
	node_to_show.visible = button_pressed
	add_theme_stylebox_override("normal", get_theme_stylebox("normal", "InspectorActionButton"))
	add_theme_stylebox_override("hover", get_theme_stylebox("hover", "InspectorActionButton"))
	add_theme_stylebox_override("pressed", get_theme_stylebox("hover", "InspectorActionButton"))
	add_theme_stylebox_override("disabled", get_theme_stylebox("disabled", "InspectorActionButton"))
	add_theme_font_override("font", get_theme_font("bold", "EditorFonts"))
	add_theme_color_override("font_color", get_theme_color("font_color", "Editor"))
	add_theme_color_override("font_focus_color", get_theme_color("font_color", "Editor"))
	add_theme_color_override("font_pressed_color", get_theme_color("font_color", "Editor"))
	add_theme_color_override("font_hover_pressed_color", get_theme_color("font_color", "Editor"))
	add_theme_color_override("icon_pressed_color", get_theme_color("font_color", "Editor"))

func _on_button_toggled(toggled_on: bool) -> void:
	node_to_show.visible = toggled_on
	if toggled_on:
		icon = get_theme_icon("CodeFoldDownArrow", "EditorIcons")
	else:
		icon = get_theme_icon("CodeFoldedRightArrow", "EditorIcons")
