###
  Master ACAS -specific implementations of required server functions

  All functions are required with unchanged signatures
###

exports.logUsage = (action, data, username) ->
	# no ACAS logging service yet
	console.log "would have logged: "+action+" with data: "+data+" and user: "+username


exports.getConfServiceVars = (sysEnv, callback) ->
	conf = {}
	callback(conf)

exports.authCheck = (user, pass, retFun) ->
	retFun "Success"

exports.getUser = (username, callback) ->
	config = require '../../../conf/compiled/conf.js'
	if config.all.client.require.login
		if username == "bob"
			callback null,
				id: "bob"
				username: "bob"
				email: "bob@nowwhere.com"
				firstName: "Bob"
				lastName: "Roberts"
		else
			callback "user not found", null
	else
		callback null,
			id: 0,
			username: username,
			email: username+"@nowhere.com",
			firstName: "",
			lastName: username



exports.findByUsername = (username, fn) ->
	return exports.getUser username, fn

exports.loginStrategy = (username, password, done) ->
	process.nextTick ->
		exports.findByUsername username, (err, user) ->
			exports.authCheck username, password, (results) ->
				if results.indexOf("Success")>=0
					try
						exports.logUsage "User logged in succesfully: ", "", username
					catch error
						console.log "Exception trying to log:"+error
					return done null, user
				else
					try
						exports.logUsage "User failed login: ", "", username
					catch error
						console.log "Exception trying to log:"+error
					return done(null, false,
						message: "Invalid credentials"
					)

exports.getProjects = (resp) ->
	projects = 	exports.projects = [
		code: "project1"
		name: "Project 1"
		ignored: false
	,
		code: "project2"
		name: "Project 2"
		ignored: false
	]

	resp.end JSON.stringify projects

