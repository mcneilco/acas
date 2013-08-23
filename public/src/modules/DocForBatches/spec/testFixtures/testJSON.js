(function(exports) {

	exports.docUploadWithFile = {
		id: 1234,
		url: "",
		currentFileName: "exampleUploadedFile.txt",
		docType: "file",
		description: "test description"
	};

	exports.docUploadWithURL = {
		id: 1234,
		url: "testURL",
		currentFileName: "",
		docType: "url",
		documentKind: "experiment",
		description: "test description"
	};

	exports.batchNameList = [
		{id: 11, requestName: "CMPD-0000007-01", preferredName: "CMPD-0000007-01", comment: "good"},
		{id: 12, requestName: "CMPD_1111", preferredName: "CMPD_1112", comment: "ok"},
		{id: 13, requestName: "CMPD_1111", preferredName: "CMPD_1113", comment: "bad"}
	];

	exports.docForBatches = {
		id: 1235,
		docUpload: exports.docUploadWithFile,
		batchNameList: exports.batchNameList
	};
	exports.docForBatchesWithURl = {
		id: 1235,
		docUpload: exports.docUploadWithURL,
		batchNameList: exports.batchNameList
	};
	exports.experiment = {
		"analysisGroups":[{
			"codeName":"AG-00037508",
			"id":76499,
			"ignored":false,
			"kind":"ACAS doc for batches",
			"lsTransaction":{
				"comments":"docForBatches upload",
				"id":554,
				"recordedDate":1369960071000,
				"version":0},
			"modifiedBy":null,
			"modifiedDate":null,
			"recordedBy":"bob",
			"recordedDate":1369960260000,
			"version":0}],
		"codeName":"EXPT-00000277",
		"experimentLabels":[{
			"id":35715,
			"ignored":false,
			"imageFile":null,
			"lsKind":"experiment name",
			"labelText":"EXPT-00000276",
			"lsType":"name",
			"lsTypeAndKind":"name_experiment name",
			"lsTransaction":{
				"comments":"docForBatches upload",
				"id":554,
				"recordedDate":1369960071000,
				"version":0},
			"modifiedDate":null,
			"physicallyLabled":false,
			"preferred":true,
			"recordedBy":"bob",
			"recordedDate":1369960072000,
			"version":0}],
		"experimentStates":[],
		"id":76498,
		"ignored":false,
		"kind":"ACAS doc for batches",
		"lsTransaction":{
			"comments":"docForBatches upload",
			"id":554,
			"recordedDate":1369960071000,
			"version":0},
		"modifiedBy":null,
		"modifiedDate":null,
		"protocol":{
			"codeName":"ACASdocForBatches",
			"id":2403,
			"ignored":false,
			"kind":null,
			"lsTransaction":{
				"comments":"docForBatches upload",
				"id":38,
				"recordedDate":1362677322000,
				"version":0},
			"modifiedBy":null,
			"modifiedDate":null,
			"recordedBy":"jmcneil",
			"recordedDate":1362677322000,
			"shortDescription":"ACAS Doc For Batches",
			"version":0},
		"recordedBy":"bob",
		"recordedDate":null,
		"shortDescription":"sdf",
		"version":0
	}

})((typeof process === 'undefined' || !process.versions)
   ? window.testJSON = window.testJSON || {}
   : exports);
