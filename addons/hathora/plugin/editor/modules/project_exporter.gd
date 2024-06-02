@tool
extends Node

## Exports the project using a given filename, output path, and preset

const EXPORT_PRESETS_PATH = 'res://export_presets.cfg'

@export var log_text: RichTextLabel

func export(p_build_name: String, p_output_path: String, p_export_preset: String) -> bool:
	print("[HATHORA] Exporting...this can take a few minutes")
	
	await get_tree().process_frame
	
	var absolute_export_path = ProjectSettings.globalize_path(p_output_path.path_join(p_build_name))

	var args = [
		'--headless',
		'--export-pack',
		p_export_preset,
		absolute_export_path,
	]

	var output = []
	var exit_code = OS.execute(OS.get_executable_path(), args, output, true)

	if exit_code != 0 or _is_dir_empty(p_output_path):
		push_error("[HATHORA] Error exporting project:" + "\n".join(output))
		return false
	
	print_rich("[color=%s][HATHORA] Exported the project to [url=%s]%s[/url][/color]" % [owner.get_theme_color("success_color", "Editor").to_html(), absolute_export_path.get_base_dir(), absolute_export_path])
	return true


static func _is_dir_empty(p_path: String) -> bool:
	var count := 0

	var dir := DirAccess.open(p_path)
	if not dir:
		return true

	dir.list_dir_begin()
	var fn = dir.get_next()
	while fn != '':
		if fn != '.' and fn != '..':
			count += 1
		fn = dir.get_next()
	dir.list_dir_end()

	return count == 0
