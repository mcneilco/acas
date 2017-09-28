class window.AuthorRole extends Backbone.Model
		
class window.AuthorRoleList extends Backbone.Collection
	model: AuthorRole

	validateCollection: =>
		modelErrors = []
		usedRoles={}
		if @.length != 0
			for index in [0..@.length-1]
				model = @.at(index)
				currentRole = model.get('id')
				if currentRole of usedRoles
					modelErrors.push
						attribute: "authorRole:eq("+index+")"
						message: "The same role can not be chosen more than once"
					modelErrors.push
						attribute: "authorRole:eq("+usedRoles[currentRole]+")"
						message: "The same role can not be chosen more than once"
				else
					usedRoles[currentRole] = index
		modelErrors

class window.Author extends Backbone.Model
#	urlRoot: TODO: fill in once have service

	defaults: ->
		lsType: "author"
		lsKind: "author"
		recordedBy: window.AppLaunchParams.loginUser.userName
		recordedDate: new Date().getTime()
		enabled: false
		authorRoles: []

	validate: (attrs) ->
		errors = []
		firstName = attrs.firstName
		if !firstName? or firstName is ""
			errors.push
				attribute: 'firstName'
				message: "First name must be set"
		lastName = attrs.lastName
		if !lastName? or lastName is ""
			errors.push
				attribute: 'lastName'
				message: "Last name must be set"
		userName = attrs.userName
		if !userName? or userName is ""
			errors.push
				attribute: 'userName'
				message: "Username must be set"
		emailAddress = attrs.emailAddress
		if !emailAddress? or emailAddress is ""
			errors.push
				attribute: 'emailAddress'
				message: "Email must be set"
		activationDate = attrs.activationDate
		if _.isNaN(attrs.activationDate) and !activationDate?
			errors.push
				attribute: 'activationDate'
				message: "Date of activation must be a valid date"


		if errors.length > 0
			return errors
		else
			return null
			
	getSystemRoles: =>
		systemRoles = _.filter @get('authorRoles'), (role) =>
			if role.roleEntry?.lsType?
				role.roleEntry.lsType is "System"

		trimmedSystemRoles = _.pluck systemRoles, 'roleEntry'
		return new AuthorRoleList trimmedSystemRoles

	getLdapRoles: =>
		ldapRoles = _.filter @get('authorRoles'), (role) =>
			if role.roleEntry?.lsType?
				role.roleEntry.lsType is "LDAP"

		trimmedLdapRoles = _.pluck ldapRoles, 'roleEntry'
		return new AuthorRoleList trimmedLdapRoles

	getProjectRoles: =>
		projectRoles = _.filter @get('authorRoles'), (role) =>
			if role.roleEntry?.lsType?
				role.roleEntry.lsType is "Project"

		trimmedProjectRoles = _.pluck projectRoles, 'roleEntry'

		return new AuthorRoleList trimmedProjectRoles

class window.AuthorList extends Backbone.Collection
	model: Author
	
class window.AuthorRoleController extends AbstractFormController
	template: _.template($("#AuthorRoleView").html())

	events: ->
		"change .bv_authorRole": "attributeChanged"
		"click .bv_deleteAuthorRole": "clear"

	initialize: ->
		@errorOwnerName = 'AuthorRoleController'
		@setBindings()
		@model.on "destroy", @remove, @
		if @options?.roleType?
			@roleType = @options.roleType
		else
			@roleType = null
		if @options?.roleKind?
			@roleKind = @options.roleKind
		else
			@roleKind = null
			
	render: =>
		$(@el).empty()
		$(@el).html @template()
		@setupAuthorRoleSelect()

		@

	setupAuthorRoleSelect: ->
		@getAuthorRoles()

	finishSetupAuthorRoleSelect: =>
		@authorRoleListController = new PickListSelectController
			el: @$('.bv_authorRole')
			collection: @authorRoleList
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Select Role"
			autoFetch: false
			selectedCode: @model.get('id')

	getAuthorRoles: =>
		authorRoleListUrl = "/api/lsRoles/codeTable"
		if @roleType?
			authorRoleListUrl += "?lsType=#{@roleType}"
			if @roleKind?
				authorRoleListUrl += "&lsKind=#{@roleKind}"
		else if @roleKind?
			authorRoleListUrl += "?lsKind=#{@roleKind}"

		$.ajax
			type: 'GET'
			json: true
			url: authorRoleListUrl
			success: (response) =>
				#change the code to be id
				_.each response, (role) =>
					role.code = role.id
				@authorRoleList = new PickListList response
				@finishSetupAuthorRoleSelect()
			error: (err) =>
				alert 'could not get the nhp test subjects'
				@serviceReturn = null


	updateModel: =>
		roleId = @authorRoleListController.getSelectedCode()
		@model.set
			id: roleId
		@trigger 'amDirty'

	clear: =>
		if @model.id?
			@model.unset 'id'
			@model.unset 'cid'
		@model.destroy()
		@trigger 'amDirty'

class window.AuthorRoleListController extends Backbone.View
	template: _.template($("#AuthorRoleListView").html())

	events:
		"click .bv_addAuthorRoleButton": "addNewAuthorRole"

	initialize: ->
		unless @collection?
			@collection = new Backbone.Collection()
			newModel = new @collection.model
			@collection.add newModel
		if @options?.roleType?
			@roleType = @options.roleType
		else
			@roleType = null
		if @options?.roleKind?
			@roleKind = @options.roleKind
		else
			@roleKind = null
		if @options?.readOnly?
			@readOnly = @options.readOnly
		else
			@readOnly = false


	render: =>
		$(@el).empty()
		$(@el).html @template()

		@collection.each (roleInfo) =>
			@addAuthorRole(roleInfo)
		if @collection.length == 0
			@addNewAuthorRole()
		@trigger 'renderComplete'

		if @readOnly
			@displayInReadOnlyMode()
		@

	addNewAuthorRole: =>
		newModel = new @collection.model
		newModel.set
			lsType: @roleType
			lsKind: @roleKind
		@collection.add newModel
		@addAuthorRole(newModel)
		@trigger 'amDirty'

	addAuthorRole: (roleInfo) =>
		plc = new AuthorRoleController
			model: roleInfo
			roleType: @roleType
			roleKind: @roleKind
		plc.on 'amDirty', =>
			@trigger 'amDirty'
		@$('.bv_authorRoleInfo').append plc.render().el

	isValid: =>
		validCheck = true
		errors = @collection.validateCollection()
		if errors.length > 0
			validCheck = false
		@validationError(errors)
		validCheck

	validationError: (errors) =>
		@clearValidationErrorStyles()
		_.each errors, (err) =>
			unless @$('.bv_'+err.attribute).attr('disabled') is 'disabled'
				@$('.bv_group_'+err.attribute).attr('data-toggle', 'tooltip')
				@$('.bv_group_'+err.attribute).attr('data-placement', 'bottom')
				@$('.bv_group_'+err.attribute).attr('data-original-title', err.message)
				#				@$('.bv_group_'+err.attribute).tooltip();
				@$("[data-toggle=tooltip]").tooltip();
				@$("body").tooltip selector: '.bv_group_'+err.attribute
				@$('.bv_group_'+err.attribute).addClass 'input_error error'
				@trigger 'notifyError',  owner: this.errorOwnerName, errorLevel: 'error', message: err.message

	clearValidationErrorStyles: =>
		errorElms = @$('.input_error')
		_.each errorElms, (ee) =>
			$(ee).removeAttr('data-toggle')
			$(ee).removeAttr('data-placement')
			$(ee).removeAttr('title')
			$(ee).removeAttr('data-original-title')
			$(ee).removeClass 'input_error error'

	displayInReadOnlyMode: =>
		@$('.bv_deleteAuthorRole').hide()
		@$('.bv_addAuthorRoleButton').hide()
		@disableAllInputs()

	disableAllInputs: ->
		@$('input').not('.dontdisable').attr 'disabled', 'disabled'
		@$('button').not('.dontdisable').attr 'disabled', 'disabled'
		@$('select').not('.dontdisable').attr 'disabled', 'disabled'
		@$("textarea").not('.dontdisable').attr 'disabled', 'disabled'
		@$(".bv_activationDateIcon").not('.dontdisable').addClass "uneditable-input"
		@$(".bv_activationDateIcon").not('.dontdisable').on "click", ->
			return false
		@$(".bv_group_tags input").not('.dontdisable').prop "placeholder", ""
		@$(".bv_group_tags input").not('.dontdisable').css "background-color", "#eeeeee"
		@$(".bv_group_tags input").not('.dontdisable').css "color", "#333333"
		@$(".bv_group_tags div.bootstrap-tagsinput").not('.dontdisable').css "background-color", "#eeeeee"
		@$("span.tag.label.label-info span").not('.dontdisable').attr "data-role", ""


class window.AuthorEditorController extends AbstractFormController
	template: _.template($("#AuthorEditorView").html())
	moduleLaunchName: "author"
	
	events: ->
		"keyup .bv_firstName": "attributeChanged"
		"keyup .bv_lastName": "attributeChanged"
		"keyup .bv_userName": "handleUsernameChanged"
		"keyup .bv_emailAddress": "handleEmailChanged"
		"change .bv_activationDate": "handleActivationDateChanged"
		"click .bv_activationDateIcon": "handleActivationDateIconClicked"
		"click .bv_enabled": "attributeChanged"
		"click .bv_save": "handleSaveClicked"
		"click .bv_newEntity": "handleNewEntityClicked"
		"click .bv_cancel": "handleCancelClicked"
		"click .bv_cancelClear": "handleCancelClearClicked"
		"click .bv_confirmClear": "handleConfirmClearClicked"



	initialize: ->
		if @model?
			@completeInitialization()
		else
			if window.AppLaunchParams.moduleLaunchParams?
				if window.AppLaunchParams.moduleLaunchParams.moduleName == @moduleLaunchName
					$.ajax
						type: 'GET'
						url: "/api/authorByUsername/"+window.AppLaunchParams.moduleLaunchParams.code
						dataType: 'json'
						error: (err) =>
							alert 'Could not get author object with this code. Creating a new author'
							@completeInitialization()
						success: (authorObj) =>
							@model = new Author authorObj
							@completeInitialization()
				else
					@completeInitialization()
			else
				@completeInitialization()


	completeInitialization: =>
		unless @model?
			@model = new Author()
		@errorOwnerName = 'AuthorEditorController'
		@setBindings()

		if @options.readOnly?
			@readOnly = @options.readOnly
		else
			#create/edit based on whether user has create/edit role
			@readOnly = false
			if window.conf.author?.editingRoles?
				editingRoles = window.conf.author.editingRoles.split(",")
				if !UtilityFunctions::testUserHasRole(window.AppLaunchParams.loginUser, editingRoles)
					@readOnly = true

		$(@el).empty()
		$(@el).html @template()
		@$('.bv_save').attr('disabled', 'disabled')
		@listenTo @model, 'sync', @modelSyncCallback
		@listenTo @model, 'change', @modelChangeCallback
		if (window.conf.security?.authstrategy? and window.conf.security.authstrategy is 'database') or (window.conf.security?.authstrategy? and window.conf.security.authstrategy is 'ldap' and window.conf.security?.syncLdapAuthRoles? and window.conf.security.syncLdapAuthRoles is false)
			@setupSystemRoleListController()
			@$('.bv_systemRoleListWrapper').show()
			@$('.bv_ldapRoleListWrapper').hide()
		else if (window.conf.security?.authstrategy? and window.conf.security.authstrategy is 'ldap') or (window.conf.security?.authstrategy? and window.conf.security.authstrategy is 'ldap' and window.conf.security?.syncLdapAuthRoles? and window.conf.security.syncLdapAuthRoles is true)
			@setupLdapRoleListController()
			@$('.bv_systemRoleListWrapper').hide()
			@$('.bv_ldapRoleListWrapper').show()
		@setupProjectRoleListController()

		@render()

	render: =>
		unless @model?
			@model = new Author()
		@$('.bv_firstName').val(@model.get('firstName'))
		@$('.bv_lastName').val(@model.get('lastName'))
		@$('.bv_userName').val(@model.get('userName'))
		@$('.bv_emailAddress').val(@model.get('emailAddress'))

		if window.conf.security?.authstrategy? and window.conf.security.authStrategy is 'database'
			@$('.bv_activationDate').datepicker();
			@$('.bv_activationDate').datepicker( "option", "dateFormat", "yy-mm-dd" );
			if @model.get('activationDate')?
				@$('.bv_activationDate').val UtilityFunctions::convertMSToYMDDate(@model.get('activationDate'))
			enabled = @$('.bv_enabled').is(":checked")
			if enabled
				@$('.bv_enabled').attr 'checked', 'checked'
			else
				@$('.bv_enabled').removeAttr 'checked'
		else
			@$('.bv_group_activationDate').hide()
			@$('.bv_group_enabled').hide()
		if @model.isNew()
			@$('.bv_userName').removeAttr 'disabled'
			@$('.bv_save').html("Save")
			@$('.bv_newEntity').hide()
		else
			@$('.bv_userName').attr 'disabled', 'disabled'
			@$('.bv_save').html("Update")
			@$('.bv_newEntity').show()
		@$('.bv_save').attr('disabled', 'disabled')
		@$('.bv_cancel').attr('disabled','disabled')

		if @readOnly is true
			@displayInReadOnlyMode()

		@

	modelSyncCallback: =>
		@trigger 'amClean'
		@$('.bv_saving').hide()
		@$('.bv_saveComplete').show()
		if (window.conf.security?.authstrategy? and window.conf.security.authstrategy is 'database') or (window.conf.security?.authstrategy? and window.conf.security.authstrategy is 'ldap' and window.conf.security?.syncLdapAuthRoles? and window.conf.security.syncLdapAuthRoles is false)
			@setupSystemRoleListController()
			@$('.bv_systemRoleListWrapper').show()
			@$('.bv_ldapRoleListWrapper').hide()
		else if (window.conf.security?.authstrategy? and window.conf.security.authstrategy is 'ldap') or (window.conf.security?.authstrategy? and window.conf.security.authstrategy is 'ldap' and window.conf.security?.syncLdapAuthRoles? and window.conf.security.syncLdapAuthRoles is true)
			@setupLdapRoleListController()
			@$('.bv_systemRoleListWrapper').hide()
			@$('.bv_ldapRoleListWrapper').show()
		@setupProjectRoleListController()
		@render()

	modelChangeCallback: =>
		@trigger 'amDirty'
		@$('.bv_saveComplete').hide()
		@$('.bv_cancel').removeAttr('disabled')
		@$('.bv_cancelComplete').hide()

	setupSystemRoleListController: ->
		acasAdminRole = window.conf.roles.acas.adminRole
		readOnly = false
		if acasAdminRole != "" and !UtilityFunctions::testUserHasRole(window.AppLaunchParams.loginUser, [acasAdminRole])
				readOnly = true

		if @systemRoleListController?
			@systemRoleListController.undelegateEvents()

		systemRoles = @model.getSystemRoles()
		@systemRoleListController= new AuthorRoleListController
			el: @$('.bv_systemRoleList')
			collection: systemRoles
			roleType: "System"
			readOnly: readOnly

		@finishAuthorRoleListControllerSetup @systemRoleListController

	setupLdapRoleListController: ->
		if @ldapRoleListController?
			@ldapRoleListController.undelegateEvents()

		ldapRoles = @model.getLdapRoles()

		@ldapRoleListController= new AuthorRoleListController
			el: @$('.bv_ldapRoleList')
			collection: ldapRoles
			roleType: "LDAP"
			readOnly: true

		@finishAuthorRoleListControllerSetup @ldapRoleListController

	setupProjectRoleListController: ->
		if @projectRoleListController?
			@projectRoleListController.undelegateEvents()

		projectRoles = @model.getProjectRoles()

		@projectRoleListController= new AuthorRoleListController
			el: @$('.bv_projectRoleList')
			collection: projectRoles
			roleType: "Project"
			readOnly: true

		@finishAuthorRoleListControllerSetup @projectRoleListController

	finishAuthorRoleListControllerSetup: (controller) ->
		controller.on 'amClean', =>
			@trigger 'amClean'
		controller.on 'renderComplete', =>
			@checkDisplayMode()
		controller.render()
		controller.on 'amDirty', =>
			@trigger 'amDirty'
			@$('.bv_saveComplete').hide()
			@$('.bv_saveFailed').hide()
			@checkFormValid()
		

	updateModel: =>
		@model.set 'firstName', UtilityFunctions::getTrimmedInput @$('.bv_firstName')
		@model.set 'lastName', UtilityFunctions::getTrimmedInput @$('.bv_lastName')
		@model.set 'enabled', @$('.bv_enabled').is(":checked")

	handleUsernameChanged: =>
		@model.set 'userName', UtilityFunctions::getTrimmedInput @$('.bv_userName')

	handleEmailChanged: =>
		@model.set 'emailAddress', UtilityFunctions::getTrimmedInput @$('.bv_emailAddress')

	handleActivationDateChanged: =>
		date = UtilityFunctions::getTrimmedInput @$('.bv_activationDate')
		if date? and date != ""
			date = UtilityFunctions::convertYMDDateToMs(UtilityFunctions::getTrimmedInput @$('.bv_activationDate'))
		else
			date = null
		@model.set 'activationDate', date

		handleActivationDateIconClicked: =>
		@$( ".bv_activationDate" ).datepicker( "show" )

	handleSaveClicked: =>
		@model.set 'authorRoles', []
		@prepareToSaveSystemRoles()
		if @model.isNew()
			@$('.bv_saveComplete').html "Save Complete"
		else
			@$('.bv_saveComplete').html "Update Complete"
		@$('.bv_save').attr('disabled', 'disabled')
		@$('.bv_saving').show()
		console.log "handleSaveClicked"
		console.log JSON.stringify @model
#		@model.save() TODO: uncomment when service works

	prepareToSaveSystemRoles: =>
		authorRoles = []
		@systemRoleListController.collection.each (role) =>
			authorRoles.push
				roleEntry: role
		ar = @model.get 'authorRoles'
		ar.push authorRoles...
		@model.set 'authorRoles', ar

	handleNewEntityClicked: =>
		@$('.bv_confirmClearEntity').modal('show')
		@$('.bv_confirmClear').removeAttr('disabled')
		@$('.bv_cancelClear').removeAttr('disabled')
		@$('.bv_closeModalButton').removeAttr('disabled')

	handleCancelClearClicked: =>
		@$('.bv_confirmClearEntity').modal('hide')

	handleConfirmClearClicked: =>
		@$('.bv_confirmClearEntity').modal('hide')
		@model = null
		@completeInitialization()
		@trigger 'amClean'

	handleCancelClicked: =>
		if @model.isNew()
			@model = null
			@completeInitialization()
		else
			@$('.bv_canceling').show()
			@model.fetch
				success: @handleCancelComplete
		@trigger 'amClean'

	handleCancelComplete: =>
		@$('.bv_canceling').hide()
		@$('.bv_cancelComplete').show()

	validationError: =>
		super()
		@$('.bv_save').attr('disabled', 'disabled')

	clearValidationErrorStyles: =>
		super()
		@$('.bv_save').removeAttr('disabled')

	checkDisplayMode: =>
		if @readOnly is true
			@displayInReadOnlyMode()

	displayInReadOnlyMode: =>
		@$(".bv_save").hide()
		@$(".bv_cancel").hide()
		@$(".bv_newEntity").hide()
		@$(".bv_addFileInfo").hide()
		@disableAllInputs()


	checkFormValid: =>
		if @isValid()
			@$('.bv_save').removeAttr('disabled')
		else
			@$('.bv_save').attr('disabled', 'disabled')

	isValid: =>
		validCheck = super()
		if @systemRoleListController?
			if @systemRoleListController.isValid() is false
				validCheck = false
		validCheck
