extends VBoxContainer
## Add UI elements programatically
##
## Similar to a Tree, but intended to replicate the look and feel of the EditorInspector
## See also https://github.com/godotengine/godot-proposals/issues/123

const PLANS: Array[String] = ["tiny","small","medium","large"]
const TRANSPORT_TYPES: Array[String] = ["udp", "tcp", "tls"]
const REGIONS: Array[String] = [
  "Seattle",
  "Washington_DC",
  "Chicago",
  "London",
  "Frankfurt",
  "Mumbai",
  "Singapore",
  "Tokyo",
  "Sydney",
  "Sao_Paulo",
]

var editable_nodes: Array[Node]

# Disable all UI elements
var read_only: bool = false:
	set(v):
		read_only = v
		for node in editable_nodes:
			if "editable" in node:
				node.editable = !v
			if "disabled" in node:
				node.disabled = v

func _ready() -> void:
	_make_settings()

# Virtual function to make settings
func _make_settings() -> void:
	pass

# Add a new row with a label
func _add_row(p_label: String) -> HBoxContainer:
	var container = HBoxContainer.new()
	var label = Label.new()
	label.text = p_label
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.clip_text = true
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	label.add_theme_color_override("font_color", get_theme_color("font_color", "EditorInspectorSection"))
	container.add_child(label)
	add_child(container)
	return container

# Add a LineEdit
func add_line_edit(p_label: String, p_text: String = "") -> LineEdit:
	var container = _add_row(p_label)
	var line_edit = LineEdit.new()
	line_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	line_edit.text = p_text
	container.add_child(line_edit)
	line_edit.add_theme_stylebox_override("normal", get_theme_stylebox("child_bg", "EditorProperty"))
	editable_nodes.append(line_edit)
	return line_edit
	
# Add a LineEdit with a button next to it
func add_line_edit_with_icon(p_label: String, p_text: String, p_icon: Texture2D, on_icon_pressed: Callable) -> LineEdit:
	var line_edit = add_line_edit(p_label, p_text)
	var button = Button.new()
	button.icon = p_icon
	button.flat = true
	button.focus_mode = Control.FOCUS_NONE
	line_edit.add_sibling(button)
	var h_container = HBoxContainer.new()
	h_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	line_edit.add_sibling(h_container)
	line_edit.reparent(h_container)
	button.reparent(h_container)
	button.pressed.connect(on_icon_pressed)
	editable_nodes.append(button)
	return line_edit

# Add an OptionButton
func add_option_button(p_label: String, p_choices: Array[String]) -> OptionButton:
	var container = _add_row(p_label)
	var option_button = OptionButton.new()
	option_button.clip_text = true
	option_button.flat = true
	option_button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	option_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for c in p_choices:
		option_button.add_item(c)
	container.add_child(option_button)
	editable_nodes.append(option_button)
	return option_button

# Add a Checkbox
func add_checkbox(p_label: String, p_checkbox_label: String, p_checked: bool = false) -> CheckBox:
	var container = _add_row(p_label)
	var checkbox = CheckBox.new()
	checkbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	checkbox.text = p_checkbox_label
	checkbox.button_pressed = p_checked
	container.add_child(checkbox)
	checkbox.add_theme_stylebox_override("normal", get_theme_stylebox("child_bg", "EditorProperty"))
	checkbox.add_theme_stylebox_override("pressed", get_theme_stylebox("child_bg", "EditorProperty"))
	editable_nodes.append(checkbox)
	return checkbox
	
# Add an OptionButton with a button next to it
func add_option_button_with_icon(p_label: String, p_choices: Array[String], icon: Texture2D, on_icon_pressed: Callable) -> OptionButton:
	var option_button = add_option_button(p_label, p_choices)
	var button = Button.new()
	button.icon = icon
	button.flat = true
	option_button.flat = true
	option_button.add_sibling(button)
	var h_container = HBoxContainer.new()
	h_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	option_button.add_sibling(h_container)
	option_button.reparent(h_container)
	button.reparent(h_container)
	button.pressed.connect(on_icon_pressed)
	button.focus_mode = Control.FOCUS_NONE
	editable_nodes.append(option_button)
	editable_nodes.append(button)
	return option_button
	
# Add a SpinBox
func add_spinbox(p_label: String, p_min: float, p_max: float, p_step: float) -> SpinBox:
	var container = _add_row(p_label)
	var spinbox = SpinBox.new()
	spinbox.step = p_step
	spinbox.min_value = p_min
	spinbox.max_value = p_max
	spinbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var spinbox_line_edit = spinbox.get_line_edit()
	spinbox_line_edit.add_theme_stylebox_override("normal", get_theme_stylebox("child_bg", "EditorProperty"))
	container.add_child(spinbox)
	editable_nodes.append(spinbox)
	return spinbox
	
# Add a button with an icon
func add_button(p_text: String, p_icon: Texture2D, on_pressed: Callable) -> Button:
	var button = Button.new()
	button.text = p_text
	button.icon = p_icon
	button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	button.add_theme_stylebox_override("normal", get_theme_stylebox("normal", "InspectorActionButton"))
	button.add_theme_stylebox_override("pressed", get_theme_stylebox("pressed", "InspectorActionButton"))
	button.add_theme_stylebox_override("hover", get_theme_stylebox("hover", "InspectorActionButton"))
	button.add_theme_stylebox_override("disabled", get_theme_stylebox("disabled", "InspectorActionButton"))
	add_child(button)
	button.pressed.connect(on_pressed)
	editable_nodes.append(button)
	return button
	
# Add a RichTextLabel
func add_rich_text_label(p_text: String, on_meta_clicked:Callable = func(_link): pass) -> RichTextLabel:
	var label = RichTextLabel.new()
	label.text = p_text
	label.fit_content = true
	label.scroll_active = false
	label.bbcode_enabled = true
	label.meta_clicked.connect(on_meta_clicked)
	label.add_theme_color_override("font_color", get_theme_color("font_color", "EditorInspectorSection"))
	add_child(label)
	return label
