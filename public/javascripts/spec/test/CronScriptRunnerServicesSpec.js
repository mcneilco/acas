
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
- API should be usable from within node or from outside processes like R scripts, so need REST API
- Must call through services. Direct function calls won't work because we have to keep global cron hash
- When called, there will be no context, so function names and arguments need to be strings or numbers, not live functions.
- R script call should be formatted like every other wrapped R script in ACAS,
  the caller supplies the script, the function name, and the arguments as a JSON formatted string
 */

(function() {
  var assert, baseURL, config, copyJSON, cronFunctions, cronScriptRunnerTestJSON, parseResponse, request;

  assert = require('assert');

  request = require('request');

  config = require('../../../../conf/compiled/conf.js');

  cronScriptRunnerTestJSON = require('../testFixtures/CronScriptRunnerTestJSON.js');

  cronFunctions = require('../../../../routes/CronScriptRunnerRoutes.js');

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
      delete unsavedReq.codeName;
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
              url: baseURL + "/api/cronScriptRunner/" + body.codeName,
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
        return assert.equal(this.responseJSON.codeName != null, true);
      });
    });
    describe("updating jobs", function() {
      describe("disable current cron and delete", function() {
        var unsavedReq;
        unsavedReq = copyJSON(cronScriptRunnerTestJSON.savedCronEntry);
        delete unsavedReq.codeName;
        before(function(done) {
          return request.post({
            url: baseURL + "/api/cronScriptRunner",
            json: true,
            body: unsavedReq
          }, (function(_this) {
            return function(error, response, body) {
              return request.put({
                url: baseURL + "/api/cronScriptRunner/" + body.codeName,
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
    describe("create and run cron and get run status", function() {
      var unsavedReq;
      unsavedReq = copyJSON(cronScriptRunnerTestJSON.savedCronEntry);
      delete unsavedReq.codeName;
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
                url: baseURL + "/api/cronScriptRunner/" + body.codeName,
                json: true
              }, function(error, response, body) {
                _this.responseJSON = body;
                _this.serverResponse = response;
                return request.put({
                  url: baseURL + "/api/cronScriptRunner/" + body.codeName,
                  json: true,
                  body: {
                    active: false,
                    ignored: true
                  }
                }, function(error, response, body) {
                  return done();
                });
              });
            }, 3000);
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
        return assert.equal(this.responseJSON.numberOfExecutions > 0, true);
      });
    });
    describe("create and run cron then stop", function() {
      var unsavedReq;
      unsavedReq = copyJSON(cronScriptRunnerTestJSON.savedCronEntry);
      delete unsavedReq.codeName;
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
                url: baseURL + "/api/cronScriptRunner/" + body.codeName,
                json: true
              }, function(error, response, body1) {
                _this.numRuns1 = body1.numberOfExecutions;
                return request.put({
                  url: baseURL + "/api/cronScriptRunner/" + body.codeName,
                  json: true,
                  body: {
                    active: false,
                    ignored: false
                  }
                }, function(error, response, body) {
                  return setTimeout(function() {
                    return request.get({
                      url: baseURL + "/api/cronScriptRunner/" + body.codeName,
                      json: true
                    }, function(error, response, body2) {
                      _this.numRuns2 = body2.numberOfExecutions;
                      return done();
                    });
                  }, 2500);
                });
              });
            }, 2500);
          };
        })(this));
      });
      return it("should run once", function() {
        return assert.equal(this.numRuns1, this.numRuns2);
      });
    });
    describe("create active job then change it", function() {
      var unsavedReq;
      unsavedReq = copyJSON(cronScriptRunnerTestJSON.savedCronEntry);
      delete unsavedReq.codeName;
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
                url: baseURL + "/api/cronScriptRunner/" + body.codeName,
                json: true
              }, function(error, response, body1) {
                _this.numRuns1 = body1.numberOfExecutions;
                return request.put({
                  url: baseURL + "/api/cronScriptRunner/" + body.codeName,
                  json: true,
                  body: {
                    active: true,
                    ignored: false,
                    scriptJSONData: '{"fileToParse": "public/src/modules/BulkLoadSampleTransfers/spec/specFiles/KilroyWasHere_good.csv", "dryRun": "true", "user": "jmcneil" }'
                  }
                }, function(error, response, body) {
                  return setTimeout(function() {
                    return request.get({
                      url: baseURL + "/api/cronScriptRunner/" + body.codeName,
                      json: true
                    }, function(error, response, body2) {
                      _this.numRuns2 = body2.numberOfExecutions;
                      _this.lastResultJSON = body2.lastResultJSON;
                      return request.put({
                        url: baseURL + "/api/cronScriptRunner/" + body.codeName,
                        json: true,
                        body: {
                          active: false,
                          ignored: false
                        }
                      }, function(error, response, body) {
                        return done();
                      });
                    });
                  }, 4500);
                });
              });
            }, 2500);
          };
        })(this));
      });
      it("should run at first", function() {
        return assert.equal(this.numRuns1 > 0, true);
      });
      it("should run later", function() {
        return assert.equal(this.numRuns2 > this.numRuns1, true);
      });
      return it("should return an error the second run", function() {
        return assert.equal(this.lastResultJSON.indexOf("KilroyWasHere") > -1, true);
      });
    });
    describe("create inactive job then set active", function() {
      var unsavedReq;
      unsavedReq = copyJSON(cronScriptRunnerTestJSON.savedCronEntry);
      delete unsavedReq.codeName;
      unsavedReq.active = false;
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
                url: baseURL + "/api/cronScriptRunner/" + body.codeName,
                json: true
              }, function(error, response, body1) {
                _this.numRuns1 = body1.numberOfExecutions;
                return request.put({
                  url: baseURL + "/api/cronScriptRunner/" + body.codeName,
                  json: true,
                  body: {
                    active: true,
                    ignored: false
                  }
                }, function(error, response, body) {
                  return setTimeout(function() {
                    return request.get({
                      url: baseURL + "/api/cronScriptRunner/" + body.codeName,
                      json: true
                    }, function(error, response, body2) {
                      _this.numRuns2 = body2.numberOfExecutions;
                      return request.put({
                        url: baseURL + "/api/cronScriptRunner/" + body.codeName,
                        json: true,
                        body: {
                          active: false,
                          ignored: false
                        }
                      }, function(error, response, body) {
                        return done();
                      });
                    });
                  }, 2500);
                });
              });
            }, 2500);
          };
        })(this));
      });
      it("should not run at first", function() {
        return assert.equal(this.numRuns1, 0);
      });
      return it("should run later", function() {
        return assert.equal(this.numRuns2 > 0, true);
      });
    });
    describe("create active job then set inactive, then active", function() {
      var unsavedReq;
      unsavedReq = copyJSON(cronScriptRunnerTestJSON.savedCronEntry);
      delete unsavedReq.codeName;
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
                url: baseURL + "/api/cronScriptRunner/" + body.codeName,
                json: true
              }, function(error, response, body1) {
                _this.numRuns1 = body1.numberOfExecutions;
                return request.put({
                  url: baseURL + "/api/cronScriptRunner/" + body.codeName,
                  json: true,
                  body: {
                    active: false,
                    ignored: false
                  }
                }, function(error, response, body) {
                  return setTimeout(function() {
                    return request.get({
                      url: baseURL + "/api/cronScriptRunner/" + body.codeName,
                      json: true
                    }, function(error, response, body2) {
                      _this.numRuns2 = body2.numberOfExecutions;
                      return request.put({
                        url: baseURL + "/api/cronScriptRunner/" + body.codeName,
                        json: true,
                        body: {
                          active: true,
                          ignored: false
                        }
                      }, function(error, response, body3) {
                        return setTimeout(function() {
                          return request.get({
                            url: baseURL + "/api/cronScriptRunner/" + body.codeName,
                            json: true
                          }, function(error, response, body3) {
                            _this.numRuns3 = body3.numberOfExecutions;
                            return request.put({
                              url: baseURL + "/api/cronScriptRunner/" + body.codeName,
                              json: true,
                              body: {
                                active: false,
                                ignored: false
                              }
                            }, function(error, response, body) {
                              return done();
                            });
                          });
                        }, 2500);
                      });
                    });
                  }, 2500);
                });
              });
            }, 2500);
          };
        })(this));
      });
      it("should  run at first", function() {
        return assert.equal(this.numRuns1 > 0, true);
      });
      it("should stop later", function() {
        return assert.equal(this.numRuns1, this.numRuns2);
      });
      return it("should start after that", function() {
        return assert.equal(this.numRuns3 > this.numRuns2, true);
      });
    });
    return describe("Post bogus or missing cron spec", function() {
      describe("missing schedule", function() {
        var unsavedReq;
        unsavedReq = copyJSON(cronScriptRunnerTestJSON.savedCronEntry);
        delete unsavedReq.codeName;
        delete unsavedReq.schedule;
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
              return done();
            };
          })(this));
        });
        return it("should return a success status code of 500", function() {
          return assert.equal(this.serverResponse.statusCode, 500);
        });
      });
      describe("missing scriptType", function() {
        var unsavedReq;
        unsavedReq = copyJSON(cronScriptRunnerTestJSON.savedCronEntry);
        delete unsavedReq.codeName;
        delete unsavedReq.scriptType;
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
              return done();
            };
          })(this));
        });
        return it("should return a success status code of 500", function() {
          return assert.equal(this.serverResponse.statusCode, 500);
        });
      });
      describe("missing scriptFile", function() {
        var unsavedReq;
        unsavedReq = copyJSON(cronScriptRunnerTestJSON.savedCronEntry);
        delete unsavedReq.codeName;
        delete unsavedReq.scriptFile;
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
              return done();
            };
          })(this));
        });
        return it("should return a success status code of 500", function() {
          return assert.equal(this.serverResponse.statusCode, 500);
        });
      });
      describe("missing functionName", function() {
        var unsavedReq;
        unsavedReq = copyJSON(cronScriptRunnerTestJSON.savedCronEntry);
        delete unsavedReq.codeName;
        delete unsavedReq.functionName;
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
              return done();
            };
          })(this));
        });
        return it("should return a success status code of 500", function() {
          return assert.equal(this.serverResponse.statusCode, 500);
        });
      });
      describe("missing scriptJSONData", function() {
        var unsavedReq;
        unsavedReq = copyJSON(cronScriptRunnerTestJSON.savedCronEntry);
        delete unsavedReq.codeName;
        delete unsavedReq.scriptJSONData;
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
              return done();
            };
          })(this));
        });
        return it("should return a success status code of 500", function() {
          return assert.equal(this.serverResponse.statusCode, 500);
        });
      });
      return describe("missing active", function() {
        var unsavedReq;
        unsavedReq = copyJSON(cronScriptRunnerTestJSON.savedCronEntry);
        delete unsavedReq.codeName;
        delete unsavedReq.active;
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
              return done();
            };
          })(this));
        });
        return it("should return a success status code of 500", function() {
          return assert.equal(this.serverResponse.statusCode, 500);
        });
      });
    });
  });

}).call(this);
