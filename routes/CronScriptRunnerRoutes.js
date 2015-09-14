(function() {
  var addJobsOnStartup, launchRScript, scriptComplete, setupNewCron, validateSpec;

  exports.setupAPIRoutes = function(app) {
    app.post('/api/cronScriptRunner', exports.postCronScriptRunner);
    app.get('/api/cronScriptRunner/:code', exports.getCronScriptRunner);
    app.put('/api/cronScriptRunner/:code', exports.putCronScriptRunner);
    console.log("about to declare global in setup");
    global.cronCodeBaseNum = 1;
    global.cronJobs = {};
    console.log("just declared global in setup");
    return addJobsOnStartup();
  };

  exports.setupRoutes = function(app, loginRoutes) {};

  addJobsOnStartup = function() {
    var codeInt, cronConfig, i, len, newCode, newCron, ref, results, spec;
    cronConfig = require('../public/javascripts/conf/StartupCronJobsConfJSON.js');
    codeInt = 1;
    ref = cronConfig.jobsToStart;
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      spec = ref[i];
      newCode = "CONF_CRON" + codeInt++;
      newCron = {
        spec: spec
      };
      newCron.spec.cronCode = newCode;
      newCron.spec.numberOfExcutions = 0;
      newCron.spec.ignored = false;
      global.cronJobs[newCode] = newCron;
      if (newCron.spec.active) {
        results.push(setupNewCron(newCron));
      } else {
        results.push(void 0);
      }
    }
    return results;
  };

  exports.postCronScriptRunner = function(req, resp) {
    var cronScriptRunnerTestJSON, newCode, newCron, validation;
    validation = validateSpec(JSON.parse(JSON.stringify(req.body)));
    if (!validation.valid) {
      console.log(validation);
      resp.send(JSON.stringify(validation.messages), 500);
      return;
    }
    if ((req.query.testMode === true) || (global.specRunnerTestmode === true)) {
      cronScriptRunnerTestJSON = require('../public/javascripts/spec/testFixtures/CronScriptRunnerTestJSON.js');
      return resp.json(cronScriptRunnerTestJSON.savedCronEntry);
    } else {
      newCode = "CRON" + global.cronCodeBaseNum++;
      newCron = {
        spec: JSON.parse(JSON.stringify(req.body))
      };
      newCron.spec.cronCode = newCode;
      newCron.spec.numberOfExcutions = 0;
      newCron.spec.ignored = false;
      global.cronJobs[newCode] = newCron;
      if (newCron.spec.active) {
        setupNewCron(newCron);
      }
      return resp.json(newCron.spec);
    }
  };

  exports.putCronScriptRunner = function(req, resp) {
    var code, cronJob, cronScriptRunnerTestJSON, key, ref, respCron, value;
    if ((req.query.testMode === true) || (global.specRunnerTestmode === true)) {
      cronScriptRunnerTestJSON = require('../public/javascripts/spec/testFixtures/CronScriptRunnerTestJSON.js');
      if (req.params.code.indexOf('error') > -1) {
        resp.send("cronCode " + code + " not found", 404);
        return;
      }
      respCron = JSON.parse(JSON.stringify(cronScriptRunnerTestJSON.savedCronEntry));
      respCron.cronCode = req.params.code;
      if (req.body.active != null) {
        respCron.active = req.body.active;
      }
      if (req.body.ignored != null) {
        respCron.ignored = req.body.ignored;
      }
      resp.json(respCron);
    } else {
      code = req.params.code;
      cronJob = global.cronJobs[code];
      if (cronJob == null) {
        resp.send("cronCode " + code + " not found", 404);
        return;
      }
      ref = req.body;
      for (key in ref) {
        value = ref[key];
        console.log(key + ": " + value);
        cronJob.spec[key] = value;
      }
      if (cronJob.job != null) {
        cronJob.job.stop();
        delete cronJob.job;
      }
      if (!cronJob.spec.ignored) {
        if (cronJob.spec.active != null) {
          if (cronJob.spec.active) {
            setupNewCron(cronJob);
          }
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
      resp.json(respCron);
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
    console.log("cronCode: " + cronCode);
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

  validateSpec = function(spec) {
    var messages, valid;
    valid = true;
    messages = [];
    if (spec.schedule == null) {
      valid = false;
      messages.push({
        attribute: "schedule",
        level: "error",
        message: "schedule must be supplied"
      });
    }
    if (spec.scriptType == null) {
      valid = false;
      messages.push({
        attribute: "scriptType",
        level: "error",
        message: "scriptType must be supplied"
      });
    }
    if (spec.scriptType != null) {
      if (spec.scriptType !== "R") {
        valid = false;
        messages.push({
          attribute: "scriptType",
          level: "error",
          message: "Only scriptType supported is R"
        });
      }
    }
    if (spec.scriptFile == null) {
      valid = false;
      messages.push({
        attribute: "scriptFile",
        level: "error",
        message: "scriptFile must be supplied"
      });
    }
    if (spec.functionName == null) {
      valid = false;
      messages.push({
        attribute: "functionName",
        level: "error",
        message: "functionName must be supplied"
      });
    }
    if (spec.scriptJSONData == null) {
      valid = false;
      messages.push({
        attribute: "scriptJSONData",
        level: "error",
        message: "scriptJSONData must be supplied"
      });
    }
    if (spec.active == null) {
      valid = false;
      messages.push({
        attribute: "active",
        level: "error",
        message: "active must be supplied"
      });
    }
    return {
      valid: valid,
      messages: messages
    };
  };

}).call(this);
