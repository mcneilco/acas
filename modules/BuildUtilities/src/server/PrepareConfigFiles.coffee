
properties = require "properties"
_ = require "underscore"
underscoreDeepExtend = require "underscore-deep-extend"
_.mixin({deepExtend: underscoreDeepExtend(_)})
fs = require 'fs'
flat = require 'flat'
glob = require 'glob'
path = require 'path'
acasHome =  path.resolve "#{__dirname}/../../.."
os = require 'os'
propertiesParser = require "properties-parser"
configDir = "#{acasHome}/conf/"
global.deployMode= "Dev" 

mkdirSync = (path) ->
	try
		fs.mkdirSync path,{ recursive: true }
	catch e
		if e.code != 'EEXIST'
			throw e
	return

writeJSONFormat = (conf) ->
	mkdirSync "#{configDir}/compiled", { recursive: true }
	fs.writeFileSync "#{configDir}/compiled/conf.js", "exports.all="+JSON.stringify(conf)+";"

writeClientJSONFormat = (conf) ->
	mkdirSync "#{acasHome}/public/conf", { recursive: true }
	fs.writeFileSync "#{acasHome}/public/conf/conf.js", "window.conf="+JSON.stringify(conf.client)+";"

writePropertiesFormat = (conf) ->
	fs = require('fs')

	flatConf = flat.flatten conf
	configOut = ""
	for attr, value of flatConf
		if value != null
			if typeof(value) == "string"
				value = value.split("\n").join("\\n")
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
	routes.push('<Location /'+config.client.service.rapache.path+'/server-status>\n\tSetHandler server-status\n</Location>')
	for rFile in rFilesWithRoute
		route = rapacheHandlerText.replace('* ROUTE_TO_BE_REPLACED_BY_PREPAREMODULEINCLUDES *',rFile.route)
		route = route.replace('* FILE_TO_BE_REPLACED_BY_PREPAREMODULEINCLUDES *', rFile.filePath)
		routes.push(route)
	routes = routes.join('\n\n')
	routes = routes+"\n\n"
	routes


getApacheCompileOptions = ->
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
		{ option: 'SERVER_CONFIG_FILE', value: '"conf/httpd.conf"' },
		{ option: 'ApacheVersion', value: "RedHat" } ]
	return compileOptions

getRApacheSpecificConfString = (config, apacheCompileOptions, acasHome) ->
	confs = []
	runUser = config.server.run.user
	confs.push('User ' + runUser)
	confs.push('Group ' + runUser)
	confs.push('Listen ' + config.server.rapache.listen + ':' + config.client.service.rapache.port)
	confs.push('PidFile ' + acasHome + '/bin/apache.pid')
	confs.push('StartServers ' + config.server.rapache.conf.startservers)
	confs.push('MinSpareServers ' + config.server.rapache.conf.minspareservers)
	confs.push('MaxSpareServers ' + config.server.rapache.conf.maxspareservers)
	confs.push('ServerLimit ' + config.server.rapache.conf.serverlimit)
	confs.push('MaxClients ' + config.server.rapache.conf.maxclients)
	confs.push('MaxRequestsPerChild ' + config.server.rapache.conf.maxrequestsperchild)
	confs.push('LimitRequestLine ' + config.server.rapache.conf.limitrequestline)
	confs.push('ServerSignature ' + config.server.rapache.conf.serversignature)
	confs.push('ServerName ' + config.client.host)
	confs.push('HostnameLookups ' + config.server.rapache.conf.hostnamelookups)
	confs.push('ServerAdmin ' + config.server.rapache.conf.serveradmin)
	confs.push('LogFormat ' + config.server.rapache.conf.logformat)
	if config.server.rapache.forceAllToStdErrOnly? && config.server.rapache.forceAllToStdErrOnly
		confs.push('ErrorLog ' + '/dev/stderr')
		confs.push('TransferLog ' + '/dev/stdout')
	else
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
	confs.push('REvalOnStartup \'Sys.setenv(ACAS_HOME = \"' + acasHome + '\");.libPaths(file.path(\"' + acasHome + '/r_libs\"));require(racas)\'')
	return confs.join('\n')

getApacheSpecificConfString = (config, apacheCompileOptions, acasHome) ->
	apacheSpecificConfs = []
	serverRoot = '\"/etc/httpd\"'
	modulesDir = 'modules/'
	typesConfig = '/etc/mime.types'

	apacheSpecificConfs.push('ServerRoot ' + serverRoot)
	apacheSpecificConfs.push('LoadModule mime_module ' + modulesDir + "mod_mime.so")
	apacheSpecificConfs.push('TypesConfig ' + typesConfig)
	apacheSpecificConfs.push('LoadModule unixd_module ' + modulesDir + "mod_unixd.so")
	apacheSpecificConfs.push("LoadModule authz_core_module " + modulesDir + "mod_authz_core.so")
	apacheSpecificConfs.push('LoadModule mpm_prefork_module ' + modulesDir + "mod_mpm_prefork.so")
	apacheSpecificConfs.push('LoadModule log_config_module ' + modulesDir + "mod_log_config.so")
	apacheSpecificConfs.push('LoadModule logio_module ' + modulesDir + "mod_logio.so")

	apacheSpecificConfs.push('LoadModule dir_module ' + modulesDir + "mod_dir.so")
	if Boolean(config.client.use.ssl)
		apacheSpecificConfs.push('LoadModule ssl_module ' + modulesDir + "mod_ssl.so")
	apacheSpecificConfs.push('LoadModule rewrite_module ' + modulesDir + "mod_rewrite.so")
	apacheSpecificConfs.push('LoadModule R_module ' + modulesDir + "mod_R.so")
	apacheSpecificConfs.push('LoadModule status_module ' + modulesDir + "mod_status.so")
	apacheSpecificConfs.push('ExtendedStatus On')
	apacheSpecificConfs.join('\n')

writeApacheConfFile = (config)->
	acasHome = path.resolve(__dirname,acasHome)
	apacheCompileOptions = getApacheCompileOptions()
	apacheSpecificConfString = getApacheSpecificConfString(config, apacheCompileOptions, acasHome)
	rapacheConfString = getRApacheSpecificConfString(config, apacheCompileOptions, acasHome)
	rFilesWithRoute = getRFilesWithRoute()
	rFileHandlerString = getRFileHandlerString(rFilesWithRoute, config, acasHome)
	fs.writeFileSync "#{acasHome}/conf/compiled/apache.conf", [apacheSpecificConfString,rapacheConfString,rFileHandlerString].join('\n')
	fs.writeFileSync "#{acasHome}/conf/compiled/rapache.conf", [rapacheConfString,rFileHandlerString].join('\n')


getProperties = (configDir) =>
	configFiles = glob.sync("#{configDir}/*.properties")
	configFiles = configFiles.sort()
	configFiles.unshift "#{configDir}/config.properties.example"
	console.info "reading configs in this order (latter configs override former configs): #{configFiles}"
	
	if configFiles.length == 0
		console.warn "no config files found"
		return

	allConf = []
	for configFile in configFiles
		console.info "reading conf file: #{configFile}"
		allConf = _.extend allConf, propertiesParser.read(configFile)
		console.info "read conf file: #{configFile}"

	confMap = new Map()
	lowerCaseConfNames = []
	confNames = []
	for attr, value of allConf
		lowerCaseConfNames.push(attr.toLowerCase())
		confNames.push(attr)
		if value != null
			confMap.set(attr, value)
		else
			confMap.set(attr, null)

	# Read environment variables prefixed with ACAS_ and substitute them in the config file
	for key, value of process.env
		if key.startsWith('ACAS_')
			# Remove ACAS prefix and lower case
			newKey = key.substring(5).toLowerCase()
			# To deal with configs with an underscore, a user can set a double _ inside an environment variable and ACAS will replace it with a single _
			# Replace double underscores with a unique separator
			uniqueSeparator = '----------------------------ACAS-UNIQUE-SEPARATOR----------------------------'
			newKey = newKey.replace(/__/g, uniqueSeparator)
			# Replace remaining underscores with a single .
			newKey = newKey.replace(/\_/g,'.')
			# Replace the unique separator with a underscore
			newKey = newKey.replace(uniqueSeparator, '_')
			# Get the index of key in lowerCaseKeys
			index = lowerCaseConfNames.indexOf(newKey)
			if index != -1
				# If there is a match then override the config by setting it in the configString
				console.log "environment variable #{key} is being substituted for config key #{confNames[index]}"
				if value != null
					confMap.set(attr, value)
				else
					confMap.set(attr, null)

	substitutions =
		env: process.env
		conf: {}
	options =
		path: false
		namespaces: true
		sections: true
		variables: true
		include: true
		vars: substitutions

	# Convert config map to a string seperated by = and \n
	configString = ""
	confMap.forEach (value, key) =>
		if value != null
			configString += key + "=" + value + "\n"
		else
			configString += key + "=\n"

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
				return os.userInfo().username
		writeJSONFormat conf
		writeClientJSONFormat conf
		writePropertiesFormat conf
		writeApacheConfFile conf

mkdirSync(configDir, { recursive: true })
getProperties(configDir)
