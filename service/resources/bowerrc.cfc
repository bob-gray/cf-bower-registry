<cfcomponent restPath=".bowerrc">
	<cffunction name="get" access="remote" httpMethod="get" produces="application/json" returnType="void">
		<cfset var file = "" />

		<cfsavecontent variable="file">
			<cfinclude template="../assets/bowerrc.cfm" />
		</cfsavecontent>

		<cfset restSetResponse({
			status = 200,
			headers = {
				"Content-Disposition" = 'attachment; filename=".bowerrc"'
			},
			content = trim(file)
		}) />
	</cffunction>
</cfcomponent>