/* To install this Module
1) Add these lines to app.coffee:
# RunPrimaryAnalysisRoutes routes
runPrimaryAnalysisRoutes = require './routes/RunPrimaryAnalysisRoutes.js'
app.post '/api/primaryAnalysis/runPrimaryAnalysis', runPrimaryAnalysisRoutes.runPrimaryAnalysis

2) Add to index.coffee
 under applicationScripts:
  	#Primary Screen module
	'javascripts/src/PrimaryScreenExperiment.js'

  under specScripts
#Primary Screen module
'javascripts/spec/RunPrimaryScreenAnalysisServiceSpec.js'
'javascripts/spec/PrimaryScreenExperimentSpec.js'

3) in layout.jade
  // for PrimaryScreen module
 include ../public/src/modules/PrimaryScreen/src/client/PrimaryScreenExperiment.html
  // for serverAPI module
  include ../public/src/modules/serverAPI/src/client/Experiment.html
*/


(function() {
  var applicationScripts, requiredScripts;

  requiredScripts = ['/src/lib/jquery.min.js', '/src/lib/json2.js', '/src/lib/underscore.js', '/src/lib/backbone-min.js', '/src/lib/bootstrap/bootstrap-tooltip.js', '/src/lib/bootstrap-tagsinput/bootstrap-tagsinput.min.js', '/src/lib/jqueryFileUpload/js/vendor/jquery.ui.widget.js', '/src/lib/jqueryFileUpload/js/jquery.iframe-transport.js', '/src/lib/bootstrap/bootstrap.min.js', '/src/lib/jqueryFileUpload/tmpl.min.js', '/src/lib/jqueryFileUpload/js/jquery.iframe-transport.js', '/src/lib/jqueryFileUpload/js/jquery.fileupload.js', '/src/lib/jqueryFileUpload/js/jquery.fileupload-fp.js', '/src/lib/jqueryFileUpload/js/jquery.fileupload-ui.js', '/src/lib/jqueryFileUpload/js/locale.js', '/src/lib/jquery-ui-1.10.2.custom/js/jquery-ui-1.10.2.custom.min.js'];

  applicationScripts = ['/src/conf/configurationNode.js', '/javascripts/src/LSFileInput.js', '/javascripts/src/LSFileChooser.js', '/javascripts/src/LSErrorNotification.js', '/javascripts/src/AbstractFormController.js', '/javascripts/src/AbstractParserFormController.js', '/javascripts/src/BasicFileValidateAndSave.js', '/javascripts/src/PickList.js', '/javascripts/src/TagList.js', '/javascripts/src/Label.js', '/javascripts/src/AnalysisGroup.js', '/javascripts/src/Protocol.js', '/javascripts/src/Experiment.js', '/javascripts/src/DoseResponseAnalysis.js', '/javascripts/src/PrimaryScreenExperiment.js', '/javascripts/src/PrimaryScreenAppController.js', '/javascripts/src/DoseResponseAnalysis.js'];

  exports.primaryScreenExperimentIndex = function(request, response) {
    var scriptsToLoad;

    scriptsToLoad = requiredScripts.concat(applicationScripts);
    global.specRunnerTestmode = true;
    return response.render('PrimaryScreenExperiment', {
      title: 'Primary Screen Experiment',
      scripts: scriptsToLoad,
      appParams: {
        exampleParam: null
      }
    });
  };

  exports.runPrimaryAnalysis = function(request, response) {
    var serverUtilityFunctions;

    request.connection.setTimeout(600000);
    serverUtilityFunctions = require('./ServerUtilityFunctions.js');
    console.log(request.body);
    response.writeHead(200, {
      'Content-Type': 'application/json'
    });
    if (global.specRunnerTestmode) {
      return serverUtilityFunctions.runRFunction(request, "public/src/modules/PrimaryScreen/src/server/PrimaryAnalysisStub.R", "runPrimaryAnalysis", function(rReturn) {
        return response.end(rReturn);
      });
    } else {
      return serverUtilityFunctions.runRFunction(request, "public/src/modules/PrimaryScreen/src/server/PrimaryAnalysis.R", "runPrimaryAnalysis", function(rReturn) {
        return response.end(rReturn);
      });
    }
  };

}).call(this);
