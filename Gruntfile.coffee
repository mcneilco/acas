path = require 'path'
fs = require 'fs'
module.exports = (grunt) ->
	"use strict"

  # upgrade config files tas
#	grunt.registerTask 'upgrade_config_files', 'upgrade_config_files task', () ->
#		upgrade = require "#{acas_base}/modules/BuildUtilities/src/server/UpgradeConfigFiles.coffee"
#		glob = require 'glob'
#		configFiles = glob.sync("#{grunt.config.get('acas_custom')}/conf/*.properties")
#		for configFile in configFiles
#			outFile = "#{configFile}.diff"
#			upgrade.upgradeConfigFiles "#{acas_base}/conf/config.properties.example", configFile, outFile

	build =  grunt.option('buildPath') || process.env.BUILD_PATH || ''
	if build == ""
		build = "build"
#	console.log "working directory '#{__dirname}'"
#	console.log "setting build to: #{build}"
	grunt.config.set('build', build)

	if grunt.option('sourceDirectories')? | process.env.SOURCE_DIRECTORIES?
		sourceDirectories = (grunt.option('sourceDirectories') || process.env.SOURCE_DIRECTORIES).split(",")
	else
		sourceDirectories = []
		if !grunt.option('customonly') || true
			acas_base =  path.relative '.', grunt.option('acasBase') || process.env.ACAS_BASE || ''
			if acas_base == ""
				acas_base = "."
			sourceDirectories.push acas_base
		acas_shared =  path.relative '.', grunt.option('acasShared') || process.env.ACAS_SHARED || ''
		if acas_shared == ""
			acas_shared = "acas_shared"
		sourceDirectories.push acas_shared
		if !grunt.option('baseonly') ||  true
			acas_custom =  path.relative '.', grunt.option('acasCustom') || process.env.ACAS_CUSTOM || ''
			if acas_custom == ""
				acas_custom = "acas_custom"
			sourceDirectories.push acas_custom
#	console.log "setting source directories to: #{JSON.stringify(sourceDirectories)}"
	grunt.config.set('sourceDirectories', sourceDirectories)

#	grunt.registerTask("buildwebpack", ["webpack:build"]);

	grunt.registerTask 'build', 'build task', () =>
		grunt.config.set('sourceDirectories', sourceDirectories)
		grunt.config.set('build', build)
		grunt.task.run 'copy'
		grunt.task.run 'execute:npm_install'
#		grunt.task.run 'upgrade_config_files'
		grunt.task.run 'coffee'
		grunt.task.run 'browserify'
		grunt.task.run 'execute:prepare_module_includes'
		if !grunt.option('customonly')
			grunt.task.run 'webpack:build'
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
		clean:
			build: ["#{grunt.config.get('build')}/*", "!#{grunt.config.get('build')}/r_libs", "!#{grunt.config.get('build')}/node_modules", "!#{grunt.config.get('build')}/privateUploads","!#{grunt.config.get('build')}/privateTempFiles"]
		coffee:
			module_client:
				options:
					sourceMap: true
				files: [
					expand: true
					flatten: false
					src: grunt.config.get('sourceDirectories').map (i) -> "#{i}/modules/**/src/client/*.coffee"
					rename: (dest, matchedSrcPath, options) ->
						replaced = matchedSrcPath
						replaced = replaced.replace(sourcePath+"/modules/", "") for sourcePath in grunt.config.get('sourceDirectories')
						module = replaced.split("/")[0]
						"#{dest.replace(/\/$/, "")}/#{replaced.replace(module+"/src/client",module)}"
					dest: "#{grunt.config.get('build')}/public/javascripts/src/"
					ext: '.js'
				]
			module_server:
				options:
					sourceMap: true
				files: [
					expand: true
					flatten: false
					src: grunt.config.get('sourceDirectories').map (i) -> "#{i}/modules/**/src/server/*.coffee"
					rename: (dest, matchedSrcPath, options) ->
#						module = "#{matchedSrcPath.replace("/"+(grunt.config.get('sourceDirectories').map (i) -> i+'/modules/').join('|')+"/", "")}".split("/")[0]
						replaced = matchedSrcPath
						replaced = replaced.replace(sourcePath+"/modules/", "") for sourcePath in grunt.config.get('sourceDirectories')
						module = replaced.split("/")[0]
						"#{dest.replace(/\/$/, "")}/#{replaced.replace(module+"/src/server",module)}"
					dest: "#{grunt.config.get('build')}/src/javascripts"
					ext: '.js'
				]
			module_spec:
				options:
					sourceMap: true
				files: [
					expand: true
					flatten: false
					src: grunt.config.get('sourceDirectories').map (i) -> "#{i}/modules/**/spec/*.coffee"
					rename: (dest, matchedSrcPath, options) ->
						replaced = matchedSrcPath
						replaced = replaced.replace(sourcePath+"/modules/", "") for sourcePath in grunt.config.get('sourceDirectories')
						module = replaced.split("/")[0]
						"#{dest.replace(/\/$/, "")}/#{replaced.replace(module+"/spec",module)}"
					dest: "#{grunt.config.get('build')}/public/javascripts/spec/"
					ext: '.js'
				]
			module_testFixtures:
				options:
					sourceMap: true
				files: [
					expand: true
					flatten: false
					src: grunt.config.get('sourceDirectories').map (i) -> "#{i}/modules/**/spec/testFixtures/*.coffee"
					rename: (dest, matchedSrcPath, options) ->
						replaced = matchedSrcPath
						replaced = replaced.replace(sourcePath+"/modules/", "") for sourcePath in grunt.config.get('sourceDirectories')
						module = replaced.split("/")[0]
						"#{dest.replace(/\/$/, "")}/#{replaced.replace(module+"/spec",module)}"
					dest: "#{grunt.config.get('build')}/public/javascripts/spec/"
					ext: '.js'
				]
			module_serviceTests:
				options:
					sourceMap: true
				files: [
					expand: true
					flatten: false
					src: grunt.config.get('sourceDirectories').map (i) -> ["#{i}/modules/**/spec/serviceTests/*.coffee","#{i}/public/conf/serviceTests/*.coffee"]
					rename: (dest, matchedSrcPath, options) ->
						replaced = matchedSrcPath
						replaced = replaced.replace(sourcePath+"/modules/", "") for sourcePath in grunt.config.get('sourceDirectories')
						module = replaced.split("/")[0]
						"#{dest.replace(/\/$/, "")}/#{replaced.replace(module+"/spec",module)}"
					dest: "#{grunt.config.get('build')}/src/spec/"
					ext: '.js'
				]
			app:
				options:
					sourceMap: true
				files: [
					expand: true
					flatten: true
					src: grunt.config.get('sourceDirectories').map (i) -> ["#{i}/*.coffee", "!#{i}/Gruntfile.coffee"]
					dest: "#{grunt.config.get('build')}/"
					ext: '.js'
				]
			conf:
				options:
					sourceMap: true
				files: [
					expand: true
					flatten: true
					src: grunt.config.get('sourceDirectories').map (i) -> ["#{i}/conf/*.coffee"]
					dest: "#{grunt.config.get('build')}/conf/"
					ext: '.js'
				]
			module_conf:
				options:
					sourceMap: true
				files: [
					expand: true
					flatten: false
					src: grunt.config.get('sourceDirectories').map (i) -> ["#{i}/modules/**/conf/*.coffee"]
					rename: (dest, matchedSrcPath, options) ->
						replaced = matchedSrcPath
						replaced = replaced.replace(sourcePath+"/modules/", "") for sourcePath in grunt.config.get('sourceDirectories')
						module = replaced.split("/")[0]
						"#{dest.replace(/\/$/, "")}/#{replaced.replace(module+"/conf",module)}"
					dest: "#{grunt.config.get('build')}/public/javascripts/conf/"
					ext: '.js'
				]
			routes:
				options:
					sourceMap: true
				files: [
					expand: true
					flatten: true
					src: grunt.config.get('sourceDirectories').map (i) -> ["#{i}/routes/*.coffee"]
					dest: "#{grunt.config.get('build')}/routes/"
					ext: '.js'
				]
			module_routes:
				options:
					sourceMap: true
				files: [
					expand: true
					flatten: true
					src: grunt.config.get('sourceDirectories').map (i) -> ["#{i}/modules/*/src/server/routes/*.coffee", "#{i}/moduledyn/*/src/server/routes/*.coffee"]
					dest: "#{grunt.config.get('build')}/routes/"
					ext: '.js'
				]
		#these compilers are for the custom coffee scripts before they get copied
			custom_compilePublicConf:
				options:
					sourceMap: true
				files: [
					expand: true
					flatten: true
					src: grunt.config.get('sourceDirectories').map (i) -> ["#{i}/public_conf/*.coffee"]
					dest: "#{grunt.config.get('build')}/src/javascripts/ServerAPI/"
					ext: '.js'
				]
		copy:
			options:
				sourceMap: true
			bin:
				files: [
					expand: true
					cwd: "."
					src: grunt.config.get('sourceDirectories').map (i) -> ["#{i}/bin/**"]
					# to preserve the folder structures on copy we use the rename option to replace the output destination
					# this is because the cwd option only allows a single string so paths in the destination would include the base and custom directory names if we didn't sub them out
					# this is only needed if flatten: false or missing (because default is false)
					rename: (dest, matchedSrcPath, options) ->
						# console.log "dest:          #{dest}"
						# console.log "matchedSrcPath #{matchedSrcPath}"
						# console.log "destre:        #{dest.replace(/\/$/, "")}"
						# console.log "outre:         #{matchedSrcPath.replace((grunt.config.get('sourceDirectories').map (i) -> i+'/').join('|'), "")}"
						# console.log "outpath:       #{dest.replace(/\/$/, "")}/#{matchedSrcPath.replace((grunt.config.get('sourceDirectories').map (i) -> i+'/').join('|'), "")}"
						replaced = matchedSrcPath
						replaced = replaced.replace(path.relative(".",sourcePath),"") for sourcePath in grunt.config.get('sourceDirectories')
						"#{dest.replace(/\/$/, "")}/#{replaced.replace(/^\//, "")}"
					dest: "#{grunt.config.get('build')}"
				]
			conf:
				files: [
					expand: true
					cwd: "."
					src: grunt.config.get('sourceDirectories').map (i) -> ["#{i}/conf/*"]
					rename: (dest, matchedSrcPath, options) ->
						replaced = matchedSrcPath
						replaced = replaced.replace(path.relative(".",sourcePath),"") for sourcePath in grunt.config.get('sourceDirectories')
						"#{dest.replace(/\/$/, "")}/#{replaced.replace(/^\//, "")}"
					dest: "#{grunt.config.get('build')}"
				]
			gruntfile:
				files: [
					expand: true
					cwd: "."
					src: grunt.config.get('sourceDirectories').map (i) -> ["#{i}/Gruntfile.coffee"]
					rename: (dest, matchedSrcPath, options) ->
						replaced = matchedSrcPath
						replaced = replaced.replace(path.relative(".",sourcePath),"") for sourcePath in grunt.config.get('sourceDirectories')
						"#{dest.replace(/\/$/, "")}/#{replaced.replace(/^\//, "")}"
					dest: "#{grunt.config.get('build')}"
				]
			package_json:
				options:
					process: (content, srcpath) ->
						packageJSON =  JSON.parse(content)
						packageJSON.scripts.start = packageJSON.scripts.start.replace "cd process.env.BUILD_PATH  && ", ""
						packageJSON.scripts.dev = packageJSON.scripts.dev.replace "cd process.env.BUILD_PATH && ", ""
						delete packageJSON.scripts.postinstall
						delete packageJSON.scripts.clean
						return JSON.stringify(packageJSON, null, '\t')
				files: [
					expand: true
					cwd: "."
					src: grunt.config.get('sourceDirectories').map (i) -> ["#{i}/package.json"]
					rename: (dest, matchedSrcPath, options) ->
						replaced = matchedSrcPath
						replaced = replaced.replace(path.relative(".",sourcePath),"") for sourcePath in grunt.config.get('sourceDirectories')
						"#{dest.replace(/\/$/, "")}/#{replaced.replace(/^\//, "")}"
					dest: "#{grunt.config.get('build')}"
				]
			jade:
				files: [
					expand: true
					cwd: "."
					src: grunt.config.get('sourceDirectories').map (i) -> ["#{i}/views/*.jade", "#{i}/views/*.jade_template"]
					rename: (dest, matchedSrcPath, options) ->
						replaced = matchedSrcPath
						replaced = replaced.replace(path.relative(".",sourcePath),"") for sourcePath in grunt.config.get('sourceDirectories')
						"#{dest.replace(/\/$/, "")}/#{replaced.replace(/^\//, "")}"
					dest: "#{grunt.config.get('build')}"
				]
			node_modules_customized:
				files: [
					expand: true
					cwd: "."
					src: grunt.config.get('sourceDirectories').map (i) -> ["#{i}/node_modules_customized/**"]
					rename: (dest, matchedSrcPath, options) ->
						replaced = matchedSrcPath
						replaced = replaced.replace(path.relative(".",sourcePath),"") for sourcePath in grunt.config.get('sourceDirectories')
						"#{dest.replace(/\/$/, "")}/#{replaced.replace(/^\//, "")}"
					dest: "#{grunt.config.get('build')}"
				]
			public_stylesheets:
				files: [
					expand: true
					cwd: "."
					src: grunt.config.get('sourceDirectories').map (i) -> ["#{i}/public/stylesheets/**"]
					rename: (dest, matchedSrcPath, options) ->
						replaced = matchedSrcPath
						replaced = replaced.replace(path.relative(".",sourcePath),"") for sourcePath in grunt.config.get('sourceDirectories')
						"#{dest.replace(/\/$/, "")}/#{replaced.replace(/^\//, "")}"
					dest: "#{grunt.config.get('build')}"
				]
			public_html:
				files: [
					expand: true
					flatten: false
					cwd: "."
					src: grunt.config.get('sourceDirectories').map (i) -> ["#{i}/modules/**/src/client/*.html"]
					rename: (dest, matchedSrcPath, options) ->
						replaced = matchedSrcPath
						replaced = replaced.replace(sourcePath+"/modules/", "") for sourcePath in grunt.config.get('sourceDirectories')
						module = replaced.split("/")[0]
						"#{dest.replace(/\/$/, "")}/#{replaced.replace(module+"/src/client",module)}"
					dest: "#{grunt.config.get('build')}/public/html"
				]
			module_client_assets:
				files: [
					expand: true
					flatten: false
					cwd: "."
					src: grunt.config.get('sourceDirectories').map (i) -> ["#{i}/modules/**/src/client/assets/**"]
					rename: (dest, matchedSrcPath, options) ->
						replaced = matchedSrcPath
						replaced = replaced.replace(sourcePath+"/modules/", "") for sourcePath in grunt.config.get('sourceDirectories')
						module = replaced.split("/")[0]
						"#{dest.replace(/\/$/, "")}/#{replaced.replace(module+"/src/client/assets",module)}"
					dest: "#{grunt.config.get('build')}/public/assets"
				]
			module_server_assets:
				files: [
					expand: true
					flatten: false
					cwd: "."
					src: grunt.config.get('sourceDirectories').map (i) -> ["#{i}/modules/**/src/server/assets/**"]
					rename: (dest, matchedSrcPath, options) ->
						replaced = matchedSrcPath
						replaced = replaced.replace(sourcePath+"/modules/", "") for sourcePath in grunt.config.get('sourceDirectories')
						module = replaced.split("/")[0]
						"#{dest.replace(/\/$/, "")}/#{replaced.replace(module+"/src/server/assets",module)}"
					dest: "#{grunt.config.get('build')}/src/assets"
				]
			module_spec_miscellaneous:
				files: [
					expand: true
					flatten: false
					cwd: "."
					src: grunt.config.get('sourceDirectories').map (i) -> ["#{i}/modules/**/spec/**", "!#{i}/modules/**/spec/**/*.coffee", "!#{i}/modules/**/spec/testFixtures/*.coffee"]
					rename: (dest, matchedSrcPath, options) ->
						replaced = matchedSrcPath
						replaced = replaced.replace(sourcePath+"/modules/", "") for sourcePath in grunt.config.get('sourceDirectories')
						module = replaced.split("/")[0]
						"#{dest.replace(/\/$/, "")}/#{replaced.replace(module+"/spec",module)}"
					dest: "#{grunt.config.get('build')}/src/spec/"
				]
			module_css:
				files: [
					expand: true
					flatten:false
					cwd: "."
					src: grunt.config.get('sourceDirectories').map (i) -> ["#{i}/modules/**/src/client/*.css"]
					rename: (dest, matchedSrcPath, options) ->
						replaced = matchedSrcPath
						replaced = replaced.replace(sourcePath+"/modules/", "") for sourcePath in grunt.config.get('sourceDirectories')
						module = replaced.split("/")[0]
						"#{dest.replace(/\/$/, "")}/#{replaced.replace(module+"/src/client",module)}"
					dest: "#{grunt.config.get('build')}/public/stylesheets"
				]
			moduledyn_css:
				files: [
					expand: true
					flatten:false
					cwd: "."
					src: grunt.config.get('sourceDirectories').map (i) -> ["#{i}/moduledyn/**/src/client/*.css"]
					rename: (dest, matchedSrcPath, options) ->
						replaced = matchedSrcPath
						replaced = replaced.replace(sourcePath+"/moduledyn/", "") for sourcePath in grunt.config.get('sourceDirectories')
						module = replaced.split("/")[0]
						"#{dest.replace(/\/$/, "")}/#{replaced.replace(module+"/src/client",module)}"
					dest: "#{grunt.config.get('build')}/public/stylesheetsdyn"
				]
			module_jade:
				files: [
					expand: true
					flatten: true
					cwd: "."
					src: grunt.config.get('sourceDirectories').map (i) -> ["#{i}/modules/**/src/client/**/*.jade"]
					dest: "#{grunt.config.get('build')}/views"
				]
			module_conf:
				files: [
					expand: true
					flatten: false
					cwd: "."
					src: grunt.config.get('sourceDirectories').map (i) -> ["#{i}/modules/**/conf/*", "!*.coffee"]
					rename: (dest, matchedSrcPath, options) ->
						replaced = matchedSrcPath
						replaced = replaced.replace(sourcePath+"/modules/", "") for sourcePath in grunt.config.get('sourceDirectories')
						module = replaced.split("/")[0]
						"#{dest.replace(/\/$/, "")}/#{replaced.replace(module+"/conf",module)}"
					dest: "#{grunt.config.get('build')}/public/conf"
				]
			public_lib:
				files: [
					expand: true
					cwd: "."
					src: grunt.config.get('sourceDirectories').map (i) -> ["#{i}/public/lib/**"]
					rename: (dest, matchedSrcPath, options) ->
						replaced = matchedSrcPath
						replaced = replaced.replace(path.relative(".",sourcePath),"") for sourcePath in grunt.config.get('sourceDirectories')
						"#{dest.replace(/\/$/, "")}/#{replaced.replace(/^\//, "")}"
					dest: "#{grunt.config.get('build')}"
				]
			public_img:
				files: [
					expand: true
					cwd: "."
					src: grunt.config.get('sourceDirectories').map (i) -> ["#{i}/public/img/**"]
					rename: (dest, matchedSrcPath, options) ->
						replaced = matchedSrcPath
						replaced = replaced.replace(path.relative(".",sourcePath),"") for sourcePath in grunt.config.get('sourceDirectories')
						"#{dest.replace(/\/$/, "")}/#{replaced.replace(/^\//, "")}"
					dest: "#{grunt.config.get('build')}"
				]
			public_conf_r:
				files: [
					expand: true
					flatten: true
					cwd: "."
					src: grunt.config.get('sourceDirectories').map (i) -> ["#{i}/public/conf/*.R"]
					dest: "#{grunt.config.get('build')}/src/r"
				]
			module_legacy_r:
				files: [
					expand: true
					flatten: false
					cwd: "."
					src: grunt.config.get('sourceDirectories').map (i) -> ["#{i}/modules/**/src/server/**/*.R", "#{i}/modules/**/src/server/**/*.r", "!#{i}/modules/**/src/server/r/**", "!#{i}/modules/**/src/server/r/**"]
					rename: (dest, matchedSrcPath, options) ->
						replaced = matchedSrcPath
						replaced = replaced.replace(sourcePath+"/modules/", "") for sourcePath in grunt.config.get('sourceDirectories')
						module = replaced.split("/")[0]
						"#{dest.replace(/\/$/, "")}/#{replaced.replace(module+"/src/server",module)}"
					dest: "#{grunt.config.get('build')}/src/r"
				]
			module_r:
				files: [
					expand: true
					flatten: false
					cwd: "."
					src: grunt.config.get('sourceDirectories').map (i) -> ["#{i}/modules/**/src/server/r/**"]
					rename: (dest, matchedSrcPath, options) ->
						replaced = matchedSrcPath
						replaced = replaced.replace(sourcePath+"/modules/", "") for sourcePath in grunt.config.get('sourceDirectories')
						module = replaced.split("/")[0]
						"#{dest.replace(/\/$/, "")}/#{replaced.replace(module+"/src/server/r",module)}"
					dest: "#{grunt.config.get('build')}/src/r"
				]
			serviceTests_r:
				files: [
					expand: true
					flatten: false
					cwd: "."
					src: grunt.config.get('sourceDirectories').map (i) -> ["#{i}/modules/**/spec/serviceTests/*.R"]
					rename: (dest, matchedSrcPath, options) ->
						replaced = matchedSrcPath
						replaced = replaced.replace(sourcePath+"/modules/", "") for sourcePath in grunt.config.get('sourceDirectories')
						module = replaced.split("/")[0]
						console.log "#{dest.replace(/\/$/, "")}/#{replaced.replace(module+"/spec",module)}"
						"#{dest.replace(/\/$/, "")}/#{replaced.replace(module+"/spec",module)}"
					dest: "#{grunt.config.get('build')}/src/r/spec"
				]
			module_python:
				files: [
					expand: true
					flatten: false
					cwd: "."
					src: grunt.config.get('sourceDirectories').map (i) -> ["#{i}/modules/**/src/server/python/**"]
					rename: (dest, matchedSrcPath, options) ->
						replaced = matchedSrcPath
						replaced = replaced.replace(sourcePath+"/modules/", "") for sourcePath in grunt.config.get('sourceDirectories')
						module = replaced.split("/")[0]
						"#{dest.replace(/\/$/, "")}/#{replaced.replace(module+"/src/server/python",module)}"
					dest: "#{grunt.config.get('build')}/src/python"
				]
			module_routes_js:
				files: [
					expand: true
					flatten: true
					cwd: "."
					src: grunt.config.get('sourceDirectories').map (i) -> ["#{i}/modules/**/src/server/routes/*.js"]
					dest: "#{grunt.config.get('build')}/routes"
				]
			cmpdreg_module:
				files: [
					expand: true
					flatten: false
					cwd: "."
					src: grunt.config.get('sourceDirectories').map (i) -> ["#{i}/modules/CmpdReg/src/client/**","#{i}/modules/CmpdReg/src/marvinjs/**", "!#{i}/modules/CmpdReg/src/server"]
					rename: (dest, matchedSrcPath, options) ->
						replaced = matchedSrcPath
						replaced = replaced.replace(sourcePath+"/modules/CmpdReg/src/", "") for sourcePath in grunt.config.get('sourceDirectories')
						"#{dest}/#{replaced}"
					dest: "#{grunt.config.get('build')}/public/CmpdReg"
				]
		execute:
			prepare_module_conf_json:
				options:
					cwd: "#{grunt.config.get("build")}/src/javascripts/BuildUtilities/"
				src: "#{grunt.config.get("build")}/src/javascripts/BuildUtilities/PrepareModuleConfJSON.js"
			prepare_module_includes:
				options:
					cwd: "#{grunt.config.get("build")}/src/javascripts/BuildUtilities/"
				src: "#{grunt.config.get("build")}/src/javascripts/BuildUtilities/PrepareModuleIncludes.js"
			prepare_config_files:
				options:
					cwd: "#{grunt.config.get("build")}/src/javascripts/BuildUtilities/"
				src: "#{grunt.config.get("build")}/src/javascripts/BuildUtilities/PrepareConfigFiles.js"
			prepare_test_JSON:
				options:
					cwd: "#{grunt.config.get("build")}/src/javascripts/BuildUtilities/"
				src: "#{grunt.config.get("build")}/src/javascripts/BuildUtilities/PrepareTestJSON.js"
			npm_install:
				options:
					build: "#{grunt.config.get("build")}"
				call: (grunt, options) ->
					shell = require('shelljs')
					result = shell.exec("cd #{options.build} && npm install", {silent:true})
					return result.output
			install_racas:
				options:
					build: "#{grunt.config.get("build")}"
				call: (grunt, options) ->
					shell = require('shelljs')
					result = shell.exec("cd #{options.build} %>/src/r && Rscript install.R", {silent:true})
					return result.output



		webpack:
			options:
				resolve:
					modulesDirectories: [path.resolve("#{grunt.config.get("build")}/node_modules")]
				resolveLoader:
					root: [path.resolve("#{grunt.config.get("build")}/node_modules")]
				sourceDirectories: ["{<%= sourceDirectories %>}"]
			build:
#				entry: {index: "<%= acas_base %>"+"/moduledyn/PlateRegistration/src/client/index.coffee"}
				devtool: "sourcemap"
				entry: (
					entries = []
					grunt.config.get('sourceDirectories').map (i,index) ->
						entry = {index: path.resolve("#{i}/moduledyn/PlateRegistration/src/client/index.coffee")}
						if fs.existsSync(entry.index)
							entries.push entry
					entries[0]
				)

				output:
					path: "#{grunt.config.get("build")}/public/compiled",
					filename: "[name].bundle.js"
				module:
					loaders: [
						{test: /\.coffee$/, loader: "coffee"},
						{test: /\.(woff|woff2)(\?v=\d+\.\d+\.\d+)?$/, loader: 'url?limit=10000&mimetype=application/font-woff'},
						{test: /\.ttf(\?v=\d+\.\d+\.\d+)?$/, loader: 'url?limit=10000&mimetype=application/octet-stream'},
						{test: /\.eot(\?v=\d+\.\d+\.\d+)?$/, loader: 'file'},
						{test: /\.svg(\?v=\d+\.\d+\.\d+)?$/, loader: 'url?limit=10000&mimetype=image/svg+xml'}
					]

		browserify:
				module_client:
					src: "#{grunt.config.get("build")}/public/javascripts/src/ExcelApp/ExcelApp.js"
					dest: "#{grunt.config.get("build")}/public/javascripts/src/ExcelApp/ExcelApp.js"
		watch:
			options:
				interval: 500
			module_client_coffee:
				files: grunt.config.get('sourceDirectories').map (i) -> ["#{i}/modules/**/src/client/*.coffee"]
				tasks: ['newer:coffee:module_client', 'newer:browserify:module_client']
			webpack_build:
				files: grunt.config.get('sourceDirectories').map (i) -> ["#{i}/moduledyn/PlateRegistration/src/client/*"]
				tasks: ['webpack:build']
			webpack_spec_build:
				files: grunt.config.get('sourceDirectories').map (i) -> ["#{i}/moduledyn/PlateRegistration/spec/*.coffee"]
				tasks: ['webpack:build']
			module_server_coffee:
				files: grunt.config.get('sourceDirectories').map (i) -> ["#{i}/modules/**/src/server/*.coffee"]
				tasks: 'newer:coffee:module_server'
			module_spec:
				files: grunt.config.get('sourceDirectories').map (i) -> ["#{i}/modules/**/spec/*.coffee"]
				tasks: "newer:coffee:module_spec"
			module_textFixtures_coffee:
				files: grunt.config.get('sourceDirectories').map (i) -> ["#{i}/modules/**/spec/testFixtures/*.coffee"]
				tasks: "newer:coffee:module_testFixtures"
			module_serviceTests_coffee:
				files: grunt.config.get('sourceDirectories').map (i) -> ["#{i}/modules/**/spec/serviceTests/*.coffee", "#{i}/public/conf/serviceTests/*.coffee"]
				tasks: "newer:coffee:module_serviceTests"
			serviceTests_r:
				files: grunt.config.get('sourceDirectories').map (i) -> ["#{i}/modules/**/spec/serviceTests/*.R"]
				tasks: "newer:copy:serviceTests_r"
			app_coffee:
				files: grunt.config.get('sourceDirectories').map (i) -> ["#{i}/*.coffee"]
				tasks: "newer:coffee:app"
			conf_coffee:
				files: grunt.config.get('sourceDirectories').map (i) -> ["#{i}/conf/*.coffee"]
				tasks: "newer:coffee:conf"
			module_conf_coffee:
				files: grunt.config.get('sourceDirectories').map (i) -> ["#{i}/modules/**/conf/*.coffee"]
				tasks: "newer:coffee:module_conf"
			module_conf:
				files: grunt.config.get('sourceDirectories').map (i) -> ["#{i}/modules/**/conf/*", "!#{i}/modules/**/conf/*.coffee"]
				tasks: "newer:copy:module_conf"
			public_conf_coffee:
				files: grunt.config.get('sourceDirectories').map (i) -> ["#{i}/public/conf/*.coffee"]
				tasks: "newer:coffee:public_conf"
			routes_coffee:
				files: grunt.config.get('sourceDirectories').map (i) -> ["#{i}/routes/*.coffee"]
				tasks: "newer:coffee:routes"
			module_routes_coffee:
				files: grunt.config.get('sourceDirectories').map (i) -> ["#{i}/modules/**/src/server/routes/*.coffee", "#{i}/moduledyn/**/src/server/routes/*.coffee"]
				tasks: "newer:coffee:module_routes"
			module_routes_js:
				files: grunt.config.get('sourceDirectories').map (i) -> ["#{i}/modules/**/src/server/routes/*.js"]
				tasks: "newer:copy:module_routes_js"
			copy_jade:
				files: grunt.config.get('sourceDirectories').map (i) -> ["#{i}/views/*.jade", "#{i}/views/*.jade_template"]
				tasks: "newer:copy:jade"
			copy_module_jade:
				files: grunt.config.get('sourceDirectories').map (i) -> ["#{i}/modules/**/src/client/**/*.jade"]
				tasks: "newer:copy:module_jade"
			copy_conf:
				files: grunt.config.get('sourceDirectories').map (i) -> ["#{i}/conf/*.properties", "#{i}/conf/*.properties.example", "#{i}/conf/*.R"]
				tasks: "newer:copy:conf"
			module_legacy_r:
				files: grunt.config.get('sourceDirectories').map (i) -> ["#{i}/modules/**/src/server/**/*.R", "#{i}/modules/**/src/server/**/*.r", "!#{i}/modules/**/src/server/r/**", "!#{i}/modules/**/src/server/r/**"]
				tasks: "newer:copy:module_legacy_r"
			module_r:
				files: grunt.config.get('sourceDirectories').map (i) -> ["#{i}/modules/**/src/server/r/**"]
				tasks: "newer:copy:module_r"
			public_html:
				files: grunt.config.get('sourceDirectories').map (i) -> ["#{i}/modules/**/src/client/*.html"]
				tasks: "newer:copy:public_html"
			module_css:
				files: grunt.config.get('sourceDirectories').map (i) -> ["#{i}/modules/**/src/client/*.css"]
				tasks: "newer:copy:module_css"
			moduledyn_css:
				files: grunt.config.get('sourceDirectories').map (i) -> ["#{i}/moduledyn/**/src/client/*.css"]
				tasks: "newer:copy:moduledyn_css"
		#watchers on the custom folder
			custom_compilePublicConf:
				files: grunt.config.get('sourceDirectories').map (i) -> ["#{i}/public_conf/*.coffee"]
				tasks: "newer:coffee:custom_compilePublicConf"
			copy_custom_public_conf:
				files: grunt.config.get('sourceDirectories').map (i) -> ["#{i}/public/conf/*.R"]
				tasks: "newer:copy:public_conf_r"
			copy_cmpdreg_module:
				files: grunt.config.get('sourceDirectories').map (i) -> ["#{i}/modules/CmpdReg/src/client/**","#{i}/modules/CmpdReg/src/marvinjs/**", "!#{i}/modules/CmpdReg/src/server"]
				tasks: "newer:copy:cmpdreg_module"
			copy_module_client_assets:
				files: grunt.config.get('sourceDirectories').map (i) -> ["#{i}/modules/**/src/client/assets/**"]
				tasks: "newer:copy:module_client_assets"
			copy_module_server_assets:
				files: grunt.config.get('sourceDirectories').map (i) -> ["#{i}/modules/**/src/server/assets/**"]
				tasks: "newer:copy:module_server_assets"
			prepare_module_includes:
				files:[
					"#{grunt.config.get("build")}/src/javascripts/BuildUtilities/PrepareModuleIncludes.js"
					#app_template
					"#{grunt.config.get("build")}/app_template.js"
					#styleFiles
					"#{grunt.config.get("build")}/public/stylesheets/**.css"
					#templateFiles
					"#{grunt.config.get("build")}/public/html/**.html"
					#appScriptsInJavascripts
					"#{grunt.config.get("build")}/public/javascripts/**.js"
					#testJSONInJavascripts
					"#{grunt.config.get("build")}/public/javascripts/spec/testFixtures/**.js"
					#specScriptsInJavascripts
					"#{grunt.config.get("build")}/public/javascripts/spec/**.js"
				]
				tasks: "execute:prepare_module_includes"
			prepare_config_files:
				files: [
					"#{grunt.config.get("build")}/src/javascripts/BuildUtilities/PrepareConfigFiles.js"
					"#{grunt.config.get("build")}/conf/*.properties"
					"#{grunt.config.get("build")}/conf/*.properties.example"
					"#{grunt.config.get("build")}/src/r/*"
				]
				tasks: ["execute:prepare_config_files"]
			prepare_test_JSON:
				files: [
					"#{grunt.config.get("build")}/public/javascripts/spec/testFixtures/*.js"
				]
				tasks: "execute:prepare_test_JSON"

	build =  grunt.option('buildPath') || process.env.BUILD_PATH || ''
	if build == ""
		build = "build"
	console.log "working directory '#{__dirname}'"
	console.log "setting build to: #{build}"
	grunt.config.set('build', build)

	if grunt.option('sourceDirectories')? | process.env.SOURCE_DIRECTORIES?
		sourceDirectories = (grunt.option('sourceDirectories') || process.env.SOURCE_DIRECTORIES).split(",")
	else
		sourceDirectories = []
		if !grunt.option('customonly') || true
			acas_base =  path.relative '.', grunt.option('acasBase') || process.env.ACAS_BASE || ''
			if acas_base == ""
				acas_base = "."
			sourceDirectories.push acas_base
		acas_shared =  path.relative '.', grunt.option('acasShared') || process.env.ACAS_SHARED || ''
		if acas_shared == ""
			acas_shared = "acas_shared"
		sourceDirectories.push acas_shared 
		if !grunt.option('baseonly') ||  true
			acas_custom =  path.relative '.', grunt.option('acasCustom') || process.env.ACAS_CUSTOM || ''
			if acas_custom == ""
				acas_custom = "acas_custom"
			sourceDirectories.push acas_custom

	console.log "setting source directories to: #{JSON.stringify(sourceDirectories)}"
	grunt.config.set('sourceDirectories', sourceDirectories)

	grunt.loadNpmTasks "grunt-contrib-coffee"
	grunt.loadNpmTasks "grunt-contrib-watch"
	grunt.loadNpmTasks "grunt-contrib-copy"
	grunt.loadNpmTasks "grunt-contrib-clean"
	grunt.loadNpmTasks "grunt-execute"
	grunt.loadNpmTasks "grunt-newer"
	grunt.loadNpmTasks "grunt-browserify"
	grunt.loadNpmTasks "grunt-webpack"

	# set the default task to the "watch" task
	grunt.registerTask "default", ["watch"]

