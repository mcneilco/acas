class PickList extends Backbone.Model

class PickListList extends Backbone.Collection
	model: PickList

	comparator: (model) ->
		displayOrder = model.get('displayOrder')
		if displayOrder?
			displayOrder
		else
			model.get("name")?.toLowerCase()

	setType: (type) ->
		@type = type

	getModelWithId: (id) ->
		@detect (enu) ->
			enu.get("id") is id

	getModelWithCode: (code) ->
		@detect (enu) ->
			enu.get("code") is code

	getNewModels: () ->
		@filter (pl) ->
			pl.isNew()

	getCurrent: ->
		@filter (pl) ->
			!(pl.get 'ignored')

class PickListOptionController extends Backbone.View
	tagName: "option"
	initialize: (options) ->
		@options = options

	render: =>
		$(@el).attr("value", @model.get("code")).text @model.get("name")
		@

class PickListOptionControllerForLsThing extends Backbone.View
	tagName: "option"
	initialize: (options) ->
		@options = options
		if @options.insertFirstOption?
			@insertFirstOption = @options.insertFirstOption
		else
			@insertFirstOption = null
		if @options.displayName?
			@displayName = @options.displayName
		else
			@displayName = null

	render: =>
		if @displayName != null
			if @displayName == 'corpName' or @displayName == 'corpName_notebook'
				unless @model.get('lsLabels') instanceof LabelList
					@model.set 'lsLabels', new LabelList @model.get('lsLabels')
				unless @model.get('lsStates') instanceof StateList
					@model.set 'lsStates', new StateList @model.get('lsStates')
				corpName = @model.get('lsLabels').getACASLsThingCorpName()
				if corpName?
					displayValue = corpName.get('labelText')
					if @displayName == 'corpName_notebook'
						notebookValue =  @model.get('lsStates').getOrCreateValueByTypeAndKind 'metadata', @model.get('lsKind')+' batch', 'stringValue', 'notebook'
						displayValue = displayValue + " " + notebookValue.get('stringValue')
				else
#Note: if some models in picklist don't have corpName, they will have their display value set to the name of the first option (ie "unassigned")
					displayValue = @insertFirstOption.get('name')
			else if @displayName is 'preferredName'
				unless @model.get('lsLabels') instanceof LabelList
					@model.set 'lsLabels', new LabelList @model.get('lsLabels')
				unless @model.get('lsStates') instanceof StateList
					@model.set 'lsStates', new StateList @model.get('lsStates')
				name = @model.get('lsLabels').pickBestName()
				if name?
					displayValue = name.get('labelText')
				else if @model.get('name')?
					displayValue = @model.get('name')
				else
					displayValue = @insertFirstOption.get('name')
			else if @model.get(@displayName)?
				displayValue = @model.get(@displayName)
			else
				displayValue = @insertFirstOption.get('name')
			$(@el).attr("value", @model.get("id")).text displayValue

		else
			preferredNames = _.filter @model.get('lsLabels'), (lab) ->
				lab.preferred && (lab.lsType == "name") && !lab.ignored
			bestName = _.max preferredNames, (lab) ->
				rd = lab.recordedDate
				(if (rd is "") then Infinity else rd)
			if bestName?
				displayValue = bestName.labelText
			else if @model.get('codeName')?
				displayValue = @model.get('codeName')
			else
				displayValue = @insertFirstOption.get('name')
			$(@el).attr("value", @model.get("id")).text displayValue

		@


class PickListSelectController extends Backbone.View
	initialize: (options) ->
		@rendered = false
		@collection.bind "add", @addOne.bind(@)
		@collection.bind "reset", @handleListReset.bind(@)
		# NOTE: Backbone 1.1.0 no longer automatically attaches options passed
		# to View constructors as this.options. So, in order to be compatible
		# with Backbone 1.0.0 and versions greater or equal to 1.1.0, we'll
		# attach it ourselves here.
		@options = options || {}

		unless @options.selectedCode is ""
			@selectedCode = @options.selectedCode
		else
			@selectedCode = null

		if @options.filters?
			@filters = @options.filters
		else
			@filters = []

		if @options.showIgnored?
			@showIgnored = @options.showIgnored
		else
			@showIgnored = false

		if @options.insertFirstOption?
			@insertFirstOption = @options.insertFirstOption
		else
			@insertFirstOption = null
		if @options.insertSecondOption?
			@insertSecondOption = @options.insertSecondOption
		else
			@insertSecondOption = null
		if @options.insertThirdOption?
			@insertThirdOption = @options.insertThirdOption
		else
			@insertThirdOption = null

		if @options.insertSelectedCode?
			@insertSelectedCode = @options.insertSelectedCode
		else
			@insertSelectedCode = false

		if @options.autoFetch?
			@autoFetch = @options.autoFetch
		else
			@autoFetch = true

		if @autoFetch == true && @collection.url?
			@collection.fetch
				success: @handleListReset.bind(@)
		else
			@handleListReset()

	handleListReset: =>
		if @insertThirdOption
			@collection.add @insertThirdOption,
				at: 0
				silent: true
		if @insertSecondOption
			@collection.add @insertSecondOption,
				at: 0
				silent: true
		if @insertFirstOption
			@collection.add @insertFirstOption,
				at: 0
				silent: true
			unless (@selectedCode is @insertFirstOption.get('code'))
				if @insertSelectedCode && (@collection.where({code: @selectedCode})).length is 0
					newOption = new PickList
						code: @selectedCode
						name: @selectedCode
					@collection.add newOption
		# Apply any filters on the collection
		@applyFilters()
		@render()

	render: =>
		$(@el).empty()
		self = this
		@collection.each (enm) =>
			@addOne enm

		# If selected code is set and also not filtered then set the selected code
		# otherwise set the selected code to the current value
		if @selectedCode && @checkOptionInCollectionAndNotFiltered(@selectedCode)?
			$(@el).val @selectedCode
		else
			@selectedCode = @getSelectedCode()
		
		# hack to fix IE bug where select doesn't work when dynamically inserted
		$(@el).hide()
		$(@el).show()
		@rendered = true

	addOne: (enm) =>
		shouldRender = true

		# Only filter if filtered is set and true
		# If filter is not set, this will be false
		if enm.get('filtered') == true
			shouldRender = false
		else
			if enm.get 'ignored'
				if @showIgnored
					shouldRender = true
				else
					shouldRender = false
					if @selectedCode?
						if @selectedCode is enm.get 'code'
							shouldRender = true
			else
				shouldRender = true

		if shouldRender
			$(@el).append new PickListOptionController(model: enm).render().el

	setSelectedCode: (code) ->
		@selectedCode = code
		#		$(@el).val @selectedCode  if @rendered
		if @rendered
			$(@el).val @selectedCode
		else
			"not done"

	getSelectedCode: ->
		$(@el).val()

	getSelectedModel: ->
		model = @collection.getModelWithCode @getSelectedCode()
		model.unset('filtered')
		return model

	removeFilters: () ->
		# Remove all filters (needs a rerender to be applied)
		@collection.map (pl) ->
			pl.set('filtered', false)

	addFilter: (filter) ->
		@filters.push(filter)

	applyFilters: ->
		# Remove current filters
		@removeFilters()

		#Apply all current filters
		@filters.forEach (filter) =>
			@collection.map (pl) ->
				if pl.get('name').toLowerCase().indexOf(filter.text) > -1
					pl.set('filtered', true)
				else
					pl.set('filtered', false)

	checkOptionInCollectionAndNotFiltered: (code) => #checks to see if option already exists in the picklist list
		return @collection.filter (item) ->
			return (item.code == code && item.ignored == false && (!item.filtered? || item.filtered == false))

	checkOptionInCollection: (code) => #checks to see if option already exists in the picklist list
		return @collection.findWhere({code: code})

class PickListForLsThingsSelectController extends PickListSelectController

	initialize: (options) ->
		super(options)
		if @options.displayName? #examples are codeName, corpName
			@displayName = @options.displayName
		else
			@displayName = null

	handleListReset: =>
		if @insertFirstOption
			@collection.add @insertFirstOption,
				at: 0
				silent: true
			unless (@selectedCode is @insertFirstOption.get('code'))
				if (@collection.where({id: @selectedCode})).length is 0
					newOption = new PickList
						id: @selectedCode
						name: @selectedCode
					@collection.add newOption
		@render()

	addOne: (enm) =>
		shouldRender = @showIgnored
		if enm.get 'ignored'
			if @selectedCode?
				if @selectedCode is enm.get 'code'
					shouldRender = true
		else
			shouldRender = true

		if shouldRender
			$(@el).append new PickListOptionControllerForLsThing(model: enm, insertFirstOption: @insertFirstOption, displayName: @displayName).render().el


	getSelectedModel: ->
		@collection.getModelWithId parseInt(@getSelectedCode())

class ComboBoxController extends PickListSelectController

	handleListReset: =>
		super()
		$(@el).combobox
			bsVersion: '2'


class PickListSelect2Controller extends PickListSelectController

	# maps the 'code' property to the select2 required 'id' property and
	# the 'name' property to the select2 required 'text' property
	acasPropertyMap = 
		id: 'code'
		text: 'name'

	# @param options.propertyMap String ('select2' or 'acas', where 'select2'
	# does no mapping and 'acas' uses the 'acasPropertyMap' defined above) or
	# an Object with 'id' and 'text' properties to use.	 If
	# 'options.propertyMap' is not specified, it defaults to using the
	# 'acasPropertyMap'
	initialize: (options) ->
		if @options?.width?
			@width = @options.width
		else
			# Select2 https://select2.org/appearance#container-width
			# Uses the style attribute value if available, falling back to the computed element width as necessary.
			@width = "resolve"

		@propertyMap = acasPropertyMap
		if options.propertyMap?
			if _.isObject(options.propertyMap) and options.propertyMap.id? and options.propertyMap.text?
				@propertyMap = options.propertyMap
			else if options.propertyMap is 'select2'
				@propertyMap = null
			else if options.propertyMap isnt 'acas'				 
				throw new Error ('PickListSelect2Controller.initialize(): Invalid propertyMap value encountered')
		super(options)

	render: =>
		$(@el).empty()
		@collection.each (enm) =>
			@addOne enm

		# convert model objects to array of json objects which have 'id' and 'text' properties if propertyMap specified
		mappedData = []
		for obj in @collection.toJSON()
			if (not obj.ignored? or (obj.ignored is false) or (@showIgnored? and @showIgnored is true)) && (!obj.filtered? || obj.filtered == false)
				if @propertyMap?
					obj.id = obj[@propertyMap.id]
					obj.text = obj[@propertyMap.text]
				mappedData.push(obj)
		@placeholder = ""
		if @options?.placeholder?
			@placeholder = @options.placeholder

		# Define the base options
		select2Options = 
			placeholder: @placeholder
			data: mappedData
			openOnEnter: false
			allowClear: true
			width: @width

		# Conditionally add the ajax property
		if @collection.url?
			select2Options.ajax = 
				url: (params) =>
					if !params.term?
						params.term = ''
					# The URL parameter on for the code service may have e.g. shortName
					# as a a parameter, so we need to remove it from the URL
					# we use relative paths url in acas currently so we need to add the full path
					# to parse the url correctly
					urlObj = new URL(@collection.url, "http://localhost")
					searchParams = new URLSearchParams()
					searchParams.set('labelTextSearchTerm', params.term)
					searchParams.set('maxHits', "100")
					urlStr = "#{urlObj.pathname}?#{searchParams.toString()}"
					return urlStr
				dataType: 'json'
				delay: 250
				processResults: (data, params) =>
					@latestData = data
					results = for option in data
						{id: option.code, text: option.name}
					return {results: results}

		# Initialize select2 with the options
		$(@el).select2(select2Options)
		
		@setSelectedCode @selectedCode
		@rendered = true
		@

	getSelectedCode: ->
		result = $(@el).val()
		# if result is null then we'll return the "unassigned" instead if it
		# was inserted as the first option
		if not result? and @insertFirstOption != false and @insertFirstOption.get('code') is "unassigned"
			result = "unassigned"
		result

	getSelectedCodeNotId: ->
		results = $(@el).select2('data')
		if results.length > 0
			results[0].code
		else
			if @insertFirstOption.get('code') is "unassigned"
				"unassigned"
			else
				null

	setSelectedCode: (code) ->
		if code?
			@selectedCode = code
			# Because it is a programmatic change, use 'change.select2' to only
			# trigger select2 change event
			# from https://github.com/select2/select2/issues/4159
			$(@el).val(@selectedCode).trigger("change.select2")


class AddParameterOptionPanel extends Backbone.Model
	defaults:
		parameter: null
		codeType: null
		codeOrigin: "ACAS DDICT"
		codeKind: null
		newOptionLabel: null
		newOptionDescription: null
		newOptionComments: null

	validate: (attrs) ->
		errors = []
		if attrs.newOptionLabel is null or attrs.newOptionLabel is ""
			errors.push
				attribute: 'newOptionLabel'
				message: "Label must be set"
		if errors.length > 0
			return errors
		else
			return null




class AddParameterOptionPanelController extends AbstractFormController
	template: _.template($("#AddParameterOptionPanelView").html())

	events:
		"change .bv_newOptionLabel": "attributeChanged"
		"change .bv_newOptionDescription": "attributeChanged"
		"change .bv_newOptionComments": "attributeChanged"
		"click .bv_addNewParameterOption": "triggerAddRequest" #.bv_addNewParameterOption adds the option to the picklist

	initialize: (options) ->
		@options = options
		@errorOwnerName = 'AddParameterOptionPanelController'
		@setBindings()


	render: =>
		$(@el).empty()
		$(@el).html @template()
		@$('.bv_addParameterOptionModal').on 'hidden.bs.modal', =>
			@trigger 'hideModal'
		@$('.bv_addParameterOptionModal').on 'show.bs.modal', =>
			@trigger 'showModal'
		@showModal()


		@

	showModal: =>
		@$('.bv_addParameterOptionModal').modal('show')
		parameterNameWithSpaces = @model.get('parameter').replace /([A-Z])/g,' $1'
		pascalCaseParameterName = (parameterNameWithSpaces).charAt(0).toUpperCase() + (parameterNameWithSpaces).slice(1)
		@$('.bv_parameter').html(pascalCaseParameterName)

	hideModal: ->
		@$('.bv_addParameterOptionModal').modal('hide')

	updateModel: =>
		@model.set
			newOptionLabel: UtilityFunctions::getTrimmedInput @$('.bv_newOptionLabel')
			newOptionDescription: UtilityFunctions::getTrimmedInput @$('.bv_newOptionDescription')
			newOptionComments: UtilityFunctions::getTrimmedInput @$('.bv_newOptionComments')

	triggerAddRequest: =>
		@trigger 'addOptionRequested'

	validationError: =>
		super()
		@$('.bv_addNewParameterOption').attr('disabled', 'disabled')

	clearValidationErrorStyles: =>
		super()
		@$('.bv_addNewParameterOption').removeAttr('disabled')



class EditablePickListSelectController extends Backbone.View
	template: _.template($("#EditablePickListView").html())

	#when creating new controller, need to provide el, collection, selectedCode, parameter, and roles
	#will also need to call render to show the controller
	events:
		"click .bv_addOptionBtn": "handleShowAddPanel"

	initialize: (options) ->
		@options = options

	render: =>
		$(@el).empty()
		$(@el).html @template()
		@setupEditablePickList()
		#		@setupContextMenu()
		@setupEditingPrivileges()


	setupEditablePickList: ->
		parameterNameWithSpaces = @options.parameter.replace /([A-Z])/g,' $1'
		pascalCaseParameterName = (parameterNameWithSpaces).charAt(0).toUpperCase() + (parameterNameWithSpaces).slice(1)
		if @pickListController?
			filters = @picklistController.filters
			@pickListController.remove()

		@pickListController = new PickListSelectController
			el: $(@el).find('.bv_parameterSelectList')
			collection: @collection
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Select "+pascalCaseParameterName
			selectedCode: @options.selectedCode

	setupEditingPrivileges: =>
		@editable = true
		if @options.editable?
			@editable = @options.editable
		
		if @editable
			if @options.roles?
				if UtilityFunctions::testUserHasRole window.AppLaunchParams.loginUser, @options.roles
					@$('.bv_tooltipWrapper').removeAttr('data-toggle')
					@$('.bv_tooltipWrapper').removeAttr('data-original-title')

				else
					@$('.bv_addOptionBtn').removeAttr('data-toggle')
					@$('.bv_addOptionBtn').removeAttr('data-target')
					@$('.bv_addOptionBtn').removeAttr('data-backdrop')
					@$('.bv_addOptionBtn').css({'color':"#cccccc"})
					@$('.bv_tooltipWrapper').tooltip()
					@$("body").tooltip selector: '.bv_tooltipWrapper'

			else
				@$('.bv_tooltipWrapper').removeAttr('data-toggle')
				@$('.bv_tooltipWrapper').removeAttr('data-original-title')
		else
			# This is set us not editable so remove the add option button
			@$('.bv_addOptionBtn').hide()

	getSelectedCode: ->
		@pickListController.getSelectedCode()

	setSelectedCode: (code) ->
		@pickListController.setSelectedCode(code)

	handleShowAddPanel: =>
		showPanel = false
		if @options.roles?
			if UtilityFunctions::testUserHasRole window.AppLaunchParams.loginUser, @options.roles
				showPanel = true
		else
			showPanel = true
		if showPanel
			unless @addPanelController?
				@addPanelController = new AddParameterOptionPanelController
					model: new AddParameterOptionPanel
						parameter: @options.parameter
						codeType: @options.codeType
						codeKind: @options.codeKind
					el: @$('.bv_addOptionPanel')
				@addPanelController.on 'addOptionRequested', @handleAddOptionRequested.bind(@)
				@addPanelController.on 'showModal', =>
					@trigger 'showModal'
				@addPanelController.on 'hideModal', =>
					@trigger 'hideModal'
			@addPanelController.render()


	handleAddOptionRequested: =>
# code and name are the same to keep capitalization
		requestedOptionModel = @addPanelController.model
		newOptionCode = requestedOptionModel.get('newOptionLabel')
		if @pickListController.checkOptionInCollection(newOptionCode) == undefined
			newPickList = new PickList
				code: newOptionCode #same as codeValue
				name: newOptionCode
				ignored: false
				codeType: requestedOptionModel.get('codeType')
				codeKind: requestedOptionModel.get('codeKind')
				codeOrigin: requestedOptionModel.get('codeOrigin')
				description: requestedOptionModel.get('newOptionDescription')
				comments: requestedOptionModel.get('newOptionComments')
			@pickListController.collection.add newPickList
			@pickListController.setSelectedCode(newPickList.get('code'))
			@trigger 'change'
			@$('.bv_errorMessage').hide()
			@addPanelController.hideModal()

		else
			@$('.bv_errorMessage').show()

		if @options.autoSave? && @options.autoSave
			@saveNewOption ()=>
				

	hideAddOptionButton: ->
		@$('.bv_addOptionBtn').hide()

	showAddOptionButton: ->
		@$('.bv_addOptionBtn').show()

	saveNewOption: (callback) =>
		code = @pickListController.getSelectedCode()
		unsavedModels = @pickListController.collection.getNewModels()
		unsavedModels = unsavedModels.filter (model) =>
			model.get('code') != "unassigned"
		if unsavedModels.length > 0
			modelToSave = unsavedModels[0]
			unless modelToSave.get('codeType')?
				modelToSave.set 'codeType', @options.codeType
			unless modelToSave.get('codeKind')?
				modelToSave.set 'codeKind', @options.codeKind
			$.ajax
				type: 'POST'
				url: "/api/codetables"
				data:
					JSON.stringify(codeEntry:(modelToSave))
				contentType: 'application/json'
				dataType: 'json'
				success: (response) =>
					callback.call()
				error: (err) =>
					alert 'could not add option to code table'
					@serviceReturn = null
		else
			callback.call()

	removeFilters: () ->
		@pickListController.removeFilters()

	addFilter: (filter) ->
		@pickListController.addFilter(filter)

	applyFilters: () =>
		@pickListController.applyFilters()

#	setupContextMenu: ->
#		$.fn.contextMenu = (settings) ->
#
#			# get left location of the context menu
#			getLeftLocation = (e) ->
#				relativeMouseWidth = e.pageX - $(window).scrollLeft()
#				absoluteMouseWidth = e.pageX
#				pageWidth = $(window).width()
#				menuWidth = $(settings.menuSelector).width()
#
#				if relativeMouseWidth + menuWidth > pageWidth and menuWidth < relativeMouseWidth
#					# opening menu would pass the side of the current view of the page
#					return absoluteMouseWidth - menuWidth
#				else
#					return absoluteMouseWidth
#
#			# get top location of the context menu
#			getTopLocation = (e) ->
#				relativeMouseHeight = e.pageY - $(window).scrollTop()
#				absoluteMouseHeight = e.pageY
#				pageHeight = $(window).height()
#				menuHeight = $(settings.menuSelector).height()
#
#				if relativeMouseHeight + menuHeight > pageHeight and menuHeight < relativeMouseHeight
#					# opening menu would pass the bottom of the current view of the page
#					return absoluteMouseHeight - menuHeight
#				else
#					return absoluteMouseHeight
#
#			return @each(->
#				$(this).on "contextmenu", (e) ->
#					$(settings.menuSelector).data("invokedOn", $(e.target)).show().css(
#						position: "absolute"
#						left: getLeftLocation(e)
#						top: getTopLocation(e)
#					).off("click").on "click", (e) ->
#						$(this).hide()
#						invokedOn = $(this).data("invokedOn")
#						$selectedMenu = $(e.target)
#						settings.menuSelected.call this, invokedOn, $selectedMenu
#
#					return false #hides the browser's generic context menu
#
#				$(document).click ->
#					$(settings.menuSelector).hide()
#
#			)
#		@$('.bv_addOptionBtn').contextMenu
#			menuSelector: ".bv_contextMenu"
#			menuSelected: (invokedOn, selectedMenu) ->
#				msg = "You selected the menu item '" + selectedMenu.text() + "' on the value '" + invokedOn.text() + "'"
#				alert msg

class EditablePickListSelect2Controller extends EditablePickListSelectController
	setupEditablePickList: ->
		plOptions =
			el: @$('.bv_parameterSelectList')
			collection: @collection
			selectedCode: @options.selectedCode
			filters: filters
			autoFetch: @options.autoFetch
		if @options.insertFirstOption
			plOptions.insertFirstOption = @options.insertFirstOption
		else if @options.parameter?
			# The parameter field gives a default first option based on the model key
			parameterNameWithSpaces = @options.parameter.replace /([A-Z])/g,' $1'
			pascalCaseParameterName = (parameterNameWithSpaces).charAt(0).toUpperCase() + (parameterNameWithSpaces).slice(1)
			plOptions.insertFirstOption = new PickList
				code: "unassigned"
				name: "Select "+pascalCaseParameterName
		if @pickListController?
			filters = @pickListController.filters
			@pickListController.remove()
		@pickListController = new PickListSelect2Controller plOptions

class ThingLabelComboBoxController extends PickListSelect2Controller

	initialize: (options) ->
		@options = options
		@thingType = @options.thingType
		@thingKind = @options.thingKind
		@labelType = if @options.labelType? then @options.labelType else null
		@placeholder = if @options.placeholder? then @options.placeholder else null
		@queryUrl = if @options.queryUrl? then @options.queryUrl else null
		if @options.sorter?
			@sorter = @options.sorter
		else
			@sorter = (data) ->
				data.sort( (a, b) ->
					if a.text.toUpperCase() > b.text.toUpperCase()
						return 1
					if a.text.toUpperCase() < b.text.toUpperCase()
						return -1
					return 0
				)

		unless @queryUrl? or (@thingType? and @thingKind?)
			alert("ThingLabelComboBoxController URL misconfigured - crash to follow")
		@$el.append('<option></option>')

	render: =>
		@selectController = @$el.select2
			placeholder: @placeholder
			openOnEnter: false
			allowClear: true
			ajax:
				url: (params) =>
					if !params.term?
						params.term = '%'
					params.term = encodeURIComponent params.term
					if @queryUrl?
						urlStr = @queryUrl + params.term
					else
						urlStr = "/api/getThingCodeTablesByLabelText/#{@thingType}/#{@thingKind}/#{params.term}"
					if @labelType?
						urlStr += "?labelType="+@labelType
					return urlStr
				dataType: 'json'
				delay: 250
				processResults: (data, params) =>
					@latestData = data
					results = for option in data
						{id: option.code, text: option.name}
					return {results: results}
			sorter: @sorter
		@

	getSelectedCode: ->
		result = @$el.val()
		# if result is null then we'll return the "unassigned" instead if it
		# was inserted as the first option
#		if not result? #and  @insertFirstOption.get('code') is "unassigned"
#			result = "unassigned"
		result

	getSelectedID: ->
		code = @getSelectedCode()
		match = _.where @latestData, code: code, ignored: false
		match[0]?.id

	getSelectedName: ->
		code = @getSelectedCode()
		match = _.where @latestData, code: code, ignored: false
		match[0]?.name

	setSelectedCode: (selection) ->
		newOption = $('<option selected="selected"></option>').val(selection.code).text(selection.label)
		@$el.append(newOption).trigger('change')