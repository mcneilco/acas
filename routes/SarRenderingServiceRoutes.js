(function() {
  var _, codeService, config, configuredEntityTypes, request, sarRenderConf;

  exports.setupAPIRoutes = function(app) {
    app.get('/api/sarRender/geneId/:referenceCode', exports.getGeneRenderRoute);
    app.get('/api/sarRender/cmpdRegBatch/:referenceCode', exports.getBatchRenderRoute);
    app.get('/api/sarRender/acasLsThingCorpName/:displayName/:referenceCode', exports.getACASLsThingCorpNameRoute);
    app.post('/api/sarRender/render', exports.renderAnyRoute);
    return app.get('/api/sarRender/title/:displayName', exports.getTitleRoute);
  };

  exports.setupRoutes = function(app, loginRoutes) {
    app.get('/api/sarRender/geneId/:referenceCode', loginRoutes.ensureAuthenticated, exports.getGeneRenderRoute);
    app.get('/api/sarRender/cmpdRegBatch/:referenceCode', loginRoutes.ensureAuthenticated, exports.getBatchRenderRoute);
    app.get('/api/sarRender/acasLsThingCorpName/:displayName/:referenceCode', loginRoutes.ensureAuthenticated, exports.getACASLsThingCorpNameRoute);
    app.post('/api/sarRender/render', loginRoutes.ensureAuthenticated, exports.renderAnyRoute);
    return app.get('/api/sarRender/title/:displayName', loginRoutes.ensureAuthenticated, exports.getTitleRoute);
  };

  _ = require('underscore');

  request = require('request');

  configuredEntityTypes = require('../conf/ConfiguredEntityTypes.js');

  sarRenderConf = require('../conf/SarRenderConf.js');

  codeService = require('../routes/PreferredEntityCodeService.js');

  config = require('../conf/compiled/conf.js');

  exports.getGeneRenderRoute = function(req, resp) {
    var referenceCode;
    console.log("in get gene route");
    referenceCode = req.params.referenceCode;
    return exports.getGeneRender(referenceCode, function(json) {
      return resp.json(json);
    });
  };

  exports.getGeneRender = function(referenceCode, callback) {
    var csv, requestData;
    requestData = {
      displayName: "Gene ID",
      requests: [
        {
          requestName: referenceCode
        }
      ]
    };
    csv = false;
    return codeService.pickBestLabels(requestData, csv, (function(_this) {
      return function(response) {
        var bestLabel;
        bestLabel = response.results[0].bestLabel;
        console.log(bestLabel);
        return callback({
          html: '<a href="http://www.ncbi.nlm.nih.gov/gene/' + bestLabel + '"  target="_blank" align="center">' + bestLabel + '</a>'
        });
      };
    })(this));
  };

  exports.getBatchRenderRoute = function(req, resp) {
    var referenceCode;
    console.log("in get cmpd reg batch code route");
    referenceCode = req.params.referenceCode;
    return exports.getBatchRender(referenceCode, function(json) {
      return resp.json(json);
    });
  };

  exports.getBatchRender = function(referenceCode, callback) {
    var htmlReturn;
    htmlReturn = '<img src="' + config.all.client.service.external.structure.url + referenceCode + '" alt="Could not load entity image" ><br />';
    htmlReturn += '<a href="' + config.all.client.service.external.lotDetails.url + referenceCode + '" target="_blank" align="center">' + referenceCode + '</a>';
    return callback({
      html: htmlReturn
    });
  };

  exports.getACASLsThingCorpNameRoute = function(req, resp) {
    var displayName, referenceCode;
    console.log("in get ACAS LsThing corpName route");
    referenceCode = req.params.referenceCode;
    displayName = req.params.displayName;
    return exports.getACASLsThingRender(referenceCode, displayName, function(json) {
      return resp.json(json);
    });
  };

  exports.getACASLsThingRender = function(referenceCode, displayName, callback) {
    var csv, requestData;
    requestData = {
      displayName: displayName,
      requests: [
        {
          requestName: referenceCode
        }
      ]
    };
    csv = false;
    return codeService.pickBestLabels(requestData, csv, (function(_this) {
      return function(response) {
        var bestLabel;
        bestLabel = response.results[0].bestLabel;
        return callback({
          html: '<a href="http://' + config.all.client.host + ":" + config.all.client.port + "/entity/edit/codeName/" + referenceCode + '" target="_blank" align="center">' + bestLabel + '</a>'
        });
      };
    })(this));
  };

  exports.getTitleRoute = function(req, resp) {
    var displayName;
    displayName = req.params.displayName;
    return exports.getTitle(displayName, function(json) {
      return resp.json(json);
    });
  };

  exports.getTitle = function(displayName, callback) {
    return callback({
      title: sarRenderConf.sarRender[displayName].title
    });
  };

  exports.renderAnyRoute = function(req, resp) {
    var requestData, withDisplayName;
    requestData = {};
    if (req.body.displayName != null) {
      withDisplayName = true;
      requestData.displayName = req.body.displayName;
    } else {
      withDisplayName = false;
    }
    console.log("reference Code is " + req.body.referenceCode);
    requestData.referenceCode = req.body.referenceCode;
    return exports.renderAny(requestData, withDisplayName, function(json) {
      return resp.json(json);
    });
  };

  exports.renderAny = function(requestData, withDisplayName, callback) {
    var displayName, requestText, sarInfo;
    if (withDisplayName) {
      displayName = requestData.displayName;
      sarInfo = sarRenderConf.sarRender[displayName];
      return request(sarInfo.route + requestData.referenceCode, (function(_this) {
        return function(error, response, body) {
          console.log(body);
          return callback(JSON.parse(body));
        };
      })(this));
    } else {
      requestText = {
        requestText: requestData.referenceCode
      };
      return codeService.searchForEntities(requestText, function(response) {
        if (response.results.length !== 1) {
          callback({
            html: requestData.referenceCode
          });
        }
        displayName = response.results[0].displayName;
        sarInfo = sarRenderConf.sarRender[displayName];
        return request(sarInfo.route + requestData.referenceCode, (function(_this) {
          return function(error, response, body) {
            console.log(body);
            return callback(JSON.parse(body));
          };
        })(this));
      });
    }
  };

}).call(this);
