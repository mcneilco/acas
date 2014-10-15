(function() {
  var config;

  exports.setupRoutes = function(app) {
    app.get('/api/logger/', exports.getAllLogStatements);
    app.get('/api/logger/:level/:application/:user', exports.getAllLogStatementOfLevel);
    app.get('/api/logger/applicationSources', exports.getApplicationSources);
    app.get('/api/logger/users', exports.getUsers);
    app.get('/api/logger/query/afterTimeStamp/:timestamp', exports.getAllLogStatementsAfterTimeStamp);
    app.get('/api/logger/query/beforeTimeStamp/:timestamp', exports.getAllLogStatementsBeforeTimeStamp);
    app.get('/api/loggerQueryBetweenTimeStamps/:start/:end', exports.getAllLogStatementsBetweenTimeStamps);
    return app.get('/api/logFile', exports.getLogFlatFile);
  };

  config = require('../conf/compiled/conf.js');

  exports.getAllLogStatements = function(req, res) {
    global.logger.writeToLog("info", "Logging", "load data", "return all data from logging service", "", null);
    return global.logger.queryLogs({}, function(logs) {
      return res.send(logs);
    });
  };

  exports.getAllLogStatementsAfterTimeStamp = function(req, res) {
    var timestamp;
    timestamp = req.params.timestamp;
    return global.logger.getAllLogStatementsAfterTimeStamp(timestamp, function(logs) {
      return res.send(logs);
    });
  };

  exports.getAllLogStatementsBeforeTimeStamp = function(req, res) {
    var timestamp;
    timestamp = req.params.timestamp;
    return global.logger.getAllLogStatementsBeforeTimeStamp(timestamp, function(logs) {
      return res.send(logs);
    });
  };

  exports.getAllLogStatementsBetweenTimeStamps = function(req, res) {
    var end, start;
    start = req.params.start;
    end = req.params.end;
    return global.logger.getAllLogStatementsBetweenTimeStamps(start, end, function(logs) {
      return res.send(logs);
    });
  };

  exports.getAllLogStatementOfLevel = function(req, res) {
    var queryPredicate;
    queryPredicate = {};
    if (req.params.level !== "all") {
      queryPredicate["meta.level"] = req.params.level;
    }
    if (req.params.application !== "all") {
      queryPredicate["meta.sourceApp"] = req.params.application;
    }
    if (req.params.user !== "all") {
      queryPredicate["meta.user"] = req.params.user;
    }
    return global.logger.queryLogs(queryPredicate, function(logs) {
      return res.send(logs);
    });
  };

  exports.getApplicationSources = function(req, res) {
    return global.logger.getApplicationSources(function(applications) {
      return res.send(applications);
    });
  };

  exports.getUsers = function(req, res) {
    return global.logger.getUsers(function(users) {
      return res.send(users);
    });
  };

  exports.getLogFlatFile = function(req, res) {
    var fileSystem, path, pathToLogFile, readStream, stat;
    fileSystem = require('fs');
    path = require('path');
    pathToLogFile = path.join(__dirname, "../acas.log");
    stat = fileSystem.statSync(pathToLogFile);
    res.writeHead(200, {
      'Content-Type': 'text/plain',
      'Content-Length': stat.size
    });
    readStream = fileSystem.createReadStream(pathToLogFile);
    return readStream.pipe(res);
  };

}).call(this);
