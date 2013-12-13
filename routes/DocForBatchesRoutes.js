/* To install this Module
1) Add these lines to app.coffee:
# DocForBatches routes
docForBatchesRoutes = require './routes/DoceForBatchesRoutes.js'
app.get '/docForBatches/*', docForBatchesRoutes.docForBatchesIndex
app.get '/docForBatches', docForBatchesRoutes.docForBatchesIndex
app.get '/api/docForBatches/:id', docForBatchesRoutes.getDocForBatches
app.post '/api/docForBatches', docForBatchesRoutes.saveDocForBatches

2) Add this line to public/src/modules/ModuleMenus/src/client/ModuleMenusConfiguration.coffee
{isHeader: false, menuName: "Annotate Batches with File", mainControllerClassName: "DocForBatchesController"}

3) Add these lines to routes/index.coffee under applicationScripts = [
# For DocForBatchesModule
'javascripts/src/BatchListValidator.js'
'javascripts/src/DocUpload.js'
'javascripts/src/DocForBatches.js'
'javascripts/src/DocForBatchesConfiguration.js'
'javascripts/src/AppController.js'
*/


(function() {
  var applicationScripts, fixturesData, requiredScripts;

  requiredScripts = ['/src/lib/jquery.min.js', '/src/lib/json2.js', '/src/lib/underscore.js', '/src/lib/backbone-min.js', '/src/lib/backbone-localstorage.js', '/src/lib/bootstrap/bootstrap-tooltip.js', '/src/lib/jqueryFileUpload/js/vendor/jquery.ui.widget.js', '/src/lib/jqueryFileUpload/js/jquery.iframe-transport.js', '/src/lib/bootstrap/bootstrap.min.js', '/src/lib/jqueryFileUpload/tmpl.min.js', '/src/lib/jqueryFileUpload/js/jquery.iframe-transport.js', '/src/lib/jqueryFileUpload/js/jquery.fileupload.js', '/src/lib/jqueryFileUpload/js/jquery.fileupload-fp.js', '/src/lib/jqueryFileUpload/js/jquery.fileupload-ui.js', '/src/lib/jqueryFileUpload/js/locale.js'];

  applicationScripts = ['/javascripts/src/Label.js', '/javascripts/src/AnalysisGroup.js', '/javascripts/src/Experiment.js', '/javascripts/src/LSFileInput.js', '/javascripts/src/LSFileChooser.js', '/javascripts/src/LSErrorNotification.js', '/javascripts/src/AbstractFormController.js', '/src/conf/configurationNode.js', '/javascripts/src/BatchListValidator.js', '/javascripts/src/DocUpload.js', '/javascripts/src/DocForBatches.js', '/javascripts/src/DocForBatchesConfiguration.js', '/javascripts/src/AppController.js'];

  fixturesData = require('../public/src/modules/DocForBatches/spec/testFixtures/testJSON.js');

  exports.docForBatchesIndex = function(request, response) {
    var scriptsToLoad;
    scriptsToLoad = requiredScripts.concat(applicationScripts);
    return response.render('docForBatchesIndex', {
      title: 'Document Annotation',
      scripts: scriptsToLoad,
      appParams: {
        loginUserName: 'jmcneil',
        testMode: false,
        liveServiceTest: true
      }
    });
  };

  exports.getDocForBatches = function(request, response) {
    if (request.params.id === "1") {
      return response.end(JSON.stringify(fixturesData.docForBatches));
    } else {
      return response.end(JSON.stringify(fixturesData.docForBatchesWithURl));
    }
  };

  exports.saveDocForBatches = function(request, response) {
    var serverUtilityFunctions;
    serverUtilityFunctions = require('./ServerUtilityFunctions.js');
    response.writeHead(200, {
      'Content-Type': 'application/json'
    });
    if (global.specRunnerTestmode) {
      return serverUtilityFunctions.runRFunction(request, "public/src/modules/DocForBatches/src/server/DocForBatches_Stub.R", "saveDocForBatches", function(rReturn) {
        return response.end(rReturn);
      });
    } else {
      return serverUtilityFunctions.runRFunction(request, "public/src/modules/DocForBatches/src/server/DocForBatches.R", "saveDocForBatches", function(rReturn) {
        return response.end(rReturn);
      });
    }
  };

}).call(this);
