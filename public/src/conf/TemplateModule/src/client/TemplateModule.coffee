class window.Reagent extends Backbone.Model
	defaults:
		cas: null
		barcode: null
		vendor: null
		hazardCategory: null

	validate: (attrs) ->
		errors = []
		if attrs.barcode is "" or attrs.barcode is undefined
			errors.push
				attribute: 'barcode'
				message: "Barcode much be set"

		if errors.length > 0
			return errors
		else
			return null





class window.ReagentController extends AbstractFormController
	template: _.template($("#ReagentView").html())
	events:
		"change .bv_cas": "updateModel"
		"change .bv_barcode": "updateModel"

	initialize: ->
		@errorOwnerName = 'ReagentController'
		unless @model?
			@model = new Reagent()
		@setBindings()

	render: =>
		$(@el).empty()
		$(@el).html @template @model.attributes
		@setupHazardCategorySelect()

		@

	updateModel: =>
		@model.set
			cas: parseInt(@getTrimmedInput('.bv_cas'))
			barcode: @getTrimmedInput('.bv_barcode')

	setupHazardCategorySelect: ->
		@hazardCategoryList = new PickListList()
		@hazardCategoryList.url = "/api/reagentReg/hazardCatagories"
		@hazardCategoryListController = new PickListSelectController
			el: @$('.bv_hazardCategory')
			collection: @hazardCategoryList
			selectedCode: @model.get('hazardCategory')
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Select Category"
