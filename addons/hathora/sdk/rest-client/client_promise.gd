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

## A promise which can have a chain of callbacks that can be resolved asynchronously or blocking.
##
## Calling [method async] or [method blocking] will start resolving the promise asynchronously or blocking, respectively.
##
## All of the callbacks added via [method then] will be called with the result.
extends RefCounted

## The promise status.
enum Status {PENDING, COMPLETED, FAILED}

## The chain of callbacks.
var chain : Array[Callable]
## The result of the REST request.
var result
## The promise status.
var status := Status.PENDING
var _run_async : Callable
var _run_blocking : Callable

func _init(run_async: Callable, run_blocking:=Callable()):
	_run_async = run_async
	_run_blocking = run_blocking


func _hathora_client_promise():
	pass


func _fail():
	status = Status.FAILED


## Starts an asynchronous HTTP request to fulfill the promise.
func async():
	assert(status == Status.PENDING)
	if _run_async.is_valid():
		result = await _run_async.call(_fail)
	# Hang on to old results so they don't go out of scope, leading to endless await.
	# @todo This is most likely a "bug" - hopefully it'll get fixed eventually!
	var old_results := []
	for c in chain:
		old_results.append(result)
		result = await c.call(result)
		if result is Object and result.has_method("_hathora_client_promise"):
			result = await result.async()
	if status != Status.FAILED:
		status = Status.COMPLETED
	return result


## Starts a blocking HTTP request to fulfill the promise.
func blocking(poll_delay_usec:=1000):
	assert(status == Status.PENDING)
	if _run_blocking.is_valid():
		result = _run_blocking.call(poll_delay_usec, _fail)
	for c in chain:
		result = c.call(result)
		if result is Object and result.has_method("_hathora_client_promise"):
			result = result.blocking(poll_delay_usec)
	if status != Status.FAILED:
		status = Status.COMPLETED
	return result


func then(callable: Callable):
	chain.push_back(callable)
	return self


static func _make_promise(callable: Callable):
	return new(func (_1): return callable.call(), func(_1, _2): return callable.call())


## Creates a new promise that will resolve the given array of promises in sequence.
static func sequence(promises: Array):
	if promises.any(func(e): return not e is Callable and not e.has_method("_hathora_client_promise")):
		push_error("The input must be an array of promises")
		return null
	var run_async = func (fail):
		var results = []
		for p in promises:
			if p is Callable:
				p = _make_promise(p)
			results.append(await p.async())
			if p.status == Status.FAILED:
				break
		return results
	var run_blocking = func (poll_delay_usec, reject):
		var results = []
		for p in promises:
			if p is Callable:
				p = _make_promise(p)
			results.append(p.blocking(poll_delay_usec))
			if p.status == Status.FAILED:
				break
		return results
	return new(run_async, run_blocking)
