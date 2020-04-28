class window.ACASFormAbstractFieldController extends Backbone.View
	###
		Launching controller must:
		- Initialize the model the correct object type
		- Call render then append this controller's new el to the launching controllers DOM
		- Supply the form's label text as an option formLabel, or call setFormLabel()

		Launching controller may:
		- set an option for required: true/false. Defaults to false
		- add a label class with addFormLabelClass() or set formLabelClass as an option
		- add an input class with addInputClass() or set inputClass as an option
		- if you want the AbstractFormController to set and clear validation style, call addControlGroupClass() or provide controlGroupClass as an option
		- set the placeholder text with placeholder option or setPlaceholder

		General:
		- All addXXXCLass() methods also have a removeXXXClass() method

	###

	tagName: "DIV"
	className: "control-group"

#Subclass to supply
#	template: _.template($("#ACASFormLSLabelFieldView").html())

	events: ->
		"keyup input": "handleInputChanged"
		"mouseover .label-tooltip": "handleToolTipMouseover"
		"mouseoff .label-tooltip": "handleToolTipMouseoff"

	initialize: ->
		@modelKey = @options.modelKey
		@thingRef = @options.thingRef
		@errorSet = false
		@userInputEvent = true
		@$('.label-tooltip').tooltip()

	getModel: ->
		if @thingRef instanceof Thing
			return @thingRef.get @modelKey
		else
			return @thingRef

	handleInputChanged: =>
		@checkEmptyAndRequired()
		@trigger 'formFieldChanged'

	checkEmptyAndRequired: ->
		if @required and @isEmpty() and !@errorSet
			@setError "required"

	isEmpty: ->
		empty = false
		mdl = @getModel()
		if mdl.has 'labelText'
			if mdl.get('labelText')=="" then empty = true
		else if mdl.has 'itxThing'
			if !mdl.get('itxThing').get('id') then empty = true
		else
			if mdl.get('value')=="" or !mdl.get('value')? or mdl.get('value')=="unassigned" then empty = true

		if mdl.get('ignored') then empty = true
		return empty

	render: =>
		$(@el).empty()
		$(@el).html @template()
		@applyOptions()
		@checkEmptyAndRequired()
		$(@el).addClass "bv_group_"+@modelKey

		@

#Subclass to extend
	afterRender: ->


	renderModelContent: =>
		@clearError()
		@checkEmptyAndRequired()

	setError: (message) ->
		@errorSet = true
		$(@el).addClass "error"
		@$('.help-inline').removeClass 'hide'
		@$('.help-inline').html message
		@trigger 'validationFail', message

	clearError: ->
		$(@el).removeClass "error"
		@$('.help-inline').addClass 'hide'
		@errorSet = false

	applyOptions: ->
		if @options.maxLabelLength?
			@maxLabelLength = @options.maxLabelLength
		if @options.formLabel?
			@setFormLabel @options.formLabel
		if @options.formLabelClass?
			@addFormLabelClass @options.formLabelClass
		if @options.formLabelOrientation?
			@setupFormLabelOrientation @options.formLabelOrientation
		if @options.formLabelTooltip?
			@setFormLabelTooltip @options.formLabelTooltip
			@showFormLabelTooltip()
		if @options.inputClass?
			@addInputClass @options.inputClass
		if @options.controlGroupClass?
			@addControlGroupClass @options.controlGroupClass
		if @options.placeholder?
			@setPlaceholder @options.placeholder
		if @options.firstSelectText?
			@firstSelectText = @options.firstSelectText
		if @options.tabIndex?
			@setTabIndex @options.tabIndex
		@required = if @options.required? then @options.required else false

	setFormLabel: (value) ->
		if @$('label .label-text').length
			@$('label .label-text').html value
		else
			@$('label').html value

	addFormLabelClass: (value) ->
		@$('label').addClass value

	setupFormLabelOrientation: (value) ->
		if value is "top"
			@$('label').removeClass 'control-label'
		# else set label to left, this is already the default
	
	setFormLabelTooltip: (value) ->
		@$('.label-tooltip').attr 'title', value
	
	showFormLabelTooltip: ->
		@$('.label-tooltip').removeClass 'hide'

	handleToolTipMouseover: ->
		@$('.label-tooltip').tooltip('show')

	handleToolTipMouseoff: ->
		@$('.label-tooltip').tooltip('hide')

	addInputClass: (value) ->
		@$('input').addClass value

	addControlGroupClass: (value) ->
		$(@el).addClass value

	removeFormLabelClass: (value) ->
		@$('label').removeClass value

	removeInputClass: (value) ->
		@$('input').removeClass value

	removeControlGroupClass: (value) ->
		$(@el).removeClass value

	setPlaceholder: (value) ->
		@$('input').attr 'placeholder', value

	disableInput: ->
		@$('input').attr 'disabled', 'disabled'

	enableInput: ->
		@$('input').removeAttr 'disabled'

	setTabIndex: (index) ->
		@$('input, select').attr  'tabindex', index

class window.ACASFormLSLabelFieldController extends ACASFormAbstractFieldController
	###
		Launching controller must:
		- Initialize the model with an LSLabel
    Do whatever else is required or optional in ACASFormAbstractFieldController
	###

	template: _.template($("#ACASFormLSLabelFieldView").html())
	maxLabelLength: 255

	handleInputChanged: =>
		@clearError()
		@userInputEvent = true
		value = UtilityFunctions::getTrimmedInput(@$('input'))

		# check
		@isValid value, (isValid) =>
			if isValid
				@clearError()
				if value != ""
					@getModel().set
						labelText: value
						ignored: false
				else
					@setEmptyValue()
			super()

	isValid: (value, callback) =>
		# if the value is empty, don't check for uniqueness, the form field should evaluate if this is required
		# so we don't need to do that here
		if(value == "") 
			callback true 
			return
		if @getModel().get("validationRegex")?
			regex = new RegExp(@getModel().get("validationRegex"));
			if !regex.test(value)
				@setError("label does not meet format requirements")
				callback false
				return
		if value.length > @maxLabelLength
				@setError("label is too long")
				@setEmptyValue()
				callback false
				return
		if @getModel().get("unique")? && @getModel().get("unique")
			@checkUnique value, (isUnique) =>
				callback isUnique
		else
			callback true

	checkUnique: (value, callback) ->
		$.ajax
			type: 'POST'
			url: "/api/getThingCodeByLabel/#{@getModel().get("thingType")}/#{@getModel().get("thingKind")}"
			data: 
				thingType: @getModel().get("thingType")
				thingKind: @getModel().get("thingKind")
				labelType: @getModel().get("lsType")
				labelKind: @getModel().get("lskind")
				requests: [requestName: value]
			dataType: 'json'
			error: (err) =>
				#codename is new
				@setError("error checking for unique labels")
				callback false 
				# @model.set codeName: codeName
			success: (json) =>
				# the route currently returns an ambiguous error if there are duplicates so give an ambigous error to the user but with a hint
				if typeof json is 'string'
					@setError("error checking for unique labels, possibly duplicates already exist")
					@setEmptyValue()
					callback false 
				else
					if json.results? && json.results[0]? && json.results[0].referenceName == ""
						@clearError()
						callback true
					else
						@setError("label must be unique")
						@setEmptyValue()
						callback false 
		
	setEmptyValue: ->
		@getModel().set
			labelText: ""
			ignored: true

	renderModelContent: =>
		@$('input').val @getModel().get('labelText')
		super()

class window.ACASFormLSNumericValueFieldController extends ACASFormAbstractFieldController
	###
		Launching controller must:
		- Initialize the model with an LSValue
    Do whatever else is required or optional in ACASFormAbstractFieldController
	###
	events: ->
		"keyup .bv_number": "handleInputChanged"

	template: _.template($("#ACASFormLSNumericValueFieldView").html())

	initialize: ->
		super()
		@userInputEvent = false

	applyOptions: ->
		super()
		if @options.toFixed?
			@toFixed = @options.toFixed

	render: =>
		super()
		if @getModel()? and @getModel().has('unitKind')
			@$('.bv_units').html @getModel().get('unitKind')
		@

	handleInputChanged: =>
		@clearError()
		@userInputEvent = true
		value = UtilityFunctions::getTrimmedInput(@$('input'))
		if value == ""
			@setEmptyValue()
		else
			numVal = parseFloat(value)
			if isNaN(numVal) or isNaN(Number(value))
				@setError("number required")
				@setEmptyValue()
			else
				@getModel().set
					value: numVal
					ignored: false
		super()
		@userInputEvent = false

	setEmptyValue: ->
		@getModel().set
			value: null
			ignored: true

	setInputValue: (inputValue) ->
		@$('.bv_number').val inputValue

	renderModelContent: =>
		unless @userInputEvent
			if @toFixed? and @getModel().get('value')?
				if !isNaN @getModel().get('value')
					@$('.bv_number').val @getModel().get('value').toFixed(@toFixed)
				else
					@$('.bv_number').val ""
			else
				@$('.bv_number').val @getModel().get('value')

		if @getModel().has 'unitKind'
			@$('.bv_units').html @getModel().get('unitKind')
		super()

class window.ACASFormLSCodeValueFieldController extends ACASFormAbstractFieldController
	###
		Launching controller must:
		- Initialize the model with an LSValue
    Do whatever else is required or optional in ACASFormAbstractFieldController
	###
	events: ->
		_.extend {}, super,
		"change select": "handleInputChanged"

	template: _.template($("#ACASFormLSCodeValueFieldView").html())

	applyOptions: ->
		super()
		if @options.url?
			@url = @options.url
		if @options.pickList?
			@pickList = @options.pickList

	handleInputChanged: =>
		@clearError()
		value = @pickListController.getSelectedCode()
		if value == "" or value=="unassigned"
			@setEmptyValue()
		else
			@getModel().set
				value: value
				ignored: false
			@showDescription()
		super()

	setEmptyValue: ->
		@getModel().set
			value: null
			ignored: true

	renderModelContent: =>
		@pickListController.setSelectedCode @getModel().get('value')
		@showDescription()
		super()

	setupSelect: ->
		mdl = @getModel()
		if @pickList?
			plOptions =
				el: @$('select')
				collection: @pickList
				selectedCode: mdl.get('value')
				parameter: @options.modelKey
				autoFetch: false
		else
			@pickList = new PickListList()
			if @url?
				@pickList.url = @url
			else
				@pickList.url = "/api/codetables/#{mdl.get 'codeType'}/#{mdl.get 'codeKind'}"
			plOptions =
				el: @$('select')
				collection: @pickList
				selectedCode: mdl.get('value')
				parameter: @options.modelKey
				codeType: mdl.get 'codeType'
				codeKind: mdl.get 'codeKind'

		if @options.insertUnassigned?
			if @options.insertUnassigned
				if @options.firstSelectText?
					plOptions.insertFirstOption = new PickList
						code: "unassigned"
						name: @options.firstSelectText
				else
					plOptions.insertFirstOption = new PickList
						code: "unassigned"
						name: "Select Category"

		@pickListController = new PickListSelectController plOptions
		@pickListController.render()


	render: =>
		super()
		@setupSelect()

		@

	disableInput: ->
		@$('select').attr 'disabled', 'disabled'

	enableInput: ->
		@$('select').removeAttr 'disabled'
	
	showDescription: ->
		if @options.showDescription? and @options.showDescription
			@clearDescription()
			if @pickListController.getSelectedModel()?
				desc = @pickListController.getSelectedModel().get('description')
				if desc?
					@setDescription(desc)
	
	setDescription: (message) ->
		@$('.desc-inline').removeClass 'hide'
		@$('.desc-inline').html message

	clearDescription: ->
		@$('.desc-inline').addClass 'hide'

class window.ACASFormLSThingInteractionFieldController extends ACASFormAbstractFieldController
	###
		Launching controller must:
		- Initialize the model with an LSInteraction
    Do whatever else is required or optional in ACASFormAbstractFieldController
	###
	events: ->
		_.extend {}, super,
		"change select": "handleInputChanged"

	template: _.template($("#ACASFormLSThingInteractionFieldView").html())

	applyOptions: ->
		super()
		if @options.thingType?
			@thingType = @options.thingType
		if @options.thingKind?
			@thingKind = @options.thingKind
		if @options.labelType?
			@labelType = @options.labelType
		if @options.queryUrl?
			@queryUrl = @options.queryUrl
		if @options.placeholder?
			@placeholder = @options.placeholder
		if @options.extendedLabel?
			@extendedLabel = @options.extendedLabel


	handleInputChanged: =>
		@clearError()
		if @userInputEvent
			thingID = @thingSelectController.getSelectedID()
			if thingID?
				@getModel().setItxThing id: thingID
				@getModel().set ignored: false
			else
				@setEmptyValue()
		super()

	setEmptyValue: ->
		@getModel().set ignored: true

	isEmpty: ->
		empty = true
		mdl = @getModel()
		iThing = @getModel().getItxThing()
		if iThing? and !mdl.get('ignored')
			if iThing.id?
				empty = false

		return empty

	renderModelContent: =>
		@userInputEvent = false
		if  @getModel()? and @getModel().getItxThing().id?
			labels = new LabelList @getModel().getItxThing().lsLabels
			if @extendedLabel? and @extendedLabel
				labelText = labels.getExtendedNameText()
			else
				labelText = labels.pickBestLabel().get('labelText')
			@thingSelectController.setSelectedCode
				code: @getModel().getItxThing().codeName
				label: labelText
			super()
		@userInputEvent = true

	setupSelect: ->
		opts =
			el: @$('select')
			placeholder: @placeholder
			labelType: @labelType
		if @queryUrl?
			opts.queryUrl = @queryUrl
		else
			opts.thingType = @thingType
			opts.thingKind = @thingKind
		@thingSelectController = new ThingLabelComboBoxController opts
		@thingSelectController.render()

	render: =>
		super()
		@setupSelect()

		@

	disableInput: ->
		@$('select').attr 'disabled', 'disabled'

	enableInput: ->
		@$('select').removeAttr 'disabled'


class window.ACASFormLSHTMLClobValueFieldController extends ACASFormAbstractFieldController
	###
		Launching controller must:
		- Initialize the model with an LSValue
    - You may include a rows option to set the height of the textarea
    Do whatever else is required or optional in ACASFormAbstractFieldController
	###

	template: _.template($("#ACASFormLSHTMLClobValueFieldView").html())

	applyOptions: ->
		super()
		if @options.rows?
			@rows = @options.rows
			@$('textarea').attr 'rows', @rows

	afterRender: ->
		@setupTinyMCE()

	textChanged: (content) ->
		@clearError()
		if content == ""
			@setEmptyValue()
		else
			@getModel().set
				value: content
				ignored: false

	setEmptyValue: ->
		@getModel().set
			value: ""
			ignored: true

	renderModelContent: =>
		if @editor?
			if @getModel().get('value')?
				@editor.setContent @getModel().get('value')
		else
			@contentToLoad = @getModel().get('value')
		super()

	setupTinyMCE: ->
		mdl = @getModel()
		cname = mdl.get('lsKind').replace(" ","")+"_"+mdl.cid
		selector = "."+cname
		@$('.bv_wysiwygEditor').addClass cname
		@wysiwygEditor = tinymce.init
			selector: selector
			inline: true
			setup: (editor) =>
				editor.on 'init', (e) =>
					@editor = editor
					if @contentToLoad?
						@editor.setContent @contentToLoad
					if @disableEditor?
						@editor.getBody().setAttribute('contenteditable', !@disableEditor)
						@editor.getBody().setAttribute('disabled', @disableEditor)
				editor.on 'change', (e) =>
					@textChanged editor.getContent()

	disableInput: ->
		if @editor?
			@editor.getBody().setAttribute('contenteditable', false)
			@editor.getBody().setAttribute('disabled', true)
		else
			@disableEditor = true

	enableInput: ->
		if @editor?
			@editor.getBody().setAttribute('contenteditable', true)
		else
			@disableEditor = false

class window.ACASFormLSStringValueFieldController extends ACASFormAbstractFieldController
	###
		Launching controller must:
		- Initialize the model with an LSValue
    Do whatever else is required or optional in ACASFormAbstractFieldController
	###

	template: _.template($("#ACASFormLSStringValueFieldView").html())

	handleInputChanged: =>
		@clearError()
		@userInputEvent = true
		value = UtilityFunctions::getTrimmedInput(@$('input'))
		if value == ""
			@setEmptyValue()
		else
			@getModel().set
				value: value
				ignored: false
		super()

	setEmptyValue: ->
		@getModel().set
			value: null
			ignored: true

	setInputValue: (inputValue) ->
		@$('input').val inputValue


	renderModelContent: =>
		@$('input').val @getModel().get('value')
		super()


class window.ACASFormLSDateValueFieldController extends ACASFormAbstractFieldController
	###
		Launching controller must:
		- Initialize the model with an LSValue
    Do whatever else is required or optional in ACASFormAbstractFieldController
	###

	template: _.template($("#ACASFormLSDateValueFieldView").html())
	events: ->
		_.extend {}, super,
		"change input": "handleInputChanged"
		"click .bv_dateIcon": "handleDateIconClicked"

	render: ->
		super()
		@$('input').datepicker();
		@$('input').datepicker( "option", "dateFormat", "yy-mm-dd" );

		@

	handleInputChanged: =>
		@clearError()
		@userInputEvent = true
		value = UtilityFunctions::convertYMDDateToMs(UtilityFunctions::getTrimmedInput(@$('input')))
		if value == "" || isNaN(value)
			@setEmptyValue()
		else
			@getModel().set
				value: value
				ignored: false
		super()

	setEmptyValue: ->
		@getModel().set
			value: null
			ignored: true

	renderModelContent: =>
		compDate = @getModel().get('value')
		if compDate?
			unless isNaN(compDate)
				@$('input').val UtilityFunctions::convertMSToYMDDate(compDate)
		super()

	handleDateIconClicked: =>
		@$('input').datepicker( "show" )


class window.ACASFormLSFileValueFieldController extends ACASFormAbstractFieldController
	###
		Launching controller must:
		- Initialize the model with an LSValue
    - Provide allowedFileTypes
    Do whatever else is required or optional in ACASFormAbstractFieldController
	###

	template: _.template($("#ACASFormLSFileValueFieldView").html())
	events: ->
		_.extend {}, super,
		"click .bv_deleteSavedFile": "handleDeleteSavedFile"

	applyOptions: ->
		super()
		if @options.allowedFileTypes?
			@allowedFileTypes = @options.allowedFileTypes
		else
			@allowedFileTypes = ['csv','xlsx','xls','png','jpeg']
		if @options.displayInline?
			@displayInline = @options.displayInline
		else
			@displayInline = false
		
	render: ->
		super()
		@setupFileController()

		@

	setEmptyValue: ->
		@getModel().set
			value: null
			ignored: true

	renderModelContent: =>
		@setupFileController()
		super()

	setupFileController: ->
		fileValue = @getModel().get('value')
		if @isEmpty()
			@createNewFileChooser()
			@$('.bv_deleteSavedFile').hide()
		else
			displayText = @getModel().get('comments')
			if !displayText?
				displayText = fileValue
			if @displayInline
				@$('.bv_file').html '<img src="'+window.conf.datafiles.downloadurl.prefix+fileValue+'" alt="'+ displayText+'">'
			else
				@$('.bv_file').html '<a href="'+window.conf.datafiles.downloadurl.prefix+fileValue+'">'+displayText+'</a>'
			@$('.bv_deleteSavedFile').show()

	createNewFileChooser: ->
		if @fileController?
			@fileController.render()
		else
			@fileController = new LSFileChooserController
				el: @$('.bv_file')
				maxNumberOfFiles: 1
				requiresValidation: false
				url: UtilityFunctions::getFileServiceURL()
				allowedFileTypes: @allowedFileTypes
				hideDelete: false
			@fileController.on 'amDirty', =>
				@trigger 'amDirty'
			@fileController.on 'amClean', =>
				@trigger 'amClean'
			@fileController.render()
			@fileController.on('fileUploader:uploadComplete', @handleFileUpload) #update model with filename
			@fileController.on('fileDeleted', @handleFileRemoved) #update model with filename

	handleFileUpload: (nameOnServer) =>
		@clearError()
		@getModel().set
			value: nameOnServer
			ignored: false

	handleFileRemoved: =>
		@setEmptyValue()
		@checkEmptyAndRequired()

	handleDeleteSavedFile: =>
		@handleFileRemoved()
		@$('.bv_deleteSavedFile').hide()
		@createNewFileChooser()

class window.ACASFormLSBooleanFieldController extends ACASFormAbstractFieldController
	###
		Launching controller must:
		- Initialize the model with an LSValue
		- Strongly recommended to use a codeValue of codeType: "boolean", codeKind: "boolean"
    Do whatever else is required or optional in ACASFormAbstractFieldController
	###

	template: _.template($("#ACASFormLSBooleanFieldView").html())
	events: ->
		_.extend {}, super,
		"change input": "handleInputChanged"

	render: ->
		super()
		@

	handleInputChanged: =>
		@clearError()
		@userInputEvent = true
		isChecked = @$('input').is(":checked")
		@getModel().set
			value: isChecked.toString()
			ignored: false
		super()

	setEmptyValue: ->
		@getModel().set
			value: null
			ignored: true

	renderModelContent: =>
		if @getModel().get('value') is "false"
			@$('input').removeAttr 'checked'
		else
			@$('input').attr 'checked', 'checked'
		super()