(function() {
  exports.setupRoutes = function(app, loginRoutes) {
    return app.get('/openExptInQueryTool', loginRoutes.ensureAuthenticated, exports.redirectToQueryToolForExperiment);
  };

  exports.redirectToQueryToolForExperiment = function(req, resp) {
    var baseurl, config, getLdUrl, request, serverUtilityFunctions, tool;
    config = require('../conf/compiled/conf.js');
    request = require('request');
    tool = req.query.tool;
    if (tool == null) {
      tool = config.all.client.service.result.viewer.defaultViewer;
      if (tool == null) {
        tool = 'Seurat';
      }
    }
    if (tool === 'LiveDesign') {
      getLdUrl = require('./CreateLiveDesignLiveReportForACAS.js');
      return getLdUrl.getUrlForNewLiveDesignLiveReportForExperiment(req.query.experiment, function(url) {
        return resp.redirect(url);
      });
    } else if (tool === 'Seurat') {
      serverUtilityFunctions = require('./ServerUtilityFunctions.js');
      baseurl = config.all.client.service.persistence.fullpath + "experiments/codename/" + req.query.experiment;
      return request.get({
        url: baseurl,
        json: true
      }, (function(_this) {
        return function(error, response, body) {
          var Experiment, expt, prefExptName, prefProtName, prot;
          if (error || response.statusCode >= 300) {
            return resp.status(500).send('error getting experiment');
          } else {
            console.log(body);
            Experiment = require('');
            expt = new Experiment(body);
            prefExptName = expt.pickBestName();
            prot = new Protocol(expt.protocol);
            prefProtName = prot.pickBestName();
            return resp.redirect(config.all.client.service.result.viewer.seurat.protocolPrefix + prefExptName + config.all.client.service.result.viewer.seurat.experimentPrefix + prefProtName);
          }
        };
      })(this));
    } else {
      return resp.status(500).send('Invalid viewer tool');
    }
  };

}).call(this);
