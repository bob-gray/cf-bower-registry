<cfcomponent restPath="packages">
	<cffunction name="getPackages" access="remote" httpMethod="get" produces="application/json" returnType="array">
		<cfreturn application.data.getPackages()/>
	</cffunction>

	<cffunction name="getPackage" access="remote" restPath="{name}" httpMethod="get" produces="application/json" returnType="struct">
		<cfargument name="name" type="string" restArgSource="path" required="true" />

		<cfset var packages = getPackages() />
		<cfset var package = {} />
		<cfset var found = false />

		<cfloop array="#packages#" index="package">
			<cfif package.name is name>
				<cfset found = true />
				<cfset package.hits += 1 />
				<cfset persistPackages(packages) />
				<cfbreak />
			</cfif>
		</cfloop>

		<cfif not found>
			<cfthrow errorcode="404" type="Client Error" message="Package not found" />
		</cfif>

		<cfreturn package />
	</cffunction>

	<cffunction name="searchPackages" access="remote" restPath="search/{criteria}" httpMethod="get" produces="application/json" returnType="array">
		<cfargument name="criteria" type="string" restArgSource="path" required="true" />

		<cfset var packages = getPackages() />
		<cfset var package = {} />
		<cfset var matches = [] />

		<cfloop array="#packages#" index="package">
			<cfif package.name contains criteria>
				<cfset arrayAppend(matches, package) />
			</cfif>
		</cfloop>

		<cfreturn matches />
	</cffunction>

	<cffunction name="postPackage" access="remote" httpMethod="post" returnType="void">
		<cfargument name="name" type="string" restArgSource="form" required="true" />
		<cfargument name="url" type="string" restArgSource="form" required="true" />

		<cfset var packages = getPackages() />

		<cfset arrayAppend(packages, {
			"name" = name,
			"url" = url,
			"hits" = 0
		}) />

		<cfset persistPackages(packages) />

		<cfset restSetResponse({
			status = 201
		}) />
	</cffunction>

	<cffunction name="putPackage" access="remote" restPath="{name}" httpMethod="put" produces="application/json" returnType="void">
		<cfargument name="name" type="string" restArgSource="path" required="true" />
		<cfargument name="url" type="string" restArgSource="form" required="true" />

		<cfset var packages = getPackages() />
		<cfset var package = {} />
		<cfset var found = false />

		<cfloop array="#packages#" index="package">
			<cfif package.name is name>
				<cfset found = true />
				<cfset package.url = url />
				<cfset persistPackages(packages) />
				<cfbreak />
			</cfif>
		</cfloop>

		<cfif not found>
			<cfthrow errorcode="404" type="Client Error" message="Package not found" />
		</cfif>

		<cfset restSetResponse({
			status = 204
		}) />
	</cffunction>

	<cffunction name="deletePackage" access="remote" restPath="{name}" httpMethod="delete" produces="application/json" returnType="void">
		<cfargument name="name" type="string" restArgSource="path" required="true" />

		<cfset var packages = getPackages() />
		<cfset var index = 1 />
		<cfset var package = {} />
		<cfset var found = false />

		<cfloop from="1" to="#arrayLen(packages)#" index="index">
			<cfset package = packages[index] />

			<cfif package.name is name>
				<cfset found = true />
				<cfset arrayDeleteAt(packages, index) />
				<cfset persistPackages(packages) />
				<cfbreak />
			</cfif>
		</cfloop>

		<cfif not found>
			<cfthrow errorcode="404" type="Client Error" message="Package not found" />
		</cfif>

		<cfset restSetResponse({
			status = 204
		}) />
	</cffunction>

	<cffunction name="persistPackages" access="private" returnType="void">
		<cfargument name="packages" type="array" required="true" />

		<cfset application.data.setPackages(packages) />
		<cfset application.data.commit("packages") />
	</cffunction>
</cfcomponent>