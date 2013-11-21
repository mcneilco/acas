###
  Master ACAS -specific implementations of required server functions

  All functions are required with unchanged signatures
###

exports.logUsage = (action, data, username) ->
	# no ACAS logging service yet
	console.log "would have logged: "+action+" with data: "+data+" and user: "+username


exports.getConfServiceVars = (sysEnv, callback) ->
	conf = {}
	if global.deployMode == "Prod"
		conf.enableSpecRunner = false
	else
		conf.enableSpecRunner = true
	callback(conf)

exports.authCheck = (user, pass, retFun) ->
	retFun "Success"

exports.getUser = (username, callback) ->
	callback null,
		id: "bob"
		username: "bob"
		email: "bob@nowwhere.com"
		firstName: "Bob"
		lastName: "Bob"


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
	projectServiceTestJSON = require '../public/javascripts/spec/testFixtures/projectServiceTestJSON.js'
	resp.end JSON.stringify projectServiceTestJSON.projects

