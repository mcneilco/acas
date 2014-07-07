module.exports = (grunt) ->
	"use strict"

	#
	# Grunt configuration:
	#
	# https://github.com/cowboy/grunt/blob/master/docs/getting_started.md
	#
	grunt.initConfig

	# Project configuration
	# ---------------------
		coffee:
			app:
				files: [
						expand: true
						flatten: true
						src: ["public/src/modules/**/src/client/*.coffee"]
						dest: "public/javascripts/src/"
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
						src: ["acas_custom/modules/**/src/client/*.coffee"]
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

		copy:
			custom_routes:
				files: [
					expand: true
					cwd: "acas_custom/routes/"
					src: ["**"]
					dest: "./routes"
				]
			custom_conf:
				files: [
					expand: true
					cwd: "acas_custom/conf/"
					src: ["**"]
					dest: "./conf"
				]
			custom_public_conf:
				files: [
					expand: true
					cwd: "acas_custom/public_conf/"
					src: ["**"]
					dest: "./public/src/conf"
				]
			custom_javascripts:
				files: [
					expand: true
					cwd: "acas_custom/javascripts/"
					src: ["**"]
					dest: "./public/javascripts"
				]
			custom_views:
				files: [
					expand: true
					cwd: "acas_custom/views/"
					src: ["**"]
					dest: "./views"
				]
			custom_modules:
				files: [
					expand: true
					cwd: "acas_custom/modules/"
					src: ["**"]
					dest: "./public/src/modules"
				]
		execute:
			prepare_module_includes:
				options:
					cwd: 'conf'
				src: 'conf/PrepareModuleIncludes.js'
			prepare_config_files:
				options:
					cwd: 'conf'
				src: 'conf/PrepareConfigFiles.js'
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
		watch:
			coffee:
				files: 'public/src/modules/**/src/client/*.coffee'
				tasks: 'coffee:app'
			compileSpec:
				files: "public/src/modules/**/spec/*.coffee"
				tasks: "coffee:spec"
			compileTestFixtures:
				files: "public/src/modules/**/spec/testFixtures/*.coffee"
				tasks: "coffee:compileTestFixtures"
			compileApp:
				files: "./*.coffee"
				tasks: "coffee:compileApp"
			compileConf:
				files: "conf/*.coffee"
				tasks: "coffee:compileConf"
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
			custom_compileApp:
				files: "acas_custom/*.coffee"
				tasks: "coffee:custom_compileApp"
			custom_compileConf:
				files: "acas_custom/conf/*.coffee"
				tasks: "coffee:custom_compileConf"
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






	grunt.loadNpmTasks "grunt-contrib-coffee"
	grunt.loadNpmTasks "grunt-contrib-watch"
	grunt.loadNpmTasks "grunt-contrib-copy"
	grunt.loadNpmTasks "grunt-text-replace"
	grunt.loadNpmTasks "grunt-execute"

	# set the default task to the "watch" task
	grunt.registerTask "default", ["watch"]