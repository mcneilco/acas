
/*
  This subsystem runs scripts on a periodic basis. Examples of uses:
- Check the status of external data analysis jobs running on a grid system
- Check for files added to a directory that need to be processed
- Check to see if ACAS should send a user a reminder to do something
- Kick off the ping-pong table generator

Basic requirements:
- Programmatically add and remove periodic jobs
- Call R script (other languages in the future)
- Queue has to survive system ACAS and server reboots, so should be stored permanently in the database or a file
- API should be usable from within node or from outside processes like R scripts, so need REST API and access to functions
- When called, there will be no context, so function names and arguments need to be strings or numbers, not live functions.
- R script call should be formatted like every other wrapped R script in ACAS,
  the caller supplies the script, the function name, and the arguments as a JSON formatted string
 */

(function() {
  var assert, baseURL, config, copyJSON, cronScriptRunnerTestJSON, parseResponse, request;

  assert = require('assert');

  request = require('request');

  config = require('../../../../conf/compiled/conf.js');

  cronScriptRunnerTestJSON = require('../testFixtures/CronScriptRunnerTestJSON.js');

  baseURL = "http://" + config.all.client.host + ":" + config.all.server.nodeapi.port;

  parseResponse = function(jsonStr) {
    var error;
    try {
      return JSON.parse(jsonStr);
    } catch (_error) {
      error = _error;
      console.log("response unparsable: " + error);
      return null;
    }
  };

  copyJSON = function(json) {
    return JSON.parse(JSON.stringify(json));
  };

  describe("Cron Script Runner Services Spec", function() {
    describe("Create new cron script runner, saves to databases and schedules the job, unless active = false", function() {
      var unsavedReq;
      unsavedReq = copyJSON(cronScriptRunnerTestJSON.savedCronEntry);
      delete unsavedReq.cronCode;
      before(function(done) {
        return request.post({
          url: baseURL + "/api/cronScriptRunner",
          json: true,
          body: unsavedReq
        }, (function(_this) {
          return function(error, response, body) {
            _this.serverError = error;
            _this.responseJSON = body;
            _this.serverResponse = response;
            return request.put({
              url: baseURL + "/api/cronScriptRunner/" + body.cronCode,
              json: true,
              body: {
                active: false,
                ignored: true
              }
            }, function(error, response, body) {
              return done();
            });
          };
        })(this));
      });
      it("should return a success status code of 200", function() {
        return assert.equal(this.serverResponse.statusCode, 200);
      });
      return it("should supply a new code", function() {
        return assert.equal(this.responseJSON.cronCode != null, true);
      });
    });
    describe("updating jobs", function() {
      describe("disable current cron and delete", function() {
        var unsavedReq;
        unsavedReq = copyJSON(cronScriptRunnerTestJSON.savedCronEntry);
        delete unsavedReq.cronCode;
        before(function(done) {
          return request.post({
            url: baseURL + "/api/cronScriptRunner",
            json: true,
            body: unsavedReq
          }, (function(_this) {
            return function(error, response, body) {
              return request.put({
                url: baseURL + "/api/cronScriptRunner/" + body.cronCode,
                json: true,
                body: {
                  active: false,
                  ignored: true
                }
              }, function(error, response, body) {
                _this.responseJSON = body;
                _this.serverResponse = response;
                return done();
              });
            };
          })(this));
        });
        it("should return a success status code of 200", function() {
          return assert.equal(this.serverResponse.statusCode, 200);
        });
        it("should return the updated active value", function() {
          return assert.equal(this.responseJSON.active, false);
        });
        return it("should return the updated ignored value", function() {
          return assert.equal(this.responseJSON.ignored, true);
        });
      });
      return describe("try to update non-existant job", function() {
        before(function(done) {
          return request.put({
            url: baseURL + "/api/cronScriptRunner/" + "errorNonExistant",
            json: true,
            body: {
              active: false,
              ignored: true
            }
          }, (function(_this) {
            return function(error, response, body) {
              _this.responseJSON = body;
              _this.serverResponse = response;
              return done();
            };
          })(this));
        });
        return it("should return a success error code of 404", function() {
          return assert.equal(this.serverResponse.statusCode, 404);
        });
      });
    });
    return describe("create and run cron and get run status", function() {
      var unsavedReq;
      unsavedReq = copyJSON(cronScriptRunnerTestJSON.savedCronEntry);
      delete unsavedReq.cronCode;
      before(function(done) {
        this.timeout(25000);
        return request.post({
          url: baseURL + "/api/cronScriptRunner",
          json: true,
          body: unsavedReq
        }, (function(_this) {
          return function(error, response, body) {
            return setTimeout(function() {
              return request.get({
                url: baseURL + "/api/cronScriptRunner/" + body.cronCode,
                json: true
              }, function(error, response, body) {
                _this.responseJSON = body;
                console.log(body);
                _this.serverResponse = response;
                return request.put({
                  url: baseURL + "/api/cronScriptRunner/" + body.cronCode,
                  json: true,
                  body: {
                    active: false,
                    ignored: true
                  }
                }, function(error, response, body) {
                  return done();
                });
              });
            }, 15000);
          };
        })(this));
      });
      it("should return the cron object with the last start time", function() {
        return assert.equal(this.responseJSON.lastStartTime > 0, true);
      });
      it("should return the cron object with the last duration", function() {
        return assert.equal(this.responseJSON.lastDuration > 0, true);
      });
      it("should return the cron object result JSON", function() {
        return assert.equal(this.responseJSON.lastResultJSON.indexOf('}') > 0, true);
      });
      it("should return success of the R script run", function() {
        return assert.equal(parseResponse(this.responseJSON.lastResultJSON).hasError, false);
      });
      return it("should increment the run count", function() {
        return assert.equal(this.responseJSON.numberOfExcutions > 0, true);
      });
    });
  });

}).call(this);
