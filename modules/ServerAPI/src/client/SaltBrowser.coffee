class SaltSearch extends Backbone.Model
	defaults:
		saltCode: null

class SaltSimpleSearchController extends AbstractFormController
	template: _.template($("#SaltSimpleSearchView").html())
	genericSearchUrl: "/api/cmpdRegAdmin/salts" 

	events:
		'keyup .bv_saltSearchTerm': 'updateSaltSearchTerm'
		'click .bv_doSearch': 'handleDoSearchClicked'

	render: =>
		$(@el).empty()
		$(@el).html @template()
		@doSearch "*"

	updateSaltSearchTerm: (e) =>
		ENTER_KEY = 13
		saltSearchTerm = $.trim(@$(".bv_saltSearchTerm").val())
		if saltSearchTerm isnt ""
			@$(".bv_doSearch").attr("disabled", false)
			if e.keyCode is ENTER_KEY
				$(':focus').blur()
				@handleDoSearchClicked()
		else
			@$(".bv_doSearch").attr("disabled", true)

	handleDoSearchClicked: =>
		$(".bv_saltTableController").hide()
		$(".bv_errorOccurredPerformingSearch").hide()
		saltSearchTerm = $.trim(@$(".bv_saltSearchTerm").val())
		$(".bv_exptSearchTerm").val ""
		if saltSearchTerm isnt ""
			$(".bv_noMatchingSaltsFoundMessage").hide()
			$(".bv_saltBrowserSearchInstructions").hide()
			$(".bv_searchSaltsStatusIndicator").show()
			if !window.conf.browser.enableSearchAll and saltSearchTerm is "*"
				$(".bv_moreSpecificSaltSearchNeeded").show()
			else 
				$(".bv_searchingSaltsMessage").show()
				$(".bv_exptSearchTerm").html _.escape(saltSearchTerm)
				$(".bv_moreSpecificSaltSearchNeeded").hide()
				@doSearch saltSearchTerm

	doSearch: (saltSearchTerm) => 
		@$(".bv_saltSearchTerm").attr "disabled", true
		@$(".bv_doSearch").attr "disabled", true
		@trigger 'find'
		unless saltSearchTerm is "" 
			$.ajax(
				type: 'GET'
				url: @genericSearchUrl + "/search/" + saltSearchTerm
				contentType: "application/json"
				dataType: "json"
				success: (salt) =>
					@trigger "searchReturned", salt
				error: (result) =>
					console.log(result)
					@trigger "searchReturned", null
				complete: =>
					@$(".bv_saltSearchTerm").attr "disabled", false
					@$(".bv_doSearch").attr "disabled", false
			)

class SaltRowSummaryController extends Backbone.View
	tagName: 'tr'
	className: 'dataTableRow'
	events:
		"click": "handleClick"

	handleClick: =>
		@trigger "gotClick", @model
		$(@el).closest("table").find("tr").removeClass "info"
		$(@el).addClass "info"

	initialize: ->
		@template = _.template($('#SaltRowSummaryView').html())

	render: =>
		toDisplay =
			saltName: @model.get('name')
			abbrev: @model.get('abbrev')
			molFormula: @model.get('formula')
			molWeight: @model.get('molWeight')
			charge: @model.get('charge')
		$(@el).html(@template(toDisplay))
		@

class SaltSummaryTableController extends Backbone.View
	initialize: ->

	selectedRowChanged: (row) =>
		@trigger "selectedRowUpdated", row

	render: =>
		@template = _.template($('#SaltSummaryTableView').html())
		$(@el).html @template
		if @collection.models.length is 0
			$(".bv_noMatchingSaltsFoundMessage").show()
		else
			$(".bv_noMatchingSaltsFoundMessage").hide()
			@collection.each (salt) =>
				prsc = new SaltRowSummaryController
					model: salt
				prsc.on "gotClick", @selectedRowChanged
				@$("tbody").append prsc.render().el

			@$("table").dataTable oLanguage:
				sSearch: "Filter results: "
		@


class SaltBrowserController extends Backbone.View
	notificationController: null

	events:
		# Download Button Event
		"click .bv_downloadSaltBtn": "handleDownloadSaltClicked"
		# Create Salt Button Events
		"click .bv_createNewSaltBtn": "handleCreateSaltClicked"
		"click .bv_confirmCreateSaltButton": "handleConfirmCreateSaltClicked"
		"click .bv_cancelCreate": "handleCancelCreateClicked"
		"click .bv_okayCreateButton":"handleOkayCreateClicked"
		"click .bv_backConfirmCreate":"handleBackConfirmCreateClicked"
		"click .bv_cancelConfirmCreate":"handleCancelConfirmCreateClicked"
		"click .bv_saveSaltButton":"handleSaveSaltButtonClicked"
		# Edit Salt Button Events
		"click .bv_editSalt": "handleEditSaltClicked"
		"click .bv_confirmEditSaltButton": "handleConfirmEditSaltClicked"
		"click .bv_cancelEdit":"handleCancelEditSaltClicked"
		"click .bv_backConfirmEdit":"handleBackConfirmEditClicked"
		"click .bv_cancelConfirmEdit":"handleCancelConfirmEditClicked"
		"click .bv_editSaltButton":"handleEditSaltButtonClicked"
		"click .bv_okayEditButton":"handleOkayEditButtonClicked"
		# Delete Salt Button Events
		"click .bv_deleteSalt": "handleDeleteSaltClicked" 
		"click .bv_okayDelete":"handleOkayDeleteButtonClicked"
		"click .bv_confirmDeleteSaltButton": "handleConfirmDeleteSaltClicked"
		"click .bv_cancelDelete": "handleCancelDeleteClicked"

	initialize: ->
		template = _.template($("#SaltBrowserView").html())
		$(@el).empty()
		$(@el).html template
		@searchController = new SaltSimpleSearchController
			model: new SaltSearch()
			el: @$('.bv_saltSearchController')
		@searchController.render()
		@searchController.on "searchReturned", @setupSaltSummaryTable.bind(@)
		@$('.bv_queryToolDisplayName').html window.conf.service.result.viewer.displayName

		@notificationController = new LSNotificationController
			el: @$('.bv_notifications')
			showPreview: false
		@$('.bv_notifications').hide()

		@createNotificationController = new LSNotificationController
			el: @$('.bv_createNotifications')
			showPreview: false
		@$('.bv_createNotifications').hide()

	setupSaltSummaryTable: (salts) =>
		@destroySaltSummaryTable()

		$(".bv_searchingSaltsMessage").hide()
		if salts is null
			@$(".bv_errorOccurredPerformingSearch").show()

		else if salts.length is 0
			@$(".bv_noMatchingSaltsFoundMessage").show()
			@$(".bv_saltTableController").html ""
		else
			$(".bv_searchSaltsStatusIndicator").hide()
			@$(".bv_saltTableController").show()
			@saltSummaryTable = new SaltSummaryTableController
				collection: new SaltList salts
			@saltSummaryTable.on "selectedRowUpdated", @selectedSaltUpdated
			$(".bv_saltTableController").html @saltSummaryTable.render().el

	selectedSaltUpdated: (salt) =>
		@trigger "selectedSaltUpdated"
		@saltController = new SaltEditorController
			model: new Salt salt.attributes
			readOnly: true

		$('.bv_saltController').html @saltController.render().el
		$(".bv_saltController").removeClass("hide")
		$(".bv_saltControllerContainer").removeClass("hide")

		# Request JSON Used to Render Image of Salt
		requestJSON = {
				"molStructure" : "#{@saltController.model.get("molStructure")}",
				"height" : 200, 
				"width" : 200, 
				"format" : "png"
			}


		$.ajax(
			type: 'POST'
			url: "/api/cmpdReg/renderMolStructureBase64"
			contentType: 'application/json'
			dataType: 'text'

			data: JSON.stringify(requestJSON)
			success: (base64ImagePNG) => # Rendered Image Should Be Displayed on Sever
				pngSrc = "data:image/png;base64," + base64ImagePNG
				pngImage = '<img src="' + pngSrc + '" />'
				@$('.bv_structureHolder').html pngImage

				if window.conf.roles.cmpdreg.adminRole?
					adminRoles = window.conf.roles.cmpdreg.adminRole.split(",")
					if UtilityFunctions::testUserHasRole(window.AppLaunchParams.loginUser, adminRoles)
						@$('.bv_editSalt').show()
						@$('.bv_deleteSalt').show()
			error: (result) =>
				console.log(result)
		)


	handleCreateSaltClicked: =>
		@createNotificationController.clearAllNotificiations()

		# Want to Clear Form Fields Here 
		@$('.bv_abbrevName').val ""
		@$('.bv_saltNameCreate').val ""

		@$('.bv_saltBrowserCoreContainer').hide()
		@$('bv_saltBrowserCore').hide()
		@$('.bv_createSalt').show()

		# Chemical Structure Controller Set by Sketcher Config Setting 
		@chemicalStructureController = null
		if window.conf.cmpdreg.sketcher == 'marvin'
			@chemicalStructureController = new MarvinJSChemicalStructureController
		else if  window.conf.cmpdreg.sketcher  == 'ketcher'
			@chemicalStructureController = new KetcherChemicalStructureController 
		else if window.conf.cmpdreg.sketcher == 'maestro'
			@chemicalStructureController = new MaestroChemicalStructureController
		else 
			console.log("No Chemical Sketcher Configured!")
			alert("Please contact your ACAS System Admin. There is no chemical sketcher configured.")
		$('.bv_chemicalStructureForm').html @chemicalStructureController.render().el

	handleConfirmCreateSaltClicked: =>

		fieldsFilled = true
		saltAbbrev = UtilityFunctions::getTrimmedInput @$('.bv_abbrevName')
		if (saltAbbrev == "" || saltAbbrev == null)
			fieldsFilled = false

		saltName = UtilityFunctions::getTrimmedInput @$('.bv_saltNameCreate')
		if (saltName == "" || saltName == null)
			fieldsFilled = false

		saltStruct = @chemicalStructureController.getMol()
		if (saltStruct == "" || saltStruct == null)
			fieldsFilled = false
		
		if (!fieldsFilled)
			console.log("User Attempted to Pass Empty Fields")
			console.log(saltAbbrev)
			console.log(saltName)
			console.log(saltStruct)
			# Need to Alert User of Empty Fields Somehow 
			alert('Please fill in name, abbrev, and structure fields!')
		if (fieldsFilled)
			saltDict = 
			{
				"abbrev": saltAbbrev,
				"molStructure": saltStruct,
				"name": saltName,
			} 

			# Dryrun Request Just to Preview Calculations 
			dryrun = true

			$.ajax(
				url: "/cmpdReg/salts?dryrun=" + dryrun, 
				type: 'POST', 
				data: JSON.stringify(saltDict)
				contentType: 'application/json'
				dataType: 'json'
				success: (result) => # Result Success Should Be JSON of Salt
					console.log(result)
					console.log(result.length)
					if result.length > 1 # If there's an error / warning and no salt 
						@$('.bv_createNotifications').show()
						@createNotificationController.clearAllNotificiations()
						for feedback in result
							@createNotificationController.addNotifications(@errorOwnerName, [{"errorLevel": feedback.level, "message":feedback.message}])
					else 
						@$('.bv_createNotifications').hide()
						# Need to Parse Result Values Into Form Fields 
						@$('.bv_createSalt').hide()
						@$('.bv_confirmCreateSalt').show()

						@$('.bv_abbrevNameConfirm').val result.abbrev
						@$('.bv_saltNameConfirm').val result.name
						@$('.bv_saltFormulaConfirm').val result.formula
						@$('.bv_saltWeightConfirm').val "#{result.molWeight}"
						@$('.bv_saltChargeConfirm').val "#{result.charge}"

						# Need to Render Preview of Structure 
						requestJSON = {
							"molStructure" : result.molStructure,
							"height" : 200, 
							"width" : 200, 
							"format" : "png"
						}

						# Render Image
						$.ajax(
							type: 'POST'
							url: "/api/cmpdReg/renderMolStructureBase64"
							contentType: 'application/json'
							dataType: 'text'
							data: JSON.stringify(requestJSON)
							success: (base64ImagePNG) => # Rendered Image Should Be Displayed on Sever
								pngSrc = "data:image/png;base64," + base64ImagePNG
								pngImage = '<img src="' + pngSrc + '" />'
								@$('.bv_saltStructConfirm').html pngImage 
							error: (result) =>
								console.log(result)
								@$('.bv_saltStructConfirm').hide()

					)

				error: (errorMsg) =>
					console.log(errorMsg)
					@$('.bv_createSalt').hide()
					@$('.bv_errorCreatingSaltMessage').show()
					@$('.bv_createSaltErrorMessageHolder') errorMsg
			)

	handleBackConfirmCreateClicked: => 
		@$('.bv_confirmCreateSalt').hide()
		@$('.bv_createSalt').show()
		@$('.bv_createNotifications').hide()

	handleCancelConfirmCreateClicked: => 
		@$('.bv_confirmCreateSalt').hide()
		@$('.bv_saltBrowserCoreContainer').show()
		@$('bv_saltBrowserCore').show()

	# Non Dry Run Method to Register Salt Reviewed by User
	handleSaveSaltButtonClicked: =>
		fieldsFilled = true
		saltAbbrev = UtilityFunctions::getTrimmedInput @$('.bv_abbrevNameConfirm')
		if (saltAbbrev == "" || saltAbbrev == null)
			fieldsFilled = false
			console.log("Salt Abbrev Was Empty! Cannot Register!")

		saltName = UtilityFunctions::getTrimmedInput @$('.bv_saltNameConfirm')
		if (saltName == "" || saltName == null)
			fieldsFilled = false
			console.log("Salt Name Was Empty! Cannot Register!")

		saltStruct = @chemicalStructureController.getMol()
		if (saltStruct == "" || saltStruct == null)
			fieldsFilled = false
			console.log("Salt Structure Was Empty! Cannot Register!")
		
		if (fieldsFilled)
			saltDict = 
			{
				"abbrev": saltAbbrev,
				"molStructure": saltStruct,
				"name": saltName,
			} 

			dryrun = false


			$.ajax(
				url: "/cmpdReg/salts?dryrun=" + dryrun,
				type: 'POST', 
				data: JSON.stringify(saltDict)
				contentType: 'application/json'
				dataType: 'json'
				success: (result) => # Succesfull Registration! 
					@$('.bv_confirmCreateSalt').hide()
					@$('.bv_saltBrowserCoreContainer').show()
					@$('bv_saltBrowserCore').show()
					# Reload Search
					@searchController.doSearch("*")
					@$('.bv_createNotifications').hide()
				error: (errorMsg) =>
					console.log(errorMsg)
					@$('.bv_confirmCreateSalt').hide()
					@$('.bv_errorCreatingSaltMessage').show()
					@$('.bv_createSaltErrorMessageHolder') errorMsg
					@$('.bv_createNotifications').hide()
			)


	handleCancelCreateClicked: =>
		@$(".bv_createSalt").hide()
		@$('.bv_saltBrowserCoreContainer').show()
		@$('bv_saltBrowserCore').show()

	handleDownloadSaltClicked: =>
		# Calls Custom Route to Download SDF of All Salts Registered 
		$.ajax(
				type: 'GET'
				url: "/cmpdReg/salts/sdf" 
				success: (salts) =>
					# Server should've returned salts in correct formatting
					@downloadSDF("allSalts.sdf", salts)
				error: (result) =>
					console.log(result)
		)
	
	downloadSDF: (filename, text) => 
		element = document.createElement('a');
		element.setAttribute('href', 'data:text/plain;charset=utf-8,' + encodeURIComponent(text));
		element.setAttribute('download', filename);
		element.style.display = 'none';
		document.body.appendChild(element);
		element.click();
		document.body.removeChild(element);
	
	handleDeleteSaltClicked: =>
		@$(".bv_saltUserName").html @saltController.model.get("name") 
		@$(".bv_deleteButtons").show()
		@$(".bv_errorDeletingSaltMessage").hide()
		@$(".bv_deleteWarningMessage").show()
		@$(".bv_deletingStatusIndicator").hide()
		@$(".bv_saltDeletedSuccessfullyMessage").hide()
		$(".bv_confirmDeleteSalt").show()
		$('.bv_confirmDeleteSalt').modal({
			keyboard: false,
			backdrop: true
		})

		# Clicking Delete should trigger a dependency check. 
		# If any Lots still reference this salt, then the Salt cannot be deleted.
		# If there are no dependent lots, then allow the user to confirm and proceed with the delete

	handleConfirmDeleteSaltClicked: =>
		@$(".bv_deleteWarningMessage").hide()
		@$(".bv_deletingStatusIndicator").show()
		@$(".bv_deleteButtons").hide()

		$.ajax(
			url: "/api/cmpdRegAdmin/salts/#{@saltController.model.get("id")}", 
			type: 'DELETE', 
			success: (result) =>
				@$(".bv_deleteSaltStatus").show()
				@$(".bv_deletingStatusIndicator").hide()
				@$(".bv_saltDeletedSuccessfullyMessage").show()
				@searchController.doSearch("*")
			error: (errorMsg) =>
				@$(".bv_deleteSaltStatus").show()
				@$(".bv_deletingStatusIndicator").hide()
				@$(".bv_deleteErrorMessage").html errorMsg.responseText
				@$(".bv_errorDeletingSaltMessage").show()

		)

	handleCancelDeleteClicked: =>
		@$(".bv_confirmDeleteSalt").modal('hide')

	handleOkayDeleteButtonClicked: =>
		@$(".bv_confirmDeleteSalt").modal('hide')
		@$(".bv_deleteSaltStatus").hide()

	handleEditSaltClicked: =>
		@notificationController.clearAllNotificiations()
		@$('.bv_saltBrowserCoreContainer').hide()
		@$('bv_saltBrowserCore').hide()
		@$()
		@$('.bv_editSaltWindow').show()

		currAbbrev = @saltController.model.get("abbrev")
		@$('.bv_abbrevNameEdit').val currAbbrev

		currName = @saltController.model.get("name")
		@$('.bv_saltNameEdit').val currName 

		molStr = @saltController.model.get("molStructure")

		# Chemical Structure Controller Set by Sketcher Config Setting 
		@chemicalStructureController = null
		if window.conf.cmpdreg.sketcher == 'marvin'
			@chemicalStructureController = new MarvinJSChemicalStructureController
		else if  window.conf.cmpdreg.sketcher  == 'ketcher'
			@chemicalStructureController = new KetcherChemicalStructureController 
		else if window.conf.cmpdreg.sketcher == 'maestro'
			@chemicalStructureController = new MaestroChemicalStructureController
		else 
			console.log("No Chemical Sketcher Configured!")
			alert("Please contact your ACAS System Admin. There is no chemical sketcher configured.")

		$('.bv_editChemicalStructureForm').html @chemicalStructureController.render().el
		@chemicalStructureController.on('sketcherLoaded', =>
			@chemicalStructureController.setMol(molStr)
			# Need to Format It Like This To Work
		)


	handleConfirmEditSaltClicked: =>
		@$('.bv_notifications').show()

		# Get Mol
		saltStruct = @chemicalStructureController.getMol()

		saltDict = 
		{
			"abbrev": @$('.bv_abbrevNameEdit').val(),
			"name":  @$('.bv_saltNameEdit').val(),
			"molStructure": saltStruct,
			"cdId":  @saltController.model.get("cdId"),
		}

		dryrun = true

		$.ajax(
			# This AJAX Call is Used to Collect Warnings and Errors If Salt is Edited 
			url: "/api/cmpdRegAdmin/salts/edit/#{@saltController.model.get("id")}?dryrun=" + dryrun,
			type: 'PUT',
			data: JSON.stringify(saltDict)
			contentType: 'application/json'
			dataType: 'json'
			success: (result) =>
				@$(".bv_editSaltWindow").hide()
				@$(".bv_confirmEditSalt").show()
				
				for feedback in result
					@notificationController.addNotifications(@errorOwnerName, [{"errorLevel": feedback.level, "message":feedback.message}])
					if feedback.level == "error"
						@$(".bv_editSaltButton").hide()

				# This AJAX Call is Used to Collect Calculations of Newly Proposed Salt
				$.ajax(
					url: "/api/cmpdRegAdmin/salts?dryrun=" + dryrun,
					type: 'POST', 
					data: JSON.stringify(saltDict)
					contentType: 'application/json'
					dataType: 'json'
					success: (result) =>
						# Need to Parse Result Values Into Form Fields 

						@$('.bv_abbrevNameEditConfirm').val result.abbrev
						@$('.bv_saltNameEditConfirm').val result.name
						@$('.bv_saltFormulaEditConfirm').val result.formula
						@$('.bv_saltWeightEditConfirm').val "#{result.molWeight}"
						@$('.bv_saltChargeEditConfirm').val "#{result.charge}"

						# Need to Render Preview of Structure 
						requestJSON = {
							"molStructure" : result.molStructure,
							"height" : 200, 
							"width" : 200, 
							"format" : "png"
						}

						# AJAX Call to Generate Picture of New Structure
						$.ajax(
							type: 'POST'
							url: "/api/cmpdReg/renderMolStructureBase64"
							contentType: 'application/json'
							dataType: 'text'
							data: JSON.stringify(requestJSON)
							success: (base64ImagePNG) => # Rendered Image Should Be Displayed on Sever
								pngSrc = "data:image/png;base64," + base64ImagePNG
								pngImage = '<img src="' + pngSrc + '" />'
								@$('.bv_saltStructEditConfirm').html pngImage 
							error: (result) =>
								console.log(result)
								@$(".bv_okayEditButton").show()
								@$(".bv_editSaltWindow").hide()
								@$(".bv_errorEditingSaltMessage").show()
								@$(".bv_errorEditingSaltMessage").html result

						)
					errors: (result) =>
						console.log(result)
						@$(".bv_okayEditButton").show()
						@$(".bv_editSaltWindow").hide()
						@$(".bv_errorEditingSaltMessage").show()
						@$(".bv_errorEditingSaltMessage").html result
				)

			error: (result) =>
				@$(".bv_okayEditButton").show()
				@$(".bv_editSaltWindow").hide()
				@$(".bv_errorEditingSaltMessage").show()
				@$(".bv_errorEditingSaltMessage").html result
		)
	
	handleEditSaltButtonClicked: =>
		@notificationController.clearAllNotificiations() 
		
		# Get Mol
		saltStruct = @chemicalStructureController.getMol()

		saltDict = 
		{
			"abbrev": @$('.bv_abbrevNameEditConfirm').val(),
			"name": @$('.bv_saltNameEditConfirm').val(),
			"molStructure": saltStruct,
			"cdId":  @saltController.model.get("cdId"),
		}

		dryrun = false

		# AJAX Call to Register New Edited Salt
		$.ajax(
			url: "/api/cmpdRegAdmin/salts/edit/#{@saltController.model.get("id")}?dryrun=" + dryrun, 
			type: 'PUT',
			data: JSON.stringify(saltDict)
			contentType: 'application/json'
			dataType: 'json'
			success: (result) =>
				@$(".bv_confirmEditSalt").hide()
				@$('.bv_notifications').hide()
				@$(".bv_editSaltStatus").show()
				@$(".bv_saltEditedSuccessfullyMessage").show()
				@$(".bv_okayEditButton").show()
				@$('.bv_saltBrowserCoreContainer').show()
				@$('bv_saltBrowserCore').show()
				@searchController.doSearch("*")
			error: (result) =>
				@$(".bv_confirmEditSalt").hide()
				@$(".bv_editSaltStatus").show()
				@$(".bv_okayEditButton").show()
				@$(".bv_errorEditingSaltMessage").show()
				@$(".bv_errorEditingSaltMessage").html result
		)
	
	handleOkayEditButtonClicked: => 
		@$('.bv_editSaltStatus').hide()
		@$('.bv_notifications').hide()
		@$('.bv_saltBrowserCoreContainer').show()
		@$('bv_saltBrowserCore').show()

	handleBackConfirmEditClicked: => 
		@$(".bv_editSaltButton").show()
		@$('.bv_notifications').hide()
		@$('.bv_confirmEditSalt').hide()
		@$('.bv_editSaltWindow').show()

	handleCancelConfirmEditClicked: =>
		@$(".bv_editSaltButton").show()
		@$('.bv_confirmEditSalt').hide()
		@$('.bv_editSaltWindow').hide()
		@$('.bv_notifications').hide()
		@$('.bv_saltBrowserCoreContainer').show()
		@$('bv_saltBrowserCore').show()

	handleCancelEditSaltClicked: =>
		@$(".bv_editSaltButton").show()
		@$(".bv_editSaltWindow").hide()
		@$('.bv_notifications').hide()
		@$('.bv_saltBrowserCoreContainer').show()
		@$('bv_saltBrowserCore').show()

	destroySaltSummaryTable: =>
		if @saltSummaryTable?
			@saltSummaryTable.remove()
		if @saltController?
			@saltController.remove()
		$(".bv_saltController").addClass("hide")
		$(".bv_saltControllerContainer").addClass("hide")
		$(".bv_noMatchingSaltsFoundMessage").addClass("hide")

	render: =>
		@