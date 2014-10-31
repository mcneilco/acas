(function() {
  var assert, config, fs, request;

  assert = require('assert');

  request = require('request');

  fs = require('fs');

  config = require('../../../../conf/compiled/conf.js');

  describe("Controller Redirect service testing", function() {
    describe("protocol redirect", function() {
      describe("When user enters in generic protocol", function() {
        before(function(done) {
          return request("http://localhost:" + config.all.server.nodeapi.port + "/entity/edit/codeName/PROT-generic", (function(_this) {
            return function(error, response, body) {
              _this.responseJSON = body;
              _this.response = response;
              return done();
            };
          })(this));
        });
        return it("should return redirect", function() {
          return assert.equal(this.response.request.uri.href.indexOf('protocol_base') > 0, true);
        });
      });
      describe("When user enters a screening protocol", function() {
        before(function(done) {
          return request("http://localhost:" + config.all.server.nodeapi.port + "/entity/edit/codeName/PROT-screening", (function(_this) {
            return function(error, response, body) {
              _this.responseJSON = body;
              _this.response = response;
              return done();
            };
          })(this));
        });
        return it("should return redirect", function() {
          return assert.equal(this.response.request.uri.href.indexOf('primary_screen_protocol') > 0, true);
        });
      });
      return describe("When user enters a not special protocol", function() {
        before(function(done) {
          return request("http://localhost:" + config.all.server.nodeapi.port + "/entity/edit/codeName/PROT-random", (function(_this) {
            return function(error, response, body) {
              _this.responseJSON = body;
              _this.response = response;
              return done();
            };
          })(this));
        });
        return it("should return redirect", function() {
          return assert.equal(this.response.request.uri.href.indexOf('protocol_base') > 0, true);
        });
      });
    });
    describe("experiment redirect", function() {
      console.log("yay");
      describe("When user enters in generic experiment", function() {
        before(function(done) {
          return request("http://localhost:" + config.all.server.nodeapi.port + "/entity/edit/codeName/EXPT-generic", (function(_this) {
            return function(error, response, body) {
              _this.responseJSON = body;
              _this.response = response;
              return done();
            };
          })(this));
        });
        return it("should return redirect", function() {
          return assert.equal(this.response.request.uri.href.indexOf('experiment_base') > 0, true);
        });
      });
      describe("When user enters a screening experiment", function() {
        before(function(done) {
          return request("http://localhost:" + config.all.server.nodeapi.port + "/entity/edit/codeName/EXPT-screening", (function(_this) {
            return function(error, response, body) {
              _this.responseJSON = body;
              _this.response = response;
              return done();
            };
          })(this));
        });
        return it("should return redirect", function() {
          return assert.equal(this.response.request.uri.href.indexOf('flipr_screening_assay') > 0, true);
        });
      });
      return describe("When user enters a not special protocol", function() {
        before(function(done) {
          return request("http://localhost:" + config.all.server.nodeapi.port + "/entity/edit/codeName/EXPT-random", (function(_this) {
            return function(error, response, body) {
              _this.responseJSON = body;
              _this.response = response;
              return done();
            };
          })(this));
        });
        return it("should return redirect", function() {
          return assert.equal(this.response.request.uri.href.indexOf('experiment_base') > 0, true);
        });
      });
    });
    return describe("entity type redirect", function() {
      describe("when entity is EXPT ", function() {
        before(function(done) {
          return request("http://localhost:" + config.all.server.nodeapi.port + "/entity/edit/codeName/EXPT-random", (function(_this) {
            return function(error, response, body) {
              _this.responseJSON = body;
              _this.response = response;
              return done();
            };
          })(this));
        });
        return it("should redirect to an experiment", function() {
          return assert.equal(this.response.request.uri.href.indexOf('experiment') > 0, true);
        });
      });
      describe("when entity is PROT", function() {
        before(function(done) {
          return request("http://localhost:" + config.all.server.nodeapi.port + "/entity/edit/codeName/PROT-random", (function(_this) {
            return function(error, response, body) {
              _this.responseJSON = body;
              _this.response = response;
              return done();
            };
          })(this));
        });
        return it("should redirect to a  protocol", function() {
          return assert.equal(this.response.request.uri.href.indexOf('protocol') > 0, true);
        });
      });
      return describe("when user enters entity that doesn't exist", function() {
        before(function(done) {
          return request("http://localhost:" + config.all.server.nodeapi.port + "/entity/edit/codeName/XXX-random", (function(_this) {
            return function(error, response, body) {
              _this.responseJSON = body;
              _this.response = response;
              return done();
            };
          })(this));
        });
        return it("should redirect to the home page", function() {
          assert.equal(this.response.request.uri.href.indexOf('protocol') < 0, true);
          assert.equal(this.response.request.uri.href.indexOf('experiment') < 0, true);
          return assert.equal(this.response.request.uri.href, "http://localhost:" + config.all.server.nodeapi.port + "/#");
        });
      });
    });
  });

}).call(this);
