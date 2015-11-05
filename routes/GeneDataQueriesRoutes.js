(function() {
  exports.setupRoutes = function(app, loginRoutes) {
    var config;
    app.post('/api/geneDataQuery', loginRoutes.ensureAuthenticated, exports.getExperimentDataForGenes);
    app.post('/api/getGeneExperiments', loginRoutes.ensureAuthenticated, exports.getExperimentListForGenes);
    app.post('/api/getExperimentSearchAttributes', loginRoutes.ensureAuthenticated, exports.getExperimentSearchAttributes);
    app.post('/api/geneDataQueryAdvanced', loginRoutes.ensureAuthenticated, exports.getExperimentDataForGenesAdvanced);
    config = require('../conf/compiled/conf.js');
    app.get('/geneIDQuery', loginRoutes.ensureAuthenticated, exports.geneIDQueryIndex);
    app.get('/geneidquery/simpleSearch/:searchOptions', loginRoutes.ensureAuthenticated, exports.autoLaunchGeneIDSimpleSearch);
    return app.get('/geneidquery/filterByExpt/:searchOptions', loginRoutes.ensureAuthenticated, exports.autoLaunchGeneIDFilterByExptSearch);
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
          file = fs.createWriteStream('./privateTempFiles/' + filename);
          rem = request(urlPref + 'localhost:' + config.all.client.port + '/src/modules/GeneDataQueries/spec/testFiles/geneQueryResult.csv');
          rem.on('data', function(chunk) {
            return file.write(chunk);
          });
          return rem.on('end', function() {
            file.close();
            console.log("file written");
            return resp.json({
              fileURL: urlPref + "localhost:'+config.all.client.port+'/tempFiles/" + filename
            });
          });
        } else {
          config = require('../conf/compiled/conf.js');
          baseurl = config.all.client.service.rapache.fullpath + "getGeneData?format=CSV";
          request = require('request');
          return request({
            method: 'POST',
            url: baseurl,
            body: JSON.stringify(req.body),
            json: true
          }, (function(_this) {
            return function(error, response, json) {
              var dirName;
              if (!error && response.statusCode === 200) {
                dirName = 'gene' + crypto.randomBytes(4).readUInt32LE(0) + 'query';
                return fs.mkdir('./privateTempFiles/' + dirName, function(err) {
                  if (err) {
                    console.log('there was an error creating a gene id query directory');
                    console.log(err);
                    resp.end("gene query directory could not be saved");
                  } else {
                    filename = 'GeneQuery.csv';
                    fs.writeFile('./privateTempFiles/' + dirName + "/" + filename, json, function(err) {
                      if (err) {
                        console.log('there was an error saving a gene id query csv file');
                        console.log(err);
                        resp.end("File could not be saved");
                      } else {
                        if (config.all.client.use.ssl) {
                          urlPref = "https://";
                        } else {
                          urlPref = "http://";
                        }
                        resp.json({
                          fileURL: urlPref + config.all.client.host + ":" + config.all.client.port + "/tempfiles/" + dirName + "/" + filename
                        });
                      }
                    });
                  }
                });
              } else {
                console.log('got ajax error trying to get gene data csv from the server');
                console.log(error);
                console.log(json);
                return console.log(response);
              }
            };
          })(this));
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
          if (!error) {
            console.log(JSON.stringify(json));
            return resp.end(JSON.stringify(json));
          } else {
            console.log('got ajax error trying to query gene data');
            console.log(error.stack);
            return console.log(response);
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

  exports.autoLaunchGeneIDSimpleSearch = function(req, res) {
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
        searchMode: "simpleSearch",
        moduleLaunchParams: typeof moduleLaunchParams !== "undefined" && moduleLaunchParams !== null ? moduleLaunchParams : null,
        searchOptions: req.params.searchOptions != null ? req.params.searchOptions : null,
        deployMode: global.deployMode
      }
    });
  };

  exports.autoLaunchGeneIDFilterByExptSearch = function(req, res) {
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
        searchMode: "filterByExpt",
        moduleLaunchParams: typeof moduleLaunchParams !== "undefined" && moduleLaunchParams !== null ? moduleLaunchParams : null,
        searchOptions: req.params.searchOptions != null ? req.params.searchOptions : null,
        deployMode: global.deployMode
      }
    });
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
          rem = request(urlPref + 'localhost:' + config.all.client.port + '/src/modules/GeneDataQueries/spec/testFiles/geneQueryResult.csv');
          rem.on('data', function(chunk) {
            return file.write(chunk);
          });
          return rem.on('end', function() {
            file.close();
            return resp.json({
              fileURL: urlPref + "localhost:'+config.all.client.port+'/tempFiles/" + filename
            });
          });
        } else {
          config = require('../conf/compiled/conf.js');
          baseurl = config.all.client.service.rapache.fullpath + "getFilteredGeneData?format=CSV";
          request = require('request');
          return request({
            method: 'POST',
            url: baseurl,
            body: JSON.stringify(req.body),
            json: true
          }, (function(_this) {
            return function(error, response, json) {
              var dirName;
              if (!error && response.statusCode === 200) {
                dirName = 'gene' + crypto.randomBytes(4).readUInt32LE(0) + 'query';
                return fs.mkdir('./privateTempFiles/' + dirName, function(err) {
                  if (err) {
                    console.log('there was an error creating a gene id query directory');
                    console.log(err);
                    resp.end("gene query directory could not be saved");
                  } else {
                    filename = 'GeneQuery.csv';
                    fs.writeFile('./privateTempFiles/' + dirName + "/" + filename, json, function(err) {
                      if (err) {
                        console.log('there was an error saving a gene id query csv file');
                        console.log(err);
                        resp.end("File could not be saved");
                      } else {
                        if (config.all.client.use.ssl) {
                          urlPref = "https://";
                        } else {
                          urlPref = "http://";
                        }
                        resp.json({
                          fileURL: urlPref + config.all.client.host + ":" + config.all.client.port + "/tempfiles/" + dirName + "/" + filename
                        });
                      }
                    });
                  }
                });
              } else {
                console.log('got ajax error trying to get gene data csv from the server');
                console.log(error);
                console.log(json);
                return console.log(response);
              }
            };
          })(this));
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
        baseurl = config.all.client.service.rapache.fullpath + "getFilteredGeneData";
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
