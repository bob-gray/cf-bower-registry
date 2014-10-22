<cfcomponent>
	<cfset root = getDirectoryFromPath(getCurrentTemplatePath()) />
	<cfset dataPath = root &"service/data/" />
	<cfset config = deserializeJSON(fileRead(dataPath &"config.json", "utf-8")) />

	<cfset this.name = left(config.name & hash(root), 64) />
	<cfset this.customTagPaths = root &"tags" />
	<cfset this.sessionManagement = true />

	<cffunction name="onApplicationStart" access="public" returnType="boolean">
		<cfset application.config = config />
		<cfset application.baseUrl = getBaseUrl() />
		<cfset application.serviceUrl = getServiceUrl() />
		<cfset application.servicePath = root &"service/resources/" />
		<cfset application.data = buildStore() />
		<cfset application.resetSession = resetSession />

		<cfreturn true />
	</cffunction>

	<cffunction name="onRequestStart" access="public" returnType="boolean">
		<cfif isDefined("url.restart") and url.restart is "client">
			<cfset applicationStop() />
			<cfset session.restarting.client = true />
			<cfset reload() />

		<cfelseif isDefined("url.restart") and url.restart is "service">
			<cfset restInitApplication(application.servicePath, application.config.name) />
			<cfset session.restarting.service = true />
			<cfset reload() />

		<cfelseif isDefined("url.configure")>
			<cfset configure(argumentCollection=form) />
			<cfset applicationStop() />
			<cfset reload() />
		</cfif>

		<cfreturn true />
	</cffunction>

	<cffunction name="onSessionStart" acess="public" returnType="boolean">
		<cfset resetSession() />
		<cfreturn true />
	</cffunction>

	<cffunction name="resetSession" accss="public" returnType="void">
		<cfset session.restarting = {
			"client" = false,
			"service" = false
		} />		
	</cffunction>

	<cffunction name="reload" access="public" returnType="void">
		<cflocation url="#application.baseUrl#" addtoken="false" />
	</cffunction>

	<cffunction name="configure" access="public" returnType="void">
		<cfargument name="name" type="string" required="true" />
		<cfargument name="brand" type="string" required="true" />
		<cfargument name="https" type="boolean" default="false" />

		<cftry>
			<cfset restDeleteApplication(application.servicePath) />
			<cfcatch></cfcatch>
		</cftry>
		<cfset application.data.setConfig({
			"name" = name,
			"brand" = brand,
			"https" = https
		}) />
		<cfset application.data.commitSync("config") />
	</cffunction>

	<cffunction name="getBaseUrl" access="private" returnType="string">
		<cfset var protocol = application.config.https ? "https://" : "http://" />
		<cfset var requestPath = getDirectoryFromPath(expandPath(cgi.script_name)) />
		<cfset var depth = listLen(requestPath, "\/") - listLen(root, "\/") />
		<cfset var basePath = reReplace(getDirectoryFromPath(cgi.script_name), "([^\\/]+[\\/]){#depth#}$", "") />

		<cfreturn protocol & cgi.http_host & basePath />
	</cffunction>

	<cffunction name="getServiceUrl" access="private" returnType="string">
		<cfset var protocol = application.config.https ? "https://" : "http://" />

		<cfreturn protocol & cgi.http_host &"/rest/"& application.config.name />
	</cffunction>

	<cffunction name="buildStore" access="private" returnType="lib.JsonStore">
		<cfreturn new lib.JsonStore(dataPath).restore() />
	</cffunction>
</cfcomponent>