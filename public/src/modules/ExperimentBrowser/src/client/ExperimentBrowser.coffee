class window.ExperimentSearch extends Backbone.Model
	defaults:
		protocolCode: null
		experimentCode: null

class window.ExperimentSearchController extends AbstractFormController
	template: _.template($("#ExperimentSearchView").html())

	events:
		'change .bv_protocolName': 'updateModel'
		'change .bv_experimentCode': 'updateModel'
		'keyup .bv_experimentCode': 'updateExperimentCode'
		'click .bv_find': 'handleFindClicked'

	render: =>
		$(@el).empty()
		$(@el).html @template()
		@setupProtocolSelect()


	updateModel: =>
		@model.set
			protocolCode: @$('.bv_protocolName').val()
			experimentCode: @getTrimmedInput('.bv_experimentCode')

	updateExperimentCode: =>
		experimentCode = $.trim(@$(".bv_experimentCode").val())
		unless experimentCode is ""
			@$(".bv_protocolKind").prop("disabled", true)
			@$(".bv_protocolName").prop("disabled", true)
		else
			@$(".bv_protocolKind").prop("disabled", false)
			@$(".bv_protocolName").prop("disabled", false)

	handleFindClicked: =>
		@trigger 'find'
		protocolCode = $(".bv_protocolName").val()
		$(".bv_experimentTableController").html "Searching..."
		#$(".bv_experimentBaseController").hide()
		experimentCode = $.trim(@$(".bv_experimentCode").val())


		unless experimentCode is ""
			@doGenericExperimentSearch(experimentCode)

		else
			$.ajax
				type: 'GET'
				#url: "api/experiments/protocolCodename/#{protocolCode}"
				url: "api/experimentsForProtocol/#{protocolCode}"
				data:
					testMode: false
				success: (experiments) =>
					window.fooexperiments = experiments
					@setupExperimentSummaryTable experiments



		###$.get("/api/experiments/protocolCodename/#{protocolCode}", ( experiments ) =>
			@setupExperimentSummaryTable experiments
		)
    ###

		###
		$.get( "/api/ExperimentsForProtocol", ( experiments ) =>
			@setupExperimentSummaryTable experiments
		)
		###


	doGenericExperimentSearch: (searchTerm) =>
		console.log "doGenericExperimentSearch"
		$.ajax
			type: 'GET'
			url: "/api/experiments/genericSearch/#{searchTerm}"
			dataType: "json"
			data:
				testMode: false
				fullObject: true
			success: (experiment) =>
				window.fooexperiments = experiment
				@setupExperimentSummaryTable [experiment]

	setupProtocolSelect: ->
		@protocolList = new PickListList()
		@protocolList.url = "/api/protocolKindCodes/"
		@protocolListController = new PickListSelectController
			el: @$('.bv_protocolKind')
			collection: @protocolList
			insertFirstOption: new PickList
				code: "any"
				name: "any"
			selectedCode: null



		@protocolNameList = new PickListList()
		@protocolNameList.url = "/api/protocolCodes/"
		@protocolNameListController = new PickListSelectController
			el: @$('.bv_protocolName')
			collection: @protocolNameList
			insertFirstOption: new PickList
				code: "any"
				name: "any"
			selectedCode: null

		$(@protocolListController.el).on "change", =>
			@protocolNameList.url = "/api/protocolCodes?protocolKind=#{$(@protocolListController.el).val()}"
			@protocolNameList.reset()
			@protocolNameList.fetch()


	selectedExperimentUpdated: (experiment) =>
		@trigger "selectedExperimentUpdated"
		experimentController = new ExperimentBaseController
			model: experiment
			el: $('.bv_experimentBaseController')
			#protocolFilter: "?protocolKind=FLIPR"
		experimentController.render()
		$(".bv_experimentBaseController").show()


	setupExperimentSummaryTable: (experiments) =>
		@experimentSummaryTable = new ExperimentSummaryTableController
			el: $(".bv_experimentTableController")
			collection: new ExperimentList experiments

		@experimentSummaryTable.on "selectedRowUpdated", @selectedExperimentUpdated
		@experimentSummaryTable.render()

class window.ExperimentSearch extends Backbone.Model
	defaults:
		protocolCode: null
		experimentCode: null

class window.ExperimentSimpleSearchController extends AbstractFormController
	template: _.template($("#ExperimentSimpleSearchView").html())

	events:
		'keyup .bv_experimentSearchTerm': 'updateExperimentSearchTerm'
		'click .bv_doSearch': 'handleDoSearchClicked'

	render: =>
		$(@el).empty()
		$(@el).html @template()

	updateExperimentSearchTerm: (e) =>
		ENTER_KEY = 13
		experimentSearchTerm = $.trim(@$(".bv_experimentSearchTerm").val())
		if experimentSearchTerm isnt ""
			@$(".bv_doSearch").attr("disabled", false)
			if e.keyCode is ENTER_KEY
				$(':focus').blur()
				@handleDoSearchClicked()
		else
			@$(".bv_doSearch").attr("disabled", true)

	handleDoSearchClicked: =>
		experimentSearchTerm = $.trim(@$(".bv_experimentSearchTerm").val())
		if experimentSearchTerm isnt ""
			if @$(".bv_clearSearchIcon").hasClass "hide"
				@$(".bv_experimentSearchTerm").attr("disabled", true)
				@$(".bv_doSearchIcon").addClass "hide"
				@$(".bv_clearSearchIcon").removeClass "hide"
				@doSearch experimentSearchTerm

			else
				@$(".bv_experimentSearchTerm").val ""
				@$(".bv_experimentSearchTerm").attr("disabled", false)
				@$(".bv_clearSearchIcon").addClass "hide"
				@$(".bv_doSearchIcon").removeClass "hide"
				@updateExperimentSearchTerm()
				@trigger "resetSearch"

	doSearch: (experimentSearchTerm) =>
		@trigger 'find'
		$(".bv_experimentTableController").html "Searching..."
		unless experimentSearchTerm is ""
			console.log "doGenericExperimentSearch"
			$.ajax
				type: 'GET'
				url: "/api/experiments/genericSearch/#{experimentSearchTerm}"
				dataType: "json"
				data:
					testMode: false
					fullObject: true
				success: (experiment) =>
					@trigger "searchReturned", [experiment]


class window.ExperimentRowSummaryController extends Backbone.View
	tagName: 'tr'
	className: 'dataTableRow'
	events:
		"click": "handleClick"

	handleClick: =>
		@trigger "gotClick", @model
		$(@el).closest("table").find("tr").removeClass "info"
		$(@el).addClass "info"

	initialize: ->
		@template = _.template($('#ExperimentRowSummaryView').html())

	render: =>
		toDisplay =
			experimentName: @model.get('lsLabels').pickBestName().get('labelText')
			experimentCode: @model.get('codeName')
			protocolName: @model.get('protocol').get("preferredName")
			recordedBy: @model.get('recordedBy')
			status: @model.getStatus().get("stringValue")
			analysisStatus: @model.getAnalysisStatus().get("stringValue")
			recordedDate: @model.get("recordedDate")
		$(@el).html(@template(toDisplay))

		@

class window.ExperimentSummaryTableController extends Backbone.View
	initialize: ->

	selectedRowChanged: (row) =>
		@trigger "selectedRowUpdated", row

	render: =>
		@template = _.template($('#ExperimentSummaryTableView').html())
		$(@el).html @template
		console.dir @collection
		@collection.each (exp) =>
			ersc = new ExperimentRowSummaryController
				model: exp
			ersc.on "gotClick", @selectedRowChanged

			@$("tbody").append ersc.render().el

		@



class window.ExperimentBrowserController extends Backbone.View
	template: _.template($("#ExperimentBrowserView").html())

	events:
		"click .bv_deleteExperiment": "handleDeleteExperimentClicked"
		"click .bv_editExperiment": "handleEditExperimentClicked"

	initialize: ->
		$(@el).empty()
		$(@el).html @template()
		@searchController = new ExperimentSimpleSearchController
			model: new ExperimentSearch()
			el: @$('.bv_experimentSearchController')
		@searchController.render()
		@searchController.on "searchReturned", @setupExperimentSummaryTable
		@searchController.on "resetSearch", @destroyExperimentSummaryTable
		###
		@searchController = new ExperimentSearchController
			model: new ExperimentSearch()
			el: @$('.bv_experimentSearchController')
		@searchController.render()
		###

	setupExperimentSummaryTable: (experiments) =>
		@experimentSummaryTable = new ExperimentSummaryTableController
			collection: new ExperimentList experiments

		@experimentSummaryTable.on "selectedRowUpdated", @selectedExperimentUpdated
		$(".bv_experimentTableController").html @experimentSummaryTable.render().el
		$(".bv_matchingExperimentsHeader").removeClass "hide"

	selectedExperimentUpdated: (experiment) =>
		@trigger "selectedExperimentUpdated"
		@experimentController = new ExperimentBaseController
			model: experiment

		$('.bv_experimentBaseController').html @experimentController.render().el
		@experimentController.displayInReadOnlyMode()
		$(".bv_experimentBaseController").removeClass("hide")
		$(".bv_experimentBaseControllerContainer").removeClass("hide")

	handleDeleteExperimentClicked: =>
		$(".bv_confirmDeleteExperiment").removeClass "hide"
		$('.bv_confirmDeleteExperiment').modal({
			keyboard: false,
			backdrop: true
		})

	handleEditExperimentClicked: =>
		window.open("/api/experiments/edit/#{@experimentController.model.get("codeName")}",'_blank');

	destroyExperimentSummaryTable: =>
		@experimentSummaryTable.remove()
		@experimentController.remove()
		$(".bv_matchingExperimentsHeader").addClass "hide"
		$(".bv_experimentBaseController").addClass("hide")
		$(".bv_experimentBaseControllerContainer").addClass("hide")

	render: =>

		@

class window.ExperimentDetailController extends Backbone.View
	template: _.template($("#ExperimentDetailsView").html())

	initialize: ->
		$(@el).empty()
		$(@el).html @template()



	render: =>

		@
