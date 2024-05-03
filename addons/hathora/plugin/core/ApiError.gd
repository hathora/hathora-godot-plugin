extends Resource

const ApiResponse = preload("../core/ApiResponse.gd")

# THIS FILE WAS AUTOMATICALLY GENERATED by the OpenAPI Generator project.
# For more information on how to customize templates, see:
# https://openapi-generator.tech
# https://github.com/OpenAPITools/openapi-generator/tree/master/modules/openapi-generator/src/main/resources/gdscript
# The OpenAPI Generator Community, © Public Domain, 2022

# Error wrapper provided to error callbacks
# =========================================
#
# Whenever this OAS client fails to comply to your request, for any reason,
# it will trigger the error callback, with an instance of this as parameter.
#

# Helps finding the error in the code, among other things.
# Could be a UUID, or even a translation key, so long as it's unique.
# Right now we're mostly using a lowercase ~namespace joined by dots. (.)
@export var identifier := ""

# A message for humans.  May be multiline.
@export var message := ""

# One of Godot's ERR_XXXX, when relevant.
@export var internal_code := OK

# The HTTP response code, if any.  (usually >= 400)
# DEPRECATED: prefer reading from response object below
@export var response_code := HTTPClient.RESPONSE_OK

# The HTTP response, if any.
@export var response: ApiResponse


func _to_string() -> String:
	var s := "ApiError"
	if identifier:
		s += " %s" % identifier
	if message:
		s += " %s" % message
	if response:
		s += "\n%s" % str(response)
	return s
