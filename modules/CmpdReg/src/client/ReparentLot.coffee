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
		
	getUlFromCodeArray: (codeArray, link) ->
		ul = "<ul>";
		_.each(codeArray, (code) ->
			descriptionText = ""
			if code.description?
				descriptionText = ": #{code.description}"
			if link?
				# target blank
				if code.code == code.name
					# target blank a tag with a href to link with code
					ul += "<li><a href='#{link+code.code}' target='_blank'>#{code.code}#{descriptionText}</a></li>"
				else
					# target blank a tag with a href to link with code
					ul += "<li><a href='#{link+code.code}' target='_blank'>#{code.code} \"#{code.name}\"</a>#{descriptionText}</li>"
			else 
				if code.name == code.code
					ul += "<li>#{code.code}#{descriptionText}</li>"
				else
					ul += "<li>#{code.code} \"#{code.name}\"#{descriptionText}" + "</li>"	
		);
		ul += "</ul>";
		return ul;
		
	
	summarizeDependencyCheckResults: (data) ->
		# Returns html string with summary of dependency check results
		

		changesToLotSummary = "<h3>Changes to this #{@lotLabel.toLowerCase()}</h3>"
		changesToLotSummary += "<ul>"
		changesToLotSummary += "<li>Parent will be updated from #{parentCorpName} to #{@.newParentCorpName}</li>"
		changesToLotSummary += "<li>#{@lotLabel} Molecular Weight will be recalculated</li>"
		
		# Get linked experiments summary
		experimentSummary = ""
		linkedExperiments = data.linkedExperiments? && data.linkedExperiments.length > 0
		if linkedExperiments
			linkedExperiments = _.sortBy(data.linkedExperiments, (experiment) -> experiment.code)

			experimentSummaryText = "Dependent Experimental Results"
			experimentSummary += "<h3>#{experimentSummaryText}</h3><ul>"
			modifableExperimentSummary = "<li>Which you have access to modify:"
			unmodifableExperimentSummary = "<li>Which are not modifable by you:"
			unreadableExperimentSummary = "<li>Which are not readable by you:"

			modifableExperiments = linkedExperiments.filter((experiment) -> experiment.acls.write)
			unmodifableExperiments = linkedExperiments.filter((experiment) -> experiment.acls.read && !experiment.acls.write)
			unreadableExperimentsCount = linkedExperiments.filter((experiment) -> !experiment.acls.read).length
			

			if modifableExperiments.length > 0
				modifableExperimentSummary += @getUlFromCodeArray(modifableExperiments, "/entity/edit/codeName/")
				experimentSummary += modifableExperimentSummary + "</li>"

			if unmodifableExperiments.length > 0
				unmodifableExperimentSummary += @getUlFromCodeArray(unmodifableExperiments, "/entity/edit/codeName/")
				experimentSummary += unmodifableExperimentSummary + "</li>"

			if unreadableExperimentsCount > 0
				unreadableExperimentSummary += " #{unreadableExperimentsCount}"
				experimentSummary += unreadableExperimentSummary + "</li>"
			experimentSummary += "</ul>"

		# Get linked lots summary
		lotSummary = ""
		linkedLots =  (data.linkedLots? && data.linkedLots.length > 0)
		if linkedLots
			linkedLots = _.sortBy(data.linkedLots, (lot) -> lot.code)

			lotSummaryText = "Remaining Lots On Parent"
			lotSummary += "<h3>#{lotSummaryText}</h3><ul>"
			readableLotSummary = "<li>Which are readable by you:"
			unreadableLotSummary = "<li>Which are not readable by you:"

			readableLots = linkedLots.filter((lot) -> lot.acls.read)
			unreadableLotsCount = linkedLots.filter((lot) -> !lot.acls.read).length

			if readableLots.length > 0
				readableLotSummary += @getUlFromCodeArray(readableLots, "#lot/")
				lotSummary += readableLotSummary + "</li>"

			if unreadableLotsCount > 0
				unreadableLotSummary += " #{unreadableLotsCount}"
				lotSummary += unreadableLotSummary + "</li>"
			lotSummary += "</ul>"
			
			## Add the lot summary as a global to the controller so it can be displayed again after reparenting
			@lotSummary = lotSummary

		errorSummary = "<h3>Errors</h3><ul>"
		if linkedExperiments && (unreadableExperimentsCount > 0 || unmodifableExperiments.length > 0)
			@$('.reparentLotButton').hide()
			errorSummary += "<li>You do not have the necessary permissions to edit associated experimental results. Please contact your Administrator for assistance.</li>"
		else
			@$('.reparentLotButton').show()
			errorSummary += "<li>None</li>"
		errorSummary += "</ul>"

		warningSummary = "<h3>Warnings</h3><ul>"
		modifableExperiments = (linkedExperiments && modifableExperiments.length > 0)
		if modifableExperiments || !linkedLots
			if modifableExperiments
				warningSummary += "<li>Reparenting this #{@lotLabel.toLowerCase()} will update dependent experimental results to reference the new #{@lotLabel} Corp Name. This will cause the database to diverge from the original experiment upload file.</li>"
			if !linkedLots
				parentCorpName = data.lot.parent.corpName
				warningSummary += "<li>This is the only lot on the parent compound #{parentCorpName}. Reparening this #{@lotLabel.toLowerCase()} will delete #{parentCorpName}.</li>"
		else
			warningSummary += "<li>None</li>"
		warningSummary += "</ul>"
		return experimentSummary + lotSummary + errorSummary + warningSummary;

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
		# Get summary of dependencies
		@$(".bv_reparentLotSuccess .bv_reparentLotSuccessSummary").html("<a href='#lot/#{data.newLot.corpName}' target='_blank'>#{data.newLot.corpName}</a>")

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
