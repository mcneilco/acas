(function() {
  exports.setupAPIRoutes = function(app, loginRoutes) {
    app.post('/api/cronScriptRunner', exports.postCronScriptRunner);
    app.get('/api/cronScriptRunner', exports.getCronScriptRunner);
    return app.put('/api/cronScriptRunner', exports.putCronScriptRunner);
  };

  exports.postCronScriptRunner = function(req, resp) {
    var cronScriptRunnerTestJSON;
    console.log("getting authors");
    if ((req.query.testMode === true) || (global.specRunnerTestmode === true)) {
      cronScriptRunnerTestJSON = require('../public/javascripts/spec/testFixtures/CronScriptRunnerTestJSON.js');
      return resp.json(cronScriptRunnerTestJSON.savedCronEntry);
    } else {
      return console.log("not implemented yet");
    }
  };

}).call(this);
