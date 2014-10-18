<cfcomponent>
	<cfset root = "" />
	<cfset data = {} />

	<cffunction name="init" access="public" returnType="JsonStore">
		<cfargument name="root" type="string" default="" />

		<cfset variables.root = arguments.root />

		<cfreturn this />
	</cffunction>

	<cffunction name="restore" access="public" returnType="JsonStore">
		<cfargument name="keys" type="string" default="" />

		<cfset var paths = getPaths() />
		<cfset var path = "" />
		<cfset var key = "" />
		<cfset var json = "" />

		<cfloop array="#paths#" index="path">
			<cfset key = getKeyFromPath(path) />
			
			<cfif keys is "" or listFindNoCase(keys, key)>
				<cfset json = getJSON(path) />
				<cfset data[key] = deserializeJSON(json) />
			</cfif>
		</cfloop>

		<cfreturn this />
	</cffunction>

	<cffunction name="get" access="public" returnType="any">
		<cfargument name="key" type="string" required="true" />

		<cfreturn data[key] />
	</cffunction>

	<cffunction name="getKeyList" access="public" returnType="string">
		<cfreturn structKeyList(data) />
	</cffunction>

	<cffunction name="set" access="public" returnType="void">
		<cfargument name="key" type="string" required="true" />
		<cfargument name="value" type="any" required="true" />

		<cfset data[key] = value />
	</cffunction>

	<cffunction name="commit" access="public" returnType="void">
		<cfargument name="keys" type="string" default="" />

		<cfthread name="#createUUID()#" priority="low" keys="#keys#">
			<cfset commitSync(keys) />
		</cfthread>
	</cffunction>

	<cffunction name="commitSync" access="public" returnType="void">
		<cfargument name="keys" type="string" default="" />

		<cfset var key = "" />

		<cfif keys is "">
			<cfset writeAll() />

		<cfelse>
			<cfloop list="#keys#" index="key">
				<cfset write(key) />
			</cfloop>
		</cfif>
	</cffunction>

	<cffunction name="write" access="private" returnType="void">
		<cfargument name="key" type="string" required="true" />

		<cfset var path = getPathFromKey(key) />
		<cfset var value = get(key) />
		<cfset var json = serializeJSON(value) />

		<cfset fileWrite(path, json, "utf-8") />		
	</cffunction>

	<cffunction name="writeAll" access="private" returnType="void">
		<cfset var key = "" />

		<cfloop collection="#data#" item="key">
			<cfset write(key) />
		</cfloop>
	</cffunction>

	<cffunction name="getPaths" access="private" returnType="array">		
		<cfreturn directoryList(root, true, "path", "*.json") />
	</cffunction>

	<cffunction name="getJSON" access="private" returnType="string">
		<cfargument name="path" type="string" required="true" />
		
		<cfreturn fileRead(path, "utf-8") />
	</cffunction>

	<cffunction name="getKeyFromPath" access="private" returnType="string">
		<cfargument name="path" type="string" required="true" />

		<cfset var key = getFileFromPath(path) />
		
		<cfreturn reReplace(key, "\.json$", "") />
	</cffunction>

	<cffunction name="getPathFromKey" access="private" returnType="string">
		<cfargument name="key" type="string" required="true" />

		<cfset var path = key &".json" />
		
		<cfreturn listAppend(root, path, "\") />
	</cffunction>

	<cffunction name="onMissingMethod" access="public" returnType="any">
		<cfargument name="missingMethodName" type="string" required="true" />
		<cfargument name="missingMethodArguments" type="struct" required="true" />

		<cfset var methodPrefix = getMethodPrefix(missingMethodName) />
		<cfset var key = getMethodKey(missingMethodName) />

		<cfif isImplicitAccessor(methodPrefix)>
			<cfinvoke method="#methodPrefix#" returnVariable="local.result">
				<cfinvokeargument name="key" value="#key#" />
				
				<cfif methodPrefix is "set">
					<cfinvokeargument name="value" value="#missingMethodArguments[1]#" />
				</cfif>
			</cfinvoke>

		<cfelse>
			<!--- Provoke error for missing method that is not implicit accessor --->
			<cfinvoke method="#missingMethodName#" />
		</cfif>

		<cfif isDefined("local.result")>
			<cfreturn local.result />
		</cfif>
	</cffunction>

	<cffunction name="getMethodPrefix" access="private" returnType="string">
		<cfargument name="methodName" type="string" required="true" />
		
		<cfreturn left(methodName, 3) />
	</cffunction>

	<cffunction name="getMethodKey" access="private" returnType="string">
		<cfargument name="methodName" type="string" required="true" />
		
		<cfreturn reReplace(methodName, "^(?:get|set)(\w)(.*)$", "\l\1\2") />
	</cffunction>

	<cffunction name="isImplicitAccessor" access="private" returnType="boolean">
		<cfargument name="methodPrefix" type="string" required="true" />
		
		<cfreturn methodPrefix is "get" or methodPrefix is "set" />
	</cffunction>
</cfcomponent>