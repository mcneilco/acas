(function() {
  var _, assert, config, exec, experimentServiceTestJSON, fs, parseResponse, request, runRFunctionServiceTestJSON;

  assert = require('assert');

  request = require('request');

  _ = require('underscore');

  experimentServiceTestJSON = require('../testFixtures/ExperimentServiceTestJSON.js');

  runRFunctionServiceTestJSON = require('../testFixtures/RunRFunctionServiceTestJSON.js');

  fs = require('fs');

  exec = require('child_process').exec;

  config = require('../.././compiled/conf.js');

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

  describe("A. Connecting to ACAS", function() {
    return describe("by requesting http://client.host:client.port", function() {
      before(function(done) {
        return request("http://" + config.all.client.host + ":" + config.all.client.port, (function(_this) {
          return function(error, response, body) {
            _this.responseJSON = body;
            _this.response = response;
            return done();
          };
        })(this));
      });
      return it("should return a status code of 200", function() {
        assert.equal(this.response === void 0, false, "communication error between node and acas. Check that client.host and client.port are set properly.");
        assert.equal(this.response.statusCode === 404, false, "unable to access acas. check that client.port is set properly");
        return assert.equal(this.response.statusCode, 200, "status code " + this.response.statusCode + " returned instead. Possible communication error between node and acas.");
      });
    });
  });

  describe("B. Connecting to the database", function() {
    describe("through tomcat", function() {
      before(function(done) {
        return request("http://" + config.all.client.service.persistence.host + ":" + config.all.client.service.persistence.port, (function(_this) {
          return function(error, response, body) {
            _this.response = response;
            return done();
          };
        })(this));
      });
      it("should return a status code of 200", function() {
        assert.equal(this.response === void 0, false, "Node cannot connect to tomcat. Check that the property client.service.persistence.port and client.service.persistence.host are set properly.");
        return assert.equal(this.response.statusCode, 200, "status code " + this.response.statusCode + " returned instead");
      });
      return describe("and fetching data from the database", function() {
        it("should be able to contact the database before timeout", function() {
          return before(function(done) {
            return request("http://" + config.all.client.service.persistence.host + ":" + config.all.client.service.persistence.port + "/acas/api/v1/containertypes", (function(_this) {
              return function(error, response, body) {
                return done();
              };
            })(this));
          });
        });
        return describe("should return a JSON", function() {
          before(function(done) {
            return request("http://" + config.all.client.service.persistence.host + ":" + config.all.client.service.persistence.port + "/acas/api/v1/containertypes", (function(_this) {
              return function(error, response, body) {
                _this.responseJSON = body;
                return done();
              };
            })(this));
          });
          return it("that can be parsed", function() {
            try {
              return parseResponse(this.responseJSON);
            } catch (_error) {
              return assert(false, "Unable to parse the JSON response, check connection between roo and the database and that client.service.persistence.port and client.service.persistence.host");
            }
          });
        });
      });
    });
    return describe("through the nodeapi port", function() {
      it("should be able to contact the database before timeout", function() {
        return before(function(done) {
          return request("http://" + config.all.client.host + ":" + config.all.server.nodeapi.port + "/api/codetables", (function(_this) {
            return function(error, response, body) {
              return done();
            };
          })(this));
        });
      });
      return describe("and pulling the codetables", function() {
        before(function(done) {
          return request("http://" + config.all.client.host + ":" + config.all.server.nodeapi.port + "/api/codetables", (function(_this) {
            return function(error, response, body) {
              _this.responseJSON = body;
              return done();
            };
          })(this));
        });
        return it("should return something that can be parsed", function() {
          try {
            return parseResponse(this.responseJSON)[0];
          } catch (_error) {
            return assert(false, "Unable to parse the JSON response, check connection between tomcat and the database and that server.nodeapi.port is set correctly.");
          }
        });
      });
    });
  });

  describe("C. Writing a file to", function() {
    describe("the uploads path", function() {
      before(function(done) {
        return fs.writeFile(config.all.server.datafiles.relative_path + '/test.txt', 'this is a test', (function(_this) {
          return function(error) {
            _this.errors = error;
            return done();
          };
        })(this));
      });
      it("should not throw an error", function() {
        return assert(this.errors === null || this.errors === void 0, "Check the connection between node and the file uploads including server.datafiles.relative_path.");
      });
      describe("then accessing the file", function() {
        describe("directly", function() {
          before(function(done) {
            return fs.readdir(config.all.server.datafiles.relative_path, (function(_this) {
              return function(err, files) {
                _this.errors = err;
                _this.files = files;
                return done();
              };
            })(this));
          });
          it("should not throw an error", function() {
            return assert(this.errors === null, "Unable to read the directory. Check the connection between node and the file uploads including server.datafiles.relative_path.");
          });
          return it("should find file", function() {
            return assert(this.files.indexOf("test.txt") !== -1, "test file was not added to the uploads directory. Check that server.datafiles.relative_path points to a directory that can be written to.");
          });
        });
        return describe("through the server", function() {
          before(function(done) {
            return request(config.all.server.service.persistence.fileUrl, (function(_this) {
              return function(error, response, body) {
                _this.errors = error;
                _this.responseJSON = body;
                return done();
              };
            })(this));
          });
          it("should not throw an error", function() {
            return assert(this.errors === null, "unable to access the test file through the nodeapi port. Ensure that server.service.persistence.fileUrl is set correctly.");
          });
          return it("should find file", function() {
            var parsedResponse;
            parsedResponse = JSON.stringify(parseResponse(this.responseJSON));
            return assert(parsedResponse.indexOf("test.txt") !== -1, "unable to access the test file through the nodeapi port. Ensure that server.service.persistence.fileUrl is set correctly.");
          });
        });
      });
      return describe("then deleting the file", function() {
        before(function(done) {
          return fs.unlink(config.all.server.datafiles.relative_path + '/test.txt', (function(_this) {
            return function(err) {
              _this.errors = err;
              return done();
            };
          })(this));
        });
        it("should not throw an error", function() {
          return assert(this.errors === null, "unable to delete file from uploads path: " + this.errors);
        });
        return describe("and checking for existence", function() {
          before(function(done) {
            return fs.readdir(config.all.server.datafiles.relative_path, (function(_this) {
              return function(err, files) {
                _this.errors = err;
                _this.files = files;
                return done();
              };
            })(this));
          });
          it("should not throw an error", function() {
            return assert(this.errors === null, "Unable to read the directory. Check the connection between node and the file uploads including server.datafiles.relative_path.");
          });
          return it("should not find file", function() {
            return assert(this.files.indexOf("test.txt") === -1, "test file was not deleted from the uploads directory. Check that server.datafiles.relative_path points to a directory that can be written to.");
          });
        });
      });
    });
    return describe("the temp path", function() {
      before(function(done) {
        return fs.writeFile(config.all.server.tempfiles.relative_path + '/test.txt', 'this is a test', (function(_this) {
          return function(error) {
            _this.errors = error;
            return done();
          };
        })(this));
      });
      it("should not throw an error", function() {
        return assert(this.errors === null || this.errors === void 0, "Check the connection between node and the temp files including server.tempfiles.relative_path.");
      });
      describe("then accessing the file", function() {
        before(function(done) {
          return fs.readdir(config.all.server.tempfiles.relative_path, (function(_this) {
            return function(err, files) {
              _this.errors = err;
              _this.files = files;
              return done();
            };
          })(this));
        });
        it("should not throw an error", function() {
          return assert(this.errors === null, "Unable to read the directory. Check the connection between node and the temp files including server.tempfiles.relative_path.");
        });
        return it("should find file", function() {
          return assert(this.files.indexOf("test.txt") !== -1, "test file was not added to the temp files directory. Check that server.tempfiles.relative_path points to a directory that can be written to.");
        });
      });
      return describe("then deleting the file", function() {
        before(function(done) {
          return fs.unlink(config.all.server.tempfiles.relative_path + '/test.txt', (function(_this) {
            return function(err) {
              _this.errors = err;
              return done();
            };
          })(this));
        });
        it("should not throw an error", function() {
          return assert(this.errors === null, "unable to delete file from uploads path: " + this.errors);
        });
        return describe("and checking for existence", function() {
          before(function(done) {
            return fs.readdir(config.all.server.tempfiles.relative_path, (function(_this) {
              return function(err, files) {
                _this.errors = err;
                _this.files = files;
                return done();
              };
            })(this));
          });
          it("should not throw an error", function() {
            return assert(this.errors === null, "Unable to read the directory. Check the connection between node and the file uploads including server.tempfiles.relative_path.");
          });
          return it("should not find file", function() {
            return assert(this.files.indexOf("test.txt") === -1, "test file was not deleted from the uploads directory. Check that server.datafiles.relative_path points to a directory that can be written to.");
          });
        });
      });
    });
  });

  describe("D. Access to Rscript", function() {
    before(function(done) {
      return exec(config.all.server.rscript + " -e 'help()'", (function(_this) {
        return function(error, stdout, stderr) {
          _this.error1 = error;
          return done();
        };
      })(this));
    });
    it("should not throw an error", function() {
      return assert.equal(this.error1, null, "Check that Rscript is installed and that config.all.server.rscript is set properly");
    });
    describe("and then to racas hello(),", function() {
      var rCommand;
      rCommand = 'tryCatch({ library(racas); hello() },error = function(ex) {cat(paste("R Execution Error:",ex));})';
      before(function(done) {
        this.timeout(10000);
        return exec(config.all.server.rscript + " -e" + " '" + rCommand + "'", (function(_this) {
          return function(error, stdout, stderr) {
            _this.stdout = stdout;
            _this.stderr = stderr;
            return done();
          };
        })(this));
      });
      it.skip("should not throw an error or warning", function() {
        return assert.equal(this.stderr, null, "racas gives the following error or warning: " + this.stderr);
      });
      return it("should return 'Hello from racas'", function() {
        return assert.equal(this.stdout, 'Hello from racas', "Rscript is unable to properly access racas.");
      });
    });
    return describe("and then to the database", function() {
      describe("through tomcat using getAllValueKinds()", function() {
        var rCommand;
        rCommand = 'tryCatch({ library(racas); getAllValueKinds() },error = function(ex) {cat(paste("R Execution Error:",ex));})';
        before(function(done) {
          this.timeout(10000);
          return exec(config.all.server.rscript + " -e" + " '" + rCommand + "'", (function(_this) {
            return function(error, stdout, stderr) {
              _this.stderr = stderr;
              _this.stdout = stdout;
              return done();
            };
          })(this));
        });
        it.skip("should not throw an error or warning", function() {
          return assert.equal(this.stderr, null, "racas gives the following error or warning: \n" + this.stderr);
        });
        return it("should return a list", function() {
          var split;
          split = this.stdout.split("\n", 1);
          return assert.equal(split[0], "[[1]]", "check that racas can access the database through tomcat.");
        });
      });
      return describe("directly using getDatabaseConnection()", function() {
        var rCommand;
        rCommand = 'tryCatch({ library(racas); conn <- getDatabaseConnection(); dbDisconnect(conn) },error = function(ex) {cat(paste("R Execution Error:",ex));})';
        before(function(done) {
          this.timeout(10000);
          return exec(config.all.server.rscript + " -e" + " '" + rCommand + "'", (function(_this) {
            return function(error, stdout, stderr) {
              _this.stderr = stderr;
              _this.stdout = stdout;
              return done();
            };
          })(this));
        });
        it.skip("should not throw an error or warning", function() {
          return assert.equal(this.stderr, null, "Error connecting to the database through racas. Check relevant environment variables. \n" + this.stderr);
        });
        return it.skip("should return a status of ???", function() {
          return assert(false, this.stdout);
        });
      });
    });
  });

  describe("E. Access to rApache", function() {
    this.timeout(10000);
    before(function(done) {
      return request(config.all.client.service.rapache.fullpath + "RApacheInfo", (function(_this) {
        return function(error, response, body) {
          _this.responseJSON = body;
          _this.response = response;
          return done();
        };
      })(this));
    });
    it("Should return an status code of 200", function() {
      assert.equal(this.response === void 0, false, "communication error between node and rApache. Check that client.service.rapache.host and client.service.rapache.port are set properly.");
      assert.equal(this.response.statusCode === 404, false, "unable to access rApache. Check that client.service.rapache.port is set properly");
      return assert.equal(this.response.statusCode, 200, "status code " + this.response.statusCode + " returned instead. Possible communication error between node and rApache.");
    });
    describe("and then to racas hello()", function() {
      before(function(done) {
        return request(config.all.client.service.rapache.fullpath + "hello", (function(_this) {
          return function(error, response, body) {
            _this.responseJSON = body;
            _this.response = response;
            return done();
          };
        })(this));
      });
      return it("should return 'Hello from racas'", function() {
        assert(this.response !== void 0, false, "communication error between rApache and racas.");
        return assert(this.response.body === 'Hello from racas', "communication error between rApache and racas," + this.response.body + " returned instead.");
      });
    });
    describe("and then to racas runfunction", function() {
      before(function(done) {
        this.timeout(20000);
        return request.post({
          url: config.all.client.service.rapache.fullpath + "runfunction",
          json: true,
          body: runRFunctionServiceTestJSON.runRFunctionRequest
        }, (function(_this) {
          return function(error, response, body) {
            _this.serverError = error;
            _this.responseJSON = body;
            return done();
          };
        })(this));
      });
      return it("should return the response", function() {
        return assert(this.responseJSON.result === 'Success', "communication error when running rApache runfunction route, returned " + this.responseJSON + " instead.");
      });
    });
    return describe("and then to the database", function() {
      describe("through tomcat", function() {
        before(function(done) {
          return request(config.all.client.service.rapache.fullpath + "test/getAllValueKinds", (function(_this) {
            return function(error, response, body) {
              _this.responseJSON = body;
              return done();
            };
          })(this));
        });
        return it("should return a stringified list", function() {
          var split;
          split = this.responseJSON.split("(", 1);
          return assert.equal(split[0], "list", "rApache unable to access the database through tomcat. Check that all environment variables are set correctly. ");
        });
      });
      return describe("directly", function() {
        before(function(done) {
          return request(config.all.client.service.rapache.fullpath + "test/getDatabaseConnection", (function(_this) {
            return function(error, response, body) {
              _this.responseJSON = body;
              return done();
            };
          })(this));
        });
        return it.skip("should not return an error", function() {
          return assert.equal(this.responseJSON, void 0, this.responseJSON);
        });
      });
    });
  });

}).call(this);
