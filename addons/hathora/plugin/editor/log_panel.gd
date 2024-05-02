@tool
extends RichTextLabel

func _ready() -> void:
	add_theme_font_override("mono_font", get_theme_font("output_source", "EditorFonts"))
	add_theme_font_override("bold_font", get_theme_font("output_source_bold", "EditorFonts"))
	add_theme_font_size_override("mono_font_size", get_theme_font_size("source_size", "EditorFonts"))
	meta_clicked.connect(_open_link)
	add_theme_stylebox_override("normal", get_theme_stylebox("read_only", "TextEdit"))
	add_theme_stylebox_override("focus", get_theme_stylebox("read_only", "TextEdit"))

func show_success(msg: String) -> void:
	_add_text(msg, get_theme_color("success_color", "Editor"))

func _add_text(p_text: String, color: Color) -> void:
	grab_focus()
	if not get_parsed_text().is_empty():
		newline()
	push_color(color)
	push_mono()
	append_text(p_text)
	pop()
	pop()
	newline()

func show_message(msg: String) -> void:
	_add_text(msg, get_theme_color("font_color", "Editor"))

func show_error(msg: String) -> void:
	_add_text(msg,get_theme_color("error_color", "Editor"))

func _open_link(link: Variant) -> void:
	if link is String:
		OS.shell_show_in_file_manager(link)
