extends Resource

const AppConfigAuthConfiguration = preload("../models/AppConfigAuthConfiguration.gd")

# THIS FILE WAS AUTOMATICALLY GENERATED by the OpenAPI Generator project.
# For more information on how to customize templates, see:
# https://openapi-generator.tech
# https://github.com/OpenAPITools/openapi-generator/tree/master/modules/openapi-generator/src/main/resources/gdscript
# The OpenAPI Generator Community, © Public Domain, 2022

# AppConfig Model


# Required: True
# isArray: false
@export var authConfiguration: AppConfigAuthConfiguration:
	set(value):
		__authConfiguration__was__set = true
		authConfiguration = value
var __authConfiguration__was__set := false

# Readable name for an application.
# Required: True
# isArray: false
@export var appName: String = "":
	set(value):
		__appName__was__set = true
		appName = value
var __appName__was__set := false


func bzz_collect_missing_properties() -> Array:
	var bzz_missing_properties := Array()
	if not self.__authConfiguration__was__set:
		bzz_missing_properties.append("authConfiguration")
	if not self.__appName__was__set:
		bzz_missing_properties.append("appName")
	return bzz_missing_properties


func bzz_normalize() -> Dictionary:
	var bzz_dictionary := Dictionary()
	if self.__authConfiguration__was__set:
		bzz_dictionary["authConfiguration"] = self.authConfiguration
	if self.__appName__was__set:
		bzz_dictionary["appName"] = self.appName
	return bzz_dictionary


# Won't work for JSON+LD
static func bzz_denormalize_single(from_dict: Dictionary):
	var me := new()
	if from_dict.has("authConfiguration"):
		me.authConfiguration = AppConfigAuthConfiguration.bzz_denormalize_single(from_dict["authConfiguration"])
	if from_dict.has("appName"):
		me.appName = from_dict["appName"]
	return me


# Won't work for JSON+LD
static func bzz_denormalize_multiple(from_array: Array):
	var mes := Array()
	for element in from_array:
		if element is Array:
			mes.append(bzz_denormalize_multiple(element))
		elif element is Dictionary:
			# TODO: perhaps check first if it looks like a match or an intermediate container
			mes.append(bzz_denormalize_single(element))
		else:
			mes.append(element)
	return mes

