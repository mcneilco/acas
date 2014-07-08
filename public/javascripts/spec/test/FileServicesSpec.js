(function() {
  var assert, fs, request;

  assert = require('assert');

  request = require('request');

  fs = require('fs');

  describe("Data File and Temp File Services", function() {
    describe("Data file services", function() {
      before(function(done) {
        fs.writeFileSync("../../../privateUploads/test.txt", "test file");
        return request("http://localhost:3001/dataFiles/test.txt", (function(_this) {
          return function(error, response, body) {
            console.log("error: " + error);
            _this.responseJSON = body;
            return done();
          };
        })(this));
      });
      after(function() {
        return fs.unlink("../../../privateUploads/test.txt");
      });
      return it("should return a file", function() {
        return assert.equal(this.responseJSON.indexOf('est file') > 0, true);
      });
    });
    return describe("temp file services", function() {
      before(function(done) {
        fs.writeFileSync("../../../privateTempFiles/test.txt", "test file");
        return request("http://localhost:3001/tempfiles/test.txt", (function(_this) {
          return function(error, response, body) {
            console.log("error: " + error);
            _this.responseJSON = body;
            return done();
          };
        })(this));
      });
      after(function() {
        return fs.unlink("../../../privateTempFiles/test.txt");
      });
      return it("should return a file", function() {
        return assert.equal(this.responseJSON.indexOf('est file') > 0, true);
      });
    });
  });

}).call(this);
