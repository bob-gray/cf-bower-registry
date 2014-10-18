<cfif thisTag.executionMode is "start">
	<cfset data = {} />

	<cfloop collection="#attributes#" item="name">
		<cfset data[lCase(name)] = attributes[name] />
	</cfloop>

	<script>
		var cf = <cfoutput>#serializeJSON(data)#</cfoutput>;
	</script>
</cfif>