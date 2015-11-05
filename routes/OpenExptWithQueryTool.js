(function() {
  exports.setupRoutes = function(app, loginRoutes) {
    return app.get('/openExptInQueryTool', loginRoutes.ensureAuthenticated, exports.redirectToQueryToolForExperiment);
  };

  exports.redirectToQueryToolForExperiment = function(req, resp) {
    var config, expRoutes, getLdUrl, tool;
    config = require('../conf/compiled/conf.js');
    tool = req.query.tool;
    if (tool == null) {
      tool = config.all.client.service.result.viewer.defaultViewer;
      if (tool == null) {
        tool = 'DataViewer';
      }
    }
    if (tool === 'LiveDesign') {
      getLdUrl = require('./CreateLiveDesignLiveReportForACAS.js');
      return getLdUrl.getUrlForNewLiveDesignLiveReportForExperiment(req.query.experiment, function(url) {
        return resp.redirect(url);
      });
    } else if (tool === 'Seurat') {
      expRoutes = require('./ExperimentServiceRoutes.js');
      return expRoutes.resultViewerURLFromExperimentCodeName(req.query.experiment, function(err, res) {
        if ((err != null) || (res.resultViewerURL == null)) {
          return resp.status(404).send("Could not get Seurat link");
        } else {
          return resp.redirect(res.resultViewerURL);
        }
      });
    } else if (tool === 'DataViewer') {
      return resp.redirect('/dataViewer/filterByExpt/' + req.query.experiment);
    } else {
      return resp.status(500).send('Invalid viewer tool');
    }
  };

}).call(this);
