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
	'/lib/dataTables/js/lsThingSorting.js',
	'/lib/bootstrap/bootstrap-datatable.js',
	'/lib/bootstrap-combobox/js/bootstrap-combobox.js',
	'/lib/jsxgraph/jsxgraphcore.js',
	'/lib/jstree/jstree.min.js',
	'/lib/moment.min.js',
	'/lib/spin/js/spin.js',
	'/lib/spin/js/jquery-spin.js',
	'/lib/handsontable/dist/handsontable.full.js',
	'/lib/select2-4.0.3/dist/js/select2.full.js',
    '/socket.io/socket.io.js'
];

exports.applicationScripts = [
	'/conf/conf.js',
	"/javascripts/src/Components/UtilityFunctions.js",
	'/javascripts/src/Components/LSFileInput.js',
	'/javascripts/src/Components/LSFileChooser.js',
	'/javascripts/src/Components/LSErrorNotification.js',
	'/javascripts/src/Components/AbstractFormController.js',
	'/javascripts/src/Components/AbstractParserFormController.js',
	'/javascripts/src/Components/BasicFileValidateAndSave.js',
	'/javascripts/src/Components/BasicFileValidateReviewAndSave.js',
	'/javascripts/src/Components/PickList.js',
	'/javascripts/src/ServerAPI/Label.js',
	'/javascripts/src/ServerAPI/Thing.js',
	'/javascripts/src/ServerAPI/Container.js',
	'/javascripts/src/ServerAPI/Subject.js',
	'/javascripts/src/ServerAPI/BaseEntity.js',
	'/javascripts/src/ServerAPI/AnalysisGroup.js',
	'/javascripts/src/ServerAPI/Experiment.js',
	'/javascripts/src/ServerAPI/Protocol.js'//APPLICATIONSCRIPTS_TO_BE_REPLACED_BY_PREPAREMODULEINCLUDES
];

exports.jasmineScripts = [
	'lib/testLibraries/jasmine-jstd-adapter/jasmine/lib/jasmine-core/jasmine.js',
	'lib/testLibraries/jasmine-jstd-adapter/jasmine/lib/jasmine-core/jasmine-html.js',
	'lib/testLibraries/jasmine-jquery/lib/jasmine-jquery.js',
	'lib/testLibraries/sinon.js'
];

exports.specScripts = [
	'src/modules/DocForBatches/spec/testFixtures/testJSON.js',
	'javascripts/spec/ServerAPI/ExperimentSpec.js',
	'javascripts/spec/DocForBatches/BatchListValidatorSpec.js',
	'javascripts/spec/DocForBatches/DocUploadSpec.js',
	'javascripts/spec/DocForBatches/DocForBatchesSpec.js'//SPECSCRIPTS_TO_BE_REPLACED_BY_PREPAREMODULEINCLUDES
]
