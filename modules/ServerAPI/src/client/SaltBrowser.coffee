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
			$.ajax
				type: 'GET'
				url: @genericSearchUrl + "/search/" + saltSearchTerm
				# CHANGE THIS AND FIX SEARCH
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

		# Need to Use This Route (Or Similar) to Display Salt Structure
		# app.get '/api/chemStructure/renderStructureByCode', exports.renderStructureByCode

		# Need to Get 
		requestJSON = {
			#	"codeName" :  "#{@saltController.model.get("id")}"
				"molStructure" : "#{@saltController.model.get("molStructure")}",
				"height" : 100, 
				"width" : 100, 
				"format" : "png"
			}


		$.ajax(
			type: 'POST'
			url: "/api/chemStructure/renderMolStructureBase64"
			contentType: 'application/json'
			dataType: 'text'

			data: JSON.stringify(requestJSON)
			success: (base64ImagePNG) => # Rendered Image Should Be Displayed on Sever
				pngSrc = "data:image/png;base64," + base64ImagePNG
				pngImage = '<img src="' + pngSrc + '" />'
				@$('.bv_structureHolder').html pngImage 

				@$('.bv_editSalt').show()
				if window.conf.salt?.editingRoles?
					editingRoles = window.conf.salt.editingRoles.split(",")
					if !UtilityFunctions::testUserHasRole(window.AppLaunchParams.loginUser, editingRoles)
						@$('.bv_editSalt').hide()

				@$('.bv_deleteSalt').show()
				if window.conf.salt?.deletingRoles?
					deletingRoles= window.conf.salt.deletingRoles.split(",")
					if !UtilityFunctions::testUserHasRole(window.AppLaunchParams.loginUser, deletingRoles)
						@$('.bv_deleteSalt').hide()
			error: (result) =>
				console.log(result)
		)

	handleCreateSaltClicked: =>
		@$('.bv_createSalt').show()
		@chemicalStructureController = new KetcherChemicalStructureController 
		$('.bv_chemicalStructureForm').html @chemicalStructureController.render().el
		# Sketcher should be controlled by CReg sketcher settings!!
		# Need to Setup Text Boxes for Name and Abbrev

	handleConfirmCreateSaltClicked: =>
		fieldsFilled = true
		saltAbbrev = UtilityFunctions::getTrimmedInput @$('.bv_abbrevName')
		if (saltAbbrev == "" || saltAbbrev == null)
			fieldsFilled = false
			# Error Msg Window 

		saltName = UtilityFunctions::getTrimmedInput @$('.bv_saltName')
		if (saltName == "" || saltName == null)
			fieldsFilled = false
			# Error Msg Window 

		saltStruct = @chemicalStructureController.getMol()
		if (saltStruct == "" || saltStruct == null)
			fieldsFilled = false
			# Error Msg Window 
		
		if (fieldsFilled)
			saltDict = 
			{
				"abbrev": saltAbbrev,
				"molStructure": saltStruct,
				"name": saltName,
			} 

			requestData = 
			{
				"dryrun" : "true",
				"saltJSON" : saltDict
			}


			$.ajax(
				url: "/api/cmpdRegAdmin/salts",
				type: 'POST', 
				data: JSON.stringify(requestData)
				contentType: 'application/json'
				dataType: 'json'
				success: (result) => # Result Success Should Be JSON of Salt
					console.log(result)
					@$('.bv_createSalt').hide()
					@$('.bv_confirmCreateSalt').show()

					# Need to Parse Result Values Into Form Fields 

					@$('.bv_abbrevNameConfirm').val result.abbrev
					@$('.bv_saltNameConfirm').val result.name
					@$('.bv_saltFormulaConfirm').val result.formula
					@$('.bv_saltWeightConfirm').val "#{result.molWeight}"
					@$('.bv_saltChargeConfirm').val "#{result.charge}"

					# Need to Render Preview of Structure 
					requestJSON = {
						"molStructure" : result.molStructure,
						"height" : 100, 
						"width" : 100, 
						"format" : "png"
					}

					$.ajax(
						type: 'POST'
						url: "/api/chemStructure/renderMolStructureBase64"
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
	# Does Dry Run of Create Structure and Shows Pre-Calculations Going to Be Saved
	handleBackConfirmCreateClicked: => 
		@$('.bv_confirmCreateSalt').hide()
		@$('.bv_createSalt').show()

	handleCancelConfirmCreateClicked: => 
		@$('.bv_confirmCreateSalt').hide()

	handleSaveSaltButtonClicked: =>
		fieldsFilled = true
		saltAbbrev = UtilityFunctions::getTrimmedInput @$('.bv_abbrevNameConfirm')
		if (saltAbbrev == "" || saltAbbrev == null)
			fieldsFilled = false
			# Error Msg Window 

		saltName = UtilityFunctions::getTrimmedInput @$('.bv_saltNameConfirm')
		if (saltName == "" || saltName == null)
			fieldsFilled = false
			# Error Msg Window 

		saltStruct = @chemicalStructureController.getMol()
		if (saltStruct == "" || saltStruct == null)
			fieldsFilled = false
			console.log("Salt Structure Was Empty! Cannot Register!")
			# Error Msg Window 
		
		if (fieldsFilled)
			saltDict = 
			{
				"abbrev": saltAbbrev,
				"molStructure": saltStruct,
				"name": saltName,
			} 

			requestData = 
			{
				"dryrun" : "false",
				"saltJSON" : saltDict
			}


			$.ajax(
				url: "/api/cmpdRegAdmin/salts",
				type: 'POST', 
				data: JSON.stringify(requestData)
				contentType: 'application/json'
				dataType: 'json'
				success: (result) =>
					console.log(result)
					@$('.bv_confirmCreateSalt').hide()
					# Reload Search
					@searchController.doSearch("*")
					# Might Need to Do Something More Sophisticated Here
				error: (errorMsg) =>
					console.log(errorMsg)
					@$('.bv_confirmCreateSalt').hide()
					@$('.bv_errorCreatingSaltMessage').show()
					@$('.bv_createSaltErrorMessageHolder') errorMsg
			)


	handleCancelCreateClicked: =>
		@$(".bv_createSalt").hide()

	handleDownloadSaltClicked: =>
		# Create Route to Download SDF of All Salts 
		console.log("Download Salt Clicked!")
		# Use Get Route to Obtain All Salts 
		# See SDF Example Route Brain Bolt Gave 
		$.ajax
				type: 'GET'
				url: "/api/cmpdRegAdmin/salts/sdf" 
				success: (salts) =>
					# Server should've returned salts in correct formatting
					@downloadSDF("allSalts.sdf", salts)
				error: (result) =>
					# Show Window Saying Server Error ? 
					console.log(result)
	
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

		# NEED TO CHECK DEPENDENCIES 
		# Clicking Delete should trigger a dependency check. 
			# Call Dependency Check
				# See Route Brian Bolt Gave 
		# If any Lots still reference this salt, then the Salt cannot be deleted.
			# If Dependency Then Show Preconfigured "Cannot Delete Salt Message"
			# Show Error Window! 
		# If there are no dependent lots, then allow the user to confirm and proceed with the delete
			# If No Dependency Then Proceed w/ Normal Base Implementation 
			# Show Normal Window 

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
				@$(".bv_errorDeletingSaltMessage").show()
				@$(".bv_deleteErrorMessage").html errorMsg
		)

	handleCancelDeleteClicked: =>
		@$(".bv_confirmDeleteSalt").modal('hide')

	handleOkayDeleteButtonClicked: =>
		@$(".bv_confirmDeleteSalt").hide()
		@$(".bv_deleteSaltStatus").hide()

	handleEditSaltClicked: =>
		console.log("Hit Edit Button!")
		@$('.bv_editSaltWindow').show()
		currAbbrev = @saltController.model.get("abbrev")
		console.log(currAbbrev)
		@$('.bv_abbrevNameEdit').val currAbbrev
		currName = @saltController.model.get("name")
		console.log(currName)
		@$('.bv_saltNameEdit').val currName 

		molStr = @saltController.model.get("molStructure")
		console.log(molStr)

		# @$('.bv_editChemicalStructureForm').attr('src',"/lib/ketcher-2.0.0-alpha.3_custom/ketcher.html?api_path=/api/cmpdReg/ketcher/")
		# @$('.bv_editChemicalStructureForm').on('load', =>
		# 	@ketcher = @$('.bv_editChemicalStructureForm')[0].contentWindow.ketcher
		# 	@ketcher.setMolecule(molStr)
		# )
		@chemicalStructureController = new KetcherChemicalStructureController 
		$('.bv_editChemicalStructureForm').html @chemicalStructureController.render().el
		@chemicalStructureController.on('sketcherLoaded', =>
			@chemicalStructureController.setMol(molStr)
			# Need to Format It Like This To Work
		)


	handleConfirmEditSaltClicked: =>
		# Placeholder 
		console.log("Edit Button Clicked! Running Edit Dry Run")
		# Get Mol
		saltStruct = @chemicalStructureController.getMol()
		# Only New to Push This Dict Through Since Everything Else Same
		console.log(saltStruct)
		saltDict = 
		{
			"abbrev": @$('.bv_abbrevNameEdit').val(),
			"name":  @$('.bv_saltNameEdit').val(),
			"molStructure": saltStruct,
			"cdId":  @saltController.model.get("cdId"),
		}

		console.log(saltDict)

		requestData = 
			{
				"dryrun" : "true",
				"saltJSON" : saltDict
			}

		$.ajax(
			url: "/api/cmpdRegAdmin/salts/edit/#{@saltController.model.get("id")}", # NEED TO CHECK VALID ROUTE
			type: 'PUT',
			data: JSON.stringify(requestData)
			contentType: 'application/json'
			dataType: 'json'
			success: (result) =>
				console.log(result)
				@$(".bv_editSaltWindow").hide()
				@$(".bv_confirmEditSalt").show()
				# Need to Get JSON of Salt and Display in Placeholder Fields
				# Need to Generate Picture of New Structure 
				$.ajax(
					url: "/api/cmpdRegAdmin/salts",
					type: 'POST', 
					data: JSON.stringify(requestData)
					contentType: 'application/json'
					dataType: 'json'
					success: (result) =>
						console.log(result)

						# Need to Parse Result Values Into Form Fields 

						@$('.bv_abbrevNameEditConfirm').val result.abbrev
						@$('.bv_saltNameEditConfirm').val result.name
						@$('.bv_saltFormulaEditConfirm').val result.formula
						@$('.bv_saltWeightEditConfirm').val "#{result.molWeight}"
						@$('.bv_saltChargeEditConfirm').val "#{result.charge}"

						# Need to Render Preview of Structure 
						requestJSON = {
							"molStructure" : result.molStructure,
							"height" : 100, 
							"width" : 100, 
							"format" : "png"
						}

						$.ajax(
							type: 'POST'
							url: "/api/chemStructure/renderMolStructureBase64"
							contentType: 'application/json'
							dataType: 'text'
							data: JSON.stringify(requestJSON)
							success: (base64ImagePNG) => # Rendered Image Should Be Displayed on Sever
								pngSrc = "data:image/png;base64," + base64ImagePNG
								pngImage = '<img src="' + pngSrc + '" />'
								@$('.bv_saltStructEditConfirm').html pngImage 
							error: (result) =>
								console.log(result)
								@$('.bv_saltStructEditConfirm').hide()

						)
					errors: (result) =>
						console.log(result)
				)
				# Need to Also Get List of Warnings and Dependencies 
					# Parse Into Speicifc Lists 
				htmlList = '<ul>'
				for warning in result
					htmlList += '<li>' + warning.message + '</li>'          
				htmlList += '</ul>'

				console.log(htmlList)
				@$(".bv_saltDependencies").html htmlList 
			error: (result) =>
				@$(".bv_okayEditButton").show()
				@$(".bv_editSaltWindow").hide()
				@$(".bv_errorEditingSaltMessage").show()
				@$(".bv_errorEditingSaltMessage").html result
		)
	
	handleEditSaltButtonClicked: =>
		# Placeholder 
		console.log("Edit Button Clicked! Registering Edited Salt")
		# Get Mol
		saltStruct = @chemicalStructureController.getMol()
		console.log(saltStruct)

		# Salt Dict Should Be Same As Before Unless Eidts Were Done
		saltDict = 
		{
			"abbrev": @$('.bv_abbrevNameEditConfirm').val(),
			"name": @$('.bv_saltNameEditConfirm').val(),
			"molStructure": saltStruct,
			"cdId":  @saltController.model.get("cdId"),
		}

		console.log(saltDict)

		requestData = 
			{
				"dryrun" : "false",
				"saltJSON" : saltDict
			}

		$.ajax(
			url: "/api/cmpdRegAdmin/salts/edit/#{@saltController.model.get("id")}", # NEED TO CHECK VALID ROUTE
			type: 'PUT',
			data: JSON.stringify(requestData)
			contentType: 'application/json'
			dataType: 'json'
			success: (result) =>
				@$(".bv_confirmEditSalt").hide()
				@$(".bv_editSaltStatus").show()
				@$(".bv_saltEditedSuccessfullyMessage").show()
				@$(".bv_okayEditButton").show()
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

	handleBackConfirmEditClicked: => 
		@$('.bv_confirmEditSalt').hide()
		@$('.bv_editSaltWindow').show()

	handleCancelConfirmEditClicked: =>
		@$('.bv_confirmEditSalt').hide()
		@$('.bv_editSaltWindow').hide()

	handleCancelEditSaltClicked: =>
		console.log("Cancel Edit Button Clicked!")
		@$(".bv_editSaltWindow").hide()

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
