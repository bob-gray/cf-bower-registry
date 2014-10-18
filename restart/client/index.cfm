<cfset applicationStop() />
<cfset session.restarting.client = true />
<cflocation url="#application.baseUrl#" addtoken="false" />