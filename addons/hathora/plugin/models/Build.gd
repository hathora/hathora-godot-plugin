extends Resource

const BuildRegionalContainerTagsInner = preload("../models/BuildRegionalContainerTagsInner.gd")

# THIS FILE WAS AUTOMATICALLY GENERATED by the OpenAPI Generator project.
# For more information on how to customize templates, see:
# https://openapi-generator.tech
# https://github.com/OpenAPITools/openapi-generator/tree/master/modules/openapi-generator/src/main/resources/gdscript
# The OpenAPI Generator Community, © Public Domain, 2022

# Build Model
# A build object represents a game server's container image and it's metadata.


# Required: True
# isArray: true
@export var regionalContainerTags: Array:
	set(value):
		__regionalContainerTags__was__set = true
		regionalContainerTags = value
var __regionalContainerTags__was__set := false

# Image size in MB.
# Required: True
# isArray: false
@export var imageSize: int:
	set(value):
		__imageSize__was__set = true
		imageSize = value
var __imageSize__was__set := false

# Status of creating a build.
# Required: True
# isArray: false
# Allowed values: "created", "running", "succeeded", "failed"
@export var status: String = "":
	set(value):
		if str(value) != "" and not (str(value) in __status__allowable__values):
			push_error("Build: tried to set property `status` to a value that is not allowed." +
				"  Allowed values: `created`, `running`, `succeeded`, `failed`")
			return
		__status__was__set = true
		status = value
var __status__was__set := false
var __status__allowable__values := ["created", "running", "succeeded", "failed"]

#       (but it's actually a DateTime ; no timezones support in Gdscript)
# Required: True
# isArray: false
@export var deletedAt: String:
	set(value):
		__deletedAt__was__set = true
		deletedAt = value
var __deletedAt__was__set := false

#       (but it's actually a DateTime ; no timezones support in Gdscript)
# Required: True
# isArray: false
@export var finishedAt: String:
	set(value):
		__finishedAt__was__set = true
		finishedAt = value
var __finishedAt__was__set := false

#       (but it's actually a DateTime ; no timezones support in Gdscript)
# Required: True
# isArray: false
@export var startedAt: String:
	set(value):
		__startedAt__was__set = true
		startedAt = value
var __startedAt__was__set := false

#       (but it's actually a DateTime ; no timezones support in Gdscript)
# Required: True
# isArray: false
@export var createdAt: String:
	set(value):
		__createdAt__was__set = true
		createdAt = value
var __createdAt__was__set := false

# Email address.
# Required: True
# isArray: false
@export var createdBy: String = "":
	set(value):
		__createdBy__was__set = true
		createdBy = value
var __createdBy__was__set := false

# System generated id for a build. Increments by 1.
# Required: True
# isArray: false
@export var buildId: int:
	set(value):
		__buildId__was__set = true
		buildId = value
var __buildId__was__set := false

# System generated unique identifier for an application.
# Required: True
# isArray: false
@export var appId: String = "":
	set(value):
		__appId__was__set = true
		appId = value
var __appId__was__set := false


func bzz_collect_missing_properties() -> Array:
	var bzz_missing_properties := Array()
	if not self.__regionalContainerTags__was__set:
		bzz_missing_properties.append("regionalContainerTags")
	if not self.__imageSize__was__set:
		bzz_missing_properties.append("imageSize")
	if not self.__status__was__set:
		bzz_missing_properties.append("status")
	if not self.__deletedAt__was__set:
		bzz_missing_properties.append("deletedAt")
	if not self.__finishedAt__was__set:
		bzz_missing_properties.append("finishedAt")
	if not self.__startedAt__was__set:
		bzz_missing_properties.append("startedAt")
	if not self.__createdAt__was__set:
		bzz_missing_properties.append("createdAt")
	if not self.__createdBy__was__set:
		bzz_missing_properties.append("createdBy")
	if not self.__buildId__was__set:
		bzz_missing_properties.append("buildId")
	if not self.__appId__was__set:
		bzz_missing_properties.append("appId")
	return bzz_missing_properties


func bzz_normalize() -> Dictionary:
	var bzz_dictionary := Dictionary()
	if self.__regionalContainerTags__was__set:
		bzz_dictionary["regionalContainerTags"] = self.regionalContainerTags
	if self.__imageSize__was__set:
		bzz_dictionary["imageSize"] = self.imageSize
	if self.__status__was__set:
		bzz_dictionary["status"] = self.status
	if self.__deletedAt__was__set:
		bzz_dictionary["deletedAt"] = self.deletedAt
	if self.__finishedAt__was__set:
		bzz_dictionary["finishedAt"] = self.finishedAt
	if self.__startedAt__was__set:
		bzz_dictionary["startedAt"] = self.startedAt
	if self.__createdAt__was__set:
		bzz_dictionary["createdAt"] = self.createdAt
	if self.__createdBy__was__set:
		bzz_dictionary["createdBy"] = self.createdBy
	if self.__buildId__was__set:
		bzz_dictionary["buildId"] = self.buildId
	if self.__appId__was__set:
		bzz_dictionary["appId"] = self.appId
	return bzz_dictionary


# Won't work for JSON+LD
static func bzz_denormalize_single(from_dict: Dictionary):
	var me := new()
	if from_dict.has("regionalContainerTags"):
		me.regionalContainerTags = BuildRegionalContainerTagsInner.bzz_denormalize_multiple(from_dict["regionalContainerTags"])
	if from_dict.has("imageSize"):
		me.imageSize = from_dict["imageSize"]
	if from_dict.has("status"):
		me.status = from_dict["status"]
	if from_dict.has("deletedAt") && from_dict["deletedAt"] != null:
		me.deletedAt = from_dict["deletedAt"]
	if from_dict.has("finishedAt") && from_dict["finishedAt"] != null:
		me.finishedAt = from_dict["finishedAt"]
	if from_dict.has("startedAt") && from_dict["finishedAt"] != null:
		me.startedAt = from_dict["startedAt"]
	if from_dict.has("createdAt"):
		me.createdAt = from_dict["createdAt"]
	if from_dict.has("createdBy"):
		me.createdBy = from_dict["createdBy"]
	if from_dict.has("buildId"):
		me.buildId = from_dict["buildId"]
	if from_dict.has("appId"):
		me.appId = from_dict["appId"]
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
