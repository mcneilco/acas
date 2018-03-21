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
			experimentCode: UtilityFunctions::getTrimmedInput @$('.bv_experimentCode')

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
		#$(".bv_searchStatusIndicator").removeClass "hide"
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
		$.ajax
			type: 'GET'
			url: "/api/experiments/genericSearch/#{searchTerm}"
			dataType: "json"
			data:
				testMode: false
				fullObject: true
			success: (experiment) =>
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
		if window.conf.experiment?.mainControllerClassName?
			exptControllerClassName = window.conf.experiment.mainControllerClassName
		else
			exptControllerClassName = "ExperimentBaseController"
		experimentController = new window[exptControllerClassName]
			model: experiment
			el: $('.bv_experimentBaseController')
		#protocolFilter: "?protocolKind=FLIPR"
		experimentController.render()
		$(".bv_experimentBaseController").show()


	setupExperimentSummaryTable: (experiments) =>
		#@$(".bv_searchStatusIndicator").addClass "hide"
		$(".bv_experimentTableController").removeClass "hide"
		if window.conf.experiment?.mainControllerClassName? and window.conf.experiment.mainControllerClassName is "EnhancedExperimentBaseController"
			experimentListClass = "EnhancedExperimentList"
		else
			experimentListClass = "ExperimentList"
		@experimentSummaryTable = new ExperimentSummaryTableController
			el: $(".bv_experimentTableController")
			collection: new window[experimentListClass] experiments

		@experimentSummaryTable.on "selectedRowUpdated", @selectedExperimentUpdated

		@experimentSummaryTable.render()

class window.ExperimentSearch extends Backbone.Model
	defaults:
		protocolCode: null
		experimentCode: null

class window.ExperimentSimpleSearchController extends AbstractFormController
	template: _.template($("#ExperimentSimpleSearchView").html())
	genericSearchUrl: "/api/experiments/genericSearch/"
	codeNameSearchUrl: "/api/experiments/codename/"

	initialize: ->
		@includeDuplicateAndEdit = @options.includeDuplicateAndEdit
		@searchUrl = ""
		if @includeDuplicateAndEdit
			@searchUrl = @genericSearchUrl
		else
			@searchUrl = @codeNameSearchUrl
		if @options.domSuffix? #suffix added to end of dom elements that are searched for globally in handleDoSearchClicked
			@domSuffix = @options.domSuffix
		else
			@domSuffix = ""


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
		$(".bv_experimentTableController"+@domSuffix).addClass "hide"
		$(".bv_errorOccurredPerformingSearch"+@domSuffix).addClass "hide"
		experimentSearchTerm = $.trim(@$(".bv_experimentSearchTerm").val())
		$(".bv_exptSearchTerm"+@domSuffix).val ""
		if experimentSearchTerm isnt ""
			$(".bv_noMatchingExperimentsFoundMessage"+@domSuffix).addClass "hide"
			$(".bv_experimentBrowserSearchInstructions"+@domSuffix).addClass "hide"
			$(".bv_searchExperimentsStatusIndicator"+@domSuffix).removeClass "hide"
			if !window.conf.browser.enableSearchAll and experimentSearchTerm is "*"
				$(".bv_moreSpecificExperimentSearchNeeded").removeClass "hide"
			else
				$(".bv_searchingExperimentsMessage").removeClass "hide"
				$(".bv_exptSearchTerm").html experimentSearchTerm
				$(".bv_moreSpecificExperimentSearchNeeded").addClass "hide"
				@doSearch experimentSearchTerm

	doSearch: (experimentSearchTerm) =>
		# disable the search text field while performing a search
		@$(".bv_experimentSearchTerm").attr "disabled", true
		@$(".bv_doSearch").attr "disabled", true
		@trigger 'find'
		unless experimentSearchTerm is ""
			$.ajax
				type: 'GET'
				url: @searchUrl + experimentSearchTerm
				dataType: "json"
				data:
					testMode: false
			#fullObject: true
				success: (experiment) =>
					@trigger "searchReturned", experiment
				error: (result) =>
					@trigger "searchReturned", null
				complete: =>
					# re-enable the search text field regardless of if any results found
					@$(".bv_experimentSearchTerm").attr "disabled", false
					@$(".bv_doSearch").attr "disabled", false



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
		date = @model.getCompletionDate()
		if date.isNew()
			date = "not recorded"
		else
			date = UtilityFunctions::convertMSToYMDDate(date.get('dateValue'))

		experimentBestName = @model.get('lsLabels').pickBestName()
		if experimentBestName
			experimentBestName = @model.get('lsLabels').pickBestName().get('labelText')
		protocolBestName = @model.get('protocol').get('lsLabels').pickBestName()
		if protocolBestName
			protocolBestName = @model.get('protocol').get('lsLabels').pickBestName().get('labelText')
		if @model.get('lsLabels') not instanceof LabelList
			@model.set 'lsLabels',  new LabelList @model.get('lsLabels')
		subclass = @model.get('subclass')
		protocolCode = @model.get('protocol').get('codeName')
		if window.conf.entity?.saveInitialsCorpName? and window.conf.entity.saveInitialsCorpName is true
			if @model.get('lsLabels').getLabelByTypeAndKind("corpName", subclass + ' corpName').length > 0
				code = @model.get('lsLabels').getLabelByTypeAndKind('corpName', subclass + ' corpName')[0].get('labelText')
				if @model.get('protocol').get('lsLabels').getLabelByTypeAndKind("corpName", 'protocol corpName').length > 0
					protocolCode = @model.get('protocol').get('lsLabels').getLabelByTypeAndKind('corpName', 'protocol corpName')[0].get('labelText')
			else if @model.get('lsKind') is "study" and @model.get('lsLabels').getLabelByTypeAndKind('id', 'study id').length > 0
				code = @model.get('lsLabels').getLabelByTypeAndKind('id', 'study id')[0].get('labelText')
			else
				code = @model.get("codeName")
		else if @model.get('lsKind') is "study" and @model.get('lsLabels').getLabelByTypeAndKind('id', 'study id').length > 0
			code = @model.get('lsLabels').getLabelByTypeAndKind('id', 'study id')[0].get('labelText')
		else
			code = @model.get('codeName')

		toDisplay =
			experimentName: experimentBestName
			experimentCode: code
			protocolCode: protocolCode
			protocolName: protocolBestName
			scientist: @model.getScientist().get('codeValue')
			status: @model.getStatus().get("codeValue")
			analysisStatus: @model.getAnalysisStatus().get("codeValue")
			completionDate: date
		$(@el).html(@template(toDisplay))

		unless window.conf.save?.project? and window.conf.save.project.toLowerCase() is "false"
			project = @model.getProjectCode().get('codeValue')
			@$('.bv_protocolName').after "<td class='bv_project'>"+project+"</td>"
		@

class window.ExperimentSummaryTableController extends Backbone.View
	initialize: ->
		if @options.domSuffix?
			@domSuffix = @options.domSuffix
		else
			@domSuffix = ""

	selectedRowChanged: (row) =>
		@trigger "selectedRowUpdated", row

	render: =>
		@template = _.template($('#ExperimentSummaryTableView').html())
		$(@el).html @template
		unless window.conf.save?.project? and window.conf.save.project.toLowerCase() is "false"
			@$('.bv_protocolNameHeader').after '<th style="width: 175px;">Project</th>'
		if @collection.models.length is 0
			$(".bv_noMatchingExperimentsFoundMessage"+@domSuffix).removeClass "hide"
			# display message indicating no results were found
		else
			$(".bv_noMatchingExperimentsFoundMessage"+@domSuffix).addClass "hide"
			@collection.each (exp) =>
				canViewDeleted = @canViewDeleted(exp)
				if exp.getStatus().get('codeValue') is 'deleted'
					if canViewDeleted
						ersc = new ExperimentRowSummaryController
							model: exp
						ersc.on "gotClick", @selectedRowChanged
						@$("tbody").append ersc.render().el
				else
					ersc = new ExperimentRowSummaryController
						model: exp
					ersc.on "gotClick", @selectedRowChanged
					@$("tbody").append ersc.render().el

			@$("table").dataTable oLanguage:
				sSearch: "Filter results: " #rename summary table's search bar

		@

	canViewDeleted: (exp) ->
		if window.conf.entity?.viewDeletedRoles?
			rolesToTest = []
			for role in window.conf.entity.viewDeletedRoles.split(",")
				role = $.trim(role)
				if role is 'entityScientist'
					if (window.AppLaunchParams.loginUserName is exp.getScientist().get('codeValue'))
						return true
				else if role is 'projectAdmin'
					projectAdminRole =
						lsType: "Project"
						lsKind: exp.getProjectCode().get('codeValue')
						roleName: "Administrator"
					if UtilityFunctions::testUserHasRoleTypeKindName(window.AppLaunchParams.loginUser, [projectAdminRole])
						return true
				else
					rolesToTest.push role
			if rolesToTest.length is 0
				return false
			if UtilityFunctions::testUserHasRole window.AppLaunchParams.loginUser, rolesToTest
				return true
		return false

class window.ExperimentBrowserController extends Backbone.View
	#template: _.template($("#ExperimentBrowserView").html())
	includeDuplicateAndEdit: true
	events:
		"click .bv_deleteExperiment": "handleDeleteExperimentClicked"
		"click .bv_editExperiment": "handleEditExperimentClicked"
		"click .bv_duplicateExperiment": "handleDuplicateExperimentClicked"
		"click .bv_confirmDeleteExperimentButton": "handleConfirmDeleteExperimentClicked"
		"click .bv_cancelDelete": "handleCancelDeleteClicked"
		"click .bv_openInQueryToolButton": "handleOpenInQueryToolClicked"

	initialize: ->
		template = _.template( $("#ExperimentBrowserView").html(),  {includeDuplicateAndEdit: @includeDuplicateAndEdit} );
		$(@el).empty()
		$(@el).html template
		@searchController = new ExperimentSimpleSearchController
			model: new ExperimentSearch()
			el: @$('.bv_experimentSearchController')
			includeDuplicateAndEdit: @includeDuplicateAndEdit
		@searchController.render()
		@searchController.on "searchReturned", @setupExperimentSummaryTable
		#@searchController.on "resetSearch", @destroyExperimentSummaryTable
#		@$('.bv_queryToolDisplayName').html window.conf.service.result.viewer.displayName

	setupExperimentSummaryTable: (experiments) =>
		@destroyExperimentSummaryTable()

		$(".bv_searchingExperimentsMessage").addClass "hide"
		if experiments is null
			@$(".bv_errorOccurredPerformingSearch").removeClass "hide"

		else if experiments.length is 0
			@$(".bv_noMatchingExperimentsFoundMessage").removeClass "hide"
			@$(".bv_experimentTableController").html ""
		else
			$(".bv_searchExperimentsStatusIndicator").addClass "hide"
			@$(".bv_experimentTableController").removeClass "hide"
			if window.conf.experiment?.mainControllerClassName? and window.conf.experiment.mainControllerClassName is "EnhancedExperimentBaseController"
				experimentListClass = "EnhancedExperimentList"
			else
				experimentListClass = "ExperimentList"
			@experimentSummaryTable = new ExperimentSummaryTableController
				collection: new window[experimentListClass] experiments

			@experimentSummaryTable.on "selectedRowUpdated", @selectedExperimentUpdated
			$(".bv_experimentTableController").html @experimentSummaryTable.render().el

	selectedExperimentUpdated: (experiment) =>
		@trigger "selectedExperimentUpdated"
		$.ajax
			type: 'GET'
			url: "/api/getControllerRedirectConf"
			success: (dict) =>
				@controllerRedirectConf = dict
				@setupExperimentController experiment
			error: (err) =>
				console.log "error reading controller redirect conf"
			dataType: 'json'
		
	setupExperimentController: (experiment) =>
		lsKind = experiment.get('lsKind')
		if @controllerRedirectConf['EXPT']?[lsKind]?['modelClass']? and @controllerRedirectConf['EXPT']?[lsKind]?['browserControllerClass']?
			if @controllerRedirectConf['EXPT']?[lsKind]?['protocolKindFilter']?
				protocolKindFilter = @controllerRedirectConf['EXPT'][lsKind]['protocolKindFilter']
			@experimentController = new window[@controllerRedirectConf['EXPT'][lsKind]['browserControllerClass']]
				protocolKindFilter: protocolKindFilter
				model: new window[@controllerRedirectConf['EXPT'][lsKind]['modelClass']] JSON.parse(JSON.stringify(experiment))
				readOnly: true
		else
			if window.conf.experiment?.mainControllerClassName?
				exptControllerClassName = window.conf.experiment.mainControllerClassName
				if exptControllerClassName is "EnhancedExperimentBaseController"
					model = new EnhancedExperiment experiment.attributes
				else
					model = new Experiment experiment.attributes
			else
				exptControllerClassName = "ExperimentBaseController"
				model = new Experiment experiment.attributes
			@experimentController = new window[exptControllerClassName]
				model: model
				readOnly: true

		#hide the Open in Data Viewer button
		console.log "hiding bv_openInQueryToolWrapper"
		@experimentController.$('.bv_openInQueryToolWrapper').hide()
		if experiment.get('lsKind') is "Bio Activity Screen"
			@experimentController.$('.bv_experimentNameLabel').html "*Parent Experiment Name"
			@experimentController.$('.bv_group_protocolCode').hide()
		$(".bv_experimentBaseController").removeClass("hide")
		$(".bv_experimentBaseControllerContainer").removeClass("hide")
		$('.bv_experimentBaseController').html @experimentController.render().el
		if experiment.getStatus().get('codeValue') is "deleted"
			@$('.bv_openInQueryTool').hide()
			@$('.bv_deleteExperiment').hide()
			@$('.bv_editExperiment').hide() #TODO for future releases, add in hiding duplicateExperiment
		else
			@$('.bv_openInQueryTool').show()
			@formatOpenInQueryToolButton()
			if @canEdit()
				@$('.bv_editExperiment').show()
			else
				@$('.bv_editExperiment').hide()
			if @canDelete()
				@$('.bv_deleteExperiment').show()
			else
				@$('.bv_deleteExperiment').hide()

	canEdit: ->
		if @experimentController.model.getScientist().get('codeValue') is "unassigned"
			return true
		else
			if @experimentController.model.get('lsKind') is 'study'
				if window.conf.entity?.study?.editingRoles?
					editingRoles = window.conf.entity.study.editingRoles
				else
					editingRoles = null
			else if window.conf.entity?.editingRoles?
				editingRoles = window.conf.entity.editingRoles
			if editingRoles?
				rolesToTest = []
				for role in editingRoles.split(",")
					role = $.trim(role)
					if role is 'entityScientist'
						if (window.AppLaunchParams.loginUserName is @experimentController.model.getScientist().get('codeValue'))
							return true
					else if role is 'projectAdmin'
						projectAdminRole =
							lsType: "Project"
							lsKind: @experimentController.model.getProjectCode().get('codeValue')
							roleName: "Administrator"
						if UtilityFunctions::testUserHasRoleTypeKindName(window.AppLaunchParams.loginUser, [projectAdminRole])
							return true
					else
						rolesToTest.push role
				if rolesToTest.length is 0
					return false
				unless UtilityFunctions::testUserHasRole window.AppLaunchParams.loginUser, rolesToTest
					return false
			return true

	canDelete: ->
		if window.conf.entity?.deletingRoles?
			rolesToTest = []
			for role in window.conf.entity.deletingRoles.split(",")
				role = $.trim(role)
				if role is 'entityScientist'
					if (window.AppLaunchParams.loginUserName is @experimentController.model.getScientist().get('codeValue'))
						return true
				else if role is 'projectAdmin'
					projectAdminRole =
						lsType: "Project"
						lsKind: @experimentController.model.getProjectCode().get('codeValue')
						roleName: "Administrator"
					if UtilityFunctions::testUserHasRoleTypeKindName(window.AppLaunchParams.loginUser, [projectAdminRole])
						return true
				else
					rolesToTest.push role
			if rolesToTest.length is 0
				return false
			unless UtilityFunctions::testUserHasRole window.AppLaunchParams.loginUser, rolesToTest
				return false
		return true

	handleDeleteExperimentClicked: =>
		if @experimentController.model.get('lsLabels') not instanceof LabelList
			@experimentController.model.set 'lsLabels',  new LabelList @experimentController.model.get('lsLabels')
		subclass = @experimentController.model.get('subclass')
		if window.conf.entity?.saveInitialsCorpName? and window.conf.entity.saveInitialsCorpName is true
			if @experimentController.model.get('lsLabels').getLabelByTypeAndKind("corpName", subclass + ' corpName').length > 0
				code = @experimentController.model.get('lsLabels').getLabelByTypeAndKind('corpName', subclass + ' corpName')[0].get('labelText')
			else if @model.get('lsKind') is "study" and @model.get('lsLabels').getLabelByTypeAndKind('id', 'study id').length > 0
				code = @model.get('lsLabels').getLabelByTypeAndKind('id', 'study id')[0].get('labelText')
			else
				code = @experimentController.model.get("codeName")
		else if @experimentController.model.get('lsKind') is "study" and @experimentController.model.get('lsLabels').getLabelByTypeAndKind('id', 'study id').length > 0
			code = @experimentController.model.get('lsLabels').getLabelByTypeAndKind('id', 'study id')[0].get('labelText')
		else
			code = @experimentController.model.get('codeName')

		@$(".bv_experimentCodeName").html code
		@$(".bv_deleteButtons").removeClass "hide"
		@$(".bv_okayButton").addClass "hide"
		@$(".bv_errorDeletingExperimentMessage").addClass "hide"
		@$(".bv_deleteWarningMessage").removeClass "hide"
		@$(".bv_deletingStatusIndicator").addClass "hide"
		@$(".bv_experimentDeletedSuccessfullyMessage").addClass "hide"
		$(".bv_confirmDeleteExperiment").removeClass "hide"
		$('.bv_confirmDeleteExperiment').modal({
			keyboard: false,
			backdrop: true
		})

	handleConfirmDeleteExperimentClicked: =>
		@$(".bv_deleteWarningMessage").addClass "hide"
		@$(".bv_deletingStatusIndicator").removeClass "hide"
		@$(".bv_deleteButtons").addClass "hide"
		$.ajax(
			url: "/api/experiments/#{@experimentController.model.get("id")}",
			type: 'DELETE',
			success: (result) =>
				@$(".bv_okayButton").removeClass "hide"
				@$(".bv_deletingStatusIndicator").addClass "hide"
				@$(".bv_experimentDeletedSuccessfullyMessage").removeClass "hide"
				@searchController.handleDoSearchClicked()
		#@destroyExperimentSummaryTable()
			error: (result) =>
				@$(".bv_okayButton").removeClass "hide"
				@$(".bv_deletingStatusIndicator").addClass "hide"
				@$(".bv_errorDeletingExperimentMessage").removeClass "hide"
		)

	handleCancelDeleteClicked: =>
		@$(".bv_confirmDeleteExperiment").modal('hide')

	handleEditExperimentClicked: =>
		if @experimentController.model.get('lsLabels') not instanceof LabelList
			@experimentController.model.set 'lsLabels',  new LabelList @experimentController.model.get('lsLabels')
		subclass = @experimentController.model.get('subclass')
		if window.conf.entity?.saveInitialsCorpName? and window.conf.entity.saveInitialsCorpName is true
			if @experimentController.model.get('lsLabels').getLabelByTypeAndKind("corpName", subclass + ' corpName').length > 0
				code = @experimentController.model.get('lsLabels').getLabelByTypeAndKind('corpName', subclass + ' corpName')[0].get('labelText')
			else if @experimentController.model.get('lsKind') is "study" and @experimentController.model.get('lsLabels').getLabelByTypeAndKind('id', 'study id').length > 0
				code = @experimentController.model.get('lsLabels').getLabelByTypeAndKind('id', 'study id')[0].get('labelText')
			else
				code = @experimentController.model.get("codeName")
		else if @experimentController.model.get('lsKind') is "study" and @experimentController.model.get('lsLabels').getLabelByTypeAndKind('id', 'study id').length > 0
			code = @experimentController.model.get('lsLabels').getLabelByTypeAndKind('id', 'study id')[0].get('labelText')
		else
			code = @experimentController.model.get('codeName')
#
#		if @experimentController.model.get('lsKind') is 'study'
#			if @experimentController.model.get('lsLabels') not instanceof LabelList
#				@experimentController.model.set 'lsLabels',  new LabelList @experimentController.model.get('lsLabels')
#			if @experimentController.model.get('lsLabels').getLabelByTypeAndKind('id', 'study id').length > 0
#				code = @experimentController.model.get('lsLabels').getLabelByTypeAndKind('id', 'study id')[0].get('labelText')
#			else
#				code = @experimentController.model.get("codeName")
#		else
#			code = @experimentController.model.get("codeName")
		window.open("/entity/edit/codeName/#{code}",'_blank');

	handleDuplicateExperimentClicked: =>
		experimentKind = @experimentController.model.get('lsKind')
		if @experimentController.model.get('lsLabels') not instanceof LabelList
			@experimentController.model.set 'lsLabels',  new LabelList @experimentController.model.get('lsLabels')
		subclass = @experimentController.model.get('subclass')
		if window.conf.entity?.saveInitialsCorpName? and window.conf.entity.saveInitialsCorpName is true
			if @experimentController.model.get('lsLabels').getLabelByTypeAndKind("corpName", subclass + ' corpName').length > 0
				code = @experimentController.model.get('lsLabels').getLabelByTypeAndKind('corpName', subclass + ' corpName')[0].get('labelText')
			else if @experimentController.model.get('lsKind') is "study" and @experimentController.model.get('lsLabels').getLabelByTypeAndKind('id', 'study id').length > 0
				code = @experimentController.model.get('lsLabels').getLabelByTypeAndKind('id', 'study id')[0].get('labelText')
			else
				code = @experimentController.model.get("codeName")
		else if @experimentController.model.get('lsKind') is "study" and @experimentController.model.get('lsLabels').getLabelByTypeAndKind('id', 'study id').length > 0
			code = @experimentController.model.get('lsLabels').getLabelByTypeAndKind('id', 'study id')[0].get('labelText')
		else
			code = @experimentController.model.get('codeName')
		
		if experimentKind is "Bio Activity"
			window.open("/entity/copy/primary_screen_experiment/#{@experimentController.model.get("codeName")}",'_blank');
		else if experimentKind is "study"
			if @experimentController.model.get('lsLabels') not instanceof LabelList
				@experimentController.model.set 'lsLabels',  new LabelList @experimentController.model.get('lsLabels')
			if @experimentController.model.get('lsLabels').getLabelByTypeAndKind('id', 'study id').length > 0
				code = @experimentController.model.get('lsLabels').getLabelByTypeAndKind('id', 'study id')[0].get('labelText')
			else
				code = @experimentController.model.get("codeName")
			window.open("/entity/copy/study_tracker_experiment/#{code}",'_blank');
		else
			window.open("/entity/copy/experiment_base/#{@experimentController.model.get("codeName")}",'_blank');

	handleOpenInQueryToolClicked: =>
		unless @$('.bv_openInQueryToolButton').hasClass 'dropdown-toggle'
			if @experimentController.model.get('lsLabels') not instanceof LabelList
				@experimentController.model.set 'lsLabels',  new LabelList @experimentController.model.get('lsLabels')
			subclass = @experimentController.model.get('subclass')
			if window.conf.entity?.saveInitialsCorpName? and window.conf.entity.saveInitialsCorpName is true
				if @experimentController.model.get('lsLabels').getLabelByTypeAndKind("corpName", subclass + ' corpName').length > 0
					code = @experimentController.model.get('lsLabels').getLabelByTypeAndKind('corpName', subclass + ' corpName')[0].get('labelText')
				else if @experimentController.model.get('lsKind') is "study" and @experimentController.model.get('lsLabels').getLabelByTypeAndKind('id', 'study id').length > 0
					code = @experimentController.model.get('lsLabels').getLabelByTypeAndKind('id', 'study id')[0].get('labelText')
				else
					code = @experimentController.model.get("codeName")
			else if @experimentController.model.get('lsKind') is "study" and @experimentController.model.get('lsLabels').getLabelByTypeAndKind('id', 'study id').length > 0
				code = @experimentController.model.get('lsLabels').getLabelByTypeAndKind('id', 'study id')[0].get('labelText')
			else
				code = @experimentController.model.get('codeName')

			window.open("/openExptInQueryTool?experiment=#{code}",'_blank')

	formatOpenInQueryToolButton: =>
		@$('.bv_viewerOptions').empty()
		configuredViewers = window.conf.service.result.viewer.configuredViewers
		if configuredViewers?
			configuredViewers = configuredViewers.split(",")
		if configuredViewers? and configuredViewers.length>1
			for viewer in configuredViewers
				viewerName = $.trim viewer
				if @experimentController.model.get('lsLabels') not instanceof LabelList
					@experimentController.model.set 'lsLabels',  new LabelList @experimentController.model.get('lsLabels')
				subclass = @experimentController.model.get('subclass')
				if window.conf.entity?.saveInitialsCorpName? and window.conf.entity.saveInitialsCorpName is true
					if @experimentController.model.get('lsLabels').getLabelByTypeAndKind("corpName", subclass + ' corpName').length > 0
						code = @experimentController.model.get('lsLabels').getLabelByTypeAndKind('corpName', subclass + ' corpName')[0].get('labelText')
					else if @experimentController.model.get('lsKind') is "study" and @experimentController.model.get('lsLabels').getLabelByTypeAndKind('id', 'study id').length > 0
						code = @experimentController.model.get('lsLabels').getLabelByTypeAndKind('id', 'study id')[0].get('labelText')
					else
						code = @experimentController.model.get("codeName")
				else if @experimentController.model.get('lsKind') is "study" and @experimentController.model.get('lsLabels').getLabelByTypeAndKind('id', 'study id').length > 0
					code = @experimentController.model.get('lsLabels').getLabelByTypeAndKind('id', 'study id')[0].get('labelText')
				else
					code = @experimentController.model.get('codeName')
					
				href = "'/openExptInQueryTool?tool=#{viewerName}&experiment=#{code}','_blank'"
				if @experimentController.model.getStatus().get('codeValue') != "approved" and viewerName is "LiveDesign"
					@$('.bv_viewerOptions').append '<li class="disabled"><a href='+href+' target="_blank">'+viewerName+'</a></li>'
				else
					@$('.bv_viewerOptions').append '<li><a href='+href+' target="_blank">'+viewerName+'</a></li>'
		else
			@$('.bv_openInQueryToolButton').removeAttr 'data-toggle', 'dropdown'
			@$('.bv_openInQueryToolButton').removeClass 'dropdown-toggle'
			@$('.bv_openInQueryToolButton .caret').hide()
			@$('.bv_openInQueryToolButton').html("Open In " + window.conf.service.result.viewer.displayName)
			@$('.bv_openInQueryTool').removeClass "btn-group"

	destroyExperimentSummaryTable: =>
		if @experimentSummaryTable?
			@experimentSummaryTable.remove()
		if @experimentController?
			@experimentController.remove()
		$(".bv_experimentBaseController").addClass("hide")
		$(".bv_experimentBaseControllerContainer").addClass("hide")
		$(".bv_noMatchingExperimentsFoundMessage").addClass("hide")

	render: =>

		@

class window.ExperimentDetailController extends Backbone.View
	template: _.template($("#ExperimentDetailsView").html())

	initialize: ->
		$(@el).empty()
		$(@el).html @template()



	render: =>

		@
