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
		<cfset application.store = buildStore() />
		<cfset application.resetSession = resetSession />

		<cfreturn true />
	</cffunction>

	<cffunction name="resetSession" accss="public" returnType="void">
		<cfset session.restarting = {
			"client" = false,
			"service" = false
		} />		
	</cffunction>

	<cffunction name="onSessionStart" acess="public" returnType="boolean">
		<cfset resetSession() />
		<cfreturn true />
	</cffunction>

	<cffunction name="buildStore" access="private" returnType="lib.JsonStore">
		<cfreturn new lib.JsonStore(dataPath).restore() />
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
</cfcomponent>