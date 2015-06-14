
/*
  This subsystem runs processes, most likely an R script, on a periodic basis to check the status of an external system or process.
  Examples of uses:
- Check the status of external data analysis jobs running on a grid system
- Check for files that need to be processed newly added to a directory
- Check to see if ACAS should send a user a reminder to do something, for example that a term in a contract document is about to occur
- Kick off ping-pong table generator

Basic requirements:
- Programmatically add and remove periodic jobs
- Call R script (in future other languages)
- When called, there will be no context, so function names and arguments need to be strings or numbers, not live functions.
- Queue has to survive system ACAS and server reboots, so should be stored permanently in the database or a file
- Need to be able to configure jobs as well as launch them programmatically.
  A module like doc manager should be able to specify jobs to run in a config file in its source, or maybe a global config.
  I guess we could make the module have to add it if doesn’t exist when it is first run
  (maybe in the setup routes function?) We would need to add a module for ping-pong
 */

(function() {
  var assert, config, cronScriptRunnerTestJSON, parseResponse, request;

  assert = require('assert');

  request = require('request');

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

  cronScriptRunnerTestJSON = require('../testFixtures/CronScriptRunnerTestJSON.js');

  config = require('../../../../conf/compiled/conf.js');

  describe("Cron Script Runner Services Spec", function() {
    describe("Create new cron script runner, saves to databases and schedules, unless active = false", function() {
      var unsavedReq;
      unsavedReq = JSON.parse(JSON.stringify(cronScriptRunnerTestJSON.savedCronEntry));
      delete unsavedReq.cronCode;
      before(function(done) {
        return request.post({
          url: "http://" + config.all.client.host + ":" + config.all.server.nodeapi.port + "/api/cronScriptRunner",
          json: true,
          body: unsavedReq
        }, (function(_this) {
          return function(error, response, body) {
            _this.serverError = error;
            _this.responseJSON = body;
            console.log(_this.responseJSON);
            _this.serverResponse = response;
            return request.put({
              url: "http://" + config.all.client.host + ":" + config.all.server.nodeapi.port + "/api/cronScriptRunner/" + body.cronCode,
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
    describe("disable current cron and delete", function() {
      var unsavedReq;
      unsavedReq = JSON.parse(JSON.stringify(cronScriptRunnerTestJSON.savedCronEntry));
      delete unsavedReq.cronCode;
      before(function(done) {
        return request.post({
          url: "http://" + config.all.client.host + ":" + config.all.server.nodeapi.port + "/api/cronScriptRunner",
          json: true,
          body: unsavedReq
        }, (function(_this) {
          return function(error, response, body) {
            return request.put({
              url: "http://" + config.all.client.host + ":" + config.all.server.nodeapi.port + "/api/cronScriptRunner/" + body.cronCode,
              json: true,
              body: {
                active: false,
                ignroed: true
              }
            }, function(error, response, body) {
              _this.responseJSON = body;
              _this.serverResponse = response;
              return done();
            });
          };
        })(this));
      });
      return it("should return a success status code of 200", function() {
        return assert.equal(this.serverResponse.statusCode, 200);
      });
    });
    return describe("create and run cron and get run status", function() {
      var unsavedReq;
      unsavedReq = JSON.parse(JSON.stringify(cronScriptRunnerTestJSON.savedCronEntry));
      delete unsavedReq.cronCode;
      before(function(done) {
        return request.post({
          url: "http://" + config.all.client.host + ":" + config.all.server.nodeapi.port + "/api/cronScriptRunner",
          json: true,
          body: unsavedReq
        }, (function(_this) {
          return function(error, response, body) {
            return setTimeout(function() {
              return request.get({
                url: "http://" + config.all.client.host + ":" + config.all.server.nodeapi.port + "/api/cronScriptRunner/" + body.cronCode,
                json: true
              }, function(error, response, body) {
                _this.responseJSON = body;
                _this.serverResponse = response;
                return request.put({
                  url: "http://" + config.all.client.host + ":" + config.all.server.nodeapi.port + "/api/cronScriptRunner/" + body.cronCode,
                  json: true,
                  body: {
                    active: false,
                    ignored: true
                  }
                }, function(error, response, body) {
                  return done();
                });
              });
            }, 20000);
          };
        })(this));
      });
      it("should return the cron object with the last start time", function() {
        return assert.equal(this.responseJSON.lastStarted > 0, true);
      });
      it("should return the cron object with the last duration", function() {
        return assert.equal(this.responseJSON.duration > 0, true);
      });
      return it("should return the cron object result JSON", function() {
        return assert.equal(this.responseJSON.lastResultJSON.indexOf('}') > 0, true);
      });
    });
  });

}).call(this);
