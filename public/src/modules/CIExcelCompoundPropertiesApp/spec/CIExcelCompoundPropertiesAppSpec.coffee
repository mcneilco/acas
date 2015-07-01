beforeEach ->
	@fixture = $.clone($("#fixture").get(0))
	window.logger =
		log: (message) ->
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
	describe "Attributes Controller", ->
		beforeEach ->
			@attributesController = new AttributesController
				el: $("#fixture")
			@attributesController.render()

		describe "Basic existence tests and defaults", ->
			it "should be defined", ->
				expect(@attributesController).toBeDefined()
			it "insert column headers and include requested ids should be checked by default", ->
				expect(@attributesController.$('.bv_insertColumnHeaders').attr("checked")).toEqual "checked"
				expect(@attributesController.$('.bv_includeRequestedID').attr("checked")).toEqual "checked"
	describe "Property Descriptor Controller", ->
		beforeEach ->
				@pdc = new  PropertyDescriptorController
					el: $("#fixture")
					model: new PropertyDescriptor window.parentPropertyDescriptorsTestJSON.parentPropertyDescriptors[0]
				@pdc.render()
		describe 'basic existence testing', (done) ->
			it "should have a Property Descriptor as a model", ->
				expect(@pdc.model instanceof PropertyDescriptor).toBeTruthy()
		describe 'rendering testing', () ->
			it "should set the description label to the models pretty name", ->
				modelPrettyName = @pdc.model.get('valueDescriptor').prettyName
				descriptorLabel =  @pdc.$('.bv_descriptorLabel').html()
				expect(descriptorLabel).toEqual(modelPrettyName)
			it "should set the description label title attribute to the models description", ->
				modelDescription = @pdc.model.get('valueDescriptor').description
				descriptorTitle =  @pdc.$('.bv_descriptorLabel').attr 'title'
				expect(descriptorTitle).toEqual(modelDescription)
		describe 'clicking on the property descriptor checkbox', () ->
			it "should trigger handleDescriptorCheckboxChanged", ->
				spyOn @pdc, "handleDescriptorCheckboxChanged"
				@pdc.delegateEvents()
				@pdc.$('.bv_propertyDescriptorCheckbox').click()
				expect(@pdc.handleDescriptorCheckboxChanged).toHaveBeenCalled()
	describe "Property Descriptor List Controller", ->
		beforeEach (done) ->
			setTimeout (->
				window.propertyDescriptorListController = new PropertyDescriptorListController
					el: $("#fixture")
					title: 'Parent Properties'
					url: '/api/compound/parent/property/descriptors'
				window.propertyDescriptorListController.on 'ready', ->
					window.propertyDescriptorListController.render()
					done()
				return
			), 100
			return
		describe 'basic existence testing', (done) ->
			it "should populate a collection", ->
				expect(window.propertyDescriptorListController.collection.length).toBeGreaterThan(0)
		describe 'basic rendering', (done) ->
			it "should have a title", ->
				expect(window.propertyDescriptorListController.$('.propertyDescriptorListControllerTitle').html()).toEqual 'Parent Properties'
			it "should render the property descriptor list", ->
				expect(window.propertyDescriptorListController.$('.bv_propertyDescriptorList .bv_descriptorLabel').length).toBeGreaterThan(0)

	describe "Excel Compound Info App controller", ->
		beforeEach (done) ->
			setTimeout (->
				window.insertCompoundPropertiesController = new ExcelInsertCompoundPropertiesController
					el: $("#fixture")
				window.insertCompoundPropertiesController.render()
				window.insertCompoundPropertiesController.batchPropertyDescriptorListController.on 'ready', ->
					done()
				return
			), 100
			return
#		beforeEach (done)->
#			window.insertCompoundPropertiesController = new ExcelInsertCompoundPropertiesController
#				el: $("#fixture")
#
#			insertCompoundPropertiesController.render()
		describe "Basic existence tests", ->
			it "should be defined", ->
				expect(insertCompoundPropertiesController).toBeDefined()
				expect(insertCompoundPropertiesController.attributesController).toBeDefined()
				expect(insertCompoundPropertiesController.parentPropertyDescriptorListController).toBeDefined()
				expect(insertCompoundPropertiesController.batchPropertyDescriptorListController).toBeDefined()
		describe "getSelectedProperties", ->
			it "should return an array of properties with a batch and parent key", ->
				window.insertCompoundPropertiesController.$('.bv_batchProperties .bv_propertyDescriptorList .bv_propertyDescriptorCheckbox')[0].click()
				window.insertCompoundPropertiesController.$('.bv_batchProperties .bv_propertyDescriptorList .bv_propertyDescriptorCheckbox')[1].click()
				window.insertCompoundPropertiesController.$('.bv_parentProperties .bv_propertyDescriptorList .bv_propertyDescriptorCheckbox')[0].click()
				selectedProperties =  window.insertCompoundPropertiesController.getSelectedProperties()
				expect(selectedProperties.parent.length).toEqual(1)
				expect(selectedProperties.batch.length).toEqual(2)

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
