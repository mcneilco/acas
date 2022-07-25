class ReparentLotController extends Backbone.View
	template: _.template($("#ReparentLotView").html())

	events:
		"click .cancelReparentLotButton": "handleCancelButtonClicked"
		"click .reparentLotButton": "handleReparentButtonClicked"
		"click .downloadLotButton": "downloadLot"
		"click .bv_backToCreg": "handleBackToCregButtonClicked"


	initialize: ->
		_.bindAll(@, 'handleCancelButtonClicked', 'handleReparentButtonClicked', 'checkDependencies', 'dependencyCheckReturn', 'dependencyCheckError', 'reparentLotError', 'reparentLotReturn', 'downloadLot', 'handleBackToCregButtonClicked');
		# $(@el).empty()
		$(@el).html @template()

		@lotLabel = if window.configuration.metaLot.lotCalledBatch == true then "Batch" else "Lot"
		@.corpName = @.options.corpName;
		@.newParentCorpName = @.options.parentCorpName;
		@$(".bv_title").html("Re-parent #{@lotLabel} #{@.corpName} on to compound #{@.newParentCorpName}: Review effects")
		@.eNotiList = @.options.errorNotifList;
		@.bind('notifyError', @.eNotiList.add);
		@.bind('clearErrors', @.eNotiList.removeMessagesForOwner);
		@checkDependencies()


	handleCancelButtonClicked: ->
		window.location.reload();

	handleReparentButtonClicked: ->
		@.trigger('clearErrors', "ReparentLotController");
		@.trigger('notifyError', {
			owner: 'ReparentLotController',
			errorLevel: 'warning',
			message: "Reparenting #{@lotLabel}..."
		});
		url = "/api/cmpdRegAdmin/lotServices/reparent/lot"
		$.ajax({
			type: "POST",
			url: url,
			data: {
				parentCorpName: @.newParentCorpName
				lotCorpName: @.corpName
			},
			success: @.reparentLotReturn,
			error: @.reparentLotError,
			dataType: "json"
		});

	checkDependencies: ->
		@.trigger('notifyError', {
			owner: 'ReparentLotController',
			errorLevel: 'warning',
			message: 'Checking dependencies...'
		});
		url = window.configuration.serverConnection.baseServerURL+"metalots/checkDependencies/corpName/"+@.corpName;
		
		# @delegateEvents({}); # stop listening to buttons
		$.ajax({
			type: "GET",
			url: url,
			success: @.dependencyCheckReturn,
			error: @.dependencyCheckError
		});
		
	downloadLot: ->
		window.open("/cmpdReg/export/corpName/"+@.corpName)

	dependencyCheckReturn: (data) ->
		@.trigger('clearErrors', "ReparentLotController");

		# Get summary of dependencies
		dependencySummary = @summarizeDependencyCheckResults(data);
		
		# Display summary of dependencies
		@$(".bv_dependencySummary").html(dependencySummary);

		# Show the summary
		@$(".bv_dependencySummary").show();
		
	handleBackToCregButtonClicked: ->
		window.location.href = 	window.configuration.serverConnection.baseServerURL
		
	getUlFromCodeArray: (codeArray, codeKey, nameKey, link) ->
		ul = "<ul>";
		_.each(codeArray, (code) ->
			descriptionText = ""
			if code.description?
				descriptionText = ": #{code.description}"
			if link?
				# target blank
				if code[codeKey] == code[nameKey]
					# target blank a tag with a href to link with code
					ul += "<li><a href='#{link+code[codeKey]}' target='_blank'>#{code[codeKey]}#{descriptionText}</a></li>"
				else
					# target blank a tag with a href to link with code
					ul += "<li><a href='#{link+code[codeKey]}' target='_blank'>#{code[codeKey]} \"#{code[nameKey]}\"</a>#{descriptionText}</li>"
			else 
				if code[codeKey] == code[nameKey]
					ul += "<li>#{code[codeKey]}#{descriptionText}</li>"
				else
					ul += "<li>#{code[codeKey]} \"#{code[nameKey]}\"#{descriptionText}" + "</li>"	
		);
		ul += "</ul>";
		return ul;
		
	summarizeLinkedCodeTable: (codeArray, header, link) ->
		# Get linked experiments summary
		entitySummary = ""
		hasLinkedEntity = codeArray? && codeArray.length > 0
		if hasLinkedEntity
			if codeArray[0].containerBarcode?
				codeKey = "containerBarcode"
				nameKey = "wellName"
			else
				codeKey = "code"
				nameKey = "name"
			linkedEntities = _.sortBy(codeArray, (codeObject) -> codeObject[codeKey])
			entitySummary += "<h3>#{header}</h3><ul>"
			ulSummary = @getUlFromCodeArray(linkedEntities, codeKey, nameKey, link)
			entitySummary += ulSummary + "</li>"
			entitySummary += "</ul>"
		return entitySummary
	
	summarizeDependencyCheckResults: (data) ->
		# Returns html string with summary of dependency check results
		
		changesToLotSummary = "<h3>Changes to this #{@lotLabel.toLowerCase()}</h3>"
		changesToLotSummary += "<ul>"
		changesToLotSummary += "<li>Parent will be updated from #{parentCorpName} to #{@.newParentCorpName}</li>"
		changesToLotSummary += "<li>#{@lotLabel} Molecular Weight will be recalculated</li>"

		# Get linked experiments summary
		experimentSummary = @summarizeLinkedCodeTable(data.linkedExperiments,"Dependent Experimental Results", "/entity/edit/codeName/")

		# Get linked lots summary
		lotSummary = @summarizeLinkedCodeTable(data.linkedLots,"Remaining Lots On Parent", "#lot/")

		# Get linked container summary
		containerSummary = @summarizeLinkedCodeTable(data.linkedContainers,"Dependent Inventory Results")

		errorSummary = "<h3>Errors</h3><ul>"
		@$('.reparentLotButton').show()
		errorSummary += "<li>None</li>"
		errorSummary += "</ul>"

		warningSummary = "<h3>Warnings</h3><ul>"
		if data.linkedLots? && data.linkedLots.length == 0
			parentCorpName = data.lot.parent.corpName
			warningSummary += "<li>This is the only lot on the parent compound #{parentCorpName}. Reparening this #{@lotLabel.toLowerCase()} will delete #{parentCorpName}.</li>"
		else
			warningSummary += "<li>None</li>"
		warningSummary += "</ul>"
		return experimentSummary + lotSummary + containerSummary + errorSummary + warningSummary;

	showOne:  (className) ->
		classes = ["bv_reparentLotError", "bv_dependencySummary", "bv_dependencyCheckError", "bv_reparentLotSuccess"]
		me = this
		_.each(classes, (c) ->
			if c == className
				me.$("." + c).show()
			else
				me.$("." + c).hide()
		)
	
	dependencyCheckError:  (data) ->
		@.trigger('clearErrors', "ReparentLotController");
		@trigger('notifyError', {
			owner: 'ReparentLotController',
			errorLevel: 'error',
			message: 'Error checking dependencies'
		})
		@showOne('bv_dependencySummary')

	reparentLotReturn: (data) ->
		@.trigger('clearErrors', "ReparentLotController");
		@trigger('notifyError', {
			owner: 'ReparentLotController',
			errorLevel: 'info',
			message: "Successfully reparented #{@lotLabel}"
		})

		successSummary = ""
		successSummary += "<h1>Success: #{@lotLabel} #{@corpName} Reparented to #{data.newLot.corpName}</h1>"
		successSummary += @summarizeLinkedCodeTable(data.dependencies.linkedExperiments,"Moved Experimental Results", "/entity/edit/codeName/")
		successSummary += @summarizeLinkedCodeTable(data.dependencies.linkedContainers,"Moved Inventory Results")

		if data.originalParentDeleted? && data.originalParentDeleted
			successSummary += "<p>The parent compound #{data.originalParentCorpName} was deleted.</p>"

		# Get summary of dependencies
		@$(".bv_reparentLotSuccess .bv_reparentLotSuccessSummary").html(successSummary)

		# Hide all buttons
		@$(".reparentLotButtons").hide()

		# Hide form title
		@$(".bv_reparentLotTitle").hide()

		# Show success message
		@showOne('bv_reparentLotSuccess')

		

	reparentLotError:  (data) ->
		@.trigger('clearErrors', "ReparentLotController");
		@trigger('notifyError', {
			owner: 'ReparentLotController',
			errorLevel: 'error',
			message: "Error reparenting #{@lotLabel}"
		})
		@showOne('bv_reparentLotError')
