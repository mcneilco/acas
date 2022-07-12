class DeleteLotController extends Backbone.View
	template: _.template($("#DeleteLotView").html())

	events:
		"click .cancelDeleteLotButton": "handleCancelButtonClicked"
		"click .deleteLotButton": "handleDeleteButtonClicked"
		"click .downloadLotButton": "downloadLot"
		"click .bv_backToCreg": "handleBackToCregButtonClicked"


	initialize: ->
		_.bindAll(@, 'handleCancelButtonClicked', 'handleDeleteButtonClicked', 'checkDependencies', 'dependencyCheckReturn', 'dependencyCheckError', 'deleteLotError', 'deleteLotReturn', 'downloadLot', 'handleBackToCregButtonClicked');
		$(@el).empty()
		$(@el).html @template()
		@lotLabel = if window.configuration.metaLot.lotCalledBatch == true then "Batch" else "Lot"
		@$(".bv_title").html("Delete #{@lotLabel} #{@.options.corpName}: Review Dependencies")
		@.corpName = @.options.corpName;
		@.eNotiList = @.options.errorNotifList;
		@.bind('notifyError', @.eNotiList.add);
		@.bind('clearErrors', @.eNotiList.removeMessagesForOwner);
		@checkDependencies()


	handleCancelButtonClicked: ->
		window.location.reload();

	handleDeleteButtonClicked: ->
		@.trigger('clearErrors', "DeleteLotController");
		@.trigger('notifyError', {
			owner: 'DeleteLotController',
			errorLevel: 'warning',
			message: "Deleting #{@lotLabel}..."
		});
		url = window.configuration.serverConnection.baseServerURL+"metalots/corpName/"+@.corpName;

		$.ajax({
			type: "DELETE",
			url: url,
			success: @.deleteLotReturn,
			error: @.deleteLotError
		});

	checkDependencies: ->
		@.trigger('notifyError', {
			owner: 'DeleteLotController',
			errorLevel: 'warning',
			message: 'Checking depedencies...'
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
		@.trigger('clearErrors', "DeleteLotController");

		# Get summary of dependencies
		dependencySummary = @summarizeDepdencyCheckResults(data);
		
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
		
	
	summarizeDepdencyCheckResults: (data) ->
		# Returns html string with summary of dependency check results
		
		# Get linked experiments summary
		experimentSummary = ""
		linkedExperiments = data.linkedExperiments? && data.linkedExperiments.length > 0
		if linkedExperiments
			linkedExperiments = _.sortBy(data.linkedExperiments, (experiment) -> experiment.code)

			experimentSummaryText = "Dependent Experimental Results"
			experimentSummary += "<h3>#{experimentSummaryText}</h3><ul>"
			deletableExperimentSummary = "<li>Which you have access to delete:"
			undeletableExperimentSummary = "<li>Which are not deletable by you:"
			unreadableExperimentSummary = "<li>Which are not readable by you:"

			deletableExperiments = linkedExperiments.filter((experiment) -> experiment.acls.delete)
			undeletableExperiments = linkedExperiments.filter((experiment) -> experiment.acls.read && !experiment.acls.delete)
			unreadableExperimentsCount = linkedExperiments.filter((experiment) -> !experiment.acls.read).length
			

			if deletableExperiments.length > 0
				deletableExperimentSummary += @getUlFromCodeArray(deletableExperiments, "/entity/edit/codeName/")
				experimentSummary += deletableExperimentSummary + "</li>"

			if undeletableExperiments.length > 0
				undeletableExperimentSummary += @getUlFromCodeArray(undeletableExperiments, "/entity/edit/codeName/")
				experimentSummary += undeletableExperimentSummary + "</li>"

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
			
			## Add the lot summary as a global to the controller so it can be displayed again after delete
			@lotSummary = lotSummary

		errorSummary = "<h3>Errors</h3><ul>"
		if linkedExperiments && (unreadableExperimentsCount > 0 || undeletableExperiments.length > 0)
			@$('.deleteLotButton').hide()
			errorSummary += "<li>You do not have the necessary permissions to delete associated experimental results. Please contact your Administrator for assistance.</li>"
		else
			@$('.deleteLotButton').show()
			errorSummary += "<li>None</li>"
		errorSummary += "</ul>"

		warningSummary = "<h3>Warnings</h3><ul>"
		deletableExperiments = (linkedExperiments && deletableExperiments.length > 0)
		if deletableExperiments || !linkedLots
			if deletableExperiments
				warningSummary += "<li>Deleting this #{@lotLabel.toLowerCase()} will also delete the associated experimental results. This will not affect results in the same experiment associated with other compound #{@lotLabel.toLowerCase()}s.</li>"
			if !linkedLots
				parentCorpName = data.lot.parent.corpName
				warningSummary += "<li>This is the only lot on the parent compound #{parentCorpName}. Deleting this #{@lotLabel.toLowerCase()} will delete #{parentCorpName} also.</li>"
		else
			warningSummary += "<li>None</li>"
		warningSummary += "</ul>"
		return experimentSummary + lotSummary + errorSummary + warningSummary;

	showOne:  (className) ->
		classes = ["bv_deleteLotError", "bv_dependencySummary", "bv_dependencyCheckError", "bv_deleteLotSuccess"]
		me = this
		_.each(classes, (c) ->
			if c == className
				me.$("." + c).show()
			else
				me.$("." + c).hide()
		)
	
	dependencyCheckError:  (data) ->
		@.trigger('clearErrors', "DeleteLotController");
		@trigger('notifyError', {
			owner: 'DeleteLotController',
			errorLevel: 'error',
			message: 'Error checking dependencies'
		})
		@showOne('bv_dependencySummary')

	deleteLotReturn: (data) ->
		@.trigger('clearErrors', "DeleteLotController");
		@trigger('notifyError', {
			owner: 'DeleteLotController',
			errorLevel: 'info',
			message: "Successfully deleted #{@lotLabel}"
		})
		# Get summary of dependencies
		@$(".bv_remainingLotsOnParentLinks").html(@lotSummary)

		# Hide all buttons
		@$(".deleteLotButtons").hide()

		# Hide form title
		@$(".bv_deleteLotTitle").hide()

		# Show success message
		@showOne('bv_deleteLotSuccess')

		

	deleteLotError:  (data) ->
		@.trigger('clearErrors', "DeleteLotController");
		@trigger('notifyError', {
			owner: 'DeleteLotController',
			errorLevel: 'error',
			message: "Error deleting #{@lotLabel}"
		})
		@showOne('bv_deleteLotError')
