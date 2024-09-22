extends "endpoint.gd"


# Fetch all builds with optional orgId
func get_builds(org_id: String = ""):
	return GET("builds", empty_string_stripped({"orgId": org_id})).then(func (result):
		if result.is_error():
			return result
		return result
	)

## Creates a new build with optional multipartUploadUrls that can be used to upload larger builds in parts before calling runBuild.
## Responds with a buildId that you must pass to RunBuild() to build the game server artifact.
## You can optionally pass in a buildTag to associate an external version with a build.
func create(build_size_in_bytes: int, build_id: String = "", build_tag: String = "", org_id: String = ""):
	return POST("builds", empty_string_stripped({
		"orgId": org_id,
		"buildId": build_id,
		"buildTag": build_tag,
		"buildSizeInBytes": build_size_in_bytes})).then(func (result):
		if result.is_error():
			return result
		return result
	)

# Fetch a specific build by buildId with optional orgId
func get_build(build_id: String, org_id: String = ""):
	return GET("builds/" + build_id, empty_string_stripped({"orgId": org_id})).then(func (result):
		if result.is_error():
			return result
		return result
	)

# Delete a build by buildId with optional orgId
func delete(build_id: String, org_id: String = ""):
	return DELETE("builds/" + build_id, empty_string_stripped({"orgId": org_id})).then(func (result):
		if result.is_error():
			return result
		return result
	)

# Run a specific build by buildId with optional orgId
func run_build(build_id: String, org_id: String = ""):
	return POST("builds/" + build_id + "/run", empty_string_stripped({
		"orgId": org_id}), {}, {}, true).then(func (result):
		if result.is_error():
			return result
		return result
	)
