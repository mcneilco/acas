(function() {
  var CRON_CONFIG_PREFIX, addJobsOnStartup, config, launchRScript, request, scriptComplete, setupNewCron, updateCronScriptRunner, validateSpec;

  exports.setupAPIRoutes = function(app) {
    app.get('/api/cronScriptRunner', exports.getAllCronScriptRunner);
    app.post('/api/cronScriptRunner', exports.postCronScriptRunner);
    app.get('/api/cronScriptRunner/:code', exports.getCronScriptRunner);
    app.put('/api/cronScriptRunner/:code', exports.putCronScriptRunner);
    global.cronJobs = {};
    console.log("just declared global cronJobs in setup");
    return addJobsOnStartup();
  };

  exports.setupRoutes = function(app, loginRoutes) {};

  config = require('../conf/compiled/conf.js');

  request = require('request');

  CRON_CONFIG_PREFIX = "CONF_CRON";

  addJobsOnStartup = function() {
    var codeInt, cronConfig, i, len, newCode, newCron, persistenceURL, ref, spec;
    cronConfig = require('../public/javascripts/conf/StartupCronJobsConfJSON.js');
    persistenceURL = config.all.client.service.persistence.fullpath + "cronjobs";
    codeInt = 1;
    if ((cronConfig != null ? cronConfig.jobsToStart : void 0) != null) {
      ref = cronConfig.jobsToStart;
      for (i = 0, len = ref.length; i < len; i++) {
        spec = ref[i];
        newCode = CRON_CONFIG_PREFIX + codeInt++;
        newCron = {
          spec: spec
        };
        newCron.spec.codeName = newCode;
        newCron.spec.numberOfExcutions = 0;
        newCron.spec.ignored = false;
        global.cronJobs[newCode] = newCron;
        if (newCron.spec.active) {
          setupNewCron(newCron);
        }
      }
    }
    if (!global.specRunnerTestmode) {
      return request.get({
        url: persistenceURL,
        json: true
      }, (function(_this) {
        return function(error, response, body) {
          var j, len1, ref1, ref2, results, startOnRestart;
          if (!error && response.statusCode < 400) {
            results = [];
            for (j = 0, len1 = body.length; j < len1; j++) {
              spec = body[j];
              newCron = {
                spec: spec
              };
              global.cronJobs[newCron.spec.codeName] = newCron;
              startOnRestart = (ref1 = config.all.server.service) != null ? (ref2 = ref1.cron) != null ? ref2.startOnRestart : void 0 : void 0;
              if (startOnRestart == null) {
                startOnRestart = true;
              }
              if (!newCron.spec.ignored && newCron.spec.active && startOnRestart) {
                results.push(setupNewCron(newCron));
              } else {
                results.push(void 0);
              }
            }
            return results;
          } else {
            return console.log('Failed to get list of existing cronjobs, error:' + error + '\n body: ' + body);
          }
        };
      })(this));
    }
  };

  exports.getAllCronScriptRunner = function(req, resp) {
    var allSavedSpecs, code, job;
    allSavedSpecs = (function() {
      var ref, results;
      ref = global.cronJobs;
      results = [];
      for (code in ref) {
        job = ref[code];
        results.push(job.spec);
      }
      return results;
    })();
    return resp.json(allSavedSpecs);
  };

  exports.postCronScriptRunner = function(req, resp) {
    var cronScriptRunnerTestJSON, persistenceURL, unsavedReq, validation;
    console.log("global.specRunnerTestmode: " + global.specRunnerTestmode);
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
      unsavedReq = req.body;
      persistenceURL = config.all.client.service.persistence.fullpath + "cronjobs";
      if (!unsavedReq.numberOfExecutions) {
        unsavedReq.numberOfExecutions = 0;
      }
      return request.post({
        url: persistenceURL,
        json: true,
        body: unsavedReq
      }, (function(_this) {
        return function(error, response, body) {
          var newCode, newCron;
          _this.serverError = error;
          _this.responseJSON = body;
          _this.serverResponse = response;
          if (!error && response.statusCode < 400 && (body.codeName != null)) {
            newCron = {
              spec: body
            };
            newCode = body.codeName;
            global.cronJobs[newCode] = newCron;
            if (newCron.spec.active) {
              setupNewCron(newCron);
            }
            return resp.json(newCron.spec);
          } else {
            resp.statusCode = 500;
            return resp.end(response.body);
          }
        };
      })(this));
    }
  };

  exports.putCronScriptRunner = function(req, resp) {
    var code, cronJob, cronScriptRunnerTestJSON, respCron;
    if ((req.query.testMode === true) || (global.specRunnerTestmode === true)) {
      cronScriptRunnerTestJSON = require('../public/javascripts/spec/testFixtures/CronScriptRunnerTestJSON.js');
      if (req.params.code.indexOf('error') > -1) {
        resp.send("codeName " + code + " not found", 404);
        return;
      }
      respCron = JSON.parse(JSON.stringify(cronScriptRunnerTestJSON.savedCronEntry));
      respCron.codeName = req.params.code;
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
        resp.send("codeName " + code + " not found", 404);
        return;
      }
      return updateCronScriptRunner(code, req.body, function(err, response) {
        if (err) {
          return resp.send(500, err);
        } else {
          return resp.json(response);
        }
      });
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
      if (cronJob != null) {
        return resp.json(cronJob.spec);
      } else {
        return resp.status(400).send("Cron Job not found");
      }
    }
  };

  updateCronScriptRunner = function(code, newSpec, callback) {
    var cronJob, key, persistenceURL, value;
    cronJob = global.cronJobs[code];
    if (cronJob == null) {
      callback("codeName " + code + " not found");
      return;
    }
    for (key in newSpec) {
      value = newSpec[key];
      cronJob.spec[key] = value;
    }
    if (cronJob.job != null) {
      cronJob.job.stop();
      delete cronJob.job;
    }
    persistenceURL = config.all.client.service.persistence.fullpath + "cronjobs/";
    if (code.indexOf(CRON_CONFIG_PREFIX < 0)) {
      return request.put({
        url: persistenceURL + code,
        json: true,
        body: cronJob.spec
      }, (function(_this) {
        return function(error, response, body) {
          if (!error && response.statusCode < 400 && (body.codeName != null)) {
            cronJob.spec = body;
            if (!cronJob.spec.ignored && (cronJob.spec.active != null) && cronJob.spec.active) {
              setupNewCron(cronJob);
            }
            return callback(null, cronJob.spec);
          } else {
            return callback("Failed put request to server: " + body);
          }
        };
      })(this));
    } else {
      if (!cronJob.spec.ignored && (cronJob.spec.active != null) && cronJob.spec.active) {
        setupNewCron(cronJob);
      }
      return callback(null, cronJob.spec);
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
    console.log('started cron r script ' + spec.codeName);
    return serverUtilityFunctions.runRFunctionOutsideRequest(spec.user, JSON.parse(spec.scriptJSONData), spec.scriptFile, spec.functionName, function(rReturn) {
      var duration;
      console.log('finished cron r script ' + spec.codeName);
      duration = new Date() - jobStart;
      return scriptComplete(spec.codeName, jobStart.getTime(), duration, rReturn);
    });
  };

  scriptComplete = function(codeName, startTime, duration, resultJSON) {
    var cronJob;
    cronJob = global.cronJobs[codeName];
    if ((cronJob != null) && (cronJob.spec != null)) {
      cronJob.spec.lastStartTime = startTime;
      cronJob.spec.lastDuration = duration;
      cronJob.spec.lastResultJSON = resultJSON;
      if (cronJob.spec.numberOfExecutions != null) {
        cronJob.spec.numberOfExecutions++;
      } else {
        cronJob.spec.numberOfExecutions = 1;
      }
      return updateCronScriptRunner(codeName, cronJob.spec, function(err, res) {
        if (err) {
          return console.log('unable to update job in database in scriptComplete: ' + err);
        }
      });
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
