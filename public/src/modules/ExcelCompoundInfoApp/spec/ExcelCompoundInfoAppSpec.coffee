beforeEach ->
	@fixture = $.clone($("#fixture").get(0))
	window.logger =
		log: (message) ->
			console.log message
	window.Office =
		context:
			document:
				getSelectedDataAsync: (type, callback) ->
					callback(window.resultMockObject)

	window.successfulResultMockObject =
		status: 'succeeded'
		value: 'mockResultValue'

	window.unsuccessfulResultMockObject =
		status: 'failed'
		value: null
		error:
			name: "error message name"
			value: "mock error message"

afterEach ->
	$("#fixture").remove()
	$("body").append $(@fixture)

describe "Excel Compound Info App module testing", ->
	describe "Excel Compound Info App controller", ->
		beforeEach ->
			window.insertCompoundPropertiesController = new ExcelInsertCompoundPropertiesController
				el: $('.bv_excelInsertCompoundPropertiesView')
			insertCompoundPropertiesController.render()

		describe "Basic existence tests", ->
			it "should be defined", ->
				expect(insertCompoundPropertiesController).toBeDefined()

		describe "handleGetPropertiesClicked", ->
			it "should call fetchPrepared if result.status is 'succeeded'", ->
				window.resultMockObject = window.successfulResultMockObject
				spyOn insertCompoundPropertiesController, "fetchPreferred"
				insertCompoundPropertiesController.handleGetPropertiesClicked()
				expect(insertCompoundPropertiesController.fetchPreferred).toHaveBeenCalled()

			it "should not call fetchPrepared if result.status is not 'succeeded'", ->
				window.resultMockObject = window.unsuccessfulResultMockObject
				spyOn insertCompoundPropertiesController, "fetchPreferred"
				insertCompoundPropertiesController.handleGetPropertiesClicked()
				expect(insertCompoundPropertiesController.fetchPreferred).not.toHaveBeenCalled()