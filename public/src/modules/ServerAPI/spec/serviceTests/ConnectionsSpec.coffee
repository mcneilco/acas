assert = require 'assert'
request = require 'request'
_ = require 'underscore'
experimentServiceTestJSON = require '../testFixtures/ExperimentServiceTestJSON.js'
fs = require 'fs'
exec = require('child_process').exec
config = require '../../../../conf/compiled/conf.js'

parseResponse = (jsonStr) ->
  try
    return JSON.parse jsonStr
  catch error
    console.log "response unparsable: " + error
    return null


#########################
# A. ACAS Communication #
#########################

describe "A. Connecting to ACAS", ->
  describe "by requesting http://client.host:client.port", ->
    before (done) ->
      request "http://"+config.all.client.host+":"+config.all.client.port, (error, response, body) =>
        @responseJSON = body
        @response = response
        done()
    it "should return a status code of 200", ->
      assert.equal(@response==undefined,false, "communication error between node and acas. Check that client.host and client.port are set properly.")
      assert.equal(@response.statusCode==404,false,"unable to access acas. check that client.port is set properly")
      assert.equal(@response.statusCode, 200, "status code "+@response.statusCode+" returned instead. Possible communication error between node and acas.")



#############################
# B. Database Communication #
#############################

describe "B. Connecting to the database", ->
  describe "through tomcat", ->
    before (done) ->
      request "http://roo:"+config.all.client.service.persistence.port, (error, response, body) =>
#     If not testing on Docker, I think the command below should be used instead:
#     request "http://"+client.service.persistence.host+":"+config.all.client.service.persistence.port, (error, response, body) =>
        @response = response
        done()
    it "should return a status code of 200", ->
      assert.equal(@response==undefined,false, "Node cannot connect to tomcat. Check that the property client.service.persistence.port and client.service.persistence.host are set properly.")
      assert.equal(@response.statusCode, 200, "status code "+@response.statusCode+" returned instead")

    describe "should be able to contact the database", ->
      it "before timeout", ->
        before (done) ->
          request "http://"+config.all.client.host+":"+config.all.server.nodeapi.port+"/api/codetables", (error, response, body) =>
            done()

    describe "and pulling the codetables", ->
      before (done) ->
        request "http://"+config.all.client.host+":"+config.all.server.nodeapi.port+"/api/codetables", (error, response, body) =>
          @responseJSON = body
          done()
      it "should return something that can be parsed", ->
        try parseResponse(@responseJSON)[0]
        catch
          assert(false,"Unable to parse the JSON response, check connection between tomcat and the database and that
                        server.nodeapi.port is set correctly.")

#################################
# C. File Storage Communication #
#################################

# todo make this test more robust
# Note, this is not a very robust test. It simply checks to see if the directory assigned to be the uploads and temp file system exists
# This does not check write permissions since fs.access can only check permissions of files, not directories
describe.only "C. Writing a file to", ->
  describe "the uploads path", ->
    before (done) ->
      fs.writeFile config.all.server.datafiles.relative_path+'/test.txt', 'this is a test', (error) =>
        @errors = error
        done()
    it "should not throw an error", ->
      assert(@errors == null || @errors == undefined, "Check the connection between node and the file uploads
                                                       including server.datafiles.relative_path.")
    describe "then accessing the file", ->
      describe  "directly", ->
        before (done) ->
          fs.readdir config.all.server.datafiles.relative_path, (err,files) =>
            @errors = err
            @files = files
            done()
        it "should not throw an error", ->
          assert(@errors==null, "Unable to read the directory. Check the connection between node and the file uploads
                                including server.datafiles.relative_path.")
        it "should find file", ->
          assert(@files.indexOf("test.txt")!= -1, "test file was not added to the uploads directory. Check that
                                                    server.datafiles.relative_path points to a directory that can be written to.")
      describe "through the server", ->
        before (done) ->
          request config.all.server.service.persistence.fileUrl, (error, response, body) =>
            @errors = error
            @responseJSON = body
            done()
        it "should not throw an error", ->
          assert(@errors==null, "unable to access the test file through the nodeapi port.
                                Ensure that server.service.persistence.fileUrl is set correctly.")
        it "should find file", ->
          parsedResponse = JSON.stringify(parseResponse(@responseJSON))
          assert(parsedResponse.indexOf("test.txt") != -1, "unable to access the test file through the nodeapi port.
                                                            Ensure that server.service.persistence.fileUrl is set correctly.")

    describe "then deleting the file", ->
      before (done) ->
        fs.unlink config.all.server.datafiles.relative_path+'/test.txt', (err) =>
          @errors = err
          done()
      it "should not throw an error", ->
        assert(@errors==null, "unable to delete file from uploads path: "+@errors)

      describe "and checking for existence", ->
        before (done) ->
          fs.readdir config.all.server.datafiles.relative_path, (err,files) =>
            @errors = err
            @files = files
            done()
        it "should not throw an error", ->
          assert(@errors==null, "Unable to read the directory. Check the connection between node and the file uploads
                                including server.datafiles.relative_path.")
        it "should not find file", ->
          assert(@files.indexOf("test.txt")== -1, "test file was not deleted from the uploads directory. Check that
                                                    server.datafiles.relative_path points to a directory that can be written to.")

  describe "the temp path", ->
    before (done) ->
      fs.writeFile config.all.server.tempfiles.relative_path+'/test.txt', 'this is a test', (error) =>
        @errors = error
        done()
    it "should not throw an error", ->
      assert(@errors == null || @errors == undefined, "Check the connection between node and the temp files
                                                       including server.tempfiles.relative_path.")
    describe "then accessing the file", ->
      before (done) ->
        fs.readdir config.all.server.tempfiles.relative_path, (err,files) =>
          @errors = err
          @files = files
          done()
      it "should not throw an error", ->
        assert(@errors==null, "Unable to read the directory. Check the connection between node and the temp files
                                including server.tempfiles.relative_path.")
      it "should find file", ->
        assert(@files.indexOf("test.txt")!= -1, "test file was not added to the temp files directory. Check that
                                                    server.tempfiles.relative_path points to a directory that can be written to.")

    describe "then deleting the file", ->
      before (done) ->
        fs.unlink config.all.server.tempfiles.relative_path+'/test.txt', (err) =>
          @errors = err
          done()
      it "should not throw an error", ->
        assert(@errors==null, "unable to delete file from uploads path: "+@errors)

      describe "and checking for existence", ->
        before (done) ->
          fs.readdir config.all.server.tempfiles.relative_path, (err,files) =>
            @errors = err
            @files = files
            done()
        it "should not throw an error", ->
          assert(@errors==null, "Unable to read the directory. Check the connection between node and the file uploads
                                including server.tempfiles.relative_path.")
        it "should not find file", ->
          assert(@files.indexOf("test.txt")== -1, "test file was not deleted from the uploads directory. Check that
                                                    server.datafiles.relative_path points to a directory that can be written to.")


#################################
# D. Communication with rScript #
#################################

describe "D. Access to Rscript", ->
  before (done) ->
    exec config.all.server.rscript + " -e 'help()'", (error, stdout, stderr) =>
      @error1 = error
      done()
  it "should not throw an error", ->
    assert.equal(@error1, null, "Check that Rscript is installed and that config.all.server.rscript is set properly")

  describe "and then to racas hello(),", ->
    rCommand =  'tryCatch({
                library(racas);
                hello()
                },error = function(ex) {cat(paste("R Execution Error:",ex));})'
    before (done) ->
      #this takes a long time even when working. Disable timeout for this test
      @timeout 0
      exec config.all.server.rscript + " -e" + " '" + rCommand + "'", (error,stdout,stderr) =>
        @stdout = stdout
        @stderr = stderr
        done()
    it.skip "should not throw an error or warning", ->
      assert.equal(@stderr, null, "racas gives the following error or warning: "+@stderr)
    it "should return 'Hello from racas'", ->
      assert.equal(@stdout, 'Hello from racas', "Rscript is unable to properly access racas.")
      #todo add description of what could be broken here

  describe "and then to the database", ->
    describe "through tomcat using getAllValueKinds()", ->
      rCommand =  'tryCatch({
                  library(racas);
                  getAllValueKinds()
                  },error = function(ex) {cat(paste("R Execution Error:",ex));})'
      before (done) ->
        #this takes a long time even when working. Disable timeout for this test
        @timeout 0
        exec config.all.server.rscript + " -e" + " '" + rCommand + "'", (error, stdout, stderr) =>
          @stderr = stderr
          @stdout = stdout
          done()
      it.skip "should not throw an error or warning", ->
        assert.equal(@stderr, null, "racas gives the following error or warning: \n"+@stderr)
      it "should return a list", ->
        #split the output into an array using the newline as the delimiter, only return the first split.
        split = @stdout.split "\n", 1
        assert.equal(split[0], "[[1]]", "check that racas can access the database through tomcat.")

    describe "directly using getDatabaseConnection()", ->
      rCommand =  'tryCatch({
                  library(racas);
                  conn <- getDatabaseConnection();
                  dbDisconnect(conn)
                  },error = function(ex) {cat(paste("R Execution Error:",ex));})'
      before (done) ->
        #this takes a long time even when working. Disabling timeout for this test
        @timeout 0
        exec config.all.server.rscript + " -e" + " '" + rCommand + "'", (error, stdout, stderr) =>
          @stderr = stderr
          @stdout = stdout
          done()
      it.skip "should not throw an error or warning", ->
        assert.equal(@stderr, null, "Error connecting to the database through racas. Check relevant environment variables. \n" +@stderr)
      it.skip "should return a status of ???", ->
        #todo figure out what this is supposed to return when postgreSQL is installed.
        assert(false,@stdout)



#################################
# E. Communication with rApache #
#################################

describe "E. Access to rApache", ->
  @timeout 0
  before (done) ->
    request config.all.client.service.rapache.fullpath + "RApacheInfo", (error, response, body) =>
      @responseJSON = body
      @response = response
      done()
  it "Should return an status code of 200", ->
    assert.equal(@response==undefined,false, "communication error between node and rApache. Check that client.service.rapache.host and client.service.rapache.port are set properly.")
    assert.equal(@response.statusCode==404,false,"unable to access rApache. Check that client.service.rapache.port is set properly")
    assert.equal(@response.statusCode, 200, "status code "+@response.statusCode+" returned instead. Possible communication error between node and rApache.")

  describe "and then to racas hello()", ->
    before (done) ->
      request config.all.client.service.rapache.fullpath + "hello", (error, response, body) =>
        @responseJSON = body
        @response = response
        done()
    it "should return 'Hello from racas'", ->
#Todo figure out what properties could be broken in this case
      assert(@response!=undefined,false, "communication error between rApache and racas.")
      assert(@response.body == 'Hello from racas', "communication error between rApache and racas,"+@response.body+" returned instead.")


  describe "and then to the database", ->
    describe "through tomcat", ->
      before (done) ->
        request config.all.client.service.rapache.fullpath + "test/getAllValueKinds", (error, response, body) =>
          @responseJSON = body
          done()
      it "should return a stringified list", ->
# split the output into an array using ( delimiter, only return the first split.
        split = @responseJSON.split "(", 1
        assert.equal(split[0], "list", "rApache unable to access the database through tomcat.
                                        Check that all environment variables are set correctly. ")

    describe "directly", ->
      before (done) ->
        request config.all.client.service.rapache.fullpath + "test/getDatabaseConnection", (error, response, body) =>
          @responseJSON = body
          done()
      it.skip "should not return an error", ->
        assert.equal(@responseJSON,undefined,@responseJSON)
