class window.ScreeningExperiment extends PrimaryScreenExperiment #TODO: make Parent Experiment separately and make Screening Experiment

	initialize: ->
		super()
		@set lsType: "Parent"
		@set lsKind: "Bio Activity Screen"

	getAnalysisParameters: =>
		ap = @.get('lsStates').getOrCreateValueByTypeAndKind "metadata", "experiment metadata", "clobValue", "data analysis parameters"
		if ap.get('clobValue')?
			return new ScreeningExperimentParameters $.parseJSON(ap.get('clobValue'))
		else
			return new ScreeningExperimentParameters()

class window.ScreeningExperimentParameters extends Backbone.Model
	defaults: ->
		signalDirectionRule: "unassigned"
		aggregateBy: "unassigned"
		aggregationMethod: "unassigned"
		normalization: new Normalization()
		transformationRuleList: new TransformationRuleList()
		hitEfficacyThreshold: null
		hitSDThreshold: null
		thresholdType: null
		useOriginalHits: false
		autoHitSelection: false

	initialize: ->
		@.set @parse(@.attributes)

	parse: (resp) =>
		if resp.transformationRuleList?
			if resp.transformationRuleList not instanceof TransformationRuleList
				resp.transformationRuleList = new TransformationRuleList(resp.transformationRuleList)
			resp.transformationRuleList.on 'change', =>
				@trigger 'change'
			resp.transformationRuleList.on 'amDirty', =>
				@trigger 'amDirty'
		if resp.normalization?
			if resp.normalization not instanceof Normalization
				resp.normalization = new Normalization(resp.normalization)
			resp.normalization.on 'change', =>
				@trigger 'change'
			resp.normalization.on 'amDirty', =>
				@trigger 'amDirty'
		resp

	validate: (attrs) =>
		errors = []
		transformationErrors = @get('transformationRuleList').validateCollection()
		errors.push transformationErrors...
		if attrs.signalDirectionRule is "unassigned" or attrs.signalDirectionRule is null
			errors.push
				attribute: 'signalDirectionRule'
				message: "Signal Direction Rule must be assigned"
		if attrs.aggregateBy is "unassigned" or attrs.aggregateBy is null
			errors.push
				attribute: 'aggregateBy'
				message: "Aggregate By must be assigned"
		if attrs.aggregationMethod is "unassigned" or attrs.aggregationMethod is null
			errors.push
				attribute: 'aggregationMethod'
				message: "Aggregation method must be assigned"
		if not attrs.normalization? or attrs.normalization.get('normalizationRule') is "unassigned"
			errors.push
				attribute: 'normalizationRule'
				message: "Normalization rule must be assigned"
		if attrs.autoHitSelection
			if attrs.thresholdType == "sd" && _.isNaN(attrs.hitSDThreshold)
				errors.push
					attribute: 'hitSDThreshold'
					message: "SD threshold must be a number"
			if attrs.thresholdType == "efficacy" && _.isNaN(attrs.hitEfficacyThreshold)
				errors.push
					attribute: 'hitEfficacyThreshold'
					message: "Efficacy threshold must be a number"
		if errors.length > 0
			return errors
		else
			return null


class window.SearchedExperimentRowSummaryController extends ExperimentRowSummaryController
	#for row in table of experiments returned from search
	events:
		"click .bv_addExperiment": "handleClick"

	initialize: ->
		@template = _.template($('#SearchedExperimentRowSummaryView').html())

	render: =>
		super()
		@$('.bv_experimentCodeLink').attr 'href', "/entity/edit/codeName/#{@model.get("codeName")}"

		@

	handleClick: =>
		super()
		@trigger 'amDirty'

class window.SearchedExperimentSummaryTableController extends ExperimentSummaryTableController
	#for table of experiments returned from search

	selectedRowChanged: (row) =>
		@trigger "selectedRowUpdated", row
		aoData = @dataTable.fnSettings().aoData
		aData = _.pluck aoData, '_aData'
		exptNames = _.pluck aData, '2'
		index = _.indexOf exptNames, row.get('lsLabels').pickBestName().get('labelText')
		@dataTable.fnDeleteRow(index)


	render: =>
		@template = _.template($('#SearchedExperimentSummaryTableView').html())
		$(@el).html @template
		if @collection.models.length is 0
			$(".bv_noMatchingExperimentsFoundMessage"+@domSuffix).removeClass "hide"
			# display message indicating no results were found
		else
			$(".bv_noMatchingExperimentsFoundMessage"+@domSuffix).addClass "hide"
			@collection.each (exp) =>
				hideStatusesList = null
				if window.conf.entity?.hideStatuses?
					hideStatusesList = window.conf.entity.hideStatuses
				#non-admin users can't see experiments with statuses in hideStatusesList
				unless (hideStatusesList? and hideStatusesList.length > 0 and hideStatusesList.indexOf(exp.getStatus().get 'codeValue') > -1 and !(UtilityFunctions::testUserHasRole window.AppLaunchParams.loginUser, ["admin"]))
					ersc = new SearchedExperimentRowSummaryController
						model: exp
					ersc.on "gotClick", @selectedRowChanged
					ersc.on 'amDirty', =>
						@trigger 'amDirty'
					@$("tbody").append ersc.render().el

			@dataTable = @$("table").dataTable oLanguage:
				sSearch: "Filter results: " #rename summary table's search bar

		@

class window.AddedExperimentRowSummaryController extends ExperimentRowSummaryController
	#for row in table of experiments returned from search

	initialize: ->
		@template = _.template($('#AddedExperimentRowSummaryView').html())

	render: =>
		super()
		@$('.bv_experimentCodeLink').attr 'href', "/entity/edit/codeName/#{@model.get("codeName")}"

		@

class window.AddedExperimentSummaryTableController extends ExperimentSummaryTableController
	#for table of linked experiments

	events:
		"click .bv_removeExpt": "handleRemoveExpt"

	initialize: ->
		super()
		if @options.exptExptItxs?
			@exptExptItxs = @options.exptExptItxs
		else
			@exptExptItxs = new Backbone.Collection

	render: =>
		@template = _.template($('#AddedExperimentSummaryTableView').html())
		$(@el).html @template
		$(".bv_noMatchingExperimentsFoundMessage"+@domSuffix).addClass "hide"
		@collection.each (exp) =>
			hideStatusesList = null
			if window.conf.entity?.hideStatuses?
				hideStatusesList = window.conf.entity.hideStatuses
			#non-admin users can't see experiments with statuses in hideStatusesList
			unless (hideStatusesList? and hideStatusesList.length > 0 and hideStatusesList.indexOf(exp.getStatus().get 'codeValue') > -1 and !(UtilityFunctions::testUserHasRole window.AppLaunchParams.loginUser, ["admin"]))
				ersc = new AddedExperimentRowSummaryController
					model: exp
				@$("tbody").append ersc.render().el

		@dataTable = @$("table").dataTable oLanguage:
			sSearch: "Filter results: " #rename summary table's search bar

		if @collection.length is 0
			$(@el).hide()
			$(".bv_noLinked"+@domSuffix).show()
		@

	linkPrimaryExpt: (exp) =>
		@linkExpt exp, "parent_primary child"

	linkFollowUpExpt: (exp) =>
		@linkExpt exp, "parent_confirmation child"

	linkExpt: (exp, itxLsKind) =>
		@collection.add exp
		@exptExptItxs.add new Backbone.Model
			lsType: "has member"
			lsKind: itxLsKind
			recordedBy: window.AppLaunchParams.loginUser.username
			recordedDate: new Date().getTime()
			secondExperiment: exp
			ignored: false


		ersc = new AddedExperimentRowSummaryController
			model: exp
		@$("tbody").append ersc.render().el

		exptInfo = []
		_.each ersc.render().el.cells, (cell) =>
			exptInfo.push cell.innerHTML

		@dataTable.fnAddData exptInfo
		$(@el).show()
		$(".bv_noLinked"+@domSuffix).hide()

	handleRemoveExpt: (src) =>
		row = src.target.closest("tr")
		codeName = $.parseHTML(row.cells[0].innerHTML)[1].text

		exptName = row.cells[1].innerHTML
		aoData = @dataTable.fnSettings().aoData
		aData = _.pluck aoData, '_aData'
		exptNames = _.pluck aData, '1'
		index = _.indexOf exptNames, exptName
		@dataTable.fnDeleteRow(index)

		#Remove model from collection. Remove itx from @exptExptItxs if itx is not saved yet, mark as ignored if previously saved itx
		exptToRemove = @collection.findWhere {codeName: codeName}
		itxToUpdate = @exptExptItxs.filter (itx) =>
			secondExpt = itx.get('secondExperiment')
			unless secondExpt instanceof Experiment
				secondExpt = new Experiment secondExpt
			secondExpt.get('codeName') is exptToRemove.get('codeName') and !itx.get('ignored')
		if itxToUpdate[0].isNew()
			@exptExptItxs.remove itxToUpdate[0]
		else
			itxToUpdate[0].set 'ignored', true
		@collection.remove @collection.findWhere {codeName: codeName}
		if @collection.length is 0
			$(@el).hide()
			$(".bv_noLinked"+@domSuffix).show()
		@trigger 'amDirty'

class window.LinkedExperimentsController extends ExperimentBrowserController

	events:
		"click .bv_save": "handleSaveClicked"
		"click .bv_cancel": "handleCancelClicked"
		"click .bv_cancelClear": "handleCancelClearClicked"
		"click .bv_confirmClear": "handleConfirmClearClicked"


	initialize: =>
		template = _.template( $("#LinkedExperimentsView").html(),  {includeDuplicateAndEdit: true} );
		$(@el).empty()
		$(@el).html template
		if @options.allExptExptItxs?
			@allExptExptItxs = @options.allExptExptItxs
		else
			@allExptExptItxs = {}
		@setupSearchAndTableControllers()

	reinitialize: =>
		template = _.template( $("#LinkedExperimentsView").html(),  {includeDuplicateAndEdit: true} );
		$(@el).empty()
		$(@el).html template
		@getLinkedExpts()

	getLinkedExpts: =>
		$.ajax
			type: 'POST'
			url: "/api/getExptExptItxsToDisplay/"+@model.get('id')
			json: true
			success: (json) =>
				@allExptExptItxs = json
				@setupSearchAndTableControllers()
				@$('.bv_cancelComplete').show()
			error: (err) =>
				alert 'Could not get expt expt itxs for this experiment, refreshing page'
				window.location.reload()

	setupSearchAndTableControllers: =>
		@showExistingExptExptItxs @allExptExptItxs
		@setupPrimaryExperimentSearchController()
		@setupAddedPrimaryExperimentsTableController()
		@setupFollowUpExperimentSearchController()
		@setupAddedFollowUpExperimentsTableController()

	showExistingExptExptItxs: (itxs) =>
		@primaryExptExptItxs = new Backbone.Collection()
		@followUpExptExptItxs = new Backbone.Collection()
		_.each itxs, (itx) =>
			if itx.lsType is "has member" and itx.lsKind is "parent_primary child" and !itx.ignored
				itx = new Backbone.Model itx
				@primaryExptExptItxs.add itx
			else if itx.lsType is "has member" and itx.lsKind is "parent_confirmation child" and !itx.ignored
				itx = new Backbone.Model itx
				@followUpExptExptItxs.add itx
		@prevLinkedPrimaryExpts = new ExperimentList()
		@primaryExptExptItxs.each (itx) =>
			@prevLinkedPrimaryExpts.add itx.get('secondExperiment')
		@prevLinkedFollowUpExpts = new ExperimentList()
		@followUpExptExptItxs.each (itx) =>
			@prevLinkedFollowUpExpts.add itx.get('secondExperiment')

	setupPrimaryExperimentSearchController: =>
		@primaryExperimentSearchController = new ExperimentSimpleSearchController
			model: new ExperimentSearch()
			el: @$('.bv_primaryExperimentSearchController')
			includeDuplicateAndEdit: true #only set this to be true so that search will use genericSearchUrl instead of codeNameSearchUrl
			domSuffix: 'PrimaryExpt'
		@primaryExperimentSearchController.render()
		@primaryExperimentSearchController.on "searchReturned", @setupSearchedPrimaryExperimentSummaryTable

	setupSearchedPrimaryExperimentSummaryTable: (experiments) =>
		@destroySearchedPrimaryExperimentSummaryTable()

		@$(".bv_searchingExperimentsMessagePrimaryExpt").addClass "hide"
		if experiments is null
			@$(".bv_errorOccurredPerformingSearchPrimaryExpt").removeClass "hide"

		else
			searchedExpts = new ExperimentList experiments
			linkedExpts = @addedPrimaryExperimentsTableController.collection
			filteredSearchedExpts = @filterSearchedExperiments(searchedExpts, linkedExpts)

			if filteredSearchedExpts.length is 0
				@$(".bv_noMatchingExperimentsFoundMessagePrimaryExpt").removeClass "hide"
				@$(".bv_experimentTableControllerPrimaryExpt").html ""
			else
				@$(".bv_searchExperimentsStatusIndicatorPrimaryExpt").addClass "hide"
				@$(".bv_experimentTableControllerPrimaryExpt").removeClass "hide"
				@searchedPrimaryExperimentsTableController = new SearchedExperimentSummaryTableController
					collection: filteredSearchedExpts
					domSuffix: "PrimaryExpt"

				@searchedPrimaryExperimentsTableController.on "selectedRowUpdated", @checkIfExptLinkedAsFollowUp
				@searchedPrimaryExperimentsTableController.on "amDirty", =>
					@handleAmDirty()
				@$(".bv_experimentTableControllerPrimaryExpt").html @searchedPrimaryExperimentsTableController.render().el

	destroySearchedPrimaryExperimentSummaryTable: =>
		if @searchedPrimaryExperimentsTableController?
			@searchedPrimaryExperimentsTableController.remove()
		@$(".bv_noMatchingExperimentsFoundMessagePrimaryExpt").addClass("hide")

	setupAddedPrimaryExperimentsTableController: =>
		@addedPrimaryExperimentsTableController = new AddedExperimentSummaryTableController
			collection: @prevLinkedPrimaryExpts
			exptExptItxs: @primaryExptExptItxs
			domSuffix: "PrimaryExpt"
		@addedPrimaryExperimentsTableController.on 'amDirty', =>
			@handleAmDirty()
		@$(".bv_addedPrimaryExperimentsTableController").html @addedPrimaryExperimentsTableController.render().el

	checkIfExptLinkedAsPrimary: (exp) =>
		if @addedPrimaryExperimentsTableController.collection.get(exp)?
			@$('.bv_experimentAlreadyLinkedMessage').html 'Experiment has already been linked as a primary experiment. This link must be removed first before linking this experiment as a follow up experiment.'
			@$('.bv_experimentAlreadyLinked').modal 'show'
		else
			@addedFollowUpExperimentsTableController.linkExpt exp, "parent_confirmation child"

	checkIfExptLinkedAsFollowUp: (exp) =>
		if @addedFollowUpExperimentsTableController.collection.get(exp)?
			@$('.bv_experimentAlreadyLinkedMessage').html 'Experiment has already been linked as a follow up experiment. This link must be removed first before linking this experiment as a primary experiment.'
			@$('.bv_experimentAlreadyLinked').modal 'show'
		else
			@addedPrimaryExperimentsTableController.linkExpt exp, "parent_primary child"

	handleAmDirty: =>
		@trigger 'amDirty'
		@$('.bv_updateComplete').hide()
		@$('.bv_cancelComplete').hide()
		@$('.bv_updateFailed').hide()
		@$('.bv_save').removeAttr 'disabled'
		@$('.bv_cancel').removeAttr 'disabled'

	filterSearchedExperiments: (searchedExpts, linkedExpts) =>
		filteredSearchedExpts = new ExperimentList()
		searchedExpts.each (expt) =>
			unless linkedExpts.get(expt.id)? or expt.id is @model.get('id')
				filteredSearchedExpts.add expt
		filteredSearchedExpts

	setupFollowUpExperimentSearchController: =>
		@followUpExperimentSearchController = new ExperimentSimpleSearchController
			model: new ExperimentSearch()
			el: @$('.bv_followUpExperimentSearchController')
			includeDuplicateAndEdit: true #only set this to be true so that search will use genericSearchUrl instead of codeNameSearchUrl
			domSuffix: 'FollowUpExpt'
		@followUpExperimentSearchController.render()
		@followUpExperimentSearchController.on "searchReturned", @setupSearchedFollowUpExperimentSummaryTable

	setupSearchedFollowUpExperimentSummaryTable: (experiments) =>
		@destroySearchedFollowUpExperimentSummaryTable()

		@$(".bv_searchingExperimentsMessageFollowUpExpt").addClass "hide"
		if experiments is null
			@$(".bv_errorOccurredPerformingSearchFollowUpExpt").removeClass "hide"

		else
			searchedExpts = new ExperimentList experiments
			linkedExpts = @addedFollowUpExperimentsTableController.collection
			filteredSearchedExpts = @filterSearchedExperiments(searchedExpts, linkedExpts)

			if filteredSearchedExpts.length is 0
				@$(".bv_noMatchingExperimentsFoundMessageFollowUpExpt").removeClass "hide"
				@$(".bv_experimentTableControllerFollowUpExpt").html ""
			else
				@$(".bv_searchExperimentsStatusIndicatorFollowUpExpt").addClass "hide"
				@$(".bv_experimentTableControllerFollowUpExpt").removeClass "hide"
				@searchedFollowUpExperimentsTableController = new SearchedExperimentSummaryTableController
					collection: filteredSearchedExpts
					domSuffix: "FollowUpExpt"
				@searchedFollowUpExperimentsTableController.on "selectedRowUpdated", @checkIfExptLinkedAsPrimary
				@searchedFollowUpExperimentsTableController.on "amDirty", =>
					@handleAmDirty()
				@$(".bv_experimentTableControllerFollowUpExpt").html @searchedFollowUpExperimentsTableController.render().el

	destroySearchedFollowUpExperimentSummaryTable: =>
		if @searchedFollowUpExperimentsTableController?
			@searchedFollowUpExperimentsTableController.remove()
		@$(".bv_noMatchingExperimentsFoundMessageFollowUpExpt").addClass("hide")

	setupAddedFollowUpExperimentsTableController: =>
		@addedFollowUpExperimentsTableController = new AddedExperimentSummaryTableController
			collection: @prevLinkedFollowUpExpts
			exptExptItxs: @followUpExptExptItxs
			domSuffix: "FollowUpExpt"

		@addedFollowUpExperimentsTableController.on 'amDirty', =>
			@handleAmDirty()
		@$(".bv_addedFollowUpExperimentsTableController").html @addedFollowUpExperimentsTableController.render().el

	handleSaveClicked: ->
		@$('.bv_updateComplete').html "Update Complete"
		@$('.bv_save').attr('disabled', 'disabled')
		@$('.bv_cancel').attr('disabled', 'disabled')
		@$('.bv_saving').show()

		newExptExptItxs = new Backbone.Collection()
		exptExptItxsToIgnore = new Backbone.Collection()
		#add firstExperiment information to new primary expt expt itxs
		@addedPrimaryExperimentsTableController.exptExptItxs.each (itx) =>
			if itx.isNew()
				itx.set 'firstExperiment', @model
				#if experiment base was updated, @model will be updated as well
				newExptExptItxs.add itx
			else #if itx.get('ignored')
				exptExptItxsToIgnore.add itx
		@addedFollowUpExperimentsTableController.exptExptItxs.each (itx) =>
			if itx.isNew()
				itx.set 'firstExperiment', @model
				newExptExptItxs.add itx
			else #if itx.get('ignored')
				exptExptItxsToIgnore.add itx

		$.ajax
			type: 'POST'
			url: "/api/createAndUpdateExptExptItxs"
			data:
				exptExptItxsToIgnore: JSON.stringify exptExptItxsToIgnore.toJSON()
				newExptExptItxs: JSON.stringify(newExptExptItxs.toJSON())
			json: true
			success: (response) =>
				@showExistingExptExptItxs response
				@addedPrimaryExperimentsTableController.exptExptItxs = @primaryExptExptItxs
				@addedPrimaryExperimentsTableController.collection = @prevLinkedPrimaryExpts
				@addedFollowUpExperimentsTableController.exptExptItxs = @followUpExptExptItxs
				@addedFollowUpExperimentsTableController.collection = @prevLinkedFollowUpExpts
				@exptItxsSavedSuccessfully()
			error: (err) =>
				@exptItxsSaveFailed()

	exptItxsSavedSuccessfully: =>
		@$('.bv_saving').hide()
		@$('.bv_updateComplete').show()
		@trigger 'amClean'

	exptItxsSaveFailed: =>
		@$('.bv_updateFailed').show()
		@$('.bv_saving').hide()
		@$('.bv_cancel').removeAttr 'disabled'
		@trigger 'amClean'

	handleCancelClicked: =>
		@$('.bv_canceling').show()
		@$('.bv_cancel').attr 'disabled', 'disabled'
		@$('.bv_save').attr 'disabled', 'disabled'
		@reinitialize()
		@trigger 'amClean'

class window.ScreeningCampaignDataAnalysisController extends AbstractFormController
	template: _.template($("#ScreeningCampaignDataAnalysisView").html())

	events: ->
		"change .bv_signalDirectionRule": "attributeChanged"
		"change .bv_aggregateBy": "attributeChanged"
		"change .bv_aggregationMethod": "attributeChanged"
		"keyup .bv_hitEfficacyThreshold": "attributeChanged"
		"keyup .bv_hitSDThreshold": "attributeChanged"
		"change .bv_thresholdTypeEfficacy": "handleThresholdTypeChanged"
		"change .bv_thresholdTypeSD": "handleThresholdTypeChanged"
		"change .bv_useOriginalHits": "handleUseOriginalHitsChanged"
		"change .bv_autoHitSelection": "handleAutoHitSelectionChanged"

		"click .bv_analyze": "handleAnalyzeClicked"

	initialize: ->
		@errorOwnerName = 'ScreeningCampaignDataAnalysisController'
		@setBindings()

		$(@el).empty()
		$(@el).html @template(@model.attributes)
		if @options.exptCode?
			@exptCode = @options.exptCode
		else
			@exptCode = ""

		if @options.analyzedPreviously?
			@analyzedPreviously = @options.analyzedPreviously
		else
			@analyzedPreviously = false

		if @options.previousAnalysisResults?
			@previousAnalysisResults = @options.previousAnalysisResults
		else
			@previousAnalysisResults = ""

		if @options.primaryExpts?
			@primaryExpts = @options.primaryExpts
		else
			@primaryExpts = new Backbone.Collection()

		if @options.followUpExpts?
			@followUpExpts = @options.followUpExpts
		else
			@followUpExpts = new Backbone.Collection()

		if @analyzedPreviously
			@$('.bv_analyze').html "Re-Analyze"
			@$('.bv_analysisResults').html @previousAnalysisResults
			@$('.bv_analysisResults').show()
		else
			@$('.bv_analyze').html "Analyze"
			@$('.bv_analysisResults').hide()
		@model.bind 'amDirty', => @trigger 'amDirty', @
		@listenTo @model, 'change', @modelChangeCallback

	render: =>
		@$("[data-toggle=popover]").popover();
		@$("body").tooltip selector: '.bv_popover'

		@setupSignalDirectionSelect()
		@setupAggregateBySelect()
		@setupAggregationMethodSelect()
		@handleAutoHitSelectionChanged(true)
		@setupNormalizationController()
		@setupTransformationRuleListController()

		@

	modelChangeCallback: =>
		@trigger 'amDirty'
		@$('.bv_analysisComplete').hide()
		@$('.bv_analysisFailed').hide()
		@$('.bv_cancel').removeAttr 'disabled'
		@$('.bv_cancelComplete').hide()


	setupSignalDirectionSelect: ->
		@signalDirectionList = new PickListList()
		@signalDirectionList.url = "/api/codetables/analysis parameter/signal direction"
		@signalDirectionListController = new PickListSelectController
			el: @$('.bv_signalDirectionRule')
			collection: @signalDirectionList
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Select Signal Direction"
			selectedCode: @model.get('signalDirectionRule')

	setupAggregateBySelect: ->
		@aggregateByList = new PickListList()
		@aggregateByList.url = "/api/codetables/analysis parameter/aggregate by"
		@aggregateByListController = new PickListSelectController
			el: @$('.bv_aggregateBy')
			collection: @aggregateByList
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Select Aggregate By"
			selectedCode: @model.get('aggregateBy')

	setupAggregationMethodSelect: ->
		@aggregationMethodList = new PickListList()
		@aggregationMethodList.url = "/api/codetables/analysis parameter/aggregation method"
		@aggregationMethodListController = new PickListSelectController
			el: @$('.bv_aggregationMethod')
			collection: @aggregationMethodList
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Select Aggregation Method"
			selectedCode: @model.get('aggregationMethod')

	setupNormalizationController: ->
		@normalizationController = new NormalizationController
			el: @$('.bv_normalization')
			model: @model.get('normalization')
		@normalizationController.render()

	setupTransformationRuleListController: ->
		@transformationRuleListController= new TransformationRuleListController
			el: @$('.bv_transformationList')
			collection: @model.get('transformationRuleList')
		@transformationRuleListController.render()

	updateModel: =>
		@model.set
			signalDirectionRule: @signalDirectionListController.getSelectedCode()
			aggregateBy: @aggregateByListController.getSelectedCode()
			aggregationMethod: @aggregationMethodListController.getSelectedCode()
			hitEfficacyThreshold: parseFloat(UtilityFunctions::getTrimmedInput @$('.bv_hitEfficacyThreshold'))
			hitSDThreshold: parseFloat(UtilityFunctions::getTrimmedInput @$('.bv_hitSDThreshold'))
		@$('.bv_cancel').removeAttr 'disabled'


	handleThresholdTypeChanged: =>
		thresholdType = @$("input[name='bv_thresholdType']:checked").val()
		@model.set thresholdType: thresholdType
		if thresholdType =="efficacy"
			@$('.bv_hitSDThreshold').attr('disabled','disabled')
			@$('.bv_hitEfficacyThreshold').removeAttr('disabled')
		else
			@$('.bv_hitEfficacyThreshold').attr('disabled','disabled')
			@$('.bv_hitSDThreshold').removeAttr('disabled')
		@attributeChanged()

	handleUseOriginalHitsChanged: =>
		useOriginalHits = @$('.bv_useOriginalHits').is(":checked")
		@model.set useOriginalHits: useOriginalHits
		@attributeChanged()

	handleAutoHitSelectionChanged: (skipUpdate) =>
		autoHitSelection = @$('.bv_autoHitSelection').is(":checked")
		@model.set autoHitSelection: autoHitSelection
		if autoHitSelection
			@$('.bv_thresholdControls').show()
		else
			@$('.bv_thresholdControls').hide()
		unless skipUpdate is true
			@attributeChanged()

	validationError: =>
		super()
		@$('.bv_analyze').attr('disabled', 'disabled')

	clearValidationErrorStyles: =>
		super()
		@$('.bv_analyze').removeAttr('disabled')

	handleAnalyzeClicked: =>
		@$('.bv_analyzing').show()
		@$('.bv_analyze').attr 'disabled', 'disabled'
		@$('.bv_cancel').attr 'disabled', 'disabled'
		@$('.bv_analyzingData').modal
			backdrop: "static"

		primaryExperimentCodes = @primaryExpts.pluck 'codeName'
		followUpExperimentCodes = @followUpExpts.pluck 'codeName'

		$.ajax
			type: 'POST'
			url: "/api/screeningCampaign/analyzeScreeningCampaign"
			data:
				user: window.AppLaunchParams.loginUser.username
				experimentCode: @exptCode
				inputParameters: JSON.stringify @model
				primaryExperimentCodes: JSON.stringify primaryExperimentCodes
				confirmationExperimentCodes: JSON.stringify followUpExperimentCodes
			json: true
			success: (response) =>
				@$('.bv_analysisComplete').show()
				@$('.bv_analyze').html "Re-analyze"
				@$('.bv_analyzing').hide()
				@$('.bv_analysisResults').html response.results.htmlSummary
				@$('.bv_analysisResults').show()
				@trigger 'analysisComplete'
			error: (err) =>
				alert "Error Analyzing Screening Campaign"
				@$('.bv_analysisFailed').show()
				@$('.bv_analyzing').hide()
				@$('.bv_analysisResults').hide()
				@$('.bv_analyzingData').modal 'hide'

class window.ScreeningCampaignModuleController extends AbstractFormController
	template: _.template($("#ScreeningCampaignModuleView").html())
	moduleLaunchName: "screening_campaign"

	initialize: =>
		if @model?
			@completeInitialization()
		else
			if window.AppLaunchParams.moduleLaunchParams?
				if window.AppLaunchParams.moduleLaunchParams.moduleName == @moduleLaunchName
					$.ajax
						type: 'GET'
						url: "/api/experiments/codename/"+window.AppLaunchParams.moduleLaunchParams.code
						dataType: 'json'
						error: (err) =>
							alert 'Could not get experiment for code in this URL, creating new one'
							@completeInitialization()
						success: (json) =>
							if json.length == 0
								alert 'Could not get experiment for code in this URL, creating new one'
							else
								lsType = json.lsType
								lsKind = json.lsKind
								if lsType is "Parent" and lsKind is "Bio Activity Screen"
									expt = new ScreeningExperiment json
									expt.set expt.parse(expt.attributes)
									$.ajax
										type: 'POST'
										url: "/api/getExptExptItxsToDisplay/"+expt.get('id')
										json: true
										success: (json) =>
											@allExptExptItxs = json
											@model = expt
											@completeInitialization()
										error: (err) =>
											alert 'Could not get expt expt itxs for this experiment, creating new experiment'
											@completeInitialization()
#									if window.AppLaunchParams.moduleLaunchParams.copy
#										@model = expt.duplicateEntity()
#									else
#										@model = expt
								else
									alert 'Could not get parent experiment for code in this URL. Creating new parent experiment'
									@completeInitialization()
				else
					@completeInitialization()
			else
				@completeInitialization()

	completeInitialization: =>
		unless @model?
			@model = new ScreeningExperiment()
			@allExptExptItxs = {}
		if @model.isNew()
			@getAndSetProtocol()
		$(@el).html @template()
		@setupExperimentBaseController()
		@setupLinkedExperimentsController()
		@setupDataAnalysisController()
		@listenTo @model, 'sync', =>
			@analysisController.exptCode = @model.get('codeName')

	getAndSetProtocol: ->
		$.ajax
			type: 'GET'
			url: "/api/protocols/codename/PROT-Screen"
			success: (json) =>
				if json.length == 0
					console.log ("Could not find screening protocol, autocreating new screening protocol")
					@createScreeningProtocol()
				else
					prot = new Protocol(json)
					if prot.get('ignored')
						alert 'Found ignored screening protocol. Contact administrator to change the codeName of PROT-Screen'
					else
						@model.set protocol: prot
						@trigger 'amClean'
#					if setAnalysisParams
#						@getFullProtocol() # this will fetch full protocol
			error: (err) =>
				console.log 'Got ajax error from getting screening protocol, autocreating new screening protocol'
				@createScreeningProtocol()

			dataType: 'json'

	createScreeningProtocol: =>
		prot = new Protocol()
		prot.set 'lsType', 'Parent'
		prot.set 'lsKind', 'Bio Activity'
		prot.set 'codeName', 'PROT-Screen'
		prot.get('lsLabels').setBestName new Label
			lsKind: "protocol name"
			labelText: "PROT-Screen"
			recordedBy: window.AppLaunchParams.loginUser.username
			recordedDate: new Date().getTime()
		prot.getScientist().set 'codeValue', window.AppLaunchParams.loginUser.username
		prot.getCreationDate().set 'dateValue', new Date().getTime()
		prot.getNotebook().set 'stringValue', 'Autocreated Screening Protocol'
		prot.prepareToSave()
		prot.save null,
			success: (model, response) =>
				if response is "not unique protocol name"
					alert 'Error creating Screening Protocol - not unique name. Contact administrator'
			error: (model, response) =>
				alert "Error saving new screening protocol"
				console.log response



	setupExperimentBaseController: ->
		if @experimentBaseController?
			@experimentBaseController.remove()
		@experimentBaseController = new ExperimentBaseController
			model: @model
			el: @$('.bv_screeningCampaignGeneralInfo')
			protocolFilter: @protocolFilter
			protocolKindFilter: @protocolKindFilter
		@experimentBaseController.$('.bv_experimentNameLabel').html "*Parent Experiment Name"
		@experimentBaseController.$('.bv_group_protocolCode').hide()
		@experimentBaseController.on 'amDirty', =>
			@trigger 'amDirty'
			@linkedExptsController.$('.bv_saveChangesBeforeLink').show()
			@linkedExptsController.$('.bv_linkedExperimentsWrapper').hide()
			@analysisController.setExperimentNotSaved()
		@experimentBaseController.on 'amClean', =>
			@trigger 'amClean'
			@linkedExptsController.$('.bv_saveChangesBeforeLink').hide()
			@linkedExptsController.$('.bv_linkedExperimentsWrapper').show()
			@analysisController.setExperimentSaved()
		@experimentBaseController.on 'reinitialize', @reinitialize

	reinitialize: =>
		@model = null
		@completeInitialization()

	setupLinkedExperimentsController: ->
		if @linkedExptsController?
			@linkedExptsController.undelegateEvents()
		@linkedExptsController = new LinkedExperimentsController
			model: @model
			allExptExptItxs: @allExptExptItxs
			el: @$('.bv_screeningCampaignLinkedExperiments')
		@linkedExptsController.on 'amDirty', =>
			@trigger 'amDirty'
			@analysisController.setExperimentNotSaved()
		@linkedExptsController.on 'amClean', =>
			@trigger 'amClean'
			@analysisController.setExperimentSaved()
		@linkedExptsController.render()

	setupDataAnalysisController: ->
		if @analysisController?
			@analysisController.undelegateEvents()
		analysisParameters = @model.get('lsStates').getStateValueByTypeAndKind 'metadata', 'experiment metadata', 'clobValue', 'data analysis parameters'
		if analysisParameters?
			analysisParameters = new ScreeningExperimentParameters $.parseJSON(analysisParameters.get('clobValue'))
		else
			analysisParameters = new ScreeningExperimentParameters()
		analysisStatus = @model.get('lsStates').getStateValueByTypeAndKind 'metadata', 'experiment metadata', 'codeValue', 'analysis status'
		if analysisStatus?
			analysisStatus = analysisStatus.get('codeValue')
		else
			analysisStatus = "not started"

		if analysisStatus is "not started"
			previousAnalysisResults = ""
		else
			previousAnalysisResults = @model.getAnalysisResultHTML().get('clobValue')

		@analysisController = new ScreeningCampaignAnalysisController
			model: @model
			el: @$('.bv_screeningCampaignDataAnalysis')
			uploadAndRunControllerName: "UploadAndRunScreeningCampaignAnalsysisController"
			exptCode: @model.get('codeName')
			primaryExpts: @linkedExptsController.addedPrimaryExperimentsTableController.collection
			followUpExpts: @linkedExptsController.addedFollowUpExperimentsTableController.collection
		@analysisController.on 'amDirty', =>
			@trigger 'amDirty'
			@linkedExptsController.$('.bv_saveChangesBeforeLink').show()
			@linkedExptsController.$('.bv_linkedExperimentsWrapper').hide()
		@analysisController.on 'amClean', =>
			@trigger 'amClean'
			@linkedExptsController.$('.bv_saveChangesBeforeLink').hide()
			@linkedExptsController.$('.bv_linkedExperimentsWrapper').show()
		@analysisController.on 'warning', =>
			@showWarningModal()
		@analysisController.on 'dryRunRunning', =>
			@showValidateProgressBar()
		@analysisController.on 'dryRunDone', =>
			@hideValidateProgressBar()
		@analysisController.on 'analysisRunning', =>
			@showSaveProgressBar()
		@analysisController.on 'analysisDone', =>
			@hideSaveProgressBar()
		@analysisController.on 'analysis-completed', =>
			@model.fetch
				success: =>
					console.log "fetched model"
				error: =>
					alert 'Could not get experiment after data analysis, refreshing page'
					window.location.reload()
		@$('.bv_screeningCampaignDataAnalysisTab').on 'shown', (e) =>
			if @model.getAnalysisStatus().get('codeValue') is "not started"
				@analysisController.checkForSourceFile()
		@analysisController.render()


	showWarningModal: ->
		@$('a[href="#screeningCampaignDataAnalysis"]').tab('show')
		dryRunStatus = @model.getDryRunStatus().get('codeValue')
		dryRunResult = @model.getDryRunResultHTML().get('clobValue')
		analysisStatus = @model.getAnalysisStatus().get('codeValue')
		analysisResult = @model.getAnalysisResultHTML().get('clobValue')
		@$('.bv_dryRunStatus').html("Dry Run Status: "+dryRunStatus)
		@$('.bv_dryRunResult').html("Dry Run Result HTML: "+dryRunResult)
		@$('.bv_analysisStatus').html("Analysis Status: "+analysisStatus)
		@$('.bv_analysisResult').html("Analysis Result HTML: "+analysisResult)
		@$('.bv_invalidAnalysisStates').modal
			backdrop: "static"
		@$('.bv_invalidAnalysisStates').modal("show")
		@$('.bv_fileUploadWrapper .bv_fileUploadWrapper').hide()
		@$('.bv_fileUploadWrapper .bv_flowControl').hide()

	showValidateProgressBar: ->
		@$('a[href="#screeningCampaignDataAnalysis"]').tab('show')
		@$('.bv_validateStatusDropDown').modal
			backdrop: "static"
		@$('.bv_validateStatusDropDown').modal("show")

	showSaveProgressBar: ->
		@$('a[href="#screeningCampaignDataAnalysis"]').tab('show')
		@$('.bv_saveStatusDropDown').modal
			backdrop: "static"
		@$('.bv_saveStatusDropDown').modal("show")

	hideValidateProgressBar: ->
		@$('.bv_validateStatusDropDown').modal("hide")

	hideSaveProgressBar: ->
		@$('.bv_saveStatusDropDown').modal("hide")

class window.ScreeningCampaignAnalysisController extends PrimaryScreenAnalysisController

	initialize: ->
		if @options.exptCode?
			@exptCode = @options.exptCode
		else
			@exptCode = ""
		if @options.primaryExpts?
			@primaryExpts = @options.primaryExpts
		else
			@primaryExpts = new Backbone.Collection()

		if @options.followUpExpts?
			@followUpExpts = @options.followUpExpts
		else
			@followUpExpts = new Backbone.Collection()
		super()
		@$('.bv_saveExperimentToAnalyze').html "To analyze data, save or cancel the changes made in the General and/or Linked Experiments tabs."

	setupDataAnalysisController: (dacClassName) ->
		if @model.getAnalysisStatus()?
			analysisStatus = @model.getAnalysisStatus().get('codeValue')
		else
			analysisStatus = "not started"
		newArgs =
			el: @$('.bv_fileUploadWrapper')
			paramsFromExperiment:	@model.getAnalysisParameters()
			analyzedPreviously: analysisStatus !="not started"
			exptCode: @exptCode
			primaryExpts: @primaryExpts
			followUpExpts: @followUpExpts
		@dataAnalysisController = new window[dacClassName](newArgs)
		@dataAnalysisController.setUser(window.AppLaunchParams.loginUserName)
		@dataAnalysisController.setExperimentId(@model.id)
		@dataAnalysisController.on 'analysis-completed', @handleAnalysisComplete
		@dataAnalysisController.on 'amDirty', =>
			@trigger 'amDirty'
		@dataAnalysisController.on 'amClean', =>
			@trigger 'amClean'

	checkForSourceFile: ->
		#don't load source file as a data file (file to parse)

class window.UploadAndRunScreeningCampaignAnalsysisController extends AbstractUploadAndRunPrimaryAnalsysisController

	initialize: ->
		if @options.exptCode?
			@exptCode = @options.exptCode
		else
			@exptCode = ""
		if @options.primaryExpts?
			@primaryExpts = @options.primaryExpts
		else
			@primaryExpts = new Backbone.Collection()

		if @options.followUpExpts?
			@followUpExpts = @options.followUpExpts
		else
			@followUpExpts = new Backbone.Collection()

		@fileProcessorURL = "/api/screeningCampaign/analyzeScreeningCampaign"
		@errorOwnerName = 'UploadAndRunScreeningCampaignAnalsysisController'
		@allowedFileTypes = ['zip']
		@maxFileSize = 200000000
		@loadReportFile = false
		@parseFileUploaded = true #not really uploaded but don't want to require data file upload
		super()
		@$('.bv_moduleTitle').hide()
		@analysisParameterController = new ScreeningCampaignDataAnalysisController
			model: @options.paramsFromExperiment
			el: @$('.bv_additionalValuesForm')
		@completeInitialization()
		@handleFormValid()
		@$('.bv_fileUploadDirections').hide()
		@$('.bv_parseFile').hide()


	validateParseFile: =>
		primaryExperimentCodes = @primaryExpts.pluck 'codeName'
		followUpExperimentCodes = @followUpExpts.pluck 'codeName'

		@analysisParameterController.updateModel()
		unless !@analysisParameterController.isValid()
			@additionalData =
				inputParameters: JSON.stringify @analysisParameterController.model
				testMode: false
				exptCode: @options.exptCode
				primaryExperimentCodes: JSON.stringify primaryExperimentCodes
				confirmationExperimentCodes: JSON.stringify followUpExperimentCodes
			if @parseFileUploaded and not @$(".bv_next").attr('disabled')
				@notificationController.clearAllNotificiations()
				@$('.bv_validateStatusDropDown').modal
					backdrop: "static"
				@$('.bv_validateStatusDropDown').modal "show"
				dataToPost = @prepareDataToPost(true)
				$.ajax
					type: 'POST'
					url: @fileProcessorURL
					data: dataToPost
					success: @handleValidationReturnSuccess
					error: (err) =>
						@$('.bv_validateStatusDropDown').modal("hide")
					dataType: 'json'

