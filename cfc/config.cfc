<cfcomponent>
	<cffunction name="set" access="remote" returnType="boolean">
		<cfargument name="name" type="string" required="true" />
		<cfargument name="brand" type="string" required="true" />
		<cfargument name="https" type="boolean" default="false" />

		<cfset restDeleteApplication(application.servicePath) />
		<cfset application.store.setConfig({
			"name" = name,
			"brand" = brand,
			"https" = https
		}) />
		<cfset application.store.commitSync("config") />
		<cfset applicationStop() />
		<cflocation url="#application.baseUrl#" />

		<cfreturn true />
	</cffunction>
</cfcomponent>