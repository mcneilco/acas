(function() {
  exports.setupRoutes = function(app, loginRoutes) {
    var config;
    app.post('/api/geneDataQuery', exports.getExperimentDataForGenes);
    config = require('../conf/compiled/conf.js');
    if (config.all.client.require.login) {
      return app.get('/geneIDQuery', loginRoutes.ensureAuthenticated, exports.geneIDQueryIndex);
    } else {
      return app.get('/geneIDQuery', exports.geneIDQueryIndex);
    }
  };

  exports.getExperimentDataForGenes = function(request, response) {
    var geneDataQueriesTestJSON, requestError, responseObj, results, serverUtilityFunctions;
    request.connection.setTimeout(600000);
    serverUtilityFunctions = require('./ServerUtilityFunctions.js');
    response.writeHead(200, {
      'Content-Type': 'application/json'
    });
    if (global.specRunnerTestmode) {
      console.log("test mode: " + global.specRunnerTestmode);
      geneDataQueriesTestJSON = require('../public/javascripts/spec/testFixtures/GeneDataQueriesTestJson.js');
      requestError = request.body.maxRowsToReturn < 0 ? true : false;
      if (request.body.geneIDs[0].gid === "fiona") {
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
      return response.end(JSON.stringify(responseObj));
    } else {
      console.log("test mode: " + global.specRunnerTestmode);
      geneDataQueriesTestJSON = require('../public/javascripts/spec/testFixtures/GeneDataQueriesTestJson.js');
      requestError = request.body.maxRowsToReturn < 0 ? true : false;
      if (request.body.geneIDs[0].gid === "fiona") {
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
      return response.end(JSON.stringify(responseObj));
    }
  };

  exports.geneIDQueryIndex = function(req, res) {
    var config, loginUser, loginUserName, scriptPaths, scriptsToLoad;
    scriptPaths = require('./RequiredClientScripts.js');
    config = require('../conf/compiled/conf.js');
    global.specRunnerTestmode = false;
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
      title: "Gene ID Queery",
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

}).call(this);
