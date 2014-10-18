<cfset restInitApplication(application.servicePath, application.config.name) />
<cfset session.restarting.service = true />
<cflocation url="#application.baseUrl#" addtoken="false" />