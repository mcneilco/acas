class window.ParentExperiment extends Experiment

	#TODO: ask Guy if screening experiment should have diff lsType/kind
	initialize: ->
		super()
		@set lsType: "Parent"
		@set lsKind: "Bio Activity"
		#TODO: set protocol here
#		@set protocol:

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
		primaryHitEfficacyThreshold: null
		primaryHitSDThreshold: null
		primaryThresholdType: null
		primaryAutoHitSelection: false
		confirmationHitEfficacyThreshold: null
		confirmationHitSDThreshold: null
		confirmationThresholdType: null
		confirmationAutoHitSelection: false
		generateSummaryReport: true

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
		if attrs.primaryAutoHitSelection
			if attrs.primaryThresholdType == "sd" && _.isNaN(attrs.primaryHitSDThreshold)
				errors.push
					attribute: 'primaryHitSDThreshold'
					message: "SD threshold must be a number"
			if attrs.primaryThresholdType == "efficacy" && _.isNaN(attrs.primaryHitEfficacyThreshold)
				errors.push
					attribute: 'primaryHitEfficacyThreshold'
					message: "Efficacy threshold must be a number"
		if attrs.confirmationAutoHitSelection
			if attrs.confirmationThresholdType == "sd" && _.isNaN(attrs.confirmationHitSDThreshold)
				errors.push
					attribute: 'confirmationHitSDThreshold'
					message: "SD threshold must be a number"
			if attrs.confirmationThresholdType == "efficacy" && _.isNaN(attrs.confirmationHitEfficacyThreshold)
				errors.push
					attribute: 'confirmationHitEfficacyThreshold'
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
		console.log "searched expt - summary table selected Row Changed"
		aoData = @dataTable.fnSettings().aoData
		console.log aoData
		aData = _.pluck aoData, '_aData'
		exptNames = _.pluck aData, '2'
		index = _.indexOf exptNames, row.get('lsLabels').pickBestName().get('labelText')
		console.log "aData: " + aData
		console.log "exptNames: " + exptNames
		console.log "index: " + index
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
						console.log "amDirty - ersc"
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

		console.log "creating datatable"
		console.log @dataTable

		if @collection.length is 0
			$(@el).hide()
			$(".bv_noLinked"+@domSuffix).show()
		@

	linkPrimaryExpt: (exp) =>
		@linkExpt exp, "parent_primary child"

	linkFollowUpExpt: (exp) =>
		@linkExpt exp, "parent_confirmation child"

	linkExpt: (exp, itxLsKind) =>
		console.log "link expt"
		console.log exp
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

		console.log "row render.el"
		console.log ersc.render().el.cells

		exptInfo = []
		_.each ersc.render().el.cells, (cell) =>
			console.log cell.innerHTML
			exptInfo.push cell.innerHTML

		@dataTable.fnAddData exptInfo
		$(@el).show()
		$(".bv_noLinked"+@domSuffix).hide()

	handleRemoveExpt: (src) =>
		console.log "handle remove expt"
		console.log src
		row = src.target.closest("tr")
		console.log "codeName"
		codeName = $.parseHTML(row.cells[0].innerHTML)[1].text
		console.log codeName

		exptName = row.cells[1].innerHTML
		console.log "exptName to delete: " + exptName
		aoData = @dataTable.fnSettings().aoData
		aData = _.pluck aoData, '_aData'
		exptNames = _.pluck aData, '1'
		index = _.indexOf exptNames, exptName
		console.log "aData: " + aData
		console.log "exptNames: " + exptNames
		console.log "index: " + index
		@dataTable.fnDeleteRow(index)
		console.log "collection"

		#TODO: remove model from collection. Remove itx from @exptExptItxs if itx is not saved yet, mark as ignored if previously saved itx
		exptToRemove = @collection.findWhere {codeName: codeName}
		itxToUpdate = @exptExptItxs.filter (itx) =>
			secondExpt = itx.get('secondExperiment')
			unless secondExpt instanceof Experiment
				console.log "cast second expt as expt"
				secondExpt = new Experiment secondExpt
			console.log "itx"
			console.log itx
			console.log "secondExpt"
			console.log secondExpt
			console.log secondExpt.get('codeName')
			console.log "secondExperiment.get('codeName'): " + secondExpt.get('codeName')
			console.log "exptToRemove.get('codeName'): " + exptToRemove.get('codeName')
			console.log "!itx.get('ignored'): " + !itx.get('ignored')
			secondExpt.get('codeName') is exptToRemove.get('codeName') and !itx.get('ignored')
		console.log "itxToUpdate list"
		console.log itxToUpdate
		if itxToUpdate[0].isNew()
			@exptExptItxs.remove itxToUpdate[0]
		else
			itxToUpdate[0].set 'ignored', true
#		@trigger 'removeLinkedExpt', exptToRemove
		@collection.remove @collection.findWhere {codeName: codeName}
		console.log @collection
		if @collection.length is 0
			$(@el).hide()
			$(".bv_noLinked"+@domSuffix).show()
		@trigger 'amDirty'

class window.LinkedExperimentsController extends ExperimentBrowserController

	events:
		"click .bv_save": "saveExptItxs"
		"click .bv_cancel": "handleCancelClicked"
		"click .bv_cancelClear": "handleCancelClearClicked"
		"click .bv_confirmClear": "handleConfirmClearClicked"


	initialize: =>
		template = _.template( $("#LinkedExperimentsView").html(),  {includeDuplicateAndEdit: true} );
		$(@el).empty()
		$(@el).html template
		@getLinkedExpts()

	reinitialize: =>
		template = _.template( $("#LinkedExperimentsView").html(),  {includeDuplicateAndEdit: true} );
		$(@el).empty()
		$(@el).html template
		@getLinkedExpts(true)

	getLinkedExpts: (reinitialize) =>
		$.ajax
			type: 'GET'
			url: "/api/getItxExptExptsByFirstExpt/"+@model.get('id')
			success: (json) =>
				console.log "linked primary experiments"
				console.log json
				@showExistingExptExptItxs JSON.parse json
				@setupPrimaryExperimentSearchController()
				@setupAddedPrimaryExperimentsTableController()
				@setupFollowUpExperimentSearchController()
				@setupAddedFollowUpExperimentsTableController()
				if reinitialize
					@$('.bv_cancelComplete').show()
			error: (err) ->
				console.log "got error"

	showExistingExptExptItxs: (itxs) =>
		console.log "showExisting expt expt itxs"
		@primaryExptExptItxs = new Backbone.Collection()
		@followUpExptExptItxs = new Backbone.Collection()
		_.each itxs, (itx) =>
			console.log itx
			if itx.lsType is "has member" and itx.lsKind is "parent_primary child" and !itx.ignored
				itx = new Backbone.Model itx
				@primaryExptExptItxs.add itx
			else if itx.lsType is "has member" and itx.lsKind is "parent_confirmation child" and !itx.ignored
				itx = new Backbone.Model itx
				@followUpExptExptItxs.add itx
		console.log "@primaryExptExptItxs"
		console.log @primaryExptExptItxs
		@prevLinkedPrimaryExpts = new ExperimentList()
		@primaryExptExptItxs.each (itx) =>
			@prevLinkedPrimaryExpts.add itx.get('secondExperiment')
		@prevLinkedFollowUpExpts = new ExperimentList()
		@followUpExptExptItxs.each (itx) =>
			@prevLinkedFollowUpExpts.add itx.get('secondExperiment')

		console.log "@prevLinkedPrimaryExpts"
		console.log @prevLinkedPrimaryExpts

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

#				@searchedPrimaryExperimentsTableController.on "selectedRowUpdated", @selectedExperimentUpdated
				@searchedPrimaryExperimentsTableController.on "selectedRowUpdated", @checkIfExptLinkedAsFollowUp
				@searchedPrimaryExperimentsTableController.on "amDirty", =>
					@handleAmDirty()
				@$(".bv_experimentTableControllerPrimaryExpt").html @searchedPrimaryExperimentsTableController.render().el

	destroySearchedPrimaryExperimentSummaryTable: =>
		if @searchedPrimaryExperimentsTableController?
			@searchedPrimaryExperimentsTableController.remove()
#		if @primaryExperimentSearchController?
#			@primaryExperimentSearchController.remove()
		@$(".bv_noMatchingExperimentsFoundMessagePrimaryExpt").addClass("hide")

	setupAddedPrimaryExperimentsTableController: =>
		@addedPrimaryExperimentsTableController = new AddedExperimentSummaryTableController
			collection: @prevLinkedPrimaryExpts
			exptExptItxs: @primaryExptExptItxs
			domSuffix: "PrimaryExpt"
#
#		@addedPrimaryExperimentsTableController.on "selectedRowUpdated", @selectedExperimentUpdated
#		@addedPrimaryExperimentsTableController.on 'removeLinkedExpt', @handleRemoveLinkedPrimaryExpt
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
		@$('.bv_save').removeAttr 'disabled'
		@$('.bv_cancel').removeAttr 'disabled'

	filterSearchedExperiments: (searchedExpts, linkedExpts) =>
		filteredSearchedExpts = new ExperimentList()
		console.log "filter searched experiments"
		console.log @model
		console.log @model.get('id')
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

				#				@searchedPrimaryExperimentsTableController.on "selectedRowUpdated", @selectedExperimentUpdated
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
		#
		#		@addedPrimaryExperimentsTableController.on "selectedRowUpdated", @selectedExperimentUpdated
		@addedFollowUpExperimentsTableController.on 'amDirty', =>
			@handleAmDirty()
		@$(".bv_addedFollowUpExperimentsTableController").html @addedFollowUpExperimentsTableController.render().el

	saveExptItxs: ->
		@$('.bv_updateComplete').html "Update Complete"
		@$('.bv_save').attr('disabled', 'disabled')
		@$('.bv_cancel').attr('disabled', 'disabled')
		@$('.bv_saving').show()

		console.log "save expt itxs"

		console.log @addedPrimaryExperimentsTableController.exptExptItxs
#		console.log "expt itxs to ignore"
#		ignoredPrimaryExptExptItxs = @addedPrimaryExperimentsTableController.exptExptItxs.filter (itx) =>
#			itx.get('ignored') is true
#		console.log ignoredPrimaryExptExptItxs
		console.log "expt itxs to create"
		@addedPrimaryExperimentsTableController.exptExptItxs.each (itx) =>
			if itx.isNew()
				itx.set 'firstExperiment', @model
		@addedFollowUpExperimentsTableController.exptExptItxs.each (itx) =>
			if itx.isNew()
				itx.set 'firstExperiment', @model
		console.log "concated expt expt itxs"
		console.log @addedPrimaryExperimentsTableController.exptExptItxs.toJSON().concat @addedFollowUpExperimentsTableController.exptExptItxs.toJSON()
#		newPrimaryExptExptItxs = @addedPrimaryExperimentsTableController.exptExptItxs.filter (itx) =>
#			itx.isNew()
		#add firstExperiment information to new primary expt expt itxs
#		newPrimaryExptExptItxs = @addFirstExptInfoToItx newPrimaryExptExptItxs
#		console.log newPrimaryExptExptItxs

		$.ajax
			type: 'PUT'
			url: "/api/putExptExptItxs"
			data: data: JSON.stringify(@addedPrimaryExperimentsTableController.exptExptItxs.toJSON().concat @addedFollowUpExperimentsTableController.exptExptItxs.toJSON())
			json: true
			success: (response) =>
				console.log "update expt itxs resp"
				console.log response
				@showExistingExptExptItxs response
				@addedPrimaryExperimentsTableController.exptExptItxs = @primaryExptExptItxs
				@addedPrimaryExperimentsTableController.collection = @prevLinkedPrimaryExpts
				@addedFollowUpExperimentsTableController.exptExptItxs = @followUpExptExptItxs
				@addedFollowUpExperimentsTableController.collection = @prevLinkedFollowUpExpts
				@exptItxsSavedSuccessfully()
			error: (err) =>
				alert "Save expt expt itx error"

	exptItxsSavedSuccessfully: =>
		@$('.bv_saving').hide()
		@$('.bv_cancel').removeAttr 'disabled'
		@$('.bv_updateComplete').show()
		@trigger 'amClean'

	handleCancelClicked: =>
#		if @model.isNew()
#			if @model.get('lsKind') is "default" #base protocol/experiment
#				@model = null
#				@completeInitialization()
#			else
#				@trigger 'reinitialize'
#		else
		@$('.bv_canceling').show()
		@$('.bv_cancel').attr 'disabled', 'disabled'
		@$('.bv_save').attr 'disabled', 'disabled'
		@reinitialize()
#			@model.fetch
#				success: @handleCancelComplete
		@trigger 'amClean'

#	addFirstExptInfoToItx: (exptExptItxs) =>
#		_.each exptExptItxs, (itx) =>
#			itx.set 'firstExperiment', @model
#		exptExptItxs

#class window.ScreeningCampaignDataAnalysisController extends PrimaryScreenAnalysisParametersController
class window.ScreeningCampaignDataAnalysisController extends AbstractFormController
#	template:  _.template($("#ScreeningCampaignDataAnalysisView").html())
#	autofillTemplate: _.template($("#ScreeningCampaignDataAnalysisAutofillView").html())
	template: _.template($("#ScreeningCampaignDataAnalysisView").html())

	events: ->
		"change .bv_signalDirectionRule": "attributeChanged"
		"change .bv_aggregateBy": "attributeChanged"
		"change .bv_aggregationMethod": "attributeChanged"
		"keyup .bv_primaryHitEfficacyThreshold": "attributeChanged"
		"keyup .bv_primaryHitSDThreshold": "attributeChanged"
		"change .bv_primaryThresholdTypeEfficacy": "handlePrimaryThresholdTypeHitChanged"
		"change .bv_primaryThresholdTypeSD": "handlePrimaryThresholdTypeHitChanged"
		"change .bv_primaryAutoHitSelection": "handlePrimaryAutoHitSelectionCheckboxChanged"

		"keyup .bv_confirmationHitEfficacyThreshold": "attributeChanged"
		"keyup .bv_confirmationHitSDThreshold": "attributeChanged"
		"change .bv_confirmationThresholdTypeEfficacy": "handleConfirmationThresholdTypeChanged"
		"change .bv_confirmationThresholdTypeSD": "handleConfirmationThresholdTypeChanged"
		"change .bv_confirmationAutoHitSelection": "handleConfirmationAutoHitSelectionCheckboxChanged"

		"click .bv_analyze": "handleAnalyzeClicked"

	initialize: ->
		@errorOwnerName = 'ScreeningCampaignDataAnalysisController'
		@setBindings()
		$(@el).empty()
		$(@el).html @template(@model.attributes)
		@model.bind 'amDirty', => @trigger 'amDirty', @
		@listenTo @model, 'change', @modelChangeCallback

	render: =>
#		$(@el).empty()
#		$(@el).html @template()

#		@$('.bv_autofillSection').empty()
#		@$('.bv_autofillSection').html @autofillTemplate(@model.attributes)

		@$("[data-toggle=popover]").popover();
		@$("body").tooltip selector: '.bv_popover'

		@setupSignalDirectionSelect()
		@setupAggregateBySelect()
		@setupAggregationMethodSelect()
		@handleAutoHitSelectionChanged(true, "primary")
		@handleAutoHitSelectionChanged(true, "confirmation")
		@setupNormalizationController()
		@setupTransformationRuleListController()

		@

	modelChangeCallback: =>
		@trigger 'amDirty'
		@$('.bv_analyzeComplete').hide()
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
		@normalizationController.on 'updateState', =>
			@trigger 'updateState'

	setupTransformationRuleListController: ->
		@transformationRuleListController= new TransformationRuleListController
			el: @$('.bv_transformationList')
			collection: @model.get('transformationRuleList')
		@transformationRuleListController.render()
		@transformationRuleListController.on 'updateState', =>
			@trigger 'updateState'

	updateModel: =>
		@model.set
			signalDirectionRule: @signalDirectionListController.getSelectedCode()
			aggregateBy: @aggregateByListController.getSelectedCode()
			aggregationMethod: @aggregationMethodListController.getSelectedCode()
			primaryHitEfficacyThreshold: parseFloat(UtilityFunctions::getTrimmedInput @$('.bv_primaryHitEfficacyThreshold'))
			primaryHitSDThreshold: parseFloat(UtilityFunctions::getTrimmedInput @$('.bv_primaryHitSDThreshold'))
			confirmationHitEfficacyThreshold: parseFloat(UtilityFunctions::getTrimmedInput @$('.bv_confirmationHitEfficacyThreshold'))
			confirmationHitSDThreshold: parseFloat(UtilityFunctions::getTrimmedInput @$('.bv_confirmationHitSDThreshold'))
		@trigger 'updateState' #TODO: need this?
		@$('.bv_cancel').removeAttr 'disabled'


	handlePrimaryThresholdTypeHitChanged: =>
		@handleThresholdTypeChanged "primary"

	handleConfirmationThresholdTypeChanged: =>
		@handleThresholdTypeChanged "confirmation"

	handleThresholdTypeChanged: (prefix) =>
		thresholdType = @$("input[name='bv_"+prefix+"ThresholdType"+"']:checked").val()

		console.log "handle threshold type changed"
		@model.set prefix+"ThresholdType", thresholdType
		console.log console.log "prefix+thresholdType: " + prefix+thresholdType
		console.log @model.get prefix+'ThresholdType'
		if thresholdType =="efficacy"
			@$('.bv_'+prefix+'HitSDThreshold').attr('disabled','disabled')
			@$('.bv_'+prefix+'HitEfficacyThreshold').removeAttr('disabled')
		else
			@$('.bv_'+prefix+'HitEfficacyThreshold').attr('disabled','disabled')
			@$('.bv_'+prefix+'HitSDThreshold').removeAttr('disabled')
		@attributeChanged()

	handlePrimaryAutoHitSelectionCheckboxChanged: =>
		@handleAutoHitSelectionChanged false, "primary"

	handleConfirmationAutoHitSelectionCheckboxChanged: =>
		@handleAutoHitSelectionChanged false, "confirmation"

	handleAutoHitSelectionChanged: (skipUpdate, prefix) =>
		autoHitSelection = @$('.bv_'+prefix+'AutoHitSelection').is(":checked")
		@model.set prefix+'AutoHitSelection', autoHitSelection
		console.log "handle auto hit selection changed"
		console.log prefix+'AutoHitSelection'
		console.log @model.get prefix+'AutoHitSelection'
		if autoHitSelection
			@$('.bv_'+prefix+'ThresholdControls').show()
		else
			@$('.bv_'+prefix+'ThresholdControls').hide()
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
		#TODO: ask Sam about route
#		$.ajax
#			type: 'POST'
#			url: "/api/analyzeScreeningCampaign"
#			data: data: JSON.stringify @model
#			json: true
#			success: (response) =>
#				console.log "analysis complete"
#				console.log response
#				@$('.bv_analysisComplete').show()
#				@$('.bv_analyze').html "Re-analyze"
#				@$('.bv_analyzing').hide()
#			error: (err) =>
#				alert "Error Analyzing Screening Campaign"
				#TODO: catch error

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
						error: (err) ->
							alert 'Could not get experiment for code in this URL, creating new one'
							@completeInitialization()
						success: (json) =>
							if json.length == 0
								alert 'Could not get experiment for code in this URL, creating new one'
							else
								lsType = json.lsType
								lsKind = json.lsKind
								if lsType is "Parent" and lsKind is "Bio Activity"
									expt = new ParentExperiment json
									expt.set expt.parse(expt.attributes)
									if window.AppLaunchParams.moduleLaunchParams.copy
										@model = expt.duplicateEntity()
									else
										@model = expt
								else
									alert 'Could not get parent experiment for code in this URL. Creating new parent experiment'
							@completeInitialization()
				else
					@completeInitialization()
			else
				@completeInitialization()

	completeInitialization: =>
		unless @model?
			@model = new ParentExperiment()
		if @model.isNew()
			@getAndSetProtocol()
		$(@el).html @template()
		@setupExperimentBaseController()
		@setupLinkedExperimentsController()
		@setupDataAnalysisController()
		@listenTo @model, 'sync', @modelSyncCallback
		@listenTo @model, 'change', @modelChangeCallback

	getAndSetProtocol: ->
		#TODO: create PROT-Screen if it doesn't exist
		$.ajax
			type: 'GET'
			url: "/api/protocols/codename/PROT-00000001"
#			url: "/api/protocols/codename/PROT-Screen"
			success: (json) =>
				if json.length == 0
					alert("Could not find screening protocol")
				else
					console.log "got protocol"
					console.log json
					@model.set protocol: new Protocol(json)
#					if setAnalysisParams
#						@getFullProtocol() # this will fetch full protocol
			error: (err) ->
				alert 'got ajax error from getting protocol '+ code
			dataType: 'json'

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
			console.log "experiment base controller is dirty"
			@trigger 'amDirty'
			@linkedExptsController.$('.bv_saveChangesBeforeLink').show()
			@linkedExptsController.$('.bv_linkedExperimentsWrapper').hide()
			@dataAnalysisController.$('.bv_saveChangesBeforeAnalysis').show()
			@dataAnalysisController.$('.bv_dataAnalysisParametersWrapper').hide()
		@experimentBaseController.on 'amClean', =>
			@trigger 'amClean'
			@linkedExptsController.$('.bv_saveChangesBeforeLink').hide()
			@linkedExptsController.$('.bv_linkedExperimentsWrapper').show()
			@dataAnalysisController.$('.bv_saveChangesBeforeAnalysis').hide()
			@dataAnalysisController.$('.bv_dataAnalysisParametersWrapper').show()
		@experimentBaseController.on 'reinitialize', @reinitialize

	setupLinkedExperimentsController: ->
		if @linkedExptsController?
			@linkedExptsController.undelegateEvents()
		@linkedExptsController = new LinkedExperimentsController
			model: @model
			el: @$('.bv_screeningCampaignLinkedExperiments')
		@linkedExptsController.on 'amDirty', =>
			@trigger 'amDirty'
			#TODO: figure out if need to disable editing general tab
			@dataAnalysisController.$('.bv_saveChangesBeforeAnalysis').show()
			@dataAnalysisController.$('.bv_dataAnalysisParametersWrapper').hide()
		@linkedExptsController.on 'amClean', =>
			@trigger 'amClean'
			@dataAnalysisController.$('.bv_saveChangesBeforeAnalysis').hide()
			@dataAnalysisController.$('.bv_dataAnalysisParametersWrapper').show()
		@linkedExptsController.render()

	setupDataAnalysisController: ->
		if @dataAnalysisController?
			@dataAnalysisController.undelegateEvents()
		console.log "setup data analysis controller - analysis params"
		console.log @model.getAnalysisParameters()
		@dataAnalysisController = new ScreeningCampaignDataAnalysisController
			model: @model.getAnalysisParameters()
			el: @$('.bv_screeningCampaignDataAnalysis')
		@dataAnalysisController.on 'amDirty', =>
			@trigger 'amDirty'
			#TODO: figure out if need to disable editing general tab
			@linkedExptsController.$('.bv_saveChangesBeforeLink').show()
			@linkedExptsController.$('.bv_linkedExperimentsWrapper').hide()
		@dataAnalysisController.on 'amClean', =>
			@trigger 'amClean'
			@linkedExptsController.$('.bv_saveChangesBeforeLink').hide()
			@linkedExptsController.$('.bv_linkedExperimentsWrapper').show()
		@dataAnalysisController.render()
