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
	this.get()
		.always(this.proxy("search"))
		.always(this.proxy("post"))
		.always(this.proxy("put"))
		.always(this.proxy("drop"))
		.done(this.proxy("emit", "pass"))
		.fail(this.proxy("emit", "fail"));
};

ServiceTester.prototype.on = function (eventName, handler) {
	$(this).on(eventName, handler);
};

ServiceTester.prototype.onSuccess = function (response, state, xhr) {
	this.emit("progress", {
		state: state,
		url: xhr.url,
		httpMethod: xhr.httpMethod,
		status: xhr.status,
		statusText: xhr.statusText,
		response: response
	});
};

ServiceTester.prototype.onFail = function (xhr, state) {
	this.emit("fault", {
		state: state,
		url: xhr.url,
		httpMethod: xhr.httpMethod,
		status: xhr.status,
		statusText: xhr.statusText
	});
};

ServiceTester.prototype.emit = function (eventName, data) {
	$(this).trigger(eventName, data);
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

ServiceTester.prototype.proxy = function (method, nArgs) {
	var params = $.makeArray(arguments);
	params.unshift(this);
	return $.proxy.apply($, params);
};