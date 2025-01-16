class ReparentLotController extends Backbone.View
	template: _.template($("#ReparentLotView").html())

	events:
		"click .cancelReparentLotButton": "handleCancelButtonClicked"
		"click .reparentLotButton": "handleReparentButtonClicked"
		"click .backFromReparentLotButton": "back"
		"click .bv_backToCreg": "handleBackToCregButtonClicked"


	initialize: (options) ->
		@options = options
		_.bindAll(@, 'handleCancelButtonClicked', 'handleReparentButtonClicked', 'reparentDryRun', 'reparentDryRunReturn', 'reparentDryRunError', 'reparentLotError', 'reparentLotReturn', 'back', 'handleBackToCregButtonClicked');
		# $(@el).empty()
		$(@el).html @template()
		@lotLink = "#lot/"
		@lotLabel = if window.configuration.metaLot.lotCalledBatch == true then "Batch" else "Lot"
		@.corpName = @.options.corpName;
		@.newParentCorpName = @.options.parentCorpName;
		@$(".bv_title").html("Re-parent #{@lotLabel} #{@.corpName} on to compound #{@.newParentCorpName}: Review effects")
		@.eNotiList = @.options.errorNotifList;
		@.bind('notifyError', @.eNotiList.add);
		@.bind('clearErrors', @.eNotiList.removeMessagesForOwner);
		@reparentDryRun()


	handleCancelButtonClicked: ->
		window.location.reload();

	handleReparentButtonClicked: ->
		@.trigger('clearErrors', "ReparentLotController");
		@.trigger('notifyError', {
			owner: 'ReparentLotController',
			errorLevel: 'warning',
			message: "Reparenting #{@lotLabel}..."
		});
		url = "/api/cmpdRegAdmin/lotServices/reparent/lot?dryRun=false"
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

	reparentDryRun: ->
		@.trigger('notifyError', {
			owner: 'ReparentLotController',
			errorLevel: 'warning',
			message: 'Checking dependencies...'
		});
		url = "/api/cmpdRegAdmin/lotServices/reparent/lot?dryRun=true"
		$.ajax({
			type: "POST",
			url: url,
			data: {
				parentCorpName: @.newParentCorpName
				lotCorpName: @.corpName
			},
			success: @.reparentDryRunReturn,
			error: @.reparentDryRunError
			dataType: "json"
		});

		
	back: ->
		this.hide()
		@.trigger("back")

	hide: ->
		$(this.el).hide()

	show: ->
		$(this.el).show()

	reparentDryRunReturn: (data) ->
		@.trigger('clearErrors', "ReparentLotController");

		# Get summary of dependencies
		dependencySummary = @summarizeDryRunResults(data);
		
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
			entitySummary += "<li>#{header}</li>"
			ulSummary = @getUlFromCodeArray(linkedEntities, codeKey, nameKey, link)
			entitySummary += ulSummary
		return entitySummary
	
	summarizeDryRunResults: (data) ->
		# Returns html string with summary of dependency check results
		
		dependencies = data.dependencies
		changesToLotSummary = "<h3>Changes to this #{@lotLabel.toLowerCase()}</h3>"
		changesToLotSummary += "<ul>"
		changesToLotSummary += "<li>Parent will be updated from #{data.originalParentCorpName} to #{@.newParentCorpName}</li>"
		changesToLotSummary += "<li>#{@lotLabel} Molecular Weight will be recalculated</li>"
		changesToLotSummary += "<li>#{@lotLabel} Number will be updated from #{data.originalLotNumber} to #{data.newLot.lotNumber}</li>"
		changesToLotSummary += "<li>#{@lotLabel} Name will be: #{data.newLot.corpName}</li>"

		# Get linked experiments summary
		experimentSummary = @summarizeLinkedCodeTable(dependencies.linkedExperiments, "Dependent experiment results which will be moved to #{@.newParentCorpName}", "/entity/edit/codeName/")
		changesToLotSummary += experimentSummary

		# Get linked lots summary
		lotSummary = @summarizeLinkedCodeTable(dependencies.linkedLots,"Remaining Lots On Parent", @lotLink)

		# Get linked container summary
		containerSummary = @summarizeLinkedCodeTable(dependencies.linkedContainers,"Dependent Inventory Results")
		changesToLotSummary += containerSummary

		changesToLotSummary += "</ul>"

		errorSummary = "<h3>Errors</h3><ul>"
		# Currently we don't have any error cases so we alway show the reparent lot button on successful service call.
		@$('.reparentLotButton').show();
		errorSummary += "<li>None</li>"
		errorSummary += "</ul>"

		warningSummary = "<h3>Warnings</h3><ul>"
		if dependencies.linkedLots? && dependencies.linkedLots.length == 0
			parentCorpName = dependencies.lot.parent.corpName
			warningSummary += "<li>This is the only lot on the parent compound #{parentCorpName}. Reparenting this #{@lotLabel.toLowerCase()} will delete #{parentCorpName}.</li>"
		else
			warningSummary += "<li>None</li>"
		warningSummary += "</ul>"
		return changesToLotSummary + lotSummary + errorSummary + warningSummary;

	showOne:  (className) ->
		classes = ["bv_reparentLotError", "bv_dependencySummary", "bv_dependencyCheckError", "bv_reparentLotSuccess"]
		me = this
		_.each(classes, (c) ->
			if c == className
				me.$("." + c).show()
			else
				me.$("." + c).hide()
		)
	
	reparentDryRunError: (xhr, status, error) ->
		@.trigger('clearErrors', "ReparentLotController");

		message = "Error checking #{@lotLabel.toLowerCase()} dependencies"
		if error == "Conflict"
			message = xhr.responseText

		@trigger('notifyError', {
			owner: 'ReparentLotController',
			errorLevel: 'error',
			message: message
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

		# Changes to this lot
		successSummary += "<h3>Changes to this #{@lotLabel.toLowerCase()}</h3>"
		successSummary += "<ul>"
		aTag = "<a href='#{@lotLink+data.newLot.corpName}' target='_blank'>#{data.newLot.corpName}</a>"
		successSummary += "<li>The #{@lotLabel} was reparented to #{aTag}</li>"
		if data.originalParentDeleted? && data.originalParentDeleted
			successSummary += "<li>The parent compound #{data.originalParentCorpName} was deleted.</li>"

		# Moveed experiment results summary
		successSummary += @summarizeLinkedCodeTable(data.dependencies.linkedExperiments,"Moved Experimental Results", "/entity/edit/codeName/")

		# Moved Inventory results summary
		successSummary += @summarizeLinkedCodeTable(data.dependencies.linkedContainers,"Moved Inventory Results")

		successSummary += "</ul>"

		# Get summary of dependencies
		@$(".bv_reparentLotSuccess .bv_reparentLotSuccessSummary").html(successSummary)

		# Hide all buttons
		@$(".reparentLotButtons").hide()

		# Hide form title
		@$(".bv_reparentLotTitle").hide()

		# Show success message
		@showOne('bv_reparentLotSuccess')

	reparentLotError: (xhr, status, error) ->
		# Hide the reparent lot button and disable it
		@$(".reparentLotButton").hide()
		@$(".reparentLotButton").attr("disabled", "disabled")
		
		message = "Error reparenting #{@lotLabel}"
		if error == "Conflict"
			message = xhr.responseText

		@.trigger('clearErrors', "ReparentLotController");
		@trigger('notifyError', {
			owner: 'ReparentLotController',
			errorLevel: 'error',
			message: message
		})
		@showOne('bv_reparentLotError')
