"use strict";

function PackageService (baseUrl) {
	this.baseUrl = baseUrl;
}

PackageService.prototype.get = function (success, fail) {
	return this.ajax({
		url: this.baseUrl +"/packages",
		method: "GET",
		dataType: "json",
		success: success,
		error: fail
	});
};

PackageService.prototype.search = function (criteria, success, fail) {
	return this.ajax({
		url: this.baseUrl +"/packages/search/"+ encodeURIComponent(criteria),
		method: "GET",
		dataType: "json",
		success: success,
		error: fail
	});
};

PackageService.prototype.post = function (pkg, success, fail) {
	return this.ajax({
		url: this.baseUrl +"/packages",
		method: "POST",
		data: {
			name: pkg.name,
			url: pkg.url
		},
		success: success,
		error: fail
	});
};

PackageService.prototype.put = function (pkg, success, fail) {
	return this.ajax({
		url: this.baseUrl +"/packages/"+ encodeURIComponent(pkg.name),
		method: "PUT",
		data: {
			url: pkg.url
		},
		success: success,
		error: fail
	});
};

PackageService.prototype.drop = function (pkg, success, fail) {
	return this.ajax({
		url: this.baseUrl +"/packages/"+ encodeURIComponent(pkg.name),
		method: "DELETE",
		success: success,
		error: fail
	});
};

PackageService.prototype.ajax = function (options) {
	var xhr = $.ajax(options);

	xhr.url = options.url;
	xhr.method = options.method;

	return xhr;
};