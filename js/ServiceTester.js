"use strict";

function ServiceTester (service) {
	this.service = service;
	this.pkg = {
		name: "service-tester",
		url: "http://test.com"
	};
	this.stats = [];
}

ServiceTester.prototype.run = function () {
	this.start("get")
		.then("search")
		.then("post")
		.then("put")
		.then("drop")
		.finish();
};

ServiceTester.prototype.on = function (eventName, handler) {
	$(this).on(eventName, handler);
};

ServiceTester.prototype.start = function (method) {
	this.deferred = this[method]();
	return this;
};

ServiceTester.prototype.then = function (method) {
	var callback = this.proxy(method);
	this.deferred.then(callback, callback);
	return this;
};

ServiceTester.prototype.finish = function () {
	this.deferred.then(
		this.proxy("emit", "pass"),
		this.proxy("emit", "fail")
	);
};

ServiceTester.prototype.success = function (method) {
	this.deferred.done(this.proxy("emit", "pass"));
	return this;
};

ServiceTester.prototype.error = function (method) {
	this.deferred.fail(this.proxy("emit", "fail"));
};

ServiceTester.prototype.get = function () {
	return this.service.get(
		this.proxy("onSuccess"),
		this.proxy("onFail")
	);
};

ServiceTester.prototype.search = function () {
	return this.service.search(
		this.pkg.name,
		this.proxy("onSuccess"),
		this.proxy("onFail")
	);
};

ServiceTester.prototype.post = function () {
	return this.service.post(
		this.pkg,
		this.proxy("onSuccess"),
		this.proxy("onFail")
	);
};

ServiceTester.prototype.put = function () {
	return this.service.put(
		this.pkg,
		this.proxy("onSuccess"),
		this.proxy("onFail")
	);
};

ServiceTester.prototype.drop = function () {
	return this.service.drop(
		this.pkg,
		this.proxy("onSuccess"),
		this.proxy("onFail")
	);
};

ServiceTester.prototype.emit = function (eventName, data) {
	$(this).trigger(eventName, data);
};

ServiceTester.prototype.onSuccess = function (response, state, xhr) {
	this.emit("progress", {
		state: state,
		url: xhr.url,
		method: xhr.method,
		status: xhr.status,
		statusText: xhr.statusText,
		response: response
	});
};

ServiceTester.prototype.onFail = function (xhr, state) {
	this.emit("fault", {
		state: state,
		url: xhr.url,
		method: xhr.method,
		status: xhr.status,
		statusText: xhr.statusText
	});
};

ServiceTester.prototype.proxy = function (method, nArgs) {
	var params = $.makeArray(arguments);
	params.unshift(this);
	return $.proxy.apply($, params);
};