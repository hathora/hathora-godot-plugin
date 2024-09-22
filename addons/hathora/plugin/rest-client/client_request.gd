# Copyright (c) 2021-present W4 Games Limited.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

## A promise that is resolved by making an HTTP request.
extends "client_promise.gd"

const Result = preload("client_result.gd")
const AsyncResult = preload("client_async_result.gd")
const BlockingResult = preload("client_blocking_result.gd")

## The [TLSOptions] for the HTTP request.
var tls_options : TLSOptions = null
## The request method.
var request_method : int = HTTPClient.METHOD_GET
## The request headers.
var request_headers : PackedStringArray
## The request body.
var request_body : PackedByteArray
## The request URL.
var request_url : String
## The request path.
var request_path : String
## A node in the scene tree that we can add an [HTTPRequest] to.
var node : Node


func _init():
	_run_async = request_async
	_run_blocking = request_blocking

## Callback used to execute a blocking HTTP request.
func request_blocking(poll_delay_usec, fail: Callable):
	assert(result == null)
	result = BlockingResult.new()
	result.poll_delay_usec = poll_delay_usec
	var err = result.connect_to_url(request_url, tls_options)
	if err != OK:
		return result
	result.make_request(request_path, request_headers, request_method, request_body)
	if result.is_http_error():
		fail.call()
	return result


## Callback used to execute an asynchronous HTTP request.
func request_async(fail: Callable):
	assert(result == null)
	var req = HTTPRequest.new()
	req.max_redirects = 0
	if tls_options != null:
		req.set_tls_options(tls_options)
	if OS.get_name() != "Web":
		req.use_threads = true
	self.node.add_child(req)
	var err = req.request_raw(request_url + request_path, request_headers, request_method, request_body)
	result = AsyncResult.new(req if err == OK else null)
	var id = result.get_instance_id()
	# The object meta was used to prevent the Result object from going out-of-scope resulting in
	# endless awaits under certain conditions in previous versions of Godot.
	# TODO: Evaluate if this is still needed.
	var keep = ("_keep_%d" % id).replace("-", "N")
	node.set_meta(keep, result)
	result.completed.connect(func (): node.remove_meta(keep), CONNECT_DEFERRED)
	await result.completed
	if result.is_http_error():
		fail.call()
	return result
