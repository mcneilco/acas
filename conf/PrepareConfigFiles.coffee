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
	rapacheHandlerText = '<Location /'+config.all.client.service.rapache.path+'* ROUTE_TO_BE_REPLACED_BY_PREPAREMODULEINCLUDES */>\n\tSetHandler r-handler\n\tRFileHandler '+acasHome+'/* FILE_TO_BE_REPLACED_BY_PREPAREMODULEINCLUDES *\n</Location>'
	routes = []
	routes.push('<Location /'+config.all.client.service.rapache.path+'>\n\tSetHandler r-handler\n\tREval "hello()"\n</Location>')
	routes.push('<Location /'+config.all.client.service.rapache.path+'/RApacheInfo>\n\tSetHandler r-info\n</Location>')
	for rFile in rFilesWithRoute
		route = rapacheHandlerText.replace('* ROUTE_TO_BE_REPLACED_BY_PREPAREMODULEINCLUDES *',rFile.route)
		route = route.replace('* FILE_TO_BE_REPLACED_BY_PREPAREMODULEINCLUDES *', rFile.filePath)
		routes.push(route)
	routes.join('\n\n')

getApacheCompileOptions = ->
	if not shell.which 'apachectl'
		if not shell.which 'httpd'
			shell.echo 'Cannot find apachectl or httpd commands'
			shell.exit 1
		else
			compileString = shell.exec('httpd -V', {silent:true})
	else
		compileString = shell.exec('apachectl -V', {silent:true})
	compileOptionStrings =  compileString.output.split("\n");
	compileOptions = []
	for option in compileOptionStrings
		option = option.match(/^ -D .*/)
		if option?
			option = option[0].replace(' -D ','')
			option = option.split('=')
			option = {option: option[0], value: option[1]}
			compileOptions.push(option)
	if os.type() == "Darwin"
		modulesPath = 'libexec/apache2/'
	else
		modulesPath = 'modules/'
	compileOptions.push(option: 'modulesPath', value: modulesPath)

	compileOptions

getApacheConfsString = (config, apacheCompileOptions, apacheHardCodedConfigs, acasHome) ->
	confs = []
	runUser = shell.exec('whoami',{silent:true}).output.replace('\n','')
	if config.all.server.run?
		if config.all.server.run.user?
			runUser = server.run.user
	confs.push('User ' + runUser)
	confs.push('Group ' + shell.exec('id -g -n ' + runUser, {silent:true}).output.replace('\n','')  )
	confs.push('Listen ' + config.all.server.rapache.listen + ':' + config.all.client.service.rapache.port)
	confs.push('PidFile ' + acasHome + '/bin/apache.pid')
	confs.push('LockFile ' + acasHome + '/bin/apache.lock')
	confs.push('StartServers ' + _.findWhere(apacheHardCodedConfigs, {directive: 'StartServers'}).value)
	confs.push('ServerSignature ' + _.findWhere(apacheHardCodedConfigs, {directive: 'ServerSignature'}).value)
	confs.push('ServerRoot ' + _.findWhere(apacheCompileOptions, {option: 'HTTPD_ROOT'}).value)
	confs.push('ServerName ' + config.all.client.host)
	confs.push('HostnameLookups ' + _.findWhere(apacheHardCodedConfigs, {directive: 'HostnameLookups'}).value)
	confs.push('ServerAdmin ' + _.findWhere(apacheHardCodedConfigs, {directive: 'ServerAdmin'}).value)
	confs.push('LoadModule mime_module ' + _.findWhere(apacheCompileOptions, {option: 'modulesPath'}).value + "mod_mime.so")
	confs.push('TypesConfig ' + _.findWhere(apacheCompileOptions, {option: 'AP_TYPES_CONFIG_FILE'}).value.replace(/\"/g,""))
	confs.push('LoadModule log_config_module ' + _.findWhere(apacheCompileOptions, {option: 'modulesPath'}).value + "mod_log_config.so")
	confs.push('LoadModule logio_module ' + _.findWhere(apacheCompileOptions, {option: 'modulesPath'}).value + "mod_logio.so")
	confs.push('LogFormat ' + _.findWhere(apacheHardCodedConfigs, {directive: 'LogFormat'}).value)
	confs.push('ErrorLog ' + config.all.server.log.path + '/racas.log')
	confs.push('LogLevel ' + config.all.server.log.level.toLowerCase())
	confs.push('LoadModule dir_module ' + _.findWhere(apacheCompileOptions, {option: 'modulesPath'}).value + "mod_dir.so")

	if Boolean(config.all.client.use.ssl)
		confs.push('LoadModule ssl_module ' + _.findWhere(apacheCompileOptions, {option: 'modulesPath'}).value + "mod_ssl.so")
		confs.push('SSLEngine on')
		confs.push('SSLCertificateFile ' + config.all.server.ssl.cert.file.path)
		confs.push('SSLCertificateFile ' + config.all.server.ssl.key.file.path)
		confs.push('SSLCertificateFile ' + config.all.server.ssl.cert.authority.file.path)

	confs.push('DirectoryIndex index.html\n<Directory />\n\tOptions FollowSymLinks\n\tAllowOverride None\n</Directory>')
	confs.push('DirectoryIndex index.html\n<Directory />\n\tOptions FollowSymLinks\n\tAllowOverride None\n</Directory>')
	confs.push('<Directory ' + acasHome + '>\n\tOptions Indexes FollowSymLinks\n\tAllowOverride None\n</Directory>')
	confs.push('LoadModule R_module ' + _.findWhere(apacheCompileOptions, {option: 'modulesPath'}).value + "mod_R.so")
	confs.push('REvalOnStartup \'Sys.setenv(ACAS_HOME = \"' + acasHome + '\");.libPaths(file.path(\"' + acasHome + '/r_libs\"));require(racas)\'')
	confs.join('\n')


apacheHardCodedConfigs= [{directive: 'StartServers', value: '4'},
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
	apacheConfString = getApacheConfsString(config, apacheCompileOptions, apacheHardCodedConfigs, acasHome)
	rFilesWithRoute = getRFilesWithRoute()
	rFileHandlerString = getRFileHandlerString(rFilesWithRoute, config, acasHome)
	fs.writeFileSync "./compiled/apache.conf", [apacheConfString,rFileHandlerString].join('\n')