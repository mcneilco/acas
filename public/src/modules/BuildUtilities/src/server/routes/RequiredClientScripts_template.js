exports.requiredScripts = [
	'/lib/jquery.min.js',
	'/lib/json2.js',
	'/lib/underscore.js',
	'/lib/backbone-min.js',
	'/lib/jqueryFileUpload/js/vendor/jquery.ui.widget.js',
	'/lib/jqueryFileUpload/js/jquery.iframe-transport.js',
	'/lib/bootstrap/bootstrap.min.js',
	'/lib/jqueryFileUpload/tmpl.min.js',
	'/lib/jqueryFileUpload/js/jquery.iframe-transport.js',
	'/lib/jqueryFileUpload/js/jquery.fileupload.js',
	'/lib/jqueryFileUpload/js/jquery.fileupload-fp.js',
	'/lib/jqueryFileUpload/js/jquery.fileupload-ui.js',
	'/lib/jqueryFileUpload/js/locale.js',
	'/lib/jquery-ui-1.10.2.custom/js/jquery-ui-1.10.2.custom.min.js',
	'/lib/bootstrap/bootstrap-tooltip.js',
	'/lib/bootstrap-tagsinput/bootstrap-tagsinput.min.js',
	'/lib/dataTables/js/jquery.dataTables.js',
	'/lib/bootstrap/bootstrap-datatable.js',
	'/lib/bootstrap-combobox/js/bootstrap-combobox.js',
	'/lib/jsxgraph/jsxgraphcore.js',
	'/lib/jstree/jstree.min.js',
	'/lib/moment.min.js',
	'/lib/spin/js/spin.js',
	'/lib/spin/js/jquery-spin.js'
];

exports.applicationScripts = [
	'/conf/conf.js',
	"/javascripts/src/UtilityFunctions.js",
	'/javascripts/src/LSFileInput.js',
	'/javascripts/src/LSFileChooser.js',
	'/javascripts/src/LSErrorNotification.js',
	'/javascripts/src/AbstractFormController.js',
	'/javascripts/src/AbstractParserFormController.js',
	'/javascripts/src/BasicFileValidateAndSave.js',
	'/javascripts/src/PickList.js',
	'/javascripts/src/Label.js',
	'/javascripts/src/Thing.js',
	'/javascripts/src/BaseEntity.js',
	'/javascripts/src/AnalysisGroup.js',
	'/javascripts/src/Experiment.js',
	'/javascripts/src/Protocol.js',
	"/javascripts/src/PrimaryScreenExperiment.js"//APPLICATIONSCRIPTS_TO_BE_REPLACED_BY_PREPAREMODULEINCLUDES
];

exports.jasmineScripts = [
	'lib/testLibraries/jasmine-jstd-adapter/jasmine/lib/jasmine-core/jasmine.js',
	'lib/testLibraries/jasmine-jstd-adapter/jasmine/lib/jasmine-core/jasmine-html.js',
	'lib/testLibraries/jasmine-jquery/lib/jasmine-jquery.js',
	'lib/testLibraries/sinon.js'
];

exports.specScripts = [
	'src/modules/DocForBatches/spec/testFixtures/testJSON.js',
	'javascripts/spec/ExperimentSpec.js',
	'javascripts/spec/BatchListValidatorSpec.js',
	'javascripts/spec/DocUploadSpec.js',
	'javascripts/spec/DocForBatchesSpec.js'//SPECSCRIPTS_TO_BE_REPLACED_BY_PREPAREMODULEINCLUDES
]
