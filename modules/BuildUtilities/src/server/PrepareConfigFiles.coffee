properties = require "properties"
_ = require "underscore"
underscoreDeepExtend = require "underscore-deep-extend"
_.mixin({deepExtend: underscoreDeepExtend(_)})
fs = require 'fs'
flat = require 'flat'
glob = require 'glob'
shell = require 'shelljs'
path = require 'path'
acasHome =  path.resolve "#{__dirname}/../../.."
csUtilities = require "#{acasHome}/src/javascripts/ServerAPI/CustomerSpecificServerFunctions.js"
os = require 'os'
propertiesParser = require "properties-parser"
configDir = "#{acasHome}/conf/"
global.deployMode= "Dev" # This may be overridden in getConfServiceVars()

sysEnv = process.env

mkdirSync = (path) ->
	try
		fs.mkdirSync path
	catch e
		if e.code != 'EEXIST'
			throw e
	return

writeJSONFormat = (conf) ->
	mkdirSync "#{configDir}/compiled"
	fs.writeFileSync "#{configDir}/compiled/conf.js", "exports.all="+JSON.stringify(conf)+";"

writeClientJSONFormat = (conf) ->
	mkdirSync "#{acasHome}/public/conf"
	fs.writeFileSync "#{acasHome}/public/conf/conf.js", "window.conf="+JSON.stringify(conf.client)+";"

writePropertiesFormat = (conf) ->
	fs = require('fs')

	flatConf = flat.flatten conf
	configOut = ""
	for attr, value of flatConf
		if value != null
			configOut += attr+"="+value+"\n"
		else
			configOut += attr+"=\n"
	fs.writeFileSync "#{configDir}/compiled/conf.properties", configOut


getRFilesWithRoute = ->
	rFiles = glob.sync("#{acasHome}/src/r/**/*.R")
	routes = []
	for rFile in rFiles
		rFilePath = path.resolve(rFile)
		data = fs.readFileSync rFilePath, "utf8", (err) ->
			return console.log(err) if err
		routeMatch = data.match('# ROUTE:.*')
		if routeMatch?
			#console.log routeExistsData
			route = routeMatch[0].replace('# ROUTE:', '').trim()
			if route != ""
				routes.push {filePath: rFilePath, route: route}
	routes

getRFileHandlerString = (rFilesWithRoute, config, acasHome)->
	rapacheHandlerText = '<Location /'+config.client.service.rapache.path+'* ROUTE_TO_BE_REPLACED_BY_PREPAREMODULEINCLUDES *>\n\tSetHandler r-handler\n\tRFileHandler '+'* FILE_TO_BE_REPLACED_BY_PREPAREMODULEINCLUDES *\n</Location>'
	routes = []
	routes.push('<Location /'+config.client.service.rapache.path+'/hello>\n\tSetHandler r-handler\n\tREval "hello()"\n</Location>')
	routes.push('<Location /'+config.client.service.rapache.path+'/RApacheInfo>\n\tSetHandler r-info\n</Location>')
	for rFile in rFilesWithRoute
		route = rapacheHandlerText.replace('* ROUTE_TO_BE_REPLACED_BY_PREPAREMODULEINCLUDES *',rFile.route)
		route = route.replace('* FILE_TO_BE_REPLACED_BY_PREPAREMODULEINCLUDES *', rFile.filePath)
		routes.push(route)
	routes = routes.join('\n\n')
	routes = routes+"\n\n"
	routes


getApacheCompileOptions = ->
	posssibleCommands = ['httpd', 'apachectl', '/usr/sbin/apachectl', '/usr/sbin/httpd2-prefork', '/usr/sbin/httpd2']
	for possibleCommand in posssibleCommands
		if shell.which(possibleCommand)
			apacheCommand = possibleCommand
			break;
	if not apacheCommand? and not sysEnv.APACHE
		console.log 'Could not find apache command in list: ' + posssibleCommands.join(', ') + 'skipping apache config'
		return 'skip'
	else
		if sysEnv.APACHE
			apacheVersion = sysEnv.APACHE
			switch apacheVersion
				when 'Redhat'
					compileOptions = [ { option: 'ApacheVersion', value: 'Redhat' },
						{ option: 'APACHE_MPM_DIR', value: '"server/mpm/prefork"' },
						{ option: 'APR_HAS_SENDFILE', value: undefined },
						{ option: 'APR_HAS_MMAP', value: undefined },
						{ option: 'APR_HAVE_IPV6 (IPv4-mapped addresses enabled)'},
						{ option: 'SINGLE_LISTEN_UNSERIALIZED_ACCEPT'},
						{ option: 'DYNAMIC_MODULE_LIMIT', value: '128' },
						{ option: 'HTTPD_ROOT', value: '"/etc/httpd"' },
						{ option: 'SUEXEC_BIN', value: '"/usr/sbin/suexec"' },
						{ option: 'DEFAULT_PIDLOG', value: '"run/httpd.pid"' },
						{ option: 'DEFAULT_SCOREBOARD', value: '"logs/apache_runtime_status"' },
						{ option: 'DEFAULT_LOCKFILE', value: '"logs/accept.lock"' },
						{ option: 'DEFAULT_ERRORLOG', value: '"logs/error_log"' },
						{ option: 'AP_TYPES_CONFIG_FILE', value: '"conf/mime.types"' },
						{ option: 'SERVER_CONFIG_FILE', value: '"conf/httpd.conf"' } ]
				when 'Ubuntu'
					console.log 'no defaults for ubuntu apache, run without APACHE environment variable if Apache is installed'
		else
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

getRApacheSpecificConfString = (config, apacheCompileOptions, acasHome) ->
	confs = []
	runUser = config.server.run.user
	confs.push('User ' + runUser)
	confs.push('Group ' + shell.exec('id -g -n ' + runUser, {silent:true}).output.replace('\n','')  )
	confs.push('Listen ' + config.server.rapache.listen + ':' + config.client.service.rapache.port)
	confs.push('PidFile ' + acasHome + '/bin/apache.pid')
	confs.push('StartServers ' + config.server.rapache.conf.startservers)
	confs.push('MinSpareServers ' + config.server.rapache.conf.minspareservers)
	confs.push('MaxSpareServers ' + config.server.rapache.conf.maxspareservers)
	confs.push('ServerLimit ' + config.server.rapache.conf.serverlimit)
	confs.push('MaxClients ' + config.server.rapache.conf.maxclients)
	confs.push('MaxRequestsPerChild ' + config.server.rapache.conf.maxrequestsperchild)
	confs.push('ServerSignature ' + config.server.rapache.conf.serversignature)
	confs.push('ServerName ' + config.client.host)
	confs.push('HostnameLookups ' + config.server.rapache.conf.hostnamelookups)
	confs.push('ServerAdmin ' + config.server.rapache.conf.serveradmin)
	confs.push('LogFormat ' + config.server.rapache.conf.logformat)
	confs.push('ErrorLog ' + config.server.log.path + '/racas.log')
	confs.push('LogLevel ' + config.server.log.level.toLowerCase())
	if Boolean(config.client.use.ssl)
		urlPrefix = 'https'
		confs.push('SSLEngine On')
		confs.push('SSLCertificateFile ' + config.server.ssl.cert.file.path)
		confs.push('SSLCertificateKeyFile ' + config.server.ssl.key.file.path)
		confs.push('SSLCACertificateFile ' + config.server.ssl.cert.authority.file.path)
		confs.push('SSLPassPhraseDialog ' + '\'|' + path.resolve(acasHome,'conf','executeNodeScript.sh') + ' ' + path.resolve(acasHome,'conf','getSSLPassphrase.js' + '\''))
	else
		urlPrefix = 'http'
	confs.push('DirectoryIndex index.html\n<Directory />\n\tOptions FollowSymLinks\n\tAllowOverride None\n</Directory>')
	confs.push('<Directory ' + acasHome + '>\n\tOptions Indexes FollowSymLinks\n\tAllowOverride None\n</Directory>')
	confs.push('RewriteEngine On')
	confs.push("RewriteRule ^/$ #{urlPrefix}://#{config.client.host}:#{config.client.port}/$1 [L,R,NE]")
	confs.push('REvalOnStartup \'Sys.setenv(acasHome = \"' + acasHome + '\");.libPaths(file.path(\"' + acasHome + '/r_libs\"));require(racas)\'')
	return confs.join('\n')

getApacheSpecificConfString = (config, apacheCompileOptions, acasHome) ->
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
	if Boolean(config.client.use.ssl)
		apacheSpecificConfs.push('LoadModule ssl_module ' + modulesDir + "mod_ssl.so")
	else
	apacheSpecificConfs.push('LoadModule rewrite_module ' + modulesDir + "mod_rewrite.so")
	apacheSpecificConfs.push('LoadModule R_module ' + modulesDir + "mod_R.so")
	apacheSpecificConfs.join('\n')

writeApacheConfFile = (config)->
	acasHome = path.resolve(__dirname,acasHome)
	apacheCompileOptions = getApacheCompileOptions()
	if apacheCompileOptions != 'skip'
		apacheSpecificConfString = getApacheSpecificConfString(config, apacheCompileOptions, acasHome)
	else
		apacheSpecificConfString = ''
	rapacheConfString = getRApacheSpecificConfString(config, apacheCompileOptions, acasHome)
	rFilesWithRoute = getRFilesWithRoute()
	rFileHandlerString = getRFileHandlerString(rFilesWithRoute, config, acasHome)
	fs.writeFileSync "#{acasHome}/conf/compiled/apache.conf", [apacheSpecificConfString,rapacheConfString,rFileHandlerString].join('\n')
	fs.writeFileSync "#{acasHome}/conf/compiled/rapache.conf", [rapacheConfString,rFileHandlerString].join('\n')

csUtilities.getConfServiceVars sysEnv, (confVars) ->

	mkdirSync = (path) ->
		try
			fs.mkdirSync path
		catch e
			if e.code != 'EEXIST'
				throw e
		return

	mkdirSync(configDir)

	getProperties = (configDir) =>
		configFiles = glob.sync("#{configDir}/*.properties")
		configFiles.unshift "#{configDir}/config.properties.example"

		if configFiles.length == 0
			console.warn "no config files found"
			return

		allConf = []
		for configFile in configFiles
			allConf = _.extend allConf, propertiesParser.read(configFile)

		configString = ""
		for attr, value of allConf
			if value != null
				configString += attr+"="+value+"\n"
			else
				configString += attr+"=\n"

		substitutions =
			env: sysEnv
			conf: confVars
		options =
			path: false
			namespaces: true
			sections: true
			variables: true
			include: true
			vars: substitutions

		properties.parse configString, options, (error, conf) =>
			if error?
				console.log "Problem parsing #{configFile}: "+error
			else
				if conf.client.deployMode == "Prod"
					conf.server.enableSpecRunner = false
				else
					conf.server.enableSpecRunner = true
				if !conf.server?.file?.server?.path?
					conf = _.deepExtend conf, server:file:server:path:"#{path.resolve acasHome+"/"+conf.server.datafiles.relative_path}"
				conf.server.run = user: do =>
					if !conf.server.run?
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

					return conf.server.run.user

			writeJSONFormat conf
			writeClientJSONFormat conf
			writePropertiesFormat conf
			writeApacheConfFile conf

	getProperties(configDir)

