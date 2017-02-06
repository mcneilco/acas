class window.SystemTestController extends Backbone.View
	template: _.template($("#SystemTestView").html())
	moduleLaunchName: "system_test"

	events: ->
		"click .bv_runAll": "handleRunAll"
		"click .bv_forceRunAll": "handleForceRunAll"
		"click .bv_openTestResults": "handleOpenTestResults"

	initialize: ->
		$(@el).empty()
		$(@el).html @template
		@handleCheckAndDisplayLatestResults "Latest Test Results", (lastTest) =>
			@render()

	handleRunAll: ->
		@runAll false

	handleForceRunAll: ->
		@runAll true

	runAll: (force) =>
		@$('.bv_runAll').attr('disabled','disabled')
		@$('.bv_runAllText').text('Running tests...')
		@$('.bv_results').hide()
		@$('.bv_running').show()
		@handleCheckAndDisplayLatestResults()
		$.ajax
			type: 'POST'
			url: "/api/runSystemTest"
			contentType: 'application/json'
			data: JSON.stringify({'force': force})
			timeout: 0
			error: (jqXHR, textStatus, errorThrown) =>
				@$('.bv_running').hide()
				if errorThrown == "Bad Request"
					textStatus = jqXHR.responseText
				@$('.bv_runAll').removeAttr('disabled')
				@$('.bv_runAllText').text('Run Again')
				@$('.bv_results').html "error running test: #{textStatus}"
				@$('.bv_results').show()
			success: (output) =>
				@$('.bv_running').hide()
				@$('.bv_runAll').removeAttr('disabled')
				@$('.bv_runAllText').text('Run Again')
				@$('.bv_results').html "success"
				@$('.bv_results').show()
				@enableOpenTestResults()

	handleCheckAndDisplayLatestResults: ->
		$.ajax
			type: 'GET'
			url: "/api/systemReport"
			error: (jqXHR, textStatus, errorThrown) =>
				@disableOpenTestResults
			success: (output) =>
				@enableOpenTestResults()

	enableOpenTestResults:  ->
		@$('.bv_openTestResults').removeAttr('disabled')

	disableOpenTestResults: ->
		@$('.bv_openTestResults').attr('disabled', 'disabled')

	handleOpenTestResults: ->
		if @$('.bv_openTestResults').attr('disabled') != "disabled"
			window.open "/api/systemReport", "_blank"
