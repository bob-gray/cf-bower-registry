"use strict";

String.prototype.interpolate = function (variables) {
	return this.replace(/\{\{(.*?)\}\}/g, function (match, name) {
		return name in variables ? variables[name] : "";
	});
};

var sort = {
	column: "name",
	order: "ascending"
};

var packages = new PackageService(cf.service);

packages.get(showPackages, showInitializeService);

$(document).ready(function () {
	$(".search, #register-package form, #edit-package form").on("submit", preventDefault);
	$("#edit-package .unregister, .popup .close, [href='#test-service'], [href='#config'").on("click", preventDefault);

	$("th").on("click", function () {
		var th = $(this);

		sort.column = th.text().toLowerCase();

		if (th.is(".ascending")) {
			sort.order = "descending";
		} else {
			sort.order = "ascending";
		}

		th.closest("tr").find("th").removeClass("ascending descending");
		th.addClass(sort.order);

		packages.get(showPackages);
	});

	$(".search").on("submit", function (event) {
		var criteria = $(this).find("[name='criteria']").val();
		packages.search(criteria, showPackages);
	});

	$(".search").on("reset", function (event) {
		packages.get(showPackages);
	});

	$(".packages table").on("click", "tbody tr", function (event) {
		var row = $(event.currentTarget),
			name = row.find("td:eq(0)").text(),
			url = row.find("td:eq(1)").text();

		$("#overlay, #edit-package").addClass("show");
		$("body").addClass("overlaid");
		$("#edit-package").find("[name='name']").val(name);
		$("#edit-package").find("[name='url']").val(url).focus();
	});

	$(".register").on("click", function () {
		$("#overlay, #register-package").addClass("show");
		$("body").addClass("overlaid");
		$("#register-package").find("input").val("");
		$("#register-package").find("[name='name']").focus();
	});

	$("#register-package").on("submit", function (event) {
		packages.post(getFormData(event.target), packageSuccess);
	});

	$("#register-package").on("reset", hidePopup);

	$("#edit-package").on("submit", function (event) {
		enableName(event.target);
		packages.put(getFormData(event.target), packageSuccess);
		disableName(event.target);
	});

	$("#edit-package").on("reset", hidePopup);

	$("#edit-package").on("click", ".unregister", function (event) {
		var form = $(event.target).closest("form");
		enableName(form);
		packages.drop(getFormData(form), packageSuccess);
		disableName(form);
	});

	$(".popup").on("click", ".close", hidePopup);

	$(document).on("keyup", function (event) {
		if (event.which === 27 && $(".popup").is(".show")) {
			hidePopup();
		} else if (event.which === 27 && $(".search [name='criteria']").val()) {
			$(".search").get(0).reset();
		}
	});

	$(".popup").click(function (event) {
		if ($(event.target).is(".popup")) {
			hidePopup();
		}
	});

	$("[href='#test-service']").click(testService);

	$("#test-service button").click(hidePopup);

	$("[href='#config']").on("click", function () {
		$("#overlay, #config").addClass("show");
		$("body").addClass("overlaid");
	});

	if (cf.restarting.service) {
		testService();
	}
});

function showPackages (packages) {
	var template = $("#package-row").html();

	packages.sort(comparePackages);

	$(".packages table tbody").html($.map(packages, function (pkg) {
		return template.interpolate(pkg);
	}));

	$(".packages").show();
}

function comparePackages (a, b) {
	var indicator = a[sort.column] > b[sort.column] ? 1 : -1;

	if (sort.order === "descending") {
		indicator *= -1;
	}

	return indicator;
}

function packageSuccess () {
	packages.get(showPackages);
	hidePopup();
}

function showInitializeService () {
	$(".packages").hide();
	$(".initialize-service").show();
}

function hidePopup (event) {
	$("#overlay, .popup").removeClass("show");
	$("body").removeClass("overlaid");
}

function getFormData (form) {
	return $(form).serializeArray().reduce(toObject, {});
}

function toObject (object, field) {
	object[field.name] = field.value;
	return object;
}

function preventDefault (event) {
	event.preventDefault();
}

function enableName (form) {
	return $(form).find("[name='name']").prop("disabled", false);
}

function disableName (form) {
	return $(form).find("[name='name']").prop("disabled", true);
}

function testService () {
	var tester = new ServiceTester(packages),
		list = $("#test-service").find("ol"),
		template = $("#test-item").html();

	list.empty();
	$("#test-service").removeClass("pass fail");
	$("#overlay, #test-service").addClass("show");
	$("body").addClass("overlaid");

	tester.on("progress fault", function (event, data) {
		list.append(template.interpolate(data));
	});

	tester.on("pass", function () {
		$("#test-service").addClass("pass");
	});

	tester.on("fail", function () {
		$("#test-service").addClass("fail");
	});

	tester.run();
}