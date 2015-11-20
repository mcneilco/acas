module.exports = (grunt) ->
	"use strict"

  # upgrade config files tas
	grunt.registerTask 'upgrade_config_files', 'upgrade_config_files task', () ->
		upgrade = require "#{acas_base}/modules/BuildUtilities/src/server/UpgradeConfigFiles.coffee"
		glob = require 'glob'
		configFiles = glob.sync("#{grunt.config.get('acas_custom')}/conf/*.properties")
		for configFile in configFiles
			outFile = "#{configFile}.diff"
			upgrade.upgradeConfigFiles "#{acas_base}/conf/config.properties.example", configFile, outFile

		# configure build tasks
	grunt.registerTask 'build', 'build task', () ->
		console.log "building to '#{build}'"
		console.log "building from '#{acas_base}'"
		grunt.config.set('build', "#{build}")
		#Definitely a better way to do this but it works to set the custom or base directory to nonsense if we don't want to build them
		if grunt.option('customonly') || false
			grunt.config.set('acas_base',"$$$$$$$$$$$$")
		if grunt.option('baseonly') ||  false
			grunt.config.set('acas_custom',"$$$$$$$$$$$$")
		grunt.task.run 'upgrade_config_files'
		grunt.task.run 'copy'
		grunt.task.run 'coffee'
		grunt.task.run 'browserify'
		grunt.task.run 'execute:npm_install'
		grunt.task.run 'execute:prepare_module_includes'
		if grunt.option('conf')
			grunt.task.run 'execute:prepare_config_files'
		grunt.task.run 'execute:prepare_test_JSON'
		return
	#
	# Grunt configuration:
	#
	# https://github.com/cowboy/grunt/blob/master/docs/getting_started.md
	#
	grunt.initConfig
	# Project configuration
	# ---------------------
		pkg: grunt.file.readJSON('package.json')
		acas_custom: 'acas_custom'
		acas_base: '.'
		build: 'build'
		clean:
			build: ["<%= build %>/*", "!<%= build %>/r_libs", "!<%= build %>/node_modules", "!<%= build %>/privateUploads","!<%= build %>/privateTempFiles"]
		coffee:
			module_client:
				files: [
					expand: true
					flatten: false
					src: ["<%= acas_base %>", "<%= acas_custom %>"].map (i) -> "#{i}/modules/**/src/client/*.coffee"
					rename: (dest, matchedSrcPath, options) ->
						module = "#{matchedSrcPath.replace(grunt.config.get('acas_custom')+"/modules/", "").replace(grunt.config.get('acas_base')+"/modules/", "")}".split("/")[0]

						"#{dest.replace(/\/$/, "")}/#{matchedSrcPath.replace(grunt.config.get('acas_custom')+"/modules/", "").replace(grunt.config.get('acas_base')+"/modules/", "").replace(module+"/src/client",module)}"
					dest: "<%= build %>/public/javascripts/src/"
					ext: '.js'
				]
			module_server:
				files: [
					expand: true
					flatten: false
					src: ["<%= acas_base %>", "<%= acas_custom %>"].map (i) -> "#{i}/modules/**/src/server/*.coffee"
					rename: (dest, matchedSrcPath, options) ->
						module = "#{matchedSrcPath.replace(grunt.config.get('acas_custom')+"/modules/", "").replace(grunt.config.get('acas_base')+"/modules/", "")}".split("/")[0]

						"#{dest.replace(/\/$/, "")}/#{matchedSrcPath.replace(grunt.config.get('acas_custom')+"/modules/", "").replace(grunt.config.get('acas_base')+"/modules/", "").replace(module+"/src/server",module)}"
					dest: "<%= build %>/src/javascripts"
					ext: '.js'
				]
			module_spec:
				files: [
					expand: true
					flatten: false
					src: ["<%= acas_base %>", "<%= acas_custom %>"].map (i) -> "#{i}/modules/**/spec/*.coffee"
					rename: (dest, matchedSrcPath, options) ->
						module = "#{matchedSrcPath.replace(grunt.config.get('acas_custom')+"/modules/", "").replace(grunt.config.get('acas_base')+"/modules/", "")}".split("/")[0]

						"#{dest.replace(/\/$/, "")}/#{matchedSrcPath.replace(grunt.config.get('acas_custom')+"/modules/", "").replace(grunt.config.get('acas_base')+"/modules/", "").replace(module+"/spec",module)}"
					dest: "<%= build %>/public/javascripts/spec/"
					ext: '.js'
				]
			module_testFixtures:
				files: [
					expand: true
					flatten: false
					src: ["<%= acas_base %>", "<%= acas_custom %>"].map (i) -> "#{i}/modules/**/spec/testFixtures/*.coffee"
					rename: (dest, matchedSrcPath, options) ->
						module = "#{matchedSrcPath.replace(grunt.config.get('acas_custom')+"/modules/", "").replace(grunt.config.get('acas_base')+"/modules/", "")}".split("/")[0]

						"#{dest.replace(/\/$/, "")}/#{matchedSrcPath.replace(grunt.config.get('acas_custom')+"/modules/", "").replace(grunt.config.get('acas_base')+"/modules/", "").replace(module+"/spec",module)}"
					dest: "<%= build %>/public/javascripts/spec/"
					ext: '.js'
				]
			module_serviceTests:
				files: [
					expand: true
					flatten: false
					src: ["<%= acas_base %>", "<%= acas_custom %>"].map (i) -> ["#{i}/modules/**/spec/serviceTests/*.coffee","#{i}/public/conf/serviceTests/*.coffee"]
					rename: (dest, matchedSrcPath, options) ->
						module = "#{matchedSrcPath.replace(grunt.config.get('acas_custom')+"/modules/", "").replace(grunt.config.get('acas_base')+"/modules/", "")}".split("/")[0]

						"#{dest.replace(/\/$/, "")}/#{matchedSrcPath.replace(grunt.config.get('acas_custom')+"/modules/", "").replace(grunt.config.get('acas_base')+"/modules/", "").replace(module+"/spec",module)}"
					dest: "<%= build %>/src/spec/"
					ext: '.js'
				]
			app:
				files: [
					expand: true
					flatten: true
					src: ["<%= acas_base %>", "<%= acas_custom %>"].map (i) -> ["#{i}/*.coffee", "!#{i}/Gruntfile.coffee"]
					dest: "<%= build %>/"
					ext: '.js'
				]
			conf:
				files: [
					expand: true
					flatten: true
					src: ["<%= acas_base %>", "<%= acas_custom %>"].map (i) -> ["#{i}/conf/*.coffee"]
					dest: "<%= build %>/conf/"
					ext: '.js'
				]
			module_conf:
				files: [
					expand: true
					flatten: false
					src: ["<%= acas_base %>", "<%= acas_custom %>"].map (i) -> ["#{i}/modules/**/conf/*.coffee"]
					rename: (dest, matchedSrcPath, options) ->
						module = "#{matchedSrcPath.replace(grunt.config.get('acas_custom')+"/modules/", "").replace(grunt.config.get('acas_base')+"/modules/", "")}".split("/")[0]

						"#{dest.replace(/\/$/, "")}/#{matchedSrcPath.replace(grunt.config.get('acas_custom')+"/modules/", "").replace(grunt.config.get('acas_base')+"/modules/", "").replace(module+"/conf",module)}"
					dest: "<%= build %>/public/javascripts/conf/"
					ext: '.js'
				]
			routes:
				files: [
					expand: true
					flatten: true
					src: ["<%= acas_base %>", "<%= acas_custom %>"].map (i) -> ["#{i}/routes/*.coffee"]
					dest: "<%= build %>/routes/"
					ext: '.js'
				]
			module_routes:
				files: [
					expand: true
					flatten: true
					src: ["<%= acas_base %>", "<%= acas_custom %>"].map (i) -> ["#{i}/modules/*/src/server/routes/*.coffee"]
					dest: "<%= build %>/routes/"
					ext: '.js'
				]
		#these compilers are for the custom coffee scripts before they get copied
			custom_compilePublicConf:
				files: [
					expand: true
					flatten: true
					src: ["<%= acas_custom %>/public_conf/*.coffee"]
					dest: "<%= build %>/src/javascripts/ServerAPI/"
					ext: '.js'
				]
		copy:
			bin:
				files: [
					expand: true
					cwd: "."
					src: ["<%= acas_base %>", "<%= acas_custom %>"].map (i) -> ["#{i}/bin/**"]
					# to preserve the folder structures on copy we use the rename option to replace the output destination
					# this is because the cwd option only allows a single string so paths in the destination would include the base and custom directory names if we didn't sub them out
					# this is only needed if flatten: false or missing (because default is false)
					rename: (dest, matchedSrcPath, options) ->
						# console.log "dest:          #{dest}"
						# console.log "matchedSrcPath #{matchedSrcPath}"
						# console.log "destre:        #{dest.replace(/\/$/, "")}"
						# console.log "outre:         #{matchedSrcPath.replace(grunt.config.get('acas_custom')+"/", "").replace(grunt.config.get('acas_base')+"/", "")}"
						# console.log "outpath:       #{dest.replace(/\/$/, "")}/#{matchedSrcPath.replace(grunt.config.get('acas_custom')+"/", "").replace(grunt.config.get('acas_base')+"/", "")}"
						"#{dest.replace(/\/$/, "")}/#{matchedSrcPath.replace(grunt.config.get('acas_custom')+"/", "").replace(grunt.config.get('acas_base')+"/", "")}"
					dest: "<%= build %>"
				]
			conf:
				files: [
					expand: true
					cwd: "."
					src: ["<%= acas_base %>", "<%= acas_custom %>"].map (i) -> ["#{i}/conf/*.properties", "#{i}/conf/*.properties.example"]
					rename: (dest, matchedSrcPath, options) ->
						"#{dest.replace(/\/$/, "")}/#{matchedSrcPath.replace(grunt.config.get('acas_custom')+"/", "").replace(grunt.config.get('acas_base')+"/", "")}"
					dest: "<%= build %>"
				]
			gruntfile:
				files: [
					expand: true
					cwd: "."
					src: ["<%= acas_base %>", "<%= acas_custom %>"].map (i) -> ["#{i}/Gruntfile.coffee"]
					rename: (dest, matchedSrcPath, options) -> "#{dest.replace(/\/$/, "")}/#{matchedSrcPath.replace(grunt.config.get('acas_custom')+"/", "").replace(grunt.config.get('acas_base')+"/", "")}"
					dest: "<%= build %>"
				]
			package_json:
				options:
					process: (content, srcpath) ->
						packageJSON =  JSON.parse(content)
						packageJSON.scripts.start = packageJSON.scripts.start.replace "cd process.env.BUILD_PATH  && ", ""
						packageJSON.scripts.debug = packageJSON.scripts.debug.replace "cd process.env.BUILD_PATH  && ", ""
						packageJSON.scripts.dev = packageJSON.scripts.dev.replace "cd process.env.BUILD_PATH && ", ""
						delete packageJSON.scripts.postinstall
						delete packageJSON.scripts.clean
						return JSON.stringify(packageJSON, null, '\t')
				files: [
					expand: true
					cwd: "."
					src: ["<%= acas_base %>", "<%= acas_custom %>"].map (i) -> ["#{i}/package.json"]
					rename: (dest, matchedSrcPath, options) -> "#{dest.replace(/\/$/, "")}/#{matchedSrcPath.replace(grunt.config.get('acas_custom')+"/", "").replace(grunt.config.get('acas_base')+"/", "")}"
					dest: "<%= build %>"
				]
			jade:
				files: [
					expand: true
					cwd: "."
					src: ["<%= acas_base %>", "<%= acas_custom %>"].map (i) -> ["#{i}/views/*.jade", "#{i}/views/*.jade_template"]
					rename: (dest, matchedSrcPath, options) -> "#{dest.replace(/\/$/, "")}/#{matchedSrcPath.replace(grunt.config.get('acas_custom')+"/", "").replace(grunt.config.get('acas_base')+"/", "")}"
					dest: "<%= build %>"
				]
			node_modules_customized:
				files: [
					expand: true
					cwd: "."
					src: ["<%= acas_base %>", "<%= acas_custom %>"].map (i) -> ["#{i}/node_modules_customized/**"]
					rename: (dest, matchedSrcPath, options) -> "#{dest.replace(/\/$/, "")}/#{matchedSrcPath.replace(grunt.config.get('acas_custom')+"/", "").replace(grunt.config.get('acas_base')+"/", "")}"
					dest: "<%= build %>"
				]
			public_stylesheets:
				files: [
					expand: true
					cwd: "."
					src: ["<%= acas_base %>", "<%= acas_custom %>"].map (i) -> ["#{i}/public/stylesheets/**"]
					rename: (dest, matchedSrcPath, options) -> "#{dest.replace(/\/$/, "")}/#{matchedSrcPath.replace(grunt.config.get('acas_custom')+"/", "").replace(grunt.config.get('acas_base')+"/", "")}"
					dest: "<%= build %>"
				]
			public_html:
				files: [
					expand: true
					flatten: false
					cwd: "."
					src: ["<%= acas_base %>", "<%= acas_custom %>"].map (i) -> ["#{i}/modules/**/src/client/*.html"]
					rename: (dest, matchedSrcPath, options) ->
						module = "#{matchedSrcPath.replace(grunt.config.get('acas_custom')+"/modules/", "").replace(grunt.config.get('acas_base')+"/modules/", "")}".split("/")[0]
						"#{dest.replace(/\/$/, "")}/#{matchedSrcPath.replace(grunt.config.get('acas_custom')+"/modules/", "").replace(grunt.config.get('acas_base')+"/modules/", "").replace(module+"/src/client",module)}"
					dest: "<%= build %>/public/html"
				]
			module_spec_miscellaneous:
				files: [
					expand: true
					flatten: false
					cwd: "."
					src: ["<%= acas_base %>", "<%= acas_custom %>"].map (i) -> ["#{i}/modules/**/spec/**", "!#{i}/modules/**/spec/**/*.coffee", "!#{i}/modules/**/spec/testFixtures/*.coffee"]
					rename: (dest, matchedSrcPath, options) ->
#						console.log "dest:          #{dest}"
#						console.log "matchedSrcPath #{matchedSrcPath}"
#						console.log "moduleName:    #{matchedSrcPath.split("/")[2]+"/spec"}"
						module = "#{matchedSrcPath.replace(grunt.config.get('acas_custom')+"/modules/", "").replace(grunt.config.get('acas_base')+"/modules/", "")}".split("/")[0]
#						console.log "outre:         #{matchedSrcPath.replace matchedSrcPath.split("/")[0]+"/", ""}"
#						console.log "outpath:       #{dest.replace(/\/$/, "")}/#{matchedSrcPath.replace(matchedSrcPath.split("/")[0]+"/modules/", "").replace(module+"/spec",module)}"
						"#{dest.replace(/\/$/, "")}/#{matchedSrcPath.replace(grunt.config.get('acas_custom')+"/modules/", "").replace(grunt.config.get('acas_base')+"/modules/", "").replace(module+"/spec",module)}"
					dest: "<%= build %>/src/spec/"
				]
			module_css:
				files: [
					expand: true
					flatten:false
					cwd: "."
					src: ["<%= acas_base %>", "<%= acas_custom %>"].map (i) -> ["#{i}/modules/**/src/client/*.css"]
					rename: (dest, matchedSrcPath, options) ->
						module = "#{matchedSrcPath.replace(grunt.config.get('acas_custom')+"/modules/", "").replace(grunt.config.get('acas_base')+"/modules/", "")}".split("/")[0]
						"#{dest.replace(/\/$/, "")}/#{matchedSrcPath.replace(grunt.config.get('acas_custom')+"/modules/", "").replace(grunt.config.get('acas_base')+"/modules/", "").replace(module+"/src/client",module)}"
					dest: "<%= build %>/public/stylesheets"
				]
			module_jade:
				files: [
					expand: true
					flatten: true
					cwd: "."
					src: ["<%= acas_base %>", "<%= acas_custom %>"].map (i) -> ["#{i}/modules/**/src/client/**/*.jade"]
					dest: "<%= build %>/views"
				]
			module_conf:
				files: [
					expand: true
					flatten: false
					cwd: "."
					src: ["<%= acas_base %>", "<%= acas_custom %>"].map (i) -> ["#{i}/modules/**/conf/*", "!*.coffee"]
					rename: (dest, matchedSrcPath, options) ->
						module = "#{matchedSrcPath.replace(grunt.config.get('acas_custom')+"/modules/", "").replace(grunt.config.get('acas_base')+"/modules/", "")}".split("/")[0]
						"#{dest.replace(/\/$/, "")}/#{matchedSrcPath.replace(grunt.config.get('acas_custom')+"/modules/", "").replace(grunt.config.get('acas_base')+"/modules/", "").replace(module+"/conf",module)}"
					dest: "<%= build %>/public/conf"
				]
			public_lib:
				files: [
					expand: true
					cwd: "."
					src: ["<%= acas_base %>", "<%= acas_custom %>"].map (i) -> ["#{i}/public/lib/**"]
					rename: (dest, matchedSrcPath, options) -> "#{dest.replace(/\/$/, "")}/#{matchedSrcPath.replace(grunt.config.get('acas_custom')+"/", "").replace(grunt.config.get('acas_base')+"/", "")}"
					dest: "<%= build %>"
				]
			public_img:
				files: [
					expand: true
					cwd: "."
					src: ["<%= acas_base %>", "<%= acas_custom %>"].map (i) -> ["#{i}/public/img/**"]
					rename: (dest, matchedSrcPath, options) -> "#{dest.replace(/\/$/, "")}/#{matchedSrcPath.replace(grunt.config.get('acas_custom')+"/", "").replace(grunt.config.get('acas_base')+"/", "")}"
					dest: "<%= build %>"
				]
			public_conf_r:
				files: [
					expand: true
					flatten: true
					cwd: "."
					src: ["<%= acas_base %>", "<%= acas_custom %>"].map (i) -> ["#{i}/public/conf/*.R"]
					dest: "<%= build %>/src/r"
				]
			module_legacy_r:
				files: [
					expand: true
					flatten: false
					cwd: "."
					src: ["<%= acas_base %>", "<%= acas_custom %>"].map (i) -> ["#{i}/modules/**/src/server/**/*.R", "#{i}/modules/**/src/server/**/*.r", "!#{i}/modules/**/src/server/r/**", "!#{i}/modules/**/src/server/r/**"]
					rename: (dest, matchedSrcPath, options) ->
						module = "#{matchedSrcPath.replace(grunt.config.get('acas_custom')+"/modules/", "").replace(grunt.config.get('acas_base')+"/modules/", "")}".split("/")[0]
						"#{dest.replace(/\/$/, "")}/#{matchedSrcPath.replace(grunt.config.get('acas_custom')+"/modules/", "").replace(grunt.config.get('acas_base')+"/modules/", "").replace(module+"/src/server",module)}"
					dest: "<%= build %>/src/r"
				]
			module_r:
				files: [
					expand: true
					flatten: false
					cwd: "."
					src: ["<%= acas_base %>", "<%= acas_custom %>"].map (i) -> ["#{i}/modules/**/src/server/r/**"]
					rename: (dest, matchedSrcPath, options) ->
						module = "#{matchedSrcPath.replace(grunt.config.get('acas_custom')+"/modules/", "").replace(grunt.config.get('acas_base')+"/modules/", "")}".split("/")[0]
						"#{dest.replace(/\/$/, "")}/#{matchedSrcPath.replace(grunt.config.get('acas_custom')+"/modules/", "").replace(grunt.config.get('acas_base')+"/modules/", "").replace(module+"/src/server/r",module)}"
						"#{dest.replace(/\/$/, "")}/#{matchedSrcPath.replace(grunt.config.get('acas_custom')+"/modules/", "").replace(grunt.config.get('acas_base')+"/modules/", "").replace(module+"/src/server/r",module)}"
					dest: "<%= build %>/src/r"
				]
			module_routes_js:
				files: [
					expand: true
					flatten: true
					cwd: "."
					src: ["<%= acas_base %>", "<%= acas_custom %>"].map (i) -> ["#{i}/modules/**/src/server/routes/*.js"]
					dest: "<%= build %>/routes"
				]
		execute:
			prepare_module_includes:
				options:
					cwd: '<%= build %>/src/javascripts/BuildUtilities/'
				src: "<%= build %>/src/javascripts/BuildUtilities/PrepareModuleIncludes.js"
			prepare_config_files:
				options:
					cwd: '<%= build %>/src/javascripts/BuildUtilities/'
				src: '<%= build %>/src/javascripts/BuildUtilities/PrepareConfigFiles.js'
			prepare_test_JSON:
				options:
					cwd: '<%= build %>/src/javascripts/BuildUtilities/'
				src: '<%= build %>/src/javascripts/BuildUtilities/PrepareTestJSON.js'
			npm_install:
				options:
					build: "<%= build %>"
				call: (grunt, options) ->
					shell = require('shelljs')
					result = shell.exec("cd #{options.build} && npm install --production", {silent:true})
					return result.output
			install_racas:
				options:
					build: "<%= build %>"
				call: (grunt, options) ->
					shell = require('shelljs')
					result = shell.exec("cd #{options.build} %>/src/r && Rscript install.R", {silent:true})
					return result.output
		browserify:
				module_client:
					src: '<%= build %>/public/javascripts/src/ExcelApp/ExcelApp.js'
					dest: '<%= build %>/public/javascripts/src/ExcelApp/ExcelApp.js'
		watch:
			module_client_coffee:
				files: ["<%= acas_base %>", "<%= acas_custom %>"].map (i) -> ["#{i}/modules/**/src/client/*.coffee"]
				tasks: ['newer:coffee:module_client', 'newer:browserify:module_client']
			module_server_coffee:
				files: ["<%= acas_base %>", "<%= acas_custom %>"].map (i) -> ["#{i}/modules/**/src/server/*.coffee"]
				tasks: 'newer:coffee:module_server'
			module_spec:
				files: ["<%= acas_base %>", "<%= acas_custom %>"].map (i) -> ["#{i}/modules/**/spec/*.coffee"]
				tasks: "newer:coffee:module_spec"
			module_textFixtures_coffee:
				files: ["<%= acas_base %>", "<%= acas_custom %>"].map (i) -> ["#{i}/modules/**/spec/testFixtures/*.coffee"]
				tasks: "newer:coffee:module_testFixtures"
			module_serviceTests_coffee:
				files: ["<%= acas_base %>", "<%= acas_custom %>"].map (i) -> ["#{i}/modules/**/spec/serviceTests/*.coffee", "#{i}/public/conf/serviceTests/*.coffee"]
				tasks: "newer:coffee:module_serviceTests"
			app_coffee:
				files: ["<%= acas_base %>", "<%= acas_custom %>"].map (i) -> ["#{i}/*.coffee"]
				tasks: "newer:coffee:app"
			conf_coffee:
				files: ["<%= acas_base %>", "<%= acas_custom %>"].map (i) -> ["#{i}/conf/*.coffee"]
				tasks: "newer:coffee:conf"
			module_conf_coffee:
				files: ["<%= acas_base %>", "<%= acas_custom %>"].map (i) -> ["#{i}/modules/**/conf/*.coffee"]
				tasks: "newer:coffee:module_conf"
			module_conf:
				files: ["<%= acas_base %>", "<%= acas_custom %>"].map (i) -> ["#{i}/modules/**/conf/*", "!#{i}/modules/**/conf/*.coffee"]
				tasks: "newer:copy:module_conf"
			public_conf_coffee:
				files: ["<%= acas_base %>", "<%= acas_custom %>"].map (i) -> ["#{i}/public/conf/*.coffee"]
				tasks: "newer:coffee:public_conf"
			routes_coffee:
				files: ["<%= acas_base %>", "<%= acas_custom %>"].map (i) -> ["#{i}/routes/*.coffee"]
				tasks: "newer:coffee:routes"
			module_routes_coffee:
				files: ["<%= acas_base %>", "<%= acas_custom %>"].map (i) -> ["#{i}/modules/**/src/server/routes/*.coffee"]
				tasks: "newer:coffee:module_routes"
			module_routes_js:
				files: ["<%= acas_base %>", "<%= acas_custom %>"].map (i) -> ["#{i}/modules/**/src/server/routes/*.js"]
				tasks: "newer:copy:module_routes_js"
			copy_module_jade:
				files: ["<%= acas_base %>", "<%= acas_custom %>"].map (i) -> ["#{i}/modules/**/src/client/**/*.jade"]
				tasks: "newer:copy:module_jade"
			copy_conf:
				files: ["<%= acas_base %>", "<%= acas_custom %>"].map (i) -> ["#{i}/conf/*.properties"]
				tasks: "newer:copy:conf"
			module_legacy_r:
				files: ["<%= acas_base %>", "<%= acas_custom %>"].map (i) -> ["#{i}/modules/**/src/server/**/*.R", "#{i}/modules/**/src/server/**/*.r", "!#{i}/modules/**/src/server/r/**", "!#{i}/modules/**/src/server/r/**"]
				tasks: "newer:copy:module_r"
			module_r:
				files: ["<%= acas_base %>", "<%= acas_custom %>"].map (i) -> ["#{i}/modules/**/src/server/r/**"]
				tasks: "newer:copy:module_r"
			public_html:
				files: ["<%= acas_base %>", "<%= acas_custom %>"].map (i) -> ["#{i}/modules/**/src/client/*.html"]
				tasks: "newer:copy:public_html"
			module_css:
				files: ["<%= acas_base %>", "<%= acas_custom %>"].map (i) -> ["#{i}/modules/**/src/client/*.css"]
				tasks: "newer:copy:module_css"
		#watchers on the custom folder
			custom_compilePublicConf:
				files: "<%= acas_custom %>/public_conf/*.coffee"
				tasks: "newer:coffee:custom_compilePublicConf"
			copy_custom_public_conf:
				files: "<%= acas_custom %>/public_conf/**"
				tasks: "newer:copy:custom_public_conf"
			prepare_module_includes:
				files:[
					"<%= build %>/src/javascripts/BuildUtilities/PrepareModuleIncludes.js"
					#app_template
					"<%= build %>/app_template.js"
					#styleFiles
					'<%= build %>/public/stylesheets/**.css'
					#templateFiles
					'<%= build %>/public/html/**.html'
					#appScriptsInJavascripts
					'<%= build %>/public/javascripts/**.js'
					#testJSONInJavascripts
					'<%= build %>/public/javascripts/spec/testFixtures/**.js'
					#specScriptsInJavascripts
					'<%= build %>/public/javascripts/spec/**.js'
				]
				tasks: "execute:prepare_module_includes"
			prepare_config_files:
				files: [
					"<%= build %>/src/javascripts/BuildUtilities/PrepareConfigFiles.js"
					"<%= build %>/conf/conf*.properties"
					"<%= build %>/src/r/*"
				]
				tasks: ["execute:prepare_config_files"]
			prepare_test_JSON:
				files: [
					"<%= build %>/public/javascripts/spec/testFixtures/*.js"
				]
				tasks: "execute:prepare_test_JSON"

	path = require 'path'
	build =  path.relative '.', grunt.option('buildPath') || process.env.BUILD_PATH || 'build'
	if build == ""
		build = "."
	acas_base =  path.relative '.', grunt.option('acasBase') || process.env.ACAS_BASE || '.'
	if acas_base == ""
		acas_base = "."
	acas_custom =  path.relative '.', grunt.option('acasCustom') || process.env.ACAS_CUSTOM || 'acas_custom'
	grunt.config.set('build', "#{build}")
	grunt.config.set('acas_base', "#{acas_base}")
	grunt.config.set('acas_custom', "#{acas_custom}")

	grunt.loadNpmTasks "grunt-contrib-coffee"
	grunt.loadNpmTasks "grunt-contrib-watch"
	grunt.loadNpmTasks "grunt-contrib-copy"
	grunt.loadNpmTasks "grunt-contrib-clean"
	grunt.loadNpmTasks "grunt-execute"
	grunt.loadNpmTasks "grunt-newer"
	grunt.loadNpmTasks "grunt-browserify"

	# set the default task to the "watch" task
	grunt.registerTask "default", ["watch"]
