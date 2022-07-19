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
		$(".bv_saltTableController").addClass "hide"
		$(".bv_errorOccurredPerformingSearch").addClass "hide"
		saltSearchTerm = $.trim(@$(".bv_saltSearchTerm").val())
		$(".bv_exptSearchTerm").val ""
		if saltSearchTerm isnt ""
			$(".bv_noMatchingSaltsFoundMessage").addClass "hide"
			$(".bv_saltBrowserSearchInstructions").addClass "hide"
			$(".bv_searchSaltsStatusIndicator").removeClass "hide"
			if !window.conf.browser.enableSearchAll and saltSearchTerm is "*"
				$(".bv_moreSpecificSaltSearchNeeded").removeClass "hide"
			else 
				$(".bv_searchingSaltsMessage").removeClass "hide"
				$(".bv_exptSearchTerm").html _.escape(saltSearchTerm)
				$(".bv_moreSpecificSaltSearchNeeded").addClass "hide"
				@doSearch saltSearchTerm

	doSearch: (saltSearchTerm) => 
		@$(".bv_saltSearchTerm").attr "disabled", true
		@$(".bv_doSearch").attr "disabled", true
		@trigger 'find'
		unless saltSearchTerm is "" 
			$.ajax
				type: 'GET'
				url: @genericSearchUrl # + "/search/" + saltSearchTerm
				# CHANGE THIS AND FIX SEARCH
				contentType: "application/json"
				dataType: "json"
				success: (salt) =>
					@trigger "searchReturned", salt
				error: (result) =>
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
			$(".bv_noMatchingSaltsFoundMessage").removeClass "hide"
		else
			$(".bv_noMatchingSaltsFoundMessage").addClass "hide"
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
		"click .bv_deleteSalt": "handleDeleteSaltClicked" 
		"click .bv_confirmDeleteSaltButton": "handleConfirmDeleteSaltClicked"
		"click .bv_cancelDelete": "handleCancelDeleteClicked"
		"click .bv_downloadSaltBtn": "handleDownloadSaltClicked"
		"click .bv_createNewSaltBtn": "handleCreateSaltClicked"
		"click .bv_confirmCreateSaltButton": "handleConfirmCreateSaltClicked"
		"click .bv_cancelCreate": "handleCancelCreateClicked"
		"click .bv_editSalt": "handleEditSaltClicked"
		"click .bv_confirmEditSaltButton": "handleConfirmEditSaltClicked"
		"click .bv_cancelEdit":"handleCancelEditSaltClicked"

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

		$(".bv_searchingSaltsMessage").addClass "hide"
		if salts is null
			@$(".bv_errorOccurredPerformingSearch").removeClass "hide"

		else if salts.length is 0
			@$(".bv_noMatchingSaltsFoundMessage").removeClass "hide"
			@$(".bv_saltTableController").html ""
		else
			$(".bv_searchSaltsStatusIndicator").addClass "hide"
			@$(".bv_saltTableController").removeClass "hide"
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

				# Not Implemented Fully Yet

	handleCreateSaltClicked: =>
		# Call Chemical Structure Service to Create Salt 
		console.log("Create Salt Clicked!")
		# Use ACASFormChemicalStructureController 
		@$('.bv_createSalt').show()
		@chemicalStructureController = new KetcherChemicalStructureController 
		$('.bv_chemicalStructureForm').html @chemicalStructureController.render().el
		# Sketcher should be controlled by CReg sketcher settings!!
		# Need to Setup Text Boxes for Name and Abbrev

	handleConfirmCreateSaltClicked: =>
		# Need to Check Name, Struct, and Abbrev Are All Filled! 
		saltAbbrev = UtilityFunctions::getTrimmedInput @$('.bv_abbrevName')
		
		saltName = UtilityFunctions::getTrimmedInput @$('.bv_saltName')

		saltStruct = @chemicalStructureController.getMol()

		# TO DO VALIDATION WORK HERE
		
		saltDict = 
		{
			"abbrev": saltAbbrev,
			"molStructure": saltStruct,
			"name": saltName,
		}


		$.ajax(
			url: "/api/cmpdRegAdmin/salts",
			type: 'POST', 
			data: JSON.stringify(saltDict)
			contentType: 'application/json'
			dataType: 'json'
			success: (result) =>
				console.log(result)
				@$('.bv_createSalt').hide()
				# Reload Search
				@searchController.doSearch("*")
			error: (result) =>
				console.log(result)
				@$('.bv_createSalt').hide()
				@$('.bv_errorCreatingSaltMessage').show()
				# Change Windows 
					# @$('.bv_createSalt').hide()
					# Show Error Window! 
					# Alternative: Insert Error Elements
				# Report Errors To User
		)

	handleCancelCreateClicked: =>
		console.log("Confirm Cancel Salt Clicked")
		@$(".bv_createSalt").hide()

	handleDownloadSaltClicked: =>
		# Create Route to Download SDF of All Salts 
		console.log("Download Salt Clicked!")
		# Use Get Route to Obtain All Salts 
		# See SDF Example Route Brain Bolt Gave 
		$.ajax
				type: 'GET'
				url: "/api/cmpdRegAdmin/salts" 
				success: (salts) =>
					console.log(salts)
				error: (result) =>
					console.log(result)
	
	handleDeleteSaltClicked: =>
		@$(".bv_saltUserName").html @saltController.model.get("name") 
		@$(".bv_deleteButtons").removeClass "hide"
		#@$(".bv_okayButton").addClass "hide"
		@$(".bv_errorDeletingSaltMessage").addClass "hide"
		@$(".bv_deleteWarningMessage").removeClass "hide"
		@$(".bv_deletingStatusIndicator").addClass "hide"
		@$(".bv_saltDeletedSuccessfullyMessage").addClass "hide"
		$(".bv_confirmDeleteSalt").removeClass "hide"
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

	# Not Implemented Fully Yet
	handleConfirmDeleteSaltClicked: =>
		@$(".bv_deleteWarningMessage").addClass "hide"
		@$(".bv_deletingStatusIndicator").removeClass "hide"
		@$(".bv_deleteButtons").addClass "hide"

		$.ajax(
			url: "/api/cmpdRegAdmin/salts/#{@saltController.model.get("id")}", # NEED TO CHECK VALID ROUTE
			type: 'DELETE', 
			success: (result) =>
				#@$(".bv_okayButton").removeClass "hide"
				@$(".bv_deletingStatusIndicator").addClass "hide"
				@$(".bv_saltDeletedSuccessfullyMessage").removeClass "hide"
				@searchController.handleDoSearchClicked()
			error: (result) =>
				#@$(".bv_okayButton").removeClass "hide"
				@$(".bv_deletingStatusIndicator").addClass "hide"
				@$(".bv_errorDeletingSaltMessage").removeClass "hide"
		)

	handleCancelDeleteClicked: =>
		@$(".bv_confirmDeleteSalt").modal('hide')

	handleEditSaltClicked: =>
		# Need to Implement
		console.log("Hit Edit Button!")
		@$('.bv_editSaltWindow').show()

		molStr = @saltController.model.get("molStructure")
		console.log(molStr)

		@chemicalStructureController = new KetcherChemicalStructureController 
		$('.bv_editChemicalStructureForm').html @chemicalStructureController.render().el

		#molSet = @chemicalStructureController.setMol(molStr)
		#This Is Causing Problems

		# Sketcher should be controlled by CReg sketcher settings!! 

	handleConfirmEditSaltClicked: =>
		# Placeholder 
		console.log("Confirm Edit Button Clicked!")
		# Get Mol
		saltStruct = @chemicalStructureController.getMol()
		# Only New to Push This Dict Through Since Everything Else Same
		saltDict = 
		{
			"molStructure": saltStruct,
		}
		# Restandardization Call

		$.ajax(
			url: "/api/cmpdRegAdmin/salts/#{@saltController.model.get("id")}", # NEED TO CHECK VALID ROUTE
			type: 'POST',
			data: JSON.stringify(saltDict)
			contentType: 'application/json'
			dataType: 'json'
			success: (result) =>
				console.log(result)
			error: (result) =>
				console.log(result)
		)

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
