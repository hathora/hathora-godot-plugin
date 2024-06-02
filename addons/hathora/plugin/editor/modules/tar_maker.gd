@tool
extends Node

## Create a tarball by specifying its relative output path,
## path of the folder containing the files to tar,
## and filenames of the files to tar

func tar_files(output_path: String, tar_file_name: String, file_names: Array) -> bool:
	var absolute_output_path = ProjectSettings.globalize_path(output_path)
	var output := []
	var arguments = ["-czvf", absolute_output_path.path_join(tar_file_name), "-C", absolute_output_path]
	arguments.append_array(file_names)
	
	var result = OS.execute("tar", arguments, output, true)
	
	if result != OK:
		print(output)
		push_error("[HATHORA] Error occurred while creating the tar file: " + str(result))
		return false
	
	print_rich("[color=%s][HATHORA] Created tar file at [url=%s]%s[/url][/color]" % [owner.get_theme_color("success_color", "Editor").to_html(), absolute_output_path, absolute_output_path.path_join(tar_file_name)])
	return true
