(function() {
  var applicationScripts, requiredScripts;

  requiredScripts = ['/src/lib/jquery.min.js', '/src/lib/json2.js', '/src/lib/underscore.js', '/src/lib/backbone-min.js', '/src/lib/bootstrap/bootstrap-tooltip.js', '/src/lib/jqueryFileUpload/js/vendor/jquery.ui.widget.js', '/src/lib/jqueryFileUpload/js/jquery.iframe-transport.js', '/src/lib/bootstrap/bootstrap.min.js', '/src/lib/jqueryFileUpload/tmpl.min.js', '/src/lib/jqueryFileUpload/js/jquery.iframe-transport.js', '/src/lib/jqueryFileUpload/js/jquery.fileupload.js', '/src/lib/jqueryFileUpload/js/jquery.fileupload-fp.js', '/src/lib/jqueryFileUpload/js/jquery.fileupload-ui.js', '/src/lib/jqueryFileUpload/js/locale.js', '/src/lib/jquery-ui-1.10.2.custom/js/jquery-ui-1.10.2.custom.min.js'];

  applicationScripts = ['/src/conf/configurationNode.js', '/src/conf/configuration.js', '/javascripts/src/LSFileInput.js', '/javascripts/src/LSFileChooser.js', '/javascripts/src/LSErrorNotification.js', '/javascripts/src/AbstractFormController.js', '/javascripts/src/BasicFileValidateAndSave.js', '/javascripts/src/Label.js', '/javascripts/src/AnalysisGroup.js', '/javascripts/src/Experiment.js', '/javascripts/src/Protocol.js', '/javascripts/src/PrimaryScreenExperiment.js', '/javascripts/src/DoseResponseAnalysis.js', 'javascripts/src/CurveCurator.js', 'javascripts/src/CurveCuratorAppController.js', '/javascripts/src/ModuleMenus.js', '/javascripts/src/ModuleLauncher.js', '/javascripts/src/ModuleMenusConfiguration.js', '/javascripts/src/BatchListValidator.js', '/javascripts/src/DocUpload.js', '/javascripts/src/DocForBatches.js', '/javascripts/src/DocForBatchesConfiguration.js', '/javascripts/src/GenericDataParser.js', '/javascripts/src/BulkLoadContainersFromSDF.js', '/javascripts/src/BulkLoadSampleTransfers.js', '/javascripts/src/PrimaryScreenExperiment.js'];

  exports.index = function(req, res) {
    var scriptsToLoad;

    global.specRunnerTestmode = false;
    scriptsToLoad = requiredScripts.concat(applicationScripts);
    return res.render('index', {
      title: "ACAS Home",
      scripts: scriptsToLoad,
      appParams: {
        loginUserName: req.user.username,
        testMode: false
      }
    });
  };

  exports.specRunner = function(req, res) {
    "use strict";
    var jasmineScripts, scriptsToLoad, specScripts;

    global.specRunnerTestmode = true;
    jasmineScripts = ['src/lib/testLibraries/jasmine-jstd-adapter/jasmine/lib/jasmine-core/jasmine.js', 'src/lib/testLibraries/jasmine-jstd-adapter/jasmine/lib/jasmine-core/jasmine-html.js', 'src/lib/testLibraries/jasmine-jquery/lib/jasmine-jquery.js', 'src/lib/testLibraries/sinon.js'];
    specScripts = ['javascripts/spec/dnsAuthenticationServiceSpec.js', 'javascripts/spec/PreferredBatchIdServiceSpec.js', 'javascripts/spec/ProtocolServiceSpec.js', 'javascripts/spec/ExperimentServiceSpec.js', 'javascripts/spec/LabelSpec.js', 'javascripts/spec/ExperimentSpec.js', 'javascripts/spec/ProtocolSpec.js', 'javascripts/spec/AnalysisGroupSpec.js', 'javascripts/spec/testFixtures/ExperimentServiceTestJSON.js', 'javascripts/spec/testFixtures/ProtocolServiceTestJSON.js', 'javascripts/spec/RunPrimaryScreenAnalysisServiceSpec.js', 'javascripts/spec/PrimaryScreenExperimentSpec.js', 'javascripts/spec/DoseResponseAnalysisSpec.js', 'javascripts/spec/CurveCuratorServiceSpec.js', 'javascripts/spec/CurveCuratorSpec.js', 'javascripts/spec/testFixtures/curveCuratorTestFixtures.js', 'javascripts/spec/ModuleMenusSpec.js', 'javascripts/spec/ModuleLauncherSpec.js', 'javascripts/spec/LSFileInputSpec.js', 'javascripts/spec/LSFileChooserSpec.js', 'javascripts/spec/LSErrorNotificationSpec.js', 'javascripts/spec/ProjectsServiceSpec.js', 'src/modules/DocForBatches/spec/testFixtures/testJSON.js', 'javascripts/spec/BatchListValidatorSpec.js', 'javascripts/spec/DocUploadSpec.js', 'javascripts/spec/DocForBatchesSpec.js', 'javascripts/spec/DocForBatchesServiceSpec.js', 'javascripts/spec/GenericDataParserSpec.js', 'javascripts/spec/GenericDataParserServiceSpec.js', 'javascripts/spec/BulkLoadContainersFromSDFSpec.js', 'javascripts/spec/BulkLoadContainersFromSDFServerSpec.js', 'javascripts/spec/BulkloadSampleTransfersSpec.js', 'javascripts/spec/BulkloadSampleTransfersServerSpec.js', 'javascripts/spec/ServerUtilityFunctionsSpec.js'];
    scriptsToLoad = requiredScripts.concat(jasmineScripts, specScripts);
    scriptsToLoad = scriptsToLoad.concat(applicationScripts);
    return res.render('SpecRunner', {
      title: 'SeuratAddOns SpecRunner',
      scripts: scriptsToLoad,
      appParams: {
        loginUserName: 'jmcneil',
        testMode: true
      }
    });
  };

  exports.liveServiceSpecRunner = function(req, res) {
    "use strict";
    var jasmineScripts, scriptsToLoad, specScripts;

    global.specRunnerTestmode = false;
    jasmineScripts = ['src/lib/testLibraries/jasmine-jstd-adapter/jasmine/lib/jasmine-core/jasmine.js', 'src/lib/testLibraries/jasmine-jstd-adapter/jasmine/lib/jasmine-core/jasmine-html.js', 'src/lib/testLibraries/jasmine-jquery/lib/jasmine-jquery.js', 'src/lib/testLibraries/sinon.js'];
    specScripts = ['javascripts/spec/ProjectsServiceSpec.js', 'javascripts/spec/PreferredBatchIdServiceSpec.js', 'javascripts/spec/dnsAuthenticationServiceSpec.js'];
    scriptsToLoad = requiredScripts.concat(jasmineScripts, specScripts);
    scriptsToLoad = scriptsToLoad.concat(applicationScripts);
    return res.render('LiveServiceSpecRunner', {
      title: 'SeuratAddOns LiveServiceSpecRunner',
      scripts: scriptsToLoad,
      appParams: {
        loginUserName: 'jmcneil',
        testMode: false,
        liveServiceTest: true
      }
    });
  };

}).call(this);
