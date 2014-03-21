beforeEach ->
	@fixture = $.clone($("#fixture").get(0))

afterEach ->
	$("#fixture").remove()
	$("body").append $(@fixture)

describe "Gene Data Queries Module Testing", ->
	describe "Gene ID model testing", ->
		describe "When loaded from new", ->
			beforeEach ->
				@gid = new GeneID()
			describe "Existence and Defaults", ->
				it "should be defined", ->
					expect(@gid).toBeDefined()
				it "should have a default gid", ->
					expect(@gid.get('gid')).toBeNull()
	describe "Gene ID List model testing", ->
		describe "When loaded from new", ->
			beforeEach ->
				@gidl = new GeneIDList()
			describe "Existence and Defaults", ->
				it "should be defined", ->
					expect(@gidl).toBeDefined()
			describe "Parsing functions", ->
				beforeEach ->
					@gidl.addGIDsFromString "1234, 3421,1111, 2222 , 3333"
				it "should be accept a string of comma seperated gene IDs", ->
					expect(@gidl.length).toEqual 5
				it "should strip spaces", ->
					expect(@gidl.at(1).get('gid')).toEqual '3421'
					expect(@gidl.at(3).get('gid')).toEqual '2222'
				it "should add to the existing set when called again", ->
					@gidl.addGIDsFromString "555, 3466621,777, 888 , 999"
					expect(@gidl.length).toEqual 10
				it "should have zero length when given an empty string", ->
					@gidl.reset()
					@gidl.addGIDsFromString ""
					expect(@gidl.length).toEqual 0

	describe "Gene ID Query Input Controller", ->
		describe 'when instantiated', ->
			beforeEach ->
				@gidqic = new GeneIDQueryInputController
					collection: new GeneIDList()
					el: $('#fixture')
				@gidqic.render()
			describe "basic existance tests", ->
				it 'should exist', ->
					expect(@gidqic).toBeDefined()
				it 'should load a template', ->
					expect(@gidqic.$('.bv_gidListString').length).toEqual 1
			describe "update the model", ->
				beforeEach ->
					@gidqic.$('.bv_gidListString').val "1234, 3421,1111, 2222 , 3333"
					@gidqic.updateGIDsFromField()
				it "should get 5 entries", ->
					expect(@gidqic.collection.length).toEqual 5
				it "should strip spaces", ->
					expect(@gidqic.collection.at(1).get('gid')).toEqual '3421'
					expect(@gidqic.collection.at(3).get('gid')).toEqual '2222'
				it "should empty the collection before adding gids from the text field", ->
					@gidqic.$('.bv_gidListString').val "555, 3466621,777, 888 , 999"
					@gidqic.updateGIDsFromField()
					expect(@gidqic.collection.length).toEqual 5
			describe "search button enabling behavior", ->
				it "should have search button disabled when nothing in field", ->
					expect(@gidqic.$('.bv_search').attr('disabled')).toEqual 'disabled'
				it "should have search button enabled when someting added to field", ->
					@gidqic.$('.bv_gidListString').val "555, 3466621,777, 888 , 999"
					@gidqic.$('.bv_gidListString').change()
					expect(@gidqic.$('.bv_search').attr('disabled')).toBeUndefined()
				it "should have search button disabled when field is emptied", ->
					@gidqic.$('.bv_gidListString').val ""
					@gidqic.$('.bv_gidListString').change()
					expect(@gidqic.$('.bv_search').attr('disabled')).toEqual 'disabled'
			describe "search button behavior", ->
				it "should trigger a search request when search button pressed", ->
					runs ->
						@gidqic.$('.bv_gidListString').val "555, 3466621,777, 888 , 999"
						@gidqic.$('.bv_gidListString').change()
						@gotTrigger = false
						@gidqic.on 'search-requested', =>
							@gotTrigger = true
						@gidqic.$('.bv_search').click()
					waitsFor =>
						@gotTrigger
					, 1000
					runs =>
						expect(@gotTrigger).toBeTruthy()

	describe "Gene ID Query Result Controller", ->
		describe 'when instantiated', ->
			beforeEach ->
				@gidqrc = new GeneIDQueryResultController
					model: new Backbone.Model window.geneDataQueriesTestJSON.geneIDQueryResults
					el: $('#fixture')
				@gidqrc.render()
			describe "basic existance tests", ->
				it 'should exist', ->
					expect(@gidqrc).toBeDefined()
				it 'should load a template', ->
					expect(@gidqrc.$('.bv_resultTable').length).toEqual 1
			describe "data display", ->
				it "should setup DOM in prep to load datatable module", ->
					expect(@gidqrc.$('thead tr').length).toEqual 2
				it "should render the rest of the table", ->
					expect(@gidqrc.$('tbody tr').length).toEqual 4
				it "should not show the no results message", ->
					expect(@gidqrc.$('.bv_noResultsFound')).toBeHidden()
		describe 'when instantiated with empty result set', ->
			beforeEach ->
				@gidqrc = new GeneIDQueryResultController
					model: new Backbone.Model window.geneDataQueriesTestJSON.geneIDQueryResultsNoneFound
					el: $('#fixture')
				@gidqrc.render()
			describe "data display", ->
				it "should hide the data table", ->
					expect(@gidqrc.$('.bv_resultTable')).toBeHidden()
				it "should show no results message", ->
					expect(@gidqrc.$('.bv_noResultsFound')).toBeVisible()



	describe "Gene ID Query Search Controller", ->
		describe 'when instantiated', ->
			beforeEach ->
				@gidqsc = new GeneIDQuerySearchController
					el: $('#fixture')
				@gidqsc.render()
			describe "basic existance tests", ->
				it 'should exist', ->
					expect(@gidqsc).toBeDefined()
				it 'should load a template', ->
					expect(@gidqsc.$('.bv_inputView').length).toEqual 1
			describe "on startup", ->
				it 'should load and show the input controller', ->
					expect(@gidqsc.$('.bv_gidListString').length).toEqual 1
				it "should hide result table", ->
					expect(@gidqsc.$('.bv_resultsView')).toBeHidden()
				it "should show search in center at start", ->
					expect(@gidqsc.$('.bv_gidSearchStart .bv_searchForm').length).toEqual 1
				it "should show gidSearchStart", ->
					expect(@gidqsc.$('.bv_gidSearchStart')).toBeVisible()
				it "should show ACAS badge at start", ->
					expect(@gidqsc.$('.bv_gidACASBadge')).toBeVisible()
				it "should hide ACAS inline badge at start", ->
					expect(@gidqsc.$('.bv_gidACASBadgeTop')).toBeHidden()
				it "should have the gidNavAdvancedSearchButton start class", ->
					expect(@gidqsc.$('.bv_gidNavAdvancedSearchButton').hasClass('gidNavAdvancedSearchButtonBottom')).toBeTruthy()
				it "should not have the gidNavHelpButton pull-right class", ->
					expect(@gidqsc.$('.bv_gidNavHelpButton').hasClass('pull-right')).toBeFalsy()
				it "should add the gidNavAdvancedSearchButton end class", ->
					expect(@gidqsc.$('.bv_gidNavAdvancedSearchButton').hasClass('gidNavAdvancedSearchButtonTop')).toBeFalsy()
				it "should have the gidNavWellBottom class at start", ->
					expect(@gidqsc.$('.bv_toolbar').hasClass('gidNavWellBottom')).toBeTruthy()
				it "should not have the gidNavWellTop class at start", ->
					expect(@gidqsc.$('.bv_toolbar').hasClass('gidNavWellTop')).toBeFalsy()
				it "should have the toolbar fixed bottom class at start", ->
					expect(@gidqsc.$('.bv_group_toolbar').hasClass('navbar-fixed-bottom')).toBeTruthy()
				it "should not have the toolbar fixed top class at start", ->
					expect(@gidqsc.$('.bv_group_toolbar').hasClass('navbar-fixed-top')).toBeFalsy()

			describe "search return handling", ->
				beforeEach ->
					@gidqsc.handleSearchReturn
						results: window.geneDataQueriesTestJSON.geneIDQueryResults
				it "should have a function to call when search returns", ->
					expect(@gidqsc.handleSearchReturn).toBeDefined()
				it "should show result view", ->
					expect(@gidqsc.$('.bv_resultsView')).toBeVisible()
				it "should move search to top navbar", ->
					expect(@gidqsc.$('.bv_toolbar .bv_searchForm').length).toEqual 1
				it "should hide gidSearchStart", ->
					expect(@gidqsc.$('.bv_gidSearchStart')).toBeHidden()
				it "should hide ACAS badge", ->
					expect(@gidqsc.$('.bv_gidACASBadge')).toBeHidden()
				it "should show ACAS inline badge", ->
					expect(@gidqsc.$('.bv_gidACASBadgeTop')).toBeVisible()
				it "should remove the gidNavAdvancedSearchButton start class", ->
					expect(@gidqsc.$('.bv_gidNavAdvancedSearchButton').hasClass('gidNavAdvancedSearchButtonBottom')).toBeFalsy()
				it "should add the gidNavHelpButton pull-right class", ->
					expect(@gidqsc.$('.bv_gidNavHelpButton').hasClass('pull-right')).toBeTruthy()
				it "should add the gidNavAdvancedSearchButton end class", ->
					expect(@gidqsc.$('.bv_gidNavAdvancedSearchButton').hasClass('gidNavAdvancedSearchButtonTop')).toBeTruthy()
				it "should remove the gidNavWellBottom class", ->
					expect(@gidqsc.$('.bv_toolbar').hasClass('gidNavWellBottom')).toBeFalsy()
				it "should add the gidNavWellTop class", ->
					expect(@gidqsc.$('.bv_toolbar').hasClass('gidNavWellTop')).toBeTruthy()
				it "should remove the toolbar fixed bottom class", ->
					expect(@gidqsc.$('.bv_group_toolbar').hasClass('navbar-fixed-bottom')).toBeFalsy()
				it "should add the toolbar fixed top class", ->
					expect(@gidqsc.$('.bv_group_toolbar').hasClass('navbar-fixed-top')).toBeTruthy()

	################  Advanced-mode queries ###



	describe "Advanced search modules", ->
		describe "Protocol and experiment display", ->
			describe 'when instantiated', ->
				beforeEach ->
					@etc = new ExperimentTreeController
						el: $('#fixture')
						model: new Backbone.Model window.geneDataQueriesTestJSON.getGeneExperimentsReturn
					@etc.render()
				describe "basic existance tests", ->
					it 'should exist', ->
						expect(@etc).toBeDefined()
					it 'should load a template', ->
						expect(@etc.$('.bv_tree').length).toEqual 1
				describe "rendering", ->
					it "should load tree and display root node", ->
						expect(@etc.$('.bv_tree').html()).toContain "Protocols"
				describe "search field management", ->
					it "should clear search field on request", ->
						@etc.$('.bv_searchVal').val "search text"
						expect(@etc.$('.bv_searchVal').val()).toEqual "search text"
						@etc.$('.bv_searchClear').click()
						expect(@etc.$('.bv_searchVal').val()).toEqual ""
					it "should show an experiment on search", ->
						expect(@etc.$('.bv_tree').html()).toNotContain "EXPT-00000397"
						@etc.$('.bv_searchVal').val "397"
						@etc.$(".bv_tree").jstree(true).search @etc.$('.bv_searchVal').val()
#						@etc.$('.bv_searchVal').keyup()
						expect(@etc.$('.bv_tree').html()).toContain "EXPT-00000397"
				describe "getting selected", ->
					it "should get selected experiments", ->
						@etc.$(".bv_tree").jstree(true).search "EXPT-00000398"
						expect(@etc.$('.bv_tree').html()).toContain "EXPT-00000398"
						@etc.$('.jstree-checkbox:eq(4)').click()
						@etc.$('.jstree-checkbox:eq(5)').click()
						expect(@etc.getSelectedExperiments()).toEqual ["EXPT-00000398", "EXPT-00000396"]

		describe "Experiment attribute filtering panel", ->
			describe "filter term controller", ->
				describe 'when instantiated', ->
					beforeEach ->
						@erftc = new ExperimentResultFilterTermController
							el: $('#fixture')
							collection: new Backbone.Collection window.geneDataQueriesTestJSON.experimentSearchOptions.experiments
						@erftc.render()
					describe "basic existance tests", ->
						it 'should exist', ->
							expect(@erftc).toBeDefined()
						it 'should load a template', ->
							expect(@erftc.$('.bv_experiment').length).toEqual 1
					describe "rendering", ->
						it "should show experiment options", ->
							expect(@erftc.$('.bv_experiment option').length).toEqual 3
							expect(@erftc.$('.bv_experiment option:eq(0)').val()).toEqual "EXPT-00000396"
					describe "show attribute list based on experiment picked", ->
						it "should show correct attributes for first experiment", ->
							@erftc.$('.bv_experiment').val "EXPT-00000396"
							@erftc.$('.bv_experiment').change()
							expect(@erftc.$('.bv_kind option').length).toEqual 3
							expect(@erftc.$('.bv_kind option:eq(0)').val()).toEqual "EC50"
						it "should show correct attributes for second experiment", ->
							@erftc.$('.bv_experiment').val "EXPT-00000398"
							@erftc.$('.bv_experiment').change()
							expect(@erftc.$('.bv_kind option').length).toEqual 3
							expect(@erftc.$('.bv_kind option:eq(0)').val()).toEqual "KD"
					describe "show operator choices based on attribute type picked", ->
						it "should show correct choice for first experiment and number type", ->
							@erftc.$('.bv_experiment').val "EXPT-00000396"
							@erftc.$('.bv_experiment').change()
							@erftc.$('.bv_kind').val "EC50"
							@erftc.$('.bv_kind').change()
							expect(@erftc.$('.bv_operator option').length).toEqual 3
							expect(@erftc.$('.bv_operator option:eq(0)').val()).toEqual "="
						it "should show correct choice for first experiment and string type", ->
							@erftc.$('.bv_experiment').val "EXPT-00000396"
							@erftc.$('.bv_experiment').change()
							@erftc.$('.bv_kind').val "category"
							@erftc.$('.bv_kind').change()
							expect(@erftc.$('.bv_operator option').length).toEqual 2
							expect(@erftc.$('.bv_operator option:eq(0)').val()).toEqual "equals"
						it "should show correct choice for first experiment and bool type", ->
							@erftc.$('.bv_experiment').val "EXPT-00000396"
							@erftc.$('.bv_experiment').change()
							@erftc.$('.bv_kind').val "hit"
							@erftc.$('.bv_kind').change()
							expect(@erftc.$('.bv_operator option').length).toEqual 2
							expect(@erftc.$('.bv_operator option:eq(0)').val()).toEqual "true"
					describe "show or hide filterValue based on attribute type picked", ->
						it "should hide value field for first experiment and bool type", ->
							@erftc.$('.bv_experiment').val "EXPT-00000396"
							@erftc.$('.bv_experiment').change()
							@erftc.$('.bv_kind').val "hit"
							@erftc.$('.bv_kind').change()
							expect(@erftc.$('.bv_operator option').length).toEqual 2
							expect(@erftc.$('.bv_filterValue')).toBeHidden()
						it "should show value field for first experiment and number type", ->
							@erftc.$('.bv_experiment').val "EXPT-00000396"
							@erftc.$('.bv_experiment').change()
							@erftc.$('.bv_kind').val "EC50"
							@erftc.$('.bv_kind').change()
							expect(@erftc.$('.bv_operator option').length).toEqual 3
							expect(@erftc.$('.bv_filterValue')).toBeVisible()

	#	describe "Advanced search wizard", ->
	#		describe 'when instantiated', ->
	#			beforeEach ->
	#				@gidaqc = new GeneIDAdvancedQueryController
	#					el: $('#fixture')
	#				@gidaqc.render()
	#			describe "basic existance tests", ->
	#				it 'should exist', ->
	#					expect(@gidaqc).toBeDefined()
	#				it 'should load a template', ->
	#					expect(@gidaqc.$('.bv_getGeneCodesView').length).toEqual 1



	################ stand-alone app launcher   ##########
	describe "Gene ID Query App Controller", ->
		describe 'when instantiated', ->
			beforeEach ->
				@gidqac = new GeneIDQueryAppController
					el: $('#fixture')
				@gidqac.render()
			describe "basic existance tests", ->
				it 'should exist', ->
					expect(@gidqac).toBeDefined()
				it 'should load a template', ->
					expect(@gidqac.$('.bv_queryView').length).toEqual 1
				it 'should load a query controller', ->
					expect(@gidqac.$('.bv_inputView').length).toEqual 1


#TODO Reconfigure GeneIDQueryInputController to send "" list instead of model
#TODO setup download CSV service
#TODO add an enuciator to show search errors etc

