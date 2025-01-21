class ACASBarcodeSELPreprocessor extends BasicFileValidateAndSaveController

	initialize: (options) ->
		@options = options
		@fileProcessorURL = "/aCASBarcodeSELPreprocessor/parseSEL"
		@errorOwnerName = 'ACASBarcodeSELPreprocessor'
		@loadReportFile = true
		@loadImagesFile = true
		@allowedFileTypes = ['csv', 'CSV']
		super(options)
		@$('.bv_moduleTitle').html('Convert Barcodes to Lot/Batch Names and Load Experiment')


