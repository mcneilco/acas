class window.UtilityFunctions
	getFileServiceURL: ->
		"/uploads"
#		if window.conf.use.ssl
#			"https://"+window.conf.host+":"+window.conf.service.file.port
#		else
#			"http://"+window.conf.host+":"+window.conf.service.file.port