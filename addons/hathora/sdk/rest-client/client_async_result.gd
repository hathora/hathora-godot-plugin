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

## The result of an async HTTP request.
extends "client_result.gd"

## Emitted when the request is complete.
signal completed

## The pending HTTP request.
var pending_request = null

func _init(request: HTTPRequest):
	if request != null:
		if not request.is_inside_tree():
			request.queue_free()
			_error.call_deferred()
		else:
			pending_request = request
			request.request_completed.connect(self._parse_result, Node.CONNECT_ONE_SHOT)
	else:
		_error.call_deferred()

func _error():
	if result_status == ResultStatus.CANCELLED:
		return
	result_status = ResultStatus.ERROR
	_done()


func _done():
	pending_request = null
	completed.emit()


func _parse_result(
	p_result: int, p_status: int, p_headers: PackedStringArray, p_body: PackedByteArray
):
	http_request_result = p_result
	http_status_code = p_status
	headers = p_headers
	body = p_body
	if http_request_result != HTTPRequest.RESULT_SUCCESS and http_request_result != HTTPRequest.RESULT_REDIRECT_LIMIT_REACHED:
		result_status = ResultStatus.ERROR
	else:
		result_status = ResultStatus.DONE
	pending_request.queue_free()
	_done()


## Cancels the pending request.
func cancel() -> void:
	if not is_pending():
		return

	if pending_request != null:
		pending_request.cancel_request()
		pending_request.request_completed.disconnect(self._parse_result)
		pending_request.queue_free()
		pending_request = null

	result_status = ResultStatus.CANCELLED
	_done()
