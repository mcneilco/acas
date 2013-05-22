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


})((typeof process === 'undefined' || !process.versions)
   ? window.testJSON = window.testJSON || {}
   : exports);
