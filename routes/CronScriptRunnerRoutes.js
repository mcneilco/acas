(function() {
  var launchRScript, scriptComplete, setupNewCron;

  exports.setupAPIRoutes = function(app) {
    app.post('/api/cronScriptRunner', exports.postCronScriptRunner);
    app.get('/api/cronScriptRunner/:code', exports.getCronScriptRunner);
    app.put('/api/cronScriptRunner/:code', exports.putCronScriptRunner);
    console.log("about to declare global in setup");
    global.cronCodeBaseNum = 1;
    return console.log("just declared global in setup");
  };

  exports.setupRoutes = function(app, loginRoutes) {};

  global.cronJobs = {};

  exports.postCronScriptRunner = function(req, resp) {
    var cronScriptRunnerTestJSON, newCode, newCron;
    if ((req.query.testMode === true) || (global.specRunnerTestmode === true)) {
      cronScriptRunnerTestJSON = require('../public/javascripts/spec/testFixtures/CronScriptRunnerTestJSON.js');
      return resp.json(cronScriptRunnerTestJSON.savedCronEntry);
    } else {
      newCode = "CRON" + global.cronCodeBaseNum++;
      newCron = {
        spec: JSON.parse(JSON.stringify(req.body))
      };
      newCron.spec.cronCode = newCode;
      global.cronJobs[newCode] = newCron;
      if (newCron.spec.active) {
        setupNewCron(newCron);
      }
      return resp.json(newCron.spec);
    }
  };

  exports.putCronScriptRunner = function(req, resp) {
    var code, cronJob, cronScriptRunnerTestJSON, respCron;
    if ((req.query.testMode === true) || (global.specRunnerTestmode === true)) {
      cronScriptRunnerTestJSON = require('../public/javascripts/spec/testFixtures/CronScriptRunnerTestJSON.js');
      if (req.params.code.indexOf('error') > -1) {
        resp.send("cronCode " + code + " not found", 404);
      }
      respCron = JSON.parse(JSON.stringify(cronScriptRunnerTestJSON.savedCronEntry));
      respCron.cronCode = req.params.code;
      if (req.body.active != null) {
        respCron.active = req.body.active;
      }
      if (req.body.ignored != null) {
        respCron.ignored = req.body.ignored;
      }
      return resp.json(respCron);
    } else {
      code = req.params.code;
      cronJob = global.cronJobs[code];
      if (cronJob == null) {
        resp.send("cronCode " + code + " not found", 404);
      }
      if (req.body.active != null) {
        if (!req.body.active && cronJob.spec.active) {
          cronJob.job.stop();
        } else if (req.body.active && !cronJob.spec.active) {
          if (cronJob.job != null) {
            cronJob.job.start();
          } else {
            setupNewCron(cronJob);
          }
        }
        cronJob.spec.active = req.body.active;
      }
      if (req.body.ignored != null) {
        cronJob.spec.ignored = req.body.ignored;
        if (req.body.ignored) {
          if (cronJob.job != null) {
            cronJob.job.stop();
          }
          delete global.cronJobs[code];
        }
      }
      return resp.json(cronJob.spec);
    }
  };

  exports.getCronScriptRunner = function(req, resp) {
    var code, cronJob, cronScriptRunnerTestJSON, respCron;
    if ((req.query.testMode === true) || (global.specRunnerTestmode === true)) {
      cronScriptRunnerTestJSON = require('../public/javascripts/spec/testFixtures/CronScriptRunnerTestJSON.js');
      respCron = JSON.parse(JSON.stringify(cronScriptRunnerTestJSON.savedCronEntry));
      respCron.lastStartTime = 1234;
      respCron.lastDuration = 42;
      respCron.lastResultJSON = '{"someKey": "someValue", "hasError": false}';
      respCron.numberOfExcutions = 1;
      return resp.json(respCron);
    } else {
      code = req.params.code;
      cronJob = global.cronJobs[code];
      return resp.json(cronJob.spec);
    }
  };

  setupNewCron = function(cron) {
    var CronJob;
    CronJob = require('cron').CronJob;
    return cron.job = new CronJob({
      cronTime: cron.spec.schedule,
      start: true,
      onTick: function() {
        return launchRScript(cron.spec);
      }
    });
  };

  launchRScript = function(spec) {
    var jobStart, serverUtilityFunctions;
    serverUtilityFunctions = require('./ServerUtilityFunctions.js');
    jobStart = new Date();
    return serverUtilityFunctions.runRFunctionOutsideRequest(spec.user, JSON.parse(spec.scriptJSONData), spec.scriptFile, spec.functionName, function(rReturn) {
      var duration;
      duration = new Date() - jobStart;
      return scriptComplete(spec.cronCode, jobStart.getTime(), duration, rReturn);
    });
  };

  scriptComplete = function(cronCode, startTime, duration, resultJSON) {
    var cronJob;
    cronJob = global.cronJobs[cronCode];
    cronJob.spec.lastStartTime = startTime;
    cronJob.spec.lastDuration = duration;
    cronJob.spec.lastResultJSON = resultJSON;
    if (cronJob.spec.numberOfExcutions != null) {
      return cronJob.spec.numberOfExcutions++;
    } else {
      return cronJob.spec.numberOfExcutions = 1;
    }
  };

}).call(this);
