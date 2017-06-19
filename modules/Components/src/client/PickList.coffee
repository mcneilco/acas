class window.PickList extends Backbone.Model

class window.PickListList extends Backbone.Collection
	model: PickList

	setType: (type) ->
		@type = type

	getModelWithId: (id) ->
		@detect (enu) ->
			enu.get("id") is id

	getModelWithCode: (code) ->
		@detect (enu) ->
			enu.get("code") is code

	getCurrent: ->
		@filter (pl) ->
			!(pl.get 'ignored')

class window.PickListOptionController extends Backbone.View
	tagName: "option"
	initialize: ->

	render: =>
		$(@el).attr("value", @model.get("code")).text @model.get("name")
		@

class window.PickListOptionControllerForLsThing extends Backbone.View
	tagName: "option"
	initialize: ->
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


class window.PickListSelectController extends Backbone.View
	initialize: ->
		@rendered = false
		@collection.bind "add", @addOne
		@collection.bind "reset", @handleListReset

		unless @options.selectedCode is ""
			@selectedCode = @options.selectedCode
		else
			@selectedCode = null

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

		if @autoFetch == true
			@collection.fetch
				success: @handleListReset
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
		@render()

	render: =>
		$(@el).empty()
		self = this
		@collection.each (enm) =>
			@addOne enm

		$(@el).val @selectedCode  if @selectedCode

		# hack to fix IE bug where select doesn't work when dynamically inserted
		$(@el).hide()
		$(@el).show()
		@rendered = true

	addOne: (enm) =>
		shouldRender = @showIgnored
		if enm.get 'ignored'
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
		@collection.getModelWithCode @getSelectedCode()

	checkOptionInCollection: (code) => #checks to see if option already exists in the picklist list
		return @collection.findWhere({code: code})

class window.PickListForLsThingsSelectController extends PickListSelectController

	initialize: ->
		super()
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

class window.ComboBoxController extends PickListSelectController

	handleListReset: =>
		super()
		$(@el).combobox
			bsVersion: '2'


class window.PickListSelect2Controller extends PickListSelectController

	render: =>
# convert model objects to array of json objects which have 'id' and 'text' properties
		mappedData = []
		for obj in @collection.toJSON()
			if (not obj.ignored? or (obj.ignored is false) or (@showIgnored? and @showIgnored is true))
				obj.id = obj.id || obj.code
				obj.text = obj.text || obj.name
				mappedData.push(obj)

		$(@el).select2
			placeholder: ""
			data: mappedData
			openOnEnter: false
			allowClear: true
			width: "100%"

		@setSelectedCode @selectedCode
		@rendered = true
		@

	addOne: (enm) =>
# override to do nothing
		return

	getSelectedCode: ->
		result = $(@el).val()
		# if result is null then we'll return the "unassigned" instead if it
		# was inserted as the first option
		if not result? and  @insertFirstOption.get('code') is "unassigned"
			result = "unassigned"
		result

	setSelectedCode: (code) ->
		if code?
			@selectedCode = code
			# Because it is a programmatic change, use 'change.select2' to only
			# trigger select2 change event
			# from https://github.com/select2/select2/issues/4159
			$(@el).val(@selectedCode).trigger("change.select2")


class window.AddParameterOptionPanel extends Backbone.Model
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




class window.AddParameterOptionPanelController extends AbstractFormController
	template: _.template($("#AddParameterOptionPanelView").html())

	events:
		"change .bv_newOptionLabel": "attributeChanged"
		"change .bv_newOptionDescription": "attributeChanged"
		"change .bv_newOptionComments": "attributeChanged"
		"click .bv_addNewParameterOption": "triggerAddRequest" #.bv_addNewParameterOption adds the option to the picklist

	initialize: ->
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



class window.EditablePickListSelectController extends Backbone.View
	template: _.template($("#EditablePickListView").html())

	#when creating new controller, need to provide el, collection, selectedCode, parameter, and roles
	#will also need to call render to show the controller
	events:
		"click .bv_addOptionBtn": "handleShowAddPanel"

	render: =>
		$(@el).empty()
		$(@el).html @template()
		@setupEditablePickList()
		#		@setupContextMenu()
		@setupEditingPrivileges()


	setupEditablePickList: ->
		parameterNameWithSpaces = @options.parameter.replace /([A-Z])/g,' $1'
		pascalCaseParameterName = (parameterNameWithSpaces).charAt(0).toUpperCase() + (parameterNameWithSpaces).slice(1)
		@pickListController = new PickListSelectController
			el: @$('.bv_parameterSelectList')
			collection: @collection
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Select "+pascalCaseParameterName
			selectedCode: @options.selectedCode

	setupEditingPrivileges: =>
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
				@addPanelController.on 'addOptionRequested', @handleAddOptionRequested
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

	hideAddOptionButton: ->
		@$('.bv_addOptionBtn').hide()

	showAddOptionButton: ->
		@$('.bv_addOptionBtn').show()

	saveNewOption: (callback) =>
		code = @pickListController.getSelectedCode()
		selectedModel = @pickListController.collection.getModelWithCode(code)
		if selectedModel != undefined and selectedModel.get('code') != "unassigned"
			if selectedModel.get('id')?
				callback.call()
			else
				unless selectedModel.get('codeType')?
					selectedModel.set 'codeType', @options.codeType
				unless selectedModel.get('codeKind')?
					selectedModel.set 'codeKind', @options.codeKind
				$.ajax
					type: 'POST'
					url: "/api/codetables"
					data:
						JSON.stringify(codeEntry:(selectedModel))
					contentType: 'application/json'
					dataType: 'json'
					success: (response) =>
						callback.call()
					error: (err) =>
						alert 'could not add option to code table'
						@serviceReturn = null
		else
			callback.call()

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

class window.EditablePickListSelect2Controller extends EditablePickListSelectController
	setupEditablePickList: ->
		parameterNameWithSpaces = @options.parameter.replace /([A-Z])/g,' $1'
		pascalCaseParameterName = (parameterNameWithSpaces).charAt(0).toUpperCase() + (parameterNameWithSpaces).slice(1)
		@pickListController = new PickListSelect2Controller #TODO: need to fix addOne function to insert unassigned option as first option
			el: @$('.bv_parameterSelectList')
			collection: @collection
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Select "+pascalCaseParameterName
			selectedCode: @options.selectedCode

class window.ThingLabelComboBoxController extends Backbone.View

	initialize: ->
		@thingType = @options.thingType
		@thingKind = @options.thingKind
		@labelType = if @options.labelType? then @options.labelType else null
		@placeholder = if @options.placeholder? then @options.placeholder else null
		@queryUrl = if @options.queryUrl? then @options.queryUrl else null
		unless @queryUrl? or (@thingType? and @thingKind?)
			alert("ThingLabelComboBoxController URL misconfigured - crash to follow")

	render: =>
		@selectController = @$el.select2
			placeholder: @placeholder
			openOnEnter: false
			allowClear: true
			width: "100%"
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

	setSelectedCode: (selection) ->
		newOption = $('<option selected="selected"></option>').val(selection.code).text(selection.label)
		@$el.append(newOption).trigger('change')