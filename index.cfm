<!DOCTYPE html>
<html lang="en">
	<head>
		<meta charset="utf-8" />
		<meta http-equiv="X-UA-Compatible" content="IE=edge" />
		<meta name="viewport" content="width=device-width, initial-scale=1" />

		<link rel="stylesheet" href="./bower_components/open-sans/css/open-sans.min.css" />
		<link rel="stylesheet" href="./bower_components/fontawesome/css/font-awesome.min.css" />
		<link rel="stylesheet" href="./css/main.css" />

		<title><cfoutput>#application.config.brand#</cfoutput> Bower Registry</title>

		<cf_to_js service="#application.serviceUrl#" restarting="#session.restarting#" />
		<cfset application.resetSession() />

		<script src="./bower_components/jquery/dist/jquery.min.js"></script>
		<script src="./js/PackageService.js"></script>
		<script src="./js/ServiceTester.js"></script>
		<script src="./js/main.js"></script>
	</head>
	<body>
		<header>
			<menu class="system">
				<li>
					<cfoutput>
						<a href="#application.serviceUrl#/.bowerrc">Download .bowerrc</a>
					</cfoutput>
				</li>
				<li>
					<a href="#test-service">Test Service</a>
				</li>
				<li>
					<a href="./restart/service/">Restart Service</a>
				</li>
				<li>
					<a href="./restart/client/">Restart Client</a>
				</li>
				<li>
					<a href="#config">Config</a>
				</li>
			</menu>
			<h1><cfoutput>#application.config.brand#</cfoutput> Bower Registry</h1>
		</header>
		<main>
			<section class="packages">
				<h2>Packages</h2>
				<div class="controls">
					<button class="register">Register Package</button>
					<form class="search">
						<input name="criteria" placeholder="Search" />
						<button type="submit" data-tooltip="Submit"></button>
						<button type="reset" data-tooltip="Cancel"></button>
					</form>
				</div>
				<table>
					<thead>
						<tr>
							<th class="ascending" width="30%">Name</th>
							<th>URL</th>
							<th width="15%">Hits</th>
						</tr>
					</thead>
					<tbody></tbody>
				</table>
			</section>
			<section class="initialize-service">
				<p>
					It appears the registry service is not running. This may be because it has not
					been initialized.
				</p>
				<p>
					Press the button below to initialize the service. If the service
					has already been initialized, you may want to click Test Service above for
					more information.
				</p>
				<a href="./restart/service/">Initialize Service</a>
			</section>
		</main>
		<div id="overlay"></div>
		<section id="edit-package" class="popup">
			<form>
				<h2>Edit Package</h2>
				<a class="close" href="#"></a>
				<fieldset class="name">
					<label for="edit-name">Name</label>
					<input id="edit-name" name="name" disabled />
				</fieldset>
				<fieldset class="url">
					<label for="edit-url">URL</label>
					<input id="edit-url" name="url" />
				</fieldset>
				<div class="buttonpane">
					<button class="unregister">Unregister</button>
					<button type="submit">Apply</button>
					<button type="reset">Cancel</button>
				</div>
			</form>
		</section>
		<section id="register-package" class="popup">
			<form>
				<h2>Register Package</h2>
				<a class="close" href="#"></a>
				<fieldset class="name">
					<label for="edit-name">Name</label>
					<input id="edit-name" name="name" />
				</fieldset>
				<fieldset class="url">
					<label for="edit-url">URL</label>
					<input id="edit-url" name="url" />
				</fieldset>
				<div class="buttonpane">
					<button type="submit">Apply</button>
					<button type="reset">Cancel</button>
				</div>
			</form>
		</section>
		
		<section id="config" class="popup">
			<form action="cfc/config.cfc?method=set" method="post">
				<h2>Application Configuration</h2>
				<a class="close" href="#"></a>
				<cfoutput>
					<fieldset class="name">
						<label for="config-name">Name</label>
						<input id="config-name" name="name" value="#application.config.name#" />
					</fieldset>
					<fieldset class="brand">
						<label for="config-brand">Brand</label>
						<input id="config-brand" name="brand" value="#application.config.brand#" />
					</fieldset>
					<fieldset class="https">
						<input id="config-https" type="checkbox" name="https" value="true" <cfif application.config.https>checked</cfif> />
						<label for="config-https">HTTPS</label>
					</fieldset>
				</cfoutput>
				<div class="buttonpane">
					<button type="submit">Save</button>
					<button type="reset">Cancel</button>
				</div>
			</form>
		</section>
		<section id="test-service" class="popup">
			<div>
				<h2>Testing Service...</h2>
				<a class="close" href="#"></a>
				<ol></ol>
				<div class="message pass">
					<h3>Congratulations!</h3>
					<p>Your bower registry service is healthy.<p>
				</div>
				<div class="message fail">
					<h3>We're Sorry.</h3>
					<p>There seems to be a problem with your bower registry service.<p>
				</div>
				<div class="buttonpane">
					<button>Ok</button>
				</div>
			</div>
		</section>
		<template id="package-row">
			<tr>
				<td>{{name}}</td>
				<td>{{url}}</td>
				<td>{{hits}}</td>
			</tr>
		</template>
		<template id="test-item">
			<li class="{{state}}">{{httpMethod}} {{url}} {{status}} {{statusText}}</li>
		</template>
	</body>
</html>