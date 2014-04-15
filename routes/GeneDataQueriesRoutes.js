(function() {
  exports.setupRoutes = function(app, loginRoutes) {
    var config;
    app.post('/api/geneDataQuery', exports.getExperimentDataForGenes);
    app.post('/api/getGeneExperiments', exports.getExperimentListForGenes);
    app.post('/api/getExperimentSearchAttributes', exports.getExperimentSearchAttributes);
    app.post('/api/geneDataQueryAdvanced', exports.getExperimentDataForGenesAdvanced);
    config = require('../conf/compiled/conf.js');
    if (config.all.client.require.login) {
      return app.get('/geneIDQuery', loginRoutes.ensureAuthenticated, exports.geneIDQueryIndex);
    } else {
      return app.get('/geneIDQuery', exports.geneIDQueryIndex);
    }
  };

  exports.getExperimentDataForGenes = function(req, resp) {
    var baseurl, config, crypto, file, filename, fs, geneDataQueriesTestJSON, rem, request, requestError, responseObj, results, serverUtilityFunctions, urlPref;
    req.connection.setTimeout(600000);
    serverUtilityFunctions = require('./ServerUtilityFunctions.js');
    request = require('request');
    fs = require('fs');
    crypto = require('crypto');
    config = require('../conf/compiled/conf.js');
    if (req.query.format != null) {
      if (req.query.format === "csv") {
        if (global.specRunnerTestmode) {
          if (config.all.client.use.ssl) {
            urlPref = "https://";
          } else {
            urlPref = "http://";
          }
          filename = 'gene' + crypto.randomBytes(4).readUInt32LE(0) + 'query.csv';
          console.log(filename);
          file = fs.createWriteStream('./privateTempFiles/' + filename);
          rem = request(urlPref + 'localhost:3000/src/modules/GeneDataQueries/spec/testFiles/geneQueryResult.csv');
          rem.on('data', function(chunk) {
            return file.write(chunk);
          });
          return rem.on('end', function() {
            file.close();
            console.log("file written");
            return resp.json({
              fileURL: urlPref + "localhost:3000/tempFiles/" + filename
            });
          });
        } else {
          baseurl = config.all.client.service.rapache.fullpath + "getGeneData?format=CSV";
          return request({
            method: 'POST',
            url: baseurl,
            body: req.body
          }).pipe(resp);
        }
      } else {
        return console.log("format requested not supported");
      }
    } else {
      resp.writeHead(200, {
        'Content-Type': 'application/json'
      });
      if (global.specRunnerTestmode) {
        console.log("test mode: " + global.specRunnerTestmode);
        geneDataQueriesTestJSON = require('../public/javascripts/spec/testFixtures/GeneDataQueriesTestJson.js');
        requestError = req.body.maxRowsToReturn < 0 ? true : false;
        if (req.body.geneIDs === "fiona") {
          results = geneDataQueriesTestJSON.geneIDQueryResultsNoneFound;
        } else {
          results = geneDataQueriesTestJSON.geneIDQueryResults;
        }
        responseObj = {
          results: results,
          hasError: requestError,
          hasWarning: true,
          errorMessages: [
            {
              errorLevel: "warning",
              message: "some genes not found"
            }
          ]
        };
        if (requestError) {
          responseObj.errorMessages.push({
            errorLevel: "error",
            message: "start offset outside allowed range, please speake to an administrator"
          });
        }
        return resp.end(JSON.stringify(responseObj));
      } else {
        baseurl = config.all.client.service.rapache.fullpath + "getGeneData/";
        return request({
          method: 'POST',
          url: baseurl,
          body: req.body,
          json: true
        }, (function(_this) {
          return function(error, response, json) {
            console.log(response.statusCode);
            if (!error) {
              console.log(JSON.stringify(json));
              return resp.end(JSON.stringify(json));
            } else {
              console.log('got ajax error trying to query gene data');
              console.log(error);
              return console.log(resp);
            }
          };
        })(this));
      }
    }
  };

  exports.getExperimentListForGenes = function(req, resp) {
    var baseurl, config, geneDataQueriesTestJSON, request, requestError, responseObj, results, serverUtilityFunctions;
    req.connection.setTimeout(600000);
    serverUtilityFunctions = require('./ServerUtilityFunctions.js');
    resp.writeHead(200, {
      'Content-Type': 'application/json'
    });
    if (global.specRunnerTestmode) {
      console.log("test mode: " + global.specRunnerTestmode);
      geneDataQueriesTestJSON = require('../public/javascripts/spec/testFixtures/GeneDataQueriesTestJson.js');
      requestError = req.body.maxRowsToReturn < 0 ? true : false;
      if (req.body.geneIDs === "fiona") {
        results = geneDataQueriesTestJSON.getGeneExperimentsNoResultsReturn;
      } else {
        results = geneDataQueriesTestJSON.getGeneExperimentsReturn;
      }
      responseObj = {
        results: results,
        hasError: requestError,
        hasWarning: true,
        errorMessages: [
          {
            errorLevel: "warning",
            message: "some genes not found"
          }
        ]
      };
      if (requestError) {
        responseObj.errorMessages.push({
          errorLevel: "error",
          message: "start offset outside allowed range, please speake to an administrator"
        });
      }
      return resp.end(JSON.stringify(responseObj));
    } else {
      config = require('../conf/compiled/conf.js');
      baseurl = config.all.client.service.rapache.fullpath + "getGeneExperiments/";
      request = require('request');
      return request({
        method: 'POST',
        url: baseurl,
        body: req.body,
        json: true
      }, (function(_this) {
        return function(error, response, json) {
          console.log(response.statusCode);
          if (!error) {
            console.log(JSON.stringify(json));
            return resp.end(JSON.stringify(json));
          } else {
            console.log('got ajax error trying to query gene data');
            console.log(error);
            return console.log(resp);
          }
        };
      })(this));
    }
  };

  exports.getExperimentSearchAttributes = function(req, resp) {
    var baseurl, config, geneDataQueriesTestJSON, request, requestError, responseObj, results, serverUtilityFunctions;
    req.connection.setTimeout(600000);
    serverUtilityFunctions = require('./ServerUtilityFunctions.js');
    resp.writeHead(200, {
      'Content-Type': 'application/json'
    });
    if (global.specRunnerTestmode) {
      console.log("test mode: " + global.specRunnerTestmode);
      geneDataQueriesTestJSON = require('../public/javascripts/spec/testFixtures/GeneDataQueriesTestJson.js');
      requestError = req.body.experimentCodes[0] === "error" ? true : false;
      if (req.body.experimentCodes[0] === "fiona") {
        results = geneDataQueriesTestJSON.experimentSearchOptionsNoMatches;
      } else {
        results = geneDataQueriesTestJSON.experimentSearchOptions;
      }
      responseObj = {
        results: results,
        hasError: requestError,
        hasWarning: true,
        errorMessages: [
          {
            errorLevel: "warning",
            message: "some warning"
          }
        ]
      };
      if (requestError) {
        responseObj.errorMessages.push({
          errorLevel: "error",
          message: "no experiment attributes found, please speake to an administrator"
        });
      }
      return resp.end(JSON.stringify(responseObj));
    } else {
      config = require('../conf/compiled/conf.js');
      baseurl = config.all.client.service.rapache.fullpath + "getExperimentFilters/";
      request = require('request');
      return request({
        method: 'POST',
        url: baseurl,
        body: req.body,
        json: true
      }, (function(_this) {
        return function(error, response, json) {
          console.log(response.statusCode);
          if (!error) {
            console.log(JSON.stringify(json));
            return resp.end(JSON.stringify(json));
          } else {
            console.log('got ajax error trying to query gene data');
            console.log(error);
            return console.log(resp);
          }
        };
      })(this));
    }
  };

  exports.geneIDQueryIndex = function(req, res) {
    var config, loginUser, loginUserName, scriptPaths, scriptsToLoad;
    scriptPaths = require('./RequiredClientScripts.js');
    config = require('../conf/compiled/conf.js');
    global.specRunnerTestmode = global.stubsMode ? true : false;
    scriptsToLoad = scriptPaths.requiredScripts.concat(scriptPaths.applicationScripts);
    if (config.all.client.require.login) {
      loginUserName = req.user.username;
      loginUser = req.user;
    } else {
      loginUserName = "nouser";
      loginUser = {
        id: 0,
        username: "nouser",
        email: "nouser@nowhere.com",
        firstName: "no",
        lastName: "user"
      };
    }
    return res.render('GeneIDQuery', {
      title: "Gene ID Query",
      scripts: scriptsToLoad,
      AppLaunchParams: {
        loginUserName: loginUserName,
        loginUser: loginUser,
        testMode: false,
        moduleLaunchParams: typeof moduleLaunchParams !== "undefined" && moduleLaunchParams !== null ? moduleLaunchParams : null,
        deployMode: global.deployMode
      }
    });
  };

  exports.getExperimentDataForGenesAdvanced = function(req, resp) {
    var baseurl, config, crypto, file, filename, fs, geneDataQueriesTestJSON, rem, request, requestError, responseObj, results, serverUtilityFunctions, urlPref;
    req.connection.setTimeout(600000);
    serverUtilityFunctions = require('./ServerUtilityFunctions.js');
    request = require('request');
    fs = require('fs');
    crypto = require('crypto');
    config = require('../conf/compiled/conf.js');
    if (config.all.client.use.ssl) {
      urlPref = "https://";
    } else {
      urlPref = "http://";
    }
    if (req.query.format != null) {
      if (req.query.format === "csv") {
        if (global.specRunnerTestmode) {
          filename = 'gene' + crypto.randomBytes(4).readUInt32LE(0) + 'query.csv';
          file = fs.createWriteStream('./privateTempFiles/' + filename);
          rem = request(urlPref + 'localhost:3000/src/modules/GeneDataQueries/spec/testFiles/geneQueryResult.csv');
          rem.on('data', function(chunk) {
            return file.write(chunk);
          });
          return rem.on('end', function() {
            file.close();
            return resp.json({
              fileURL: urlPref + "localhost:3000/tempFiles/" + filename
            });
          });
        } else {
          config = require('../conf/compiled/conf.js');
          baseurl = config.all.client.service.rapache.fullpath + "getFilteredGeneData?format=CSV";
          return request({
            method: 'POST',
            url: baseurl,
            body: req.body
          }).pipe(resp);
        }
      } else {
        return console.log("format requested not supported");
      }
    } else {
      resp.writeHead(200, {
        'Content-Type': 'application/json'
      });
      if (global.specRunnerTestmode) {
        console.log("test mode: " + global.specRunnerTestmode);
        geneDataQueriesTestJSON = require('../public/javascripts/spec/testFixtures/GeneDataQueriesTestJson.js');
        requestError = req.body.maxRowsToReturn < 0 ? true : false;
        if (req.body.queryParams.batchCodes === "fiona") {
          results = geneDataQueriesTestJSON.geneIDQueryResultsNoneFound;
        } else {
          results = geneDataQueriesTestJSON.geneIDQueryResults;
        }
        responseObj = {
          results: results,
          hasError: requestError,
          hasWarning: true,
          errorMessages: [
            {
              errorLevel: "warning",
              message: "some genes not found"
            }
          ]
        };
        if (requestError) {
          responseObj.errorMessages.push({
            errorLevel: "error",
            message: "start offset outside allowed range, please speake to an administrator"
          });
        }
        return resp.end(JSON.stringify(responseObj));
      } else {
        config = require('../conf/compiled/conf.js');
        baseurl = config.all.client.service.rapache.fullpath + "getFilteredGeneData/";
        return request({
          method: 'POST',
          url: baseurl,
          body: req.body,
          json: true
        }, (function(_this) {
          return function(error, response, json) {
            console.log(response.statusCode);
            if (!error) {
              console.log(JSON.stringify(json));
              return resp.end(JSON.stringify(json));
            } else {
              console.log('got ajax error trying to query gene data');
              console.log(error);
              return console.log(resp);
            }
          };
        })(this));
      }
    }
  };

}).call(this);
