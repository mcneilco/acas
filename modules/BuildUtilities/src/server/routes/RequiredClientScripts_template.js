exports.requiredScripts = [
	'/lib/jquery.min.js',
	'/lib/json2.js',
	'/lib/underscore-umd.js',
	'/lib/backbone-1.6.0/backbone-min.js',
	'/lib/jqueryFileUpload-10.32.0/js/vendor/jquery.ui.widget.js',
	'/lib/jqueryFileUpload-10.32.0/js/jquery.iframe-transport.js',
	'/lib/bootstrap-3.4.1-dist/js/bootstrap.min.js',
	'/lib/jqueryFileUpload/tmpl.min.js',
	'/lib/jqueryFileUpload-10.32.0/js/jquery.iframe-transport.js',
	'/lib/jqueryFileUpload-10.32.0/js/jquery.fileupload.js',
	'/lib/jqueryFileUpload-10.32.0/js/jquery.fileupload-process.js',
	'/lib/jqueryFileUpload-10.32.0/js/jquery.fileupload-ui.js',
	'/lib/jqueryFileUpload/js/locale.js',
	'/lib/jquery-ui-1.14.1.custom/jquery-ui.min.js',
	'/lib/bootstrap/bootstrap-tooltip.js',
	'/lib/bootstrap-tagsinput/bootstrap-tagsinput.min.js',
	'/lib/dataTables/js/dataTables.dataTables.min.js',
	'/lib/dataTables/js/lsThingSorting.js',
	'/lib/bootstrap/bootstrap-datatable.js',
	'/lib/bootstrap-combobox/js/bootstrap-combobox.js',
	'/lib/jsxgraph/jsxgraphcore.js',
	'/lib/jstree/jstree.min.js',
	'/lib/moment.min.js',
	'/lib/spin/js/spin.js',
	'/lib/spin/js/jquery-spin.js',
	'/lib/handsontable/handsontable.full.min.js',
	'/lib/select2-4.0.2/dist/js/select2.full.js',
	// Add the following four lines to use MarvinJSChemicalStructureController
	// '/CmpdReg/marvinjs/js/lib/rainbow/rainbow-custom.min.js',
	// '/CmpdReg/marvinjs/gui/lib/promise-1.0.0.min.js',
	// '/CmpdReg/marvinjs/js/marvinjslauncher.js',
	// '/CmpdReg/client/custom/marvinStructureTemplate.js',
	// The following line is for the Maestro sketcher
	'/CmpdReg/client/schrodinger/maestrosketcher/maestrosketcherlauncher.js',
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
	'/javascripts/src/Components/ACASFormFields.js',
	'/javascripts/src/Components/ACASFormStateTable.js',
	'/javascripts/src/Components/BasicFileValidateAndSave.js',
	'/javascripts/src/Components/BasicFileValidateReviewAndSave.js',
	'/javascripts/src/Components/BasicThingValidateAndSave.js',
	'/javascripts/src/Components/ACASThingBrowser.js',
	'/javascripts/src/Components/PickList.js',
	'/javascripts/src/CodeTablesAdmin/AbstractCodeTable.js',
	'/javascripts/src/CodeTablesAdmin/AbstractCodeTablesAdmin.js',
	'/javascripts/src/CodeTablesAdmin/AbstractCodeTablesAdminBrowser.js',
	'/javascripts/src/ServerAPI/Label.js',
	'/javascripts/src/ServerAPI/Thing.js',
	'/javascripts/src/ServerAPI/Container.js',
	'/javascripts/src/ServerAPI/Subject.js',
	'/javascripts/src/ServerAPI/BaseEntity.js',
	'/javascripts/src/ServerAPI/AnalysisGroup.js',
	'/javascripts/src/ServerAPI/AttachFile.js',
	'/javascripts/src/ServerAPI/Experiment.js',
	'/javascripts/src/ServerAPI/Protocol.js',
	'/javascripts/src/Standardization/Standardization.js'//APPLICATIONSCRIPTS_TO_BE_REPLACED_BY_PREPAREMODULEINCLUDES
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
