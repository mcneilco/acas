class window.DocUpload extends Backbone.Model
	defaults:
		url: ""
		currentFileName: ""
		description: ""
		docType: ""
		documentKind: "experiment"

	validate: (attrs) ->
		errors = []
		if  attrs.docType not in ['url', 'file']
			errors.push
				attribute: 'docType'
				message: "Type must be one of url or file"

		if attrs.docType =='file'
			if attrs.currentFileName == ""
				errors.push
					attribute: 'currentFileName'
					message: "must set file when docType is file"

		if attrs.docType =='url'
			if attrs.url == ""
				errors.push
					attribute: 'url'
					message: "must set url when docType is url"

		if errors.length > 0
			return errors
		else
			return null

class window.DocUploadController extends AbstractFormController
	template: _.template($("#DocUploadView").html())

	events:
		'change [name="docTypeRadio"]': "docTypeChanged"
		'change .bv_url': "attributeChanged"
		'change .bv_description': "attributeChanged"

	initialize: ->
		@errorOwnerName = 'DocUploadController'
		$(@el).html @template()
		@fileInputController = new LSFileInputController
			el: @$('.bv_fileInput'),
			inputTitle: ''
			url: "http://"+window.conf.host+":"+window.conf.service.file.port
			fieldIsRequired: false
			requiresValidation: false
			maxNumberOfFiles: 1
		@fileInputController.on('fileInput:uploadComplete', @setNewFileName)
		@fileInputController.on('fileInput:removedFile', @clearNewFileName)
		@setBindings()
		# do this here because we don't want to do this on re-render
		unless @model.isNew()
			@$('.bv_fileInput').hide()
			if @model.get('docType') is 'file'
				$('.bv_currentFileRadio').attr('checked', true)
				@$('.bv_currentFileName').html(@model.get('currentFileName'))
			else
				@.$('.bv_currentDocContainer').hide()
				$('.bv_urlRadio').attr('checked', true)
				@$('.bv_url').val(@model.get('url'))

	render: =>
		@fileInputController.render()
		if @model.isNew() then @.$('.bv_currentDocContainer').hide()
		unless @$('.bv_urlRadio').is(":checked")
			@$('.bv_urlInputWrapper').hide()

		@

	docTypeChanged: (event) =>
		currentChecked = @$('[name="docTypeRadio"]:checked').val()
		if currentChecked != 'url'
			@$('.bv_urlInputWrapper').hide('slide')
		else
			@$('.bv_urlInputWrapper').show('slide')
		if currentChecked != 'file'
			@$('.bv_fileInput').hide('slide')
		else
			@$('.bv_fileInput').show('slide')

		@updateModel()

	setNewFileName: (fileNameOnServer) =>
		@model.set({currentFileName: fileNameOnServer})
		@updateModel()

	clearNewFileName: =>
		@model.set({currentFileName: ""})
		@updateModel()

	attributeChanged: =>
		@trigger 'amDirty'
		@updateModel()

	updateModel: () =>
		@model.set
				docType: @$('[name="docTypeRadio"]:checked').val()
				url: @$('.bv_url').val()
				description: @$('.bv_description').val()
