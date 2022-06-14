class DeleteLotController extends Backbone.View
	template: _.template($("#DeleteLotView").html())

	events:
		"click .cancelDeleteLotButton": "handleCancelButtonClicked"

	initialize: ->
		_.bindAll(@, 'handleCancelButtonClicked', 'checkDependencies', 'dependencyCheckReturn', 'dependencyCheckError');
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


	checkDependencies: ->
		@.trigger('notifyError', {
			owner: 'DeleteLotController',
			errorLevel: 'warning',
			message: 'Checking depedencies...'
		});
		url = window.configuration.serverConnection.baseServerURL+"lot/checkDependencies/"+@.corpName;
		# @delegateEvents({}); # stop listening to buttons
		$.ajax({
			type: "GET",
			url: url,
			success: @.dependencyCheckReturn,
			error: @.dependencyCheckError
		});

	dependencyCheckReturn: (data) ->
		if data.error
			@trigger('notifyError', {
				owner: 'EditParentWorkflowController',
				errorLevel: 'error',
				message: data.error
			});

	dependencyCheckError:  (data) ->
		@.trigger('clearErrors', "DeleteLotController");
		@trigger('notifyError', {
			owner: 'DeleteLotController',
			errorLevel: 'error',
			message: 'Error checking dependencies'
		});
		@$(".bv_dependencyCheckError").show();
