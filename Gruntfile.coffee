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
			module_client:
				files: [
					expand: true
					flatten: true
					src: ["public/src/modules/**/src/client/*.coffee"]
					dest: "build/public/javascripts/src/"
					ext: '.js'
				]
			module_server:
				files: [
					expand: true
					flatten: true
					src: ["public/src/modules/**/src/server/*.coffee"]
					dest: "build/src"
					ext: '.js'
				]
			module_spec:
				files: [
					expand: true
					flatten: true
					src: ["public/src/modules/**/spec/*.coffee"]
					dest: "build/public/javascripts/spec/"
					ext: '.js'
				]
			module_testFixtures:
				files: [
					expand: true
					flatten: true
					src: ["public/src/modules/**/spec/testFixtures/*.coffee"]
					dest: "build/public/javascripts/spec/testFixtures/"
					ext: '.js'
				]
			module_serviceTests:
				files: [
					expand: true
					flatten: true
					src: ["public/src/modules/**/spec/serviceTests/*.coffee","public/src/conf/serviceTests/*.coffee"]
					dest: "build/public/javascripts/spec/test/"
					ext: '.js'
				]
			app:
				files: [
					expand: true
					flatten: true
					src: ["./*.coffee"]
					dest: "build/"
					ext: '.js'
				]
			conf:
				files: [
					expand: true
					flatten: true
					src: ["conf/*.coffee"]
					dest: "build/conf/"
					ext: '.js'
				]
			module_conf:
				files: [
					expand: true
					flatten: true
					src: ["public/src/modules/**/conf/*.coffee"]
					dest: "build/public/javascripts/conf/"
					ext: '.js'
				]
			public_conf:
				files: [
					expand: true
					flatten: true
					src: ["public/src/conf/*.coffee"]
					dest: "build/src"
					ext: '.js'
				]
			routes:
				files: [
					expand: true
					flatten: true
					src: ["routes/*.coffee"]
					dest: "build/routes/"
					ext: '.js'
				]
			module_routes:
				files: [
					expand: true
					flatten: true
					src: ["public/src/modules/*/src/server/routes/*.coffee"]
					dest: "build/routes/"
					ext: '.js'
				]
		#these compilers are for the custom coffee scripts before they get copied
			custom_app:
				files: [
					expand: true
					flatten: true
					src: ["acas_custom/modules/**/src/client/**/*.coffee"]
					dest: "build/public/javascripts/src/"
					ext: '.js'
				]
			custom_spec:
				files: [
					expand: true
					flatten: true
					src: ["acas_custom/modules/**/spec/*.coffee"]
					dest: "build/public/javascripts/spec/"
					ext: '.js'
				]
			custom_compileTestFixtures:
				files: [
					expand: true
					flatten: true
					src: ["acas_custom/modules/**/spec/testFixtures/*.coffee"]
					dest: "build/public/javascripts/spec/testFixtures/"
					ext: '.js'
				]
			custom_compileServiceTests:
				files: [
					expand: true
					flatten: true
					src: ["acas_custom/modules/**/spec/serviceTests/*.coffee","acas_custom/public_conf/serviceTests/*.coffee"]
					dest: "build/public/javascripts/spec/test/"
					ext: '.js'
				]
			custom_compileApp:
				files: [
					expand: true
					flatten: true
					src: ["acas_custom/*.coffee"]
					dest: "build/src"
					ext: '.js'
				]
			custom_compileConf:
				files: [
					expand: true
					flatten: true
					src: ["acas_custom/conf/*.coffee"]
					dest: "build/conf/"
					ext: '.js'
				]
			custom_compileModuleConf:
				files: [
					expand: true
					flatten: true
					src: ["acas_custom/modules/**/src/conf/*.coffee"]
					dest: "build/public/javascripts/conf/"
					ext: '.js'
				]
			custom_compilePublicConf:
				files: [
					expand: true
					flatten: true
					src: ["acas_custom/public_conf/*.coffee"]
					dest: "build/src"
					ext: '.js'
				]
			custom_compileRoutes:
				files: [
					expand: true
					flatten: true
					src: ["acas_custom/routes/*.coffee"]
					dest: "build/routes/"
					ext: '.js'
				]
			custom_moduleRoutes:
				files: [
					expand: true
					flatten: true
					src: ["acas_custom/modules/**/src/server/routes/*.coffee"]
					dest: "build/routes/"
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
			bin:
				files: [
					expand: true
					cwd: "bin"
					src: ["**"]
					dest: "build/bin"
				]
			conf:
				files: [
					expand: true
					cwd: "conf"
					src: ["*.properties"]
					dest: "build/conf"
				]
			package_json:
				files: [
					expand: true
					cwd: "./"
					src: ["package.json"]
					dest: "build"
				]
			jade:
				files: [
					expand: true
					cwd: "views"
					src: ["*.jade", "*.jade_template", "!CIExcel*"]
					dest: "build/views"
				]
			node_modules_customized:
				files: [
					expand: true
					cwd: "node_modules_customized"
					src: ["**"]
					dest: "build/node_modules_customized"
				]
			public_stylesheets:
				files: [
					expand: true
					cwd: "public/stylesheets"
					src: ["**"]
					dest: "build/public/stylesheets"
				]
			public_html:
				files: [
					expand: true
					cwd: "public/src/"
					src: ["modules/**/src/client/*.html", "!modules/**/src/client/CI*.html"]
					dest: "build/public/html"
				]
			public_css:
				files: [
					expand: true
					cwd: "public/src/"
					src: ["modules/**/src/client/*.css", "!modules/**/src/client/CIExcel*"]
					dest: "build/public/stylesheets"
				]
			public_jade:
				files: [
					expand: true
					flatten: true
					cwd: "public/src/"
					src: ["modules/**/src/client/**/*.jade"]
					dest: "./views"
				]
			public_lib:
				files: [
					expand: true
					cwd: "public/src/lib"
					src: ["**"]
					dest: "build/public/lib"
				]
			public_img:
				files: [
					expand: true
					cwd: "public/img"
					src: ["**"]
					dest: "build/public/img"
				]
			module_r:
				files: [
					expand: true
					flatten: true
					cwd: "public/src/modules"
					src: ["**/src/server/*.R", "**/src/server/*.r"]
					dest: "build/src/r"
				]
			module_routes_js:
				files: [
					expand: true
					flatten: true
					cwd: "public/src/modules"
					src: ["**/src/server/routes/*.js"]
					dest: "build/routes"
				]
		execute:
			prepare_module_includes:
				options:
					cwd: 'build/src'
				src: "build/src/PrepareModuleIncludes.js"
			prepare_config_files:
				options:
					cwd: 'build/conf'
				src: 'build/src/PrepareConfigFiles.js'
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
		watch:
			module_client_coffee:
				files: 'public/src/modules/**/src/client/*.coffee'
				tasks: 'coffee:module_client'
			module_server_coffee:
				files: 'public/src/modules/**/src/server/*.coffee'
				tasks: 'coffee:module_server'
			module_spec:
				files: "public/src/modules/**/spec/*.coffee"
				tasks: "coffee:module_spec"
			module_textFixtures_coffee:
				files: "public/src/modules/**/spec/testFixtures/*.coffee"
				tasks: "coffee:module_testFixtures"
			module_serviceTests_coffee:
				files: ["public/src/modules/**/spec/serviceTests/*.coffee", "public/src/conf/serviceTests/*.coffee"]
				tasks: "coffee:module_serviceTests"
			app_coffee:
				files: "./*.coffee"
				tasks: "coffee:app"
			conf_coffee:
				files: "conf/*.coffee"
				tasks: "coffee:conf"
			module_conf_coffee:
				files: "public/src/modules/**/conf/*.coffee"
				tasks: "coffee:module_conf"
			public_conf_coffee:
				files: "public/src/conf/*.coffee"
				tasks: "coffee:public_conf"
			routes_coffee:
				files: "routes/*.coffee"
				tasks: "coffee:routes"
			module_routes_coffee:
				files: "public/src/modules/**/src/server/routes/*.coffee"
				tasks: "coffee:module_routes"
			module_routes_js:
				files: "public/src/modules/**/src/server/routes/*.js"
				tasks: "copy:module_routes_js"
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
					"build/src/PrepareModuleIncludes.js"
					#app_template
					"build/app_template.js"
					#app_api_template
					"build/app_api.js"
					#styleFiles
					'build/public/stylesheets/*.css'
					#templateFiles
					'build/public/html/*.html'
					#appScriptsInJavascripts
					'build/public/javascripts/src/*.js'
					#testJSONInJavascripts
					'build/public/javascripts/spec/testFixtures/*.js'
					#specScriptsInJavascripts
					'build/public/javascripts/spec/*.js'
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

	grunt.loadNpmTasks "grunt-contrib-coffee"
	grunt.loadNpmTasks "grunt-contrib-watch"
	grunt.loadNpmTasks "grunt-contrib-copy"
	grunt.loadNpmTasks "grunt-sync"
	grunt.loadNpmTasks "grunt-execute"

	# set the default task to the "watch" task
	grunt.registerTask "default", ["watch"]