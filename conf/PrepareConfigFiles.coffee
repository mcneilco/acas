csUtilities = require "../public/src/conf/CustomerSpecificServerFunctions.js"
properties = require "properties"
_ = require "underscore"
underscoreDeepExtend = require "underscoreDeepExtend"
_.mixin({deepExtend: underscoreDeepExtend(_)})
fs = require 'fs'
flat = require 'flat'
glob = require 'glob'
shell = require 'shelljs'
path = require 'path'
os = require 'os'

global.deployMode= "Dev" # This may be overridden in getConfServiceVars()

sysEnv = process.env

csUtilities.getConfServiceVars sysEnv, (confVars) ->

	substitutions =
		env: sysEnv
		conf: confVars

	options =
		path: true
		namespaces: true
		sections: true
		variables: true
		include: true
		vars: substitutions

	configDir = "./"

	configSuffix=process.argv[2]
	if typeof configSuffix == "undefined"
		configFile = "config.properties"
		configFileAdvanced = "config_advanced.properties"
	else
		configFile = "config-"+configSuffix+".properties"
		configFileAdvanced = "config_advanced-"+configSuffix+".properties"

	console.log "Using "+configFile
	console.log "Using "+configFileAdvanced
	properties.parse configDir+configFile, options, (error, conf) ->
		if error?
			console.log "Problem parsing config.properties: "+error
		else
			properties.parse configDir+configFileAdvanced, options, (error, confAdv) ->
				if errors?
					console.log "Problem parsing config_advanced.properties: "+error
				else
					allConf = _.deepExtend confAdv, conf
					if allConf.client.deployMode == "Prod"
						allConf.server.enableSpecRunner = false
					else
						allConf.server.enableSpecRunner = true
					allConf.server.run = user: do =>
						if !allConf.server.run?
							console.log "server.run.user is not set"
							if sysEnv.USER
								console.log "using process.env.USER #{sysEnv.USER}"
								return sysEnv.USER
							else
								console.log "process.env.USER is not set"
								if process.getuid()
									user = shell.exec('whoami',{silent:true}).output.replace('\n','')
									console.log "using whoami result #{user}"
									return user
								else
									console.log "could not get run user exiting"
									process.exit 1

						return allConf.server.run.user

					writeJSONFormat allConf
					writeClientJSONFormat allConf
					writePropertiesFormat allConf
					writeApacheConfFile()

writeJSONFormat = (conf) ->
	fs.writeFileSync "./compiled/conf.js", "exports.all="+JSON.stringify(conf)+";"

writeClientJSONFormat = (conf) ->
	fs.writeFileSync "../public/src/conf/conf.js", "window.conf="+JSON.stringify(conf.client)+";"

writePropertiesFormat = (conf) ->
	fs = require('fs')

	flatConf = flat.flatten conf
	configOut = ""
	for attr, value of flatConf
		if value != null
			configOut += attr+"="+value+"\n"
		else
			configOut += attr+"=\n"
	fs.writeFileSync "./compiled/conf.properties", configOut

getRFilesWithRoute = ->
	rFiles = glob.sync('public/src/modules/*/src/server/*.R', {cwd: path.resolve(__dirname,'..')})
	routes = []
	for rFile in rFiles
		rFilePath = path.resolve('..',rFile)
		data = fs.readFileSync rFilePath, "utf8", (err) ->
			return console.log(err) if err
		routeMatch = data.match('# ROUTE:.*')
		if routeMatch?
			#console.log routeExistsData
			route = routeMatch[0].replace('# ROUTE:', '').trim()
			if route != ""
				routes.push {filePath: rFile, route: route}
	routes

getRFileHandlerString = (rFilesWithRoute, config, acasHome)->
	rapacheHandlerText = '<Location /'+config.all.client.service.rapache.path+'* ROUTE_TO_BE_REPLACED_BY_PREPAREMODULEINCLUDES *>\n\tSetHandler r-handler\n\tRFileHandler '+acasHome+'/* FILE_TO_BE_REPLACED_BY_PREPAREMODULEINCLUDES *\n</Location>'
	routes = []
	routes.push('<Location /'+config.all.client.service.rapache.path+'/hello>\n\tSetHandler r-handler\n\tREval "hello()"\n</Location>')
	routes.push('<Location /'+config.all.client.service.rapache.path+'/RApacheInfo>\n\tSetHandler r-info\n</Location>')
	for rFile in rFilesWithRoute
		route = rapacheHandlerText.replace('* ROUTE_TO_BE_REPLACED_BY_PREPAREMODULEINCLUDES *',rFile.route)
		route = route.replace('* FILE_TO_BE_REPLACED_BY_PREPAREMODULEINCLUDES *', rFile.filePath)
		routes.push(route)
	routes.join('\n\n')

getApacheCompileOptions = ->
	posssibleCommands = ['httpd', 'apachectl', '/usr/sbin/apachectl', '/usr/sbin/httpd2-prefork', '/usr/sbin/httpd2']
	for possibleCommand in posssibleCommands
		if shell.which(possibleCommand)
			apacheCommand = possibleCommand
			break;
	if not apacheCommand?
		console.log 'Could not find apache command in list: ' + posssibleCommands.join(', ') + 'skipping apache config'
		return 'skip'

	compileString = shell.exec(apacheCommand + ' -V', {silent:true})
	compileOptionStrings =  compileString.output.split("\n");
	compileOptions = []
	apacheVersion = ''
	for option in compileOptionStrings
		if option.match('Server version')
			if option.match('Ubuntu')
				apacheVersion = 'Ubuntu'
			else
				if option.match('SUSE')
					apacheVersion = 'SUSE'
				else
					if os.type() == "Darwin"
						apacheVersion = 'Darwin'
					else
						apacheVersion = 'Redhat'
		else
			option = option.match(/^ -D .*/)
			if option?
				option = option[0].replace(' -D ','')
				option = option.split('=')
				option = {option: option[0], value: option[1]}
				compileOptions.push(option)
	console.log apacheVersion
	compileOptions.push(option: 'ApacheVersion', value: apacheVersion)
	compileOptions

getRApacheSpecificConfString = (config, apacheCompileOptions, apacheHardCodedConfigs, acasHome) ->
	confs = []
	runUser = config.all.server.run.user
	confs.push('User ' + runUser)
	confs.push('Group ' + shell.exec('id -g -n ' + runUser, {silent:true}).output.replace('\n','')  )
	confs.push('Listen ' + config.all.server.rapache.listen + ':' + config.all.client.service.rapache.port)
	confs.push('PidFile ' + acasHome + '/bin/apache.pid')
	confs.push('StartServers ' + _.findWhere(apacheHardCodedConfigs, {directive: 'StartServers'}).value)
	confs.push('ServerSignature ' + _.findWhere(apacheHardCodedConfigs, {directive: 'ServerSignature'}).value)
	confs.push('ServerName ' + config.all.client.host)
	confs.push('HostnameLookups ' + _.findWhere(apacheHardCodedConfigs, {directive: 'HostnameLookups'}).value)
	confs.push('ServerAdmin ' + _.findWhere(apacheHardCodedConfigs, {directive: 'ServerAdmin'}).value)
	confs.push('LogFormat ' + _.findWhere(apacheHardCodedConfigs, {directive: 'LogFormat'}).value)
	confs.push('ErrorLog ' + config.all.server.log.path + '/racas.log')
	confs.push('LogLevel ' + config.all.server.log.level.toLowerCase())
	if Boolean(config.all.client.use.ssl)
		urlPrefix = 'https'
		confs.push('SSLEngine On')
		confs.push('SSLCertificateFile ' + config.all.server.ssl.cert.file.path)
		confs.push('SSLCertificateKeyFile ' + config.all.server.ssl.key.file.path)
		confs.push('SSLCACertificateFile ' + config.all.server.ssl.cert.authority.file.path)
		confs.push('SSLPassPhraseDialog ' + '\'|' + path.resolve(acasHome,'conf','executeNodeScript.sh') + ' ' + path.resolve(acasHome,'conf','getSSLPassphrase.js' + '\''))
	else
		urlPrefix = 'http'
	confs.push('DirectoryIndex index.html\n<Directory />\n\tOptions FollowSymLinks\n\tAllowOverride None\n</Directory>')
	confs.push('<Directory ' + acasHome + '>\n\tOptions Indexes FollowSymLinks\n\tAllowOverride None\n</Directory>')
	confs.push('RewriteEngine On')
	confs.push("RewriteRule ^/$ #{urlPrefix}://#{config.all.client.host}:#{config.all.client.port}/$1 [L,R,NE]")
	confs.push('REvalOnStartup \'Sys.setenv(ACAS_HOME = \"' + acasHome + '\");.libPaths(file.path(\"' + acasHome + '/r_libs\"));require(racas)\'')
	return confs.join('\n')

getApacheSpecificConfString = (config, apacheCompileOptions, apacheHardCodedConfigs, acasHome) ->
	apacheSpecificConfs = []
	apacheVersion = _.findWhere(apacheCompileOptions, {option: 'ApacheVersion'}).value
	switch apacheVersion
		when 'Ubuntu'
			serverRoot = '\"/usr/lib/apache2\"'
			modulesDir = 'modules/'
			typesConfig = '/etc/mime.types'
		when 'Redhat'
			serverRoot = '\"/etc/httpd\"'
			modulesDir = 'modules/'
			typesConfig = '/etc/mime.types'
		when 'SUSE'
			serverRoot = '\"/usr\"'
			modulesDir = 'lib64/apache2/'
			typesConfig = '/etc/mime.types'
		when 'Darwin'
			serverRoot = '\"/usr\"'
			modulesDir = 'libexec/apache2/'
			typesConfig = '/private/etc/apache2/mime.types'

	apacheSpecificConfs.push('ServerRoot ' + serverRoot)
	apacheSpecificConfs.push('LoadModule mime_module ' + modulesDir + "mod_mime.so")
	apacheSpecificConfs.push('TypesConfig ' + typesConfig)
	if apacheVersion in ['Redhat', 'Darwin', 'SUSE']
		apacheSpecificConfs.push('LoadModule log_config_module ' + modulesDir + "mod_log_config.so")
		apacheSpecificConfs.push('LoadModule logio_module ' + modulesDir + "mod_logio.so")
	if apacheVersion == 'Darwin'
		apacheSpecificConfs.push('Mutex default:' + acasHome + '/bin')
		apacheSpecificConfs.push("LoadModule unixd_module " + modulesDir + "mod_unixd.so")
		apacheSpecificConfs.push("LoadModule authz_core_module " + modulesDir + "mod_authz_core.so")
	if apacheVersion == 'Ubuntu'
		apacheSpecificConfs.push('LoadModule mpm_prefork_module ' + modulesDir + "mod_mpm_prefork.so")
		apacheSpecificConfs.push('LoadModule authz_core_module ' + modulesDir + "mod_authz_core.so")
	apacheSpecificConfs.push('LoadModule dir_module ' + modulesDir + "mod_dir.so")
	if Boolean(config.all.client.use.ssl)
		apacheSpecificConfs.push('LoadModule ssl_module ' + modulesDir + "mod_ssl.so")
	else
	apacheSpecificConfs.push('LoadModule rewrite_module ' + modulesDir + "mod_rewrite.so")
	apacheSpecificConfs.push('LoadModule R_module ' + modulesDir + "mod_R.so")
	apacheSpecificConfs.join('\n')


apacheHardCodedConfigs= [{directive: 'StartServers', value: '5'},
	{directive: 'ServerSignature', value: 'On'},
	{directive: 'HostnameLookups', value: 'On'},
	{directive: 'ServerAdmin', value: 'root@localhost'},
	{directive: 'ServerSignature', value: 'On'},
	{directive: 'LogFormat', value: '"%h %l %u %t \\"%r\\" %>s %b \\"%{Referer}i\\" \\"%{User-Agent}i\\"" combined'},
	{directive: 'RewriteEngine', value: 'On'}]

writeApacheConfFile = ->
	config = require './compiled/conf.js'
	acasHome = path.resolve(__dirname,'..')
	apacheCompileOptions = getApacheCompileOptions()
	if apacheCompileOptions != 'skip'
		apacheSpecificConfString = getApacheSpecificConfString(config, apacheCompileOptions, apacheHardCodedConfigs, acasHome)
	else
		apacheSpecificConfString = ''
	rapacheConfString = getRApacheSpecificConfString(config, apacheCompileOptions, apacheHardCodedConfigs, acasHome)
	rFilesWithRoute = getRFilesWithRoute()
	rFileHandlerString = getRFileHandlerString(rFilesWithRoute, config, acasHome)
	fs.writeFileSync "./compiled/apache.conf", [apacheSpecificConfString,rapacheConfString,rFileHandlerString].join('\n')
	fs.writeFileSync "./compiled/rapache.conf", [rapacheConfString,rFileHandlerString].join('\n')