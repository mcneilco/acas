class window.ACASBarcodeSELPreprocessor extends BasicFileValidateAndSaveController

	initialize: ->
		@fileProcessorURL = "/aCASBarcodeSELPreprocessor/parseSEL"
		@errorOwnerName = 'ACASBarcodeSELPreprocessor'
		@loadReportFile = true
		@loadImagesFile = true
		@allowedFileTypes = ['csv', 'CSV']
		super()
		@$('.bv_moduleTitle').html('Convert Barcodes to Lot/Batch Names and Load Experiment')


