assert = require 'assert'
request = require 'request'
fs = require 'fs'


config = require '../../../../conf/compiled/conf.js'
describe "Data File and Temp File Services", ->
  describe "File download test", ->
    describe "Data file services", ->
      before (done) ->
        fs.writeFileSync "../../../"+ config.all.server.datafiles.relative_path + "/test.txt", "test file"
        request "http://localhost:"+config.all.server.nodeapi.port+"/dataFiles/test.txt", (error, response, body) =>
          console.log "error: "+error
          #					console.log response
          @responseJSON = body
          done()
      after ->
        fs.unlink "../../../"+ config.all.server.datafiles.relative_path + "/test.txt"

      it "should return a file", ->
        assert.equal @responseJSON.indexOf('est file')>0, true
    describe "temp file services", ->
      before (done) ->
        fs.writeFileSync "../../../"+ config.all.server.tempfiles.relative_path + "/test.txt", "test file"
        request "http://localhost:"+config.all.server.nodeapi.port+"/tempfiles/test.txt", (error, response, body) =>
          console.log "error: "+error
          #					console.log response
          @responseJSON = body
          done()
      after ->
        fs.unlink "../../../"+ config.all.server.tempfiles.relative_path + "/test.txt"

      it "should return a file", ->
        assert.equal @responseJSON.indexOf('est file')>0, true
