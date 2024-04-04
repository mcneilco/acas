class ACASFormAbstractFieldController extends Backbone.View
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
		"keyup textarea": "handleInputChanged"
		"mouseover .label-tooltip": "handleToolTipMouseover"
		"mouseoff .label-tooltip": "handleToolTipMouseoff"

	initialize: (options) ->
		@options = options
		@modelKey = @options.modelKey
		@thingRef = @options.thingRef
		@errorSet = false
		@userInputEvent = true
		@$('.label-tooltip').tooltip()

	getModel: ->
		if @thingRef instanceof Thing or @thingRef instanceof BaseEntity
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

class ACASFormLSLabelFieldController extends ACASFormAbstractFieldController
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
				# Behavior of persistance layer on save is to look up auto label sequences based on 
				# thing lsTypeAndKind and label lsTypeAndKind
				# If the label text is "" or null then it will set the next auto sequence value
				# so in this case its ok to send "" and ignored = false
				if value != "" || @getModel().get("isAutoLabel") 
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

class ACASFormLSNumericValueFieldController extends ACASFormAbstractFieldController
	###
		Launching controller must:
		- Initialize the model with an LSValue
    Do whatever else is required or optional in ACASFormAbstractFieldController
	###
	events: ->
		"keyup .bv_number": "handleInputChanged"

	template: _.template($("#ACASFormLSNumericValueFieldView").html())

	initialize: (options) ->
		@options = options
		super(@options)
		@userInputEvent = false

	applyOptions: ->
		super()
		if @options.toFixed?
			@toFixed = @options.toFixed

	render: =>
		super()
		if @getModel()? and @getModel().has('unitKind')
			@$('.bv_units').html @getModel().escape('unitKind')
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
			@$('.bv_units').html @getModel().escape('unitKind')
		super()

class ACASFormLSCodeValueFieldController extends ACASFormAbstractFieldController
	###
		Launching controller must:
		- Initialize the model with an LSValue
    Do whatever else is required or optional in ACASFormAbstractFieldController
	###
	events: ->
		_.extend {}, super(),
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

		# Tell the picklist what the selected code should be
		# incase it re-renders it needs to have an update to date
		# value here.
		@pickListController.setSelectedCode(value)
		
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
		if @options.parameter?
			parameter = @options.parameter
		else
			parameter = @options.modelKey

		if @pickList?
			plOptions =
				el: @$('.bv_editablePicklist')
				collection: @pickList
				selectedCode: mdl.get('value')
				parameter: parameter
				autoFetch: false
		else
			@pickList = new PickListList()
			if @url?
				@pickList.url = @url
			else
				## Editable picklists can type ahead serch code tables
				## we want to first populate with the matching value only by adding a shortName parameter
				@pickList.url = "/api/codetables/#{mdl.get 'codeType'}/#{mdl.get 'codeKind'}/"
				if mdl.get('value')?
					@pickList.url = "#{@pickList.url}?shortName=#{mdl.get('value')}"
			plOptions =
				el: @$('.bv_editablePicklist')
				collection: @pickList
				selectedCode: mdl.get('value')
				parameter: parameter
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

		# Default is not editable picklist
		if @options.editablePicklist? && @options.editablePicklist
			plOptions.editable = true
		else
			plOptions.editable = false

		# Default is no role required to edit picklist
		if @options.editablePicklistRoles?
			plOptions.roles = @options.editablePicklistRoles

		# Default is to automatically save picklist items to the db
		# Otherwise the controller will need to explicitly tell editable picklist controller
		# to save the picklist items to the db.  This is because there is a use case to only save
		# the picklist items to the db when the user clicks the save button on the thing.
		plOptions.autoSave = true
		if @options.autoSavePickListItem? && !@options.autoSavePickListItem
			plOptions.autoSave = false

		plOptions.autoFetch = true
		if @options.autoFetch?
			plOptions.autoFetch = @options.autoFetch
		@pickListController = new EditablePickListSelect2Controller plOptions
		@pickListController.on('change', @handleInputChanged).bind(@)
		@pickListController.render()


	render: =>
		super()
		@setupSelect()

		@

	setSelectedCode: (code) =>
		@pickListController.setSelectedCode(code)

	applyFilter: (filter) =>
		# Remove the current filters if any
		@pickListController.removeFilters(false)

		# Add the new filter
		@addFilter(filter)

		# Apply the filters actually updates the collection items
		@pickListController.applyFilters()

		# Re-render the picklist once operations are complete
		@pickListController.render()

	addFilter: (filter) =>
		# Add a filter to the picklist
		@pickListController.addFilter(filter)

	removeFilters: (render) =>
		# Remove all filters 
		@pickListController.removeFilters()

		# Render if render not false
		if render != false
			@pickListController.render()

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
		@$('.desc-inline').html _.escape message

	clearDescription: ->
		@$('.desc-inline').addClass 'hide'

class ACASFormLSThingInteractionFieldController extends ACASFormAbstractFieldController
	###
		Launching controller must:
		- Initialize the model with an LSInteraction
    Do whatever else is required or optional in ACASFormAbstractFieldController
	###
	events: ->
		_.extend {}, super(),
		"change select": "handleInputChanged"

	initialize: (options) ->
		@options = options
		super(@options)

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
		if @options.sorter?
			@sorter = @options.sorter

	handleInputChanged: =>
		@clearError()
		if @userInputEvent
			thingID = @thingSelectController.getSelectedID()
			thingCodeName = @thingSelectController.getSelectedCode()
			thingLabel = @thingSelectController.getSelectedName()
			if thingID?
				@getModel().setItxThing id: thingID, codeName: thingCodeName, label: thingLabel
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
		model = @getModel()
		if model? and model instanceof ThingItx and model.getItxThing()?.id?
			labels = new LabelList model.getItxThing().lsLabels
			if labels.length > 0
				if @extendedLabel? and @extendedLabel
					labelText = labels.getExtendedNameText()
				else
					labelText = labels.pickBestLabel().get('labelText')
			else
				# If the interacting thing has no labels, then use the code name as a the users text label
				labelText = model.getItxThing().codeName
			@thingSelectController.setSelectedCode
				code: model.getItxThing().codeName
				label: labelText
			super()
		else
			# If the interaction has a code name and display name just use that as its likely not saved yet
			# and part of a picklist
			if model.firstLsThing?
				@thingSelectController.setSelectedCode
					code: model.firstLsThing.codeName
					label: model.firstLsThing.label
			else if model.secondLsThing?
				@thingSelectController.setSelectedCode
					code: model.secondLsThing.codeName
					label: model.secondLsThing.label
					
			super()
		@userInputEvent = true

	setupSelect: ->
		opts =
			el: @$('select')
			placeholder: @placeholder
			labelType: @labelType
			sorter: @sorter
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


class ACASFormLSHTMLClobValueFieldController extends ACASFormAbstractFieldController
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
		cname = mdl.get('lsKind').split(' ').join('')+"_"+mdl.cid
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
						if @disableEditor
							@editor.getBody().setAttribute('disabled', true)
						else
							@editor.getBody().removeAttribute('disabled')
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
			@editor.getBody().removeAttribute('disabled')
		else
			@disableEditor = false


class ACASFormLSClobValueFieldController extends ACASFormAbstractFieldController
	###
		Launching controller must:
		- Initialize the model with an LSValue
    Do whatever else is required or optional in ACASFormAbstractFieldController
	###

	template: _.template($("#ACASFormLSClobValueFieldView").html())

	applyOptions: ->
		super()
		if @options.rows?
			@rows = @options.rows
			@$('textarea').attr 'rows', @rows

	handleInputChanged: =>
		@clearError()
		@userInputEvent = true
		value = UtilityFunctions::getTrimmedInput(@$('textarea'))
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
		@$('textarea').val inputValue


	renderModelContent: =>
		@$('textarea').val @getModel().get('value')
		super()


class ACASFormLSStringValueFieldController extends ACASFormAbstractFieldController
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


class ACASFormLSDateValueFieldController extends ACASFormAbstractFieldController
	###
		Launching controller must:
		- Initialize the model with an LSValue
    Do whatever else is required or optional in ACASFormAbstractFieldController
	###

	template: _.template($("#ACASFormLSDateValueFieldView").html())
	events: ->
		_.extend {}, super(),
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

	disableInput: =>
		$(@el).off('click', '.bv_dateIcon');

class ACASFormLSFileValueFieldController extends ACASFormAbstractFieldController
	###
		Launching controller must:
		- Initialize the model with an LSValue
    - Provide allowedFileTypes
    Do whatever else is required or optional in ACASFormAbstractFieldController
	###

	template: _.template($("#ACASFormLSFileValueFieldView").html())
	events: ->
		_.extend {}, super(),
		"click .bv_deleteSavedFile": "handleDeleteSavedFile"

	initialize: (options)->
		super(options)
		@fileURL = UtilityFunctions::getFileServiceURL()

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
		if @options.maxFileSize?
			@maxFileSize = @options.maxFileSize
		
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
		fileValue = @getModel().escape('value')
		if @isEmpty()
			@createNewFileChooser()
			@$('.bv_deleteSavedFile').hide()
		else
			displayText = @getModel().escape('comments')
			if !displayText?
				displayText = fileValue
			if @displayInline
				@$('.bv_file').html '<img src="'+encodeURI(window.conf.datafiles.downloadurl.prefix+fileValue)+'" alt="'+ displayText+'">'
			else
				@$('.bv_file').html '<a href="'+encodeURI(window.conf.datafiles.downloadurl.prefix+fileValue)+'">'+displayText+'</a>'
			@$('.bv_deleteSavedFile').show()

	createNewFileChooser: ->
		if @fileController?
			@fileController.render()
		else
			@fileController = new LSFileChooserController
				el: @$('.bv_file')
				maxNumberOfFiles: 1
				requiresValidation: false
				url: @fileURL
				allowedFileTypes: @allowedFileTypes
				hideDelete: false
				maxFileSize: @maxFileSize
			@fileController.on 'amDirty', =>
				@trigger 'amDirty'
			@fileController.on 'amClean', =>
				@trigger 'amClean'
			@fileController.render()
			@fileController.on('fileUploader:uploadComplete', @handleFileUpload.bind(@)) #update model with filename
			@fileController.on('fileDeleted', @handleFileRemoved.bind(@)) #update model with filename

	handleFileUpload: (file) =>
		@clearError()
		@getModel().set
			comments: file.originalName
			value: file.name
			ignored: false

	enableInput: ->
		super()
		if !@isEmpty()
			@$('.bv_deleteSavedFile').show()
	
	disableInput: ->
		super()
		@$('.bv_deleteSavedFile').hide()

	handleFileRemoved: =>
		@setEmptyValue()
		@checkEmptyAndRequired()

	handleDeleteSavedFile: =>
		@handleFileRemoved()
		@$('.bv_deleteSavedFile').hide()
		@createNewFileChooser()


class ACASFormLSBlobValueFieldController extends ACASFormLSFileValueFieldController
	###
		Launching controller must:
		- Initialize the model with an LSValue
    - Provide allowedFileTypes
    Do whatever else is required or optional in ACASFormAbstractFieldController
	###

	initialize: (options)->
		super(options)
		@fileURL = "/blobUploads"

	arrayToBase64String: (a)->
		btoa new Uint8Array(a).reduce(((data, byte) ->
			data + String.fromCharCode(byte)
		), '')

	setupFileController: ->
		fileValue = @getModel().escape('value')
		if @isEmpty()
			@createNewFileChooser()
			@$('.bv_deleteSavedFile').hide()
		else
			displayText = @getModel().escape('comments')
			if !displayText?
				displayText = "InternalErrorUnknownFileName"
			id = @getModel().get('id')
			# Display inline not supported right now because guessing mimetype from extension isn't available
			# so always be falsey here but leaving this in place
			if false and @displayInline and @mimeType?
				@$('.bv_file').html '<img src="data:' + @mimeType + ';base64,'+@arrayToBase64String(fileValue)+'" alt="'+ displayText+'">'
			else
				# The value is filled but the id is empty so convert the blobValue to base64 and create link for download
				if id?
					@$('.bv_file').html '<a href="/api/thingvalues/downloadThingBlobValueByID/'+id+'">'+displayText+'</a>'
				else
					@$('.bv_file').html '<a href="data:application/octet-stream;base64,'+@arrayToBase64String(fileValue)+'" download="'+displayText+'">'+displayText+'</a>'
			@$('.bv_deleteSavedFile').show()

	setEmptyValue: ->
		@getModel().set
			value: null 
			ignored: true

	isEmpty: ->
		empty = false
		mdl = @getModel()
		if mdl.get('comments')=="" or !mdl.get('comments')? then empty = true
		if mdl.get('ignored') then empty = true
		return empty

	createNewFileChooser: ->
		if @fileController?
			@fileController.render()
		else
			@fileController = new LSFileChooserController
				el: @$('.bv_file')
				maxNumberOfFiles: 1
				requiresValidation: false
				url: @fileURL
				allowedFileTypes: @allowedFileTypes
				hideDelete: false
			@fileController.on 'amDirty', =>
				@trigger 'amDirty'
			@fileController.on 'amClean', =>
				@trigger 'amClean'
			@fileController.render()
			@fileController.on('fileUploader:uploadComplete', @handleFileUpload.bind(@)) #update model with filename
			@fileController.on('fileDeleted', @handleFileRemoved.bind(@)) #update model with filename

	handleFileUpload: (file) =>
		@clearError()
		@mimeType = file.mimeType
		@getModel().set
			value: file.binaryData
			comments: file.originalName
			ignored: false

class ACASFormLSBooleanFieldController extends ACASFormAbstractFieldController
	###
		Launching controller must:
		- Initialize the model with an LSValue
		- Strongly recommended to use a codeValue of codeType: "boolean", codeKind: "boolean"
    Do whatever else is required or optional in ACASFormAbstractFieldController
	###

	template: _.template($("#ACASFormLSBooleanFieldView").html())
	events: ->
		_.extend {}, super(),
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
		# If value is anything other than true (i.e. null), then default to unchecked
		if @getModel().get('value')? && @getModel().get('value').toLowerCase() is "true"
			@$('input').attr 'checked', 'checked'
		else
			@$('input').removeAttr 'checked'
		super()



class ACASFormLSURLValueFieldController extends ACASFormAbstractFieldController
	###
		Launching controller must:
		- Initialize the model with an LSValue
    Do whatever else is required or optional in ACASFormAbstractFieldController
	###

	template: _.template($("#ACASFormLSURLValueFieldView").html())

	events: ->
		"click .bv_linkBtn": "handleLinkBtnClicked"

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

	handleLinkBtnClicked: =>
		url = UtilityFunctions::getTrimmedInput(@$('input'))
		window.open(url);


	renderModelContent: =>
		@$('input').val @getModel().get('value')
		super()
