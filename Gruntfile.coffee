module.exports = (grunt) ->
	"use strict"

	# configure build tasks
	global['clean'] = grunt.option('clean')
	grunt.registerTask 'build', 'build task', () ->
		compiledPath =  grunt.option('compilePath') || '../compiled'
		console.log "compiling to #{compiledPath}"
		grunt.config.set('acas_custom', "#{compiledPath}/acas_custom")
		grunt.config.set('acas_base', "#{compiledPath}")
		grunt.task.run 'sync'
		grunt.task.run 'copy'
		grunt.task.run 'execute:prepare_module_includes'
		return

	#
	# Grunt configuration:
	#
	# https://github.com/cowboy/grunt/blob/master/docs/getting_started.md
	#
	grunt.initConfig
	# Project configuration
	# ---------------------
		acas_custom: 'acas_custom'
		acas_base: '.'
		coffee:
			app:
				files: [
					expand: true
					flatten: true
					src: ["public/src/modules/**/src/client/*.coffee"]
					dest: "public/javascripts/src/"
					ext: '.js'
				]
			serverSideCode:
				files: [
					expand: true
					flatten: true
					src: ["public/src/modules/**/src/server/*.coffee"]
					dest: "src"
					ext: '.js'
				]
			spec:
				files: [
					expand: true
					flatten: true
					src: ["public/src/modules/**/spec/*.coffee"]
					dest: "public/javascripts/spec/"
					ext: '.js'
				]
			compileTestFixtures:
				files: [
					expand: true
					flatten: true
					src: ["public/src/modules/**/spec/testFixtures/*.coffee"]
					dest: "public/javascripts/spec/testFixtures/"
					ext: '.js'
				]
			compileServiceTests:
				files: [
					expand: true
					flatten: true
					src: ["public/src/modules/**/spec/serviceTests/*.coffee","public/src/conf/serviceTests/*.coffee"]
					dest: "public/javascripts/spec/test/"
					ext: '.js'
				]
			compileApp:
				files: [
					expand: true
					flatten: true
					src: ["./*.coffee"]
					dest: "./"
					ext: '.js'
				]
			compileConf:
				files: [
					expand: true
					flatten: true
					src: ["conf/*.coffee"]
					dest: "conf/"
					ext: '.js'
				]
			compileModuleConf:
				files: [
					expand: true
					flatten: true
					src: ["public/src/modules/**/conf/*.coffee"]
					dest: "public/javascripts/conf/"
					ext: '.js'
				]
			compilePublicConf:
				files: [
					expand: true
					flatten: true
					src: ["public/src/conf/*.coffee"]
					dest: "public/src/conf/"
					ext: '.js'
				]
			compileRoutes:
				files: [
					expand: true
					flatten: true
					src: ["routes/*.coffee"]
					dest: "routes/"
					ext: '.js'
				]
			moduleRoutes:
				files: [
					expand: true
					flatten: true
					src: ["public/src/modules/**/src/server/routes/*.coffee"]
					dest: "routes/"
					ext: '.js'
				]
		#these compilers are for the custom coffee scripts before they get copied
			custom_app:
				files: [
					expand: true
					flatten: true
					src: ["acas_custom/modules/**/src/client/**/*.coffee"]
					dest: "acas_custom/javascripts/src/"
					ext: '.js'
				]
			custom_spec:
				files: [
					expand: true
					flatten: true
					src: ["acas_custom/modules/**/spec/*.coffee"]
					dest: "acas_custom/javascripts/spec/"
					ext: '.js'
				]
			custom_compileTestFixtures:
				files: [
					expand: true
					flatten: true
					src: ["acas_custom/modules/**/spec/testFixtures/*.coffee"]
					dest: "acas_custom/javascripts/spec/testFixtures/"
					ext: '.js'
				]
			custom_compileServiceTests:
				files: [
					expand: true
					flatten: true
					src: ["acas_custom/modules/**/spec/serviceTests/*.coffee","acas_custom/public_conf/serviceTests/*.coffee"]
					dest: "acas_custom/javascripts/spec/test/"
					ext: '.js'
				]
			custom_compileApp:
				files: [
					expand: true
					flatten: true
					src: ["acas_custom/*.coffee"]
					dest: "acas_custom/"
					ext: '.js'
				]
			custom_compileConf:
				files: [
					expand: true
					flatten: true
					src: ["acas_custom/conf/*.coffee"]
					dest: "acas_custom/conf/"
					ext: '.js'
				]
			custom_compileModuleConf:
				files: [
					expand: true
					flatten: true
					src: ["acas_custom/modules/**/src/conf/*.coffee"]
					dest: "acas_custom/javascripts/conf/"
					ext: '.js'
				]
			custom_compilePublicConf:
				files: [
					expand: true
					flatten: true
					src: ["acas_custom/public_conf/*.coffee"]
					dest: "acas_custom/public_conf/"
					ext: '.js'
				]
			custom_compileRoutes:
				files: [
					expand: true
					flatten: true
					src: ["acas_custom/routes/*.coffee"]
					dest: "acas_custom/routes/"
					ext: '.js'
				]
			custom_moduleRoutes:
				files: [
					expand: true
					flatten: true
					src: ["acas_custom/modules/**/src/server/routes/*.coffee"]
					dest: "acas_custom/routes/"
					ext: '.js'
				]
		sync:
			custom:
				files: [
					expand: true
					cwd: "acas_custom"
					src: ["**"]
					dest: '<%= acas_custom %>'
				]
				compareUsing: "md5"
				verbose: true
				updateAndDelete: global['clean']
			base:
				files: [
					expand: true
					cwd: "."
					src: ["**"
					      "!**/*.coffee"
					      "!acas_custom/**"
					      "!tmp/**"
					].concat require('gitignore-to-glob')()
					dest: '<%= acas_base %>'
				]
				ignoreInDest: "acas_custom/**"
				compareUsing: "md5"
				verbose: true
				updateAndDelete: global['clean']
		copy:
			custom_routes:
				files: [
					expand: true
					cwd: "<%= acas_custom %>/routes/"
					src: ["**"]
					dest: "<%= acas_base %>/routes"
				]
			custom_conf:
				files: [
					expand: true
					cwd: "<%= acas_custom %>/conf/"
					src: ["**"]
					dest: "<%= acas_base %>/conf"
				]
			custom_public_conf:
				files: [
					expand: true
					cwd: "<%= acas_custom %>/public_conf/"
					src: ["**"]
					dest: "<%= acas_base %>/public/src/conf"
				]
			custom_javascripts:
				files: [
					expand: true
					cwd: "<%= acas_custom %>/javascripts/"
					src: ["**"]
					dest: "<%= acas_base %>/public/javascripts"
				]
			custom_views:
				files: [
					expand: true
					cwd: "<%= acas_custom %>/views/"
					src: ["**"]
					dest: "<%= acas_base %>/views"
				]
			custom_modules:
				files: [
					expand: true
					cwd: "<%= acas_custom %>/modules/"
					src: ["**"]
					dest: "<%= acas_base %>/public/src/modules"
				]
			public_jade:
				files: [
					expand: true
					flatten: true
					cwd: "public/src/"
					src: ["modules/**/src/client/**/*.jade"]
					dest: "./views"
				]
		execute:
			prepare_module_includes:
				options:
					cwd: 'conf'
					args: "<%= acas_base %>"
				src: "conf/PrepareModuleIncludes.js"
			prepare_config_files:
				options:
					cwd: 'conf'
				src: 'conf/PrepareConfigFiles.js'
			prepare_test_JSON:
				options:
					cwd: 'conf'
				src: 'conf/PrepareTestJSON.js'
			reload_rapache:
				call: (grunt, options) ->
					shell = require('shelljs')
					result = shell.exec('bin/acas-darwin.sh reload', {silent:true})
					return result.output
			grunt_copy_compiled:
				options:
					cwd: '../compiled'
				call: (grunt, options) ->
					shell = require('shelljs')
					result = shell.exec('grunt copy', {silent:true})
					return result.output
		replace:
			clientHost:
				src: ["conf/config.properties"]
				overwrite: true
				replacements: [
					from: /\nclient.host=.*/i
					to: ->
						hostname = require('os').hostname()
						newString = 'client.host=' + hostname
						console.log 'setting ' + newString
						return '\n' + newString
				]
		browserify:
			standalone:
				src: [ 'public/javascripts/src/ExcelApp.js' ]
				dest: 'public/javascripts/src/ExcelApp.js'
				ext: '*.js'
		watch:
			coffee:
				files: 'public/src/modules/**/src/client/*.coffee'
				tasks: 'coffee:app'
			compileServerOnlyModules:
				files: 'serverOnlyModules/**/*.coffee'
				tasks: 'coffee:serverOnlyModules'
			compileSpec:
				files: "public/src/modules/**/spec/*.coffee"
				tasks: "coffee:spec"
			compileTestFixtures:
				files: "public/src/modules/**/spec/testFixtures/*.coffee"
				tasks: "coffee:compileTestFixtures"
			compileServiceTests:
				files: "public/src/modules/**/spec/serviceTests/*.coffee"
				tasks: "coffee:compileServiceTests"
			compileServiceTests2:
				files: "public/src/conf/serviceTests/*.coffee"
				tasks: "coffee:compileServiceTests"
			compileApp:
				files: "./*.coffee"
				tasks: "coffee:compileApp"
			compileConf:
				files: "conf/*.coffee"
				tasks: "coffee:compileConf"
			compileModuleConf:
				files: "public/src/modules/**/conf/*.coffee"
				tasks: "coffee:compileModuleConf"
			compilePublicConf:
				files: "public/src/conf/*.coffee"
				tasks: "coffee:compilePublicConf"
			compileRoutes:
				files: "routes/*.coffee"
				tasks: "coffee:compileRoutes"
			moduleRoutes:
				files: "public/src/modules/**/src/server/routes/*.coffee"
				tasks: "coffee:moduleRoutes"
		#watchers on the custom folder
			custom_coffee:
				files: 'acas_custom/modules/**/src/client/*.coffee'
				tasks: 'coffee:custom_app'
			custom_compileSpec:
				files: "acas_custom/modules/**/spec/*.coffee"
				tasks: "coffee:custom_spec"
			custom_compileTestFixtures:
				files: "acas_custom/modules/**/spec/testFixtures/*.coffee"
				tasks: "coffee:custom_compileTestFixtures"
			custom_compileServiceTests:
				files: "acas_custom/modules/**/spec/serviceTests/*.coffee"
				tasks: "coffee:custom_compileServiceTests"
			custom_compileServiceTests2:
				files: "acas_custom/public_conf/serviceTests/*.coffee"
				tasks: "coffee:custom_compileServiceTests"
			custom_compileApp:
				files: "acas_custom/*.coffee"
				tasks: "coffee:custom_compileApp"
			custom_compileConf:
				files: "acas_custom/conf/*.coffee"
				tasks: "coffee:custom_compileConf"
			custom_compileModuleConf:
				files: "acas_custom/public_conf/*.coffee"
				tasks: "coffee:custom_compileModuleConf"
			custom_compilePublicConf:
				files: "acas_custom/public_conf/*.coffee"
				tasks: "coffee:custom_compilePublicConf"
			custom_compileRoutes:
				files: "acas_custom/routes/*.coffee"
				tasks: "coffee:custom_compileRoutes"
			custom_moduleRoutes:
				files: "acas_custom/modules/**/src/server/routes/*.coffee"
				tasks: "coffee:custom_moduleRoutes"
			copy_custom_routes:
				files: "acas_custom/routes/**"
				tasks: "copy:custom_routes"
			copy_custom_conf:
				files: "acas_custom/conf/**"
				tasks: "copy:custom_conf"
			copy_custom_public_conf:
				files: "acas_custom/public_conf/**"
				tasks: "copy:custom_public_conf"
			copy_custom_javascripts:
				files: "acas_custom/javascripts/**"
				tasks: "copy:custom_javascripts"
			copy_custom_views:
				files: "acas_custom/views/**"
				tasks: "copy:custom_views"
			copy_custom_modules:
				files: "acas_custom/modules/**"
				tasks: "copy:custom_modules"
			copy_public_jade:
				files: "acas_custom/modules/**/src/client/*.jade"
				tasks: "copy:public_jade"
			prepare_module_includes:
				files:[
					"conf/PrepareModuleIncludes.js"
					#styleFiles
					'public/src/modules/*/src/client/*.css'
					#templateFiles
					'/public/src/modules/*/src/client/*.html'
					#appScriptsInModules
					'public/src/modules/*/src/client/*.js'
					#appScriptsInJavascripts
					'public/javascripts/src/*.js'
					#testJSONInModules
					'public/src/modules/*/spec/testFixtures/*.js'
					#testJSONInJavascripts
					'public/javascripts/spec/testFixtures/*.js'
					#specScriptsInModules
					'public/src/modules/*/spec/*.js'
					#specScriptsInJavascripts
					'public/javascripts/spec/*.js'
				]
				tasks: "execute:prepare_module_includes"
			prepare_config_files:
				files: [
					"conf/PrepareConfigFiles.js"
					"conf/conf*.properties"
					"public/src/modules/*/src/server/*.R"
				]
				tasks: "execute:prepare_config_files"
			prepare_test_JSON:
				files: [
					"public/javascripts/spec/testFixtures/*.js"
				]
				tasks: "execute:prepare_test_JSON"
			reload_rapache:
				files: [
					"r_libs/racas/*"
				]
				tasks: "execute:reload_rapache"
#			browserify:
#				files: [
#					"public/javascripts/src/ExcelApp.js"
#				]
#				tasks: "browserify"


	grunt.loadNpmTasks "grunt-contrib-coffee"
	grunt.loadNpmTasks "grunt-contrib-watch"
	grunt.loadNpmTasks "grunt-contrib-copy"
	grunt.loadNpmTasks "grunt-sync"
	grunt.loadNpmTasks "grunt-text-replace"
	grunt.loadNpmTasks "grunt-execute"
	grunt.loadNpmTasks "grunt-browserify"

	# set the default task to the "watch" task
	grunt.registerTask "default", ["watch"]