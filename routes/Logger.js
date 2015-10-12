(function() {
  var config, db, winston, winstonLoggingOptions;

  config = require('./compiled/conf.js');

  winston = require('winston');

  require('winston-mongodb').MongoDB;

  exports.setupRoutes = function(app) {
    return true;
  };

  if (config.all.logging.usemongo) {
    db = require("mongojs").connect(config.all.logging.database, ["logs"]);
    db.createCollection("logs");
    winstonLoggingOptions = {
      db: config.all.logging.database
    };
    winston.add(winston.transports.MongoDB, winstonLoggingOptions);
  } else {
    winston.add(winston.transports.File, {
      filename: 'acas.log',
      json: false
    });
  }

  exports.writeToLog = function(logLevel, application, action, data, user, transactionId) {
    if (user === null || user === "") {
      user = "acas_system";
    }
    return winston.log(logLevel, {
      sourceApp: application,
      action: action,
      data: data,
      user: user,
      transactionId: transactionId
    });
  };

  exports.getUsers = function(callback) {
    var response;
    db = require("mongojs").connect(config.all.logging.database, ["logs"]);
    response = [];
    return db.logs.distinct('meta.user', function(err, sources) {
      sources.forEach(function(source) {
        return response.push({
          value: source
        });
      });
      return callback(response);
    });
  };

  exports.getApplicationSources = function(callback) {
    var response;
    db = require("mongojs").connect(config.all.logging.database, ["logs"]);
    response = [];
    return db.logs.distinct('meta.sourceApp', function(err, sources) {
      sources.forEach(function(source) {
        return response.push({
          value: source
        });
      });
      return callback(response);
    });
  };

  exports.queryLogs = function(queryPredicate, callback) {
    console.log("queryLogs");
    console.dir(queryPredicate);
    db = require("mongojs").connect(config.all.logging.database, ["logs"]);
    return db.logs.find(queryPredicate, function(err, logs) {
      return callback(logs);
    });
  };

  exports.getAllLogStatementsBetweenTimeStamps = function(start, end, callback) {
    console.log("start: " + start);
    console.log("end: " + end);
    start = new Date(parseInt(start));
    end = new Date(parseInt(end));
    console.log("start: " + start);
    console.log("end: " + end);
    db = require("mongojs").connect(config.all.logging.database, ["logs"]);
    return db.logs.find({
      timestamp: {
        $gte: start,
        $lt: end
      }
    }, function(err, logs) {
      return callback(logs);
    });
  };

  exports.getAllLogStatementsBeforeTimeStamp = function(timestamp, callback) {
    timestamp = new Date(parseInt(timestamp));
    db = require("mongojs").connect(config.all.logging.database, ["logs"]);
    return db.logs.find({
      timestamp: {
        $lte: timestamp
      }
    }, function(err, logs) {
      return callback(logs);
    });
  };

  exports.getAllLogStatementsAfterTimeStamp = function(timestamp, callback) {
    timestamp = new Date(parseInt(timestamp));
    db = require("mongojs").connect(config.all.logging.database, ["logs"]);
    return db.logs.find({
      timestamp: {
        $gte: timestamp
      }
    }, function(err, logs) {
      return callback(logs);
    });
  };

}).call(this);
