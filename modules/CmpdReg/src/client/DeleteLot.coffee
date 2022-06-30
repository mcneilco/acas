class DeleteLotController extends Backbone.View
	template: _.template($("#DeleteLotView").html())

	events:
		"click .cancelDeleteLotButton": "handleCancelButtonClicked"
		"click .deleteLotButton": "handleDeleteButtonClicked"

	initialize: ->
		_.bindAll(@, 'handleCancelButtonClicked', 'handleDeleteButtonClicked', 'checkDependencies', 'dependencyCheckReturn', 'dependencyCheckError', 'deleteLotError', 'deleteLotReturn');
		$(@el).empty()
		$(@el).html @template()
		@$(".bv_title").html("Delete " + @.options.corpName + ": Review Dependencies")
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
			message: 'Deleting lot...'
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
		

	dependencyCheckReturn: (data) ->
		@.trigger('clearErrors', "DeleteLotController");

		# Get summary of dependencies
		dependencySummary = @summarizeDepdencyCheckResults(data);
		
		# Display summary of dependencies
		@$(".bv_dependencySummary").html(dependencySummary);

		# Show the summary
		@$(".bv_dependencySummary").show();
		
		
	getUlFromCodeArray: (codeArray, link) ->
		ul = "<ul>";
		_.each(codeArray, (code) ->
			if link?
				# target blank
				if code.name == code.name
					# target blank a tag with a href to link with code
					ul += "<li><a href='"+link+code.name+"' target='_blank'>"+code.name+"</a></li>"
				else
					# target blank a tag with a href to link with code
					ul += "<li><a href='"+link+code.name+"' target='_blank'>"+code.name+"</a> ("+code.code+")</li>"
			else 
				if code.name == code.code
					ul += "<li>" + code.name + "</li>"
				else
					ul += "<li>" + code.name + " (" + code.code + ")" + "</li>"	
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

			experimentSummaryHeader = "Dependent Experimental Results"
			deletableExperimentSummary = "<h3>#{experimentSummaryHeader}:</h3>"
			undeletableExperimentSummary = "<h3>#{experimentSummaryHeader} which are not deletable by you:</h3>"
			unreadableExperimentSummary = "<h3>#{experimentSummaryHeader} which are not readable by you:</h3>"

			deletableExperiments = linkedExperiments.filter((experiment) -> experiment.acls.delete)
			undeletableExperiments = linkedExperiments.filter((experiment) -> experiment.acls.read && !experiment.acls.delete)
			unreadableExperimentsCount = linkedExperiments.filter((experiment) -> !experiment.acls.read).length
			

			if deletableExperiments.length > 0
				deletableExperimentSummary += @getUlFromCodeArray(deletableExperiments)
			else
				deletableExperimentSummary += "<p>None</p>"

			if undeletableExperiments.length > 0
				undeletableExperimentSummary += @getUlFromCodeArray(undeletableExperiments)
			else
				undeletableExperimentSummary += "<p>None</p>"

			if unreadableExperimentsCount > 0
				unreadableExperimentSummary += "<p>#{unreadableExperimentsCount}</p>"
			else
				unreadableExperimentSummary += "<p>None</p>"
			experimentSummary = deletableExperimentSummary

		# Get linked lots summary
		lotSummary = ""
		linkedLots =  (data.linkedLots? && data.linkedLots.length > 0)
		if linkedLots
			# Sorty the list of lots
			linkedLots = _.sortBy(data.linkedLots, (lot) -> lot.code)

			lotSummaryHeader = "Remaining Lots On This Parent"
			deletableLotSummary = "<h3>#{lotSummaryHeader}:</h3>"
			readableLotSummary = "<h3>#{lotSummaryHeader} which are not deletable by you:</h3>"
			unreadableLotSummary = "<h3>#{lotSummaryHeader} which are not readable by you:</h3>"

			deletableLots = linkedLots.filter((lot) -> lot.acls.delete)
			readableLots = linkedLots.filter((lot) -> lot.acls.read && !lot.acls.delete)
			unreadableLotsCount = linkedLots.filter((lot) -> !lot.acls.read).length

			if deletableLots.length > 0
				deletableLotSummary += @getUlFromCodeArray(deletableLots, "#lot/")
			else
				deletableLotSummary += "<p>None</p>"

			if readableLots.length > 0
				readableLotSummary += @getUlFromCodeArray(readableLots, "#lot/")
			else
				readableLotSummary += "<p>None</p>"

			if unreadableLotsCount > 0
				unreadableLotSummary += "<p>#{unreadableLotsCount}</p>"
			else
				unreadableLotSummary += "<p>None</p>"

			lotSummary = deletableLotSummary
			@lotSummary = lotSummary

		errorSummary = "<h3>Errors</h3>"
		if linkedExperiments && (unreadableExperimentsCount > 0 || undeletableExperiments.length > 0)
			@$('.deleteLotButton').hide()
			errorSummary += unreadableExperimentSummary + undeletableExperimentSummary
		else
			@$('.deleteLotButton').show()
			errorSummary += "<p>None</p>"

		warningSummary = "<h3>Warnings</h3>"
		deletableExperiments = (linkedExperiments && deletableExperiments.length > 0)
		if deletableExperiments || !linkedLots
			warningSummary += "<ul>"
			if deletableExperiments
				warningSummary += "<li>Deleting this lot will also delete associated assay results. This will not affect results in the same experiment associated with other compound lots.</li>"
			if !linkedLots
				parentCorpName = data.metaLot.lot.parent.corpName
				warningSummary += "<li>This is the only lot on the parent structure #{parentCorpName}. Deleting this lot will delete #{parentCorpName} also.</li>"
			warningSummary += "</ul>"
		else
			warningSummary += "<p>None</p>"

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
			message: 'Successfully deleted lot'
		})
		# Get summary of dependencies
		@$(".bv_remainintLotsOnParentLinks").html(@lotSummary)
		@$(".bv_backToCreg").attr("href", window.configuration.serverConnection.baseServerURL)

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
			message: 'Error deleting lot'
		})
		@showOne('bv_deleteLotError')
