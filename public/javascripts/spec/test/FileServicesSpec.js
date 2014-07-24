(function() {
  var assert, config, fs, request;

  assert = require('assert');

  request = require('request');

  fs = require('fs');

  config = require('../../../../conf/compiled/conf.js');

  describe("Data File and Temp File Services", function() {
    return describe("File download test", function() {
      describe("Data file services", function() {
        before(function(done) {
          fs.writeFileSync("../../../" + config.all.server.datafiles.relative_path + "/test.txt", "test file");
          return request("http://localhost:3001/dataFiles/test.txt", (function(_this) {
            return function(error, response, body) {
              console.log("error: " + error);
              _this.responseJSON = body;
              return done();
            };
          })(this));
        });
        after(function() {
          return fs.unlink("../../../" + config.all.server.datafiles.relative_path + "/test.txt");
        });
        return it("should return a file", function() {
          return assert.equal(this.responseJSON.indexOf('est file') > 0, true);
        });
      });
      return describe("temp file services", function() {
        before(function(done) {
          fs.writeFileSync("../../../" + config.all.server.tempfiles.relative_path + "/test.txt", "test file");
          return request("http://localhost:3001/tempfiles/test.txt", (function(_this) {
            return function(error, response, body) {
              console.log("error: " + error);
              _this.responseJSON = body;
              return done();
            };
          })(this));
        });
        after(function() {
          return fs.unlink("../../../" + config.all.server.tempfiles.relative_path + "/test.txt");
        });
        return it("should return a file", function() {
          return assert.equal(this.responseJSON.indexOf('est file') > 0, true);
        });
      });
    });
  });

}).call(this);
