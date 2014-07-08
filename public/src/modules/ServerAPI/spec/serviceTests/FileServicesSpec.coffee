assert = require 'assert'
request = require 'request'
fs = require 'fs'



describe "Data File and Temp File Services", ->
	describe "Data file services", ->
		before (done) ->
			fs.writeFileSync "../../../privateUploads/test.txt", "test file"
			request "http://localhost:3001/dataFiles/test.txt", (error, response, body) =>
				console.log "error: "+error
#					console.log response
				@responseJSON = body
				done()
		after ->
			fs.unlink "../../../privateUploads/test.txt"

		it "should return a file", ->
			assert.equal @responseJSON.indexOf('est file')>0, true
	describe "temp file services", ->
		before (done) ->
			fs.writeFileSync "../../../privateTempFiles/test.txt", "test file"
			request "http://localhost:3001/tempfiles/test.txt", (error, response, body) =>
				console.log "error: "+error
#					console.log response
				@responseJSON = body
				done()
		after ->
			fs.unlink "../../../privateTempFiles/test.txt"

		it "should return a file", ->
			assert.equal @responseJSON.indexOf('est file')>0, true

