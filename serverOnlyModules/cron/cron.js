(function() {
  exports.startCron = function() {
    var CronJob, config, ex, serverUtilityFunctions;
    config = require('./../../conf/compiled/conf.js');
    serverUtilityFunctions = require('../../routes/ServerUtilityFunctions.js');
    CronJob = require("cron").CronJob;
    if (typeof config.all.server.cron !== "undefined") {
      if (typeof config.all.server.cron.pingpong !== "undefined") {
        try {
          new CronJob(config.all.server.cron.pingpong, function() {
            console.log('running ping pong cron');
            serverUtilityFunctions.runRScript('serverOnlyModules/PingPongTables/pingPong.R');
          }, null, true, null);
          console.log('installed Ping Pong cron on schedule: ' + config.all.server.cron.pingpong);
        } catch (_error) {
          ex = _error;
          console.log("Ping Pong cron pattern not valid");
        }
      }
      if (typeof config.all.server.cron.summarystatistics !== "undefined") {
        try {
          new CronJob(config.all.server.cron.summarystatistics, function() {
            console.log('running summary statistics cron');
            serverUtilityFunctions.runRScript('serverOnlyModules/SummaryStatistics/generateSummaryStatistics.R');
          }, null, true, null);
          return console.log('installed Summary Statistics cron on schedule: ' + config.all.server.cron.summarystatistics);
        } catch (_error) {
          ex = _error;
          return console.log("Summary Statistics cron pattern not valid");
        }
      }
    }
  };

}).call(this);
