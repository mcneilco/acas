beforeEach ->
	@fixture = $.clone($("#fixture").get(0))

afterEach ->
	$("#fixture").remove()
	$("body").append $(@fixture)

describe "Gene Data Queries Module Testing", ->
	describe "Gene ID Query Input Controller", ->
		describe 'when instantiated', ->
			beforeEach ->
				@gidqic = new GeneIDQueryInputController
					el: $('#fixture')
				@gidqic.render()
			describe "basic existance tests", ->
				it 'should exist', ->
					expect(@gidqic).toBeDefined()
				it 'should load a template', ->
					expect(@gidqic.$('.bv_gidListString').length).toEqual 1
			describe "search button enabling behavior", ->
				it "should have search button disabled when nothing in field", ->
					expect(@gidqic.$('.bv_search').attr('disabled')).toEqual 'disabled'
				it "should have search button enabled when someting added to field", ->
					@gidqic.$('.bv_gidListString').val "555, 3466621,777, 888 , 999"
					@gidqic.$('.bv_gidListString').keyup()
					expect(@gidqic.$('.bv_search').attr('disabled')).toBeUndefined()
				it "should have search button disabled when field is emptied", ->
					@gidqic.$('.bv_gidListString').val ""
					@gidqic.$('.bv_gidListString').keyup()
					expect(@gidqic.$('.bv_search').attr('disabled')).toEqual 'disabled'
			describe "search button behavior", ->
				it "should trigger a search request when search button pressed", ->
					runs ->
						@gidqic.$('.bv_gidListString').val "555, 3466621,777, 888 , 999"
						@gidqic.$('.bv_gidListString').keyup()
						@gotTrigger = false
						@gidqic.on 'search-requested', =>
							@gotTrigger = true
						@gidqic.$('.bv_search').click()
					waitsFor =>
						@gotTrigger
					, 1000
					runs =>
						expect(@gotTrigger).toBeTruthy()
			describe "when advanced mode pressed", ->
				beforeEach ->
					runs ->
						@advanceTriggered = false
						@gidqic.on 'requestAdvancedMode', =>
							@advanceTriggered = true
						@gidqic.$('.bv_gidNavAdvancedSearchButton').click()
				it "should request enable button disabled when an experiment selected", ->
					waitsFor =>
						@advanceTriggered
					, 100
					runs ->
						expect(@advanceTriggered).toBeTruthy()

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
			describe "request results as CSV", ->
				it "should trigger search format csv request", ->
					runs =>
						@downLoadCSVRequested = false
						@gidqrc.on 'downLoadCSVRequested', =>
							@downLoadCSVRequested = true
						@gidqrc.$('.bv_downloadCSV').click()
					waitsFor =>
						@downLoadCSVRequested
					, 200
					runs =>
						expect(@downLoadCSVRequested).toBeTruthy()
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
				it "should hide the download CSV option", ->
					expect(@gidqrc.$('.bv_gidDownloadCSV')).toBeHidden()

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
					expect(@gidqsc.$('.bv_gidNavAdvancedSearchButton').hasClass('gidAdvancedNavSearchButtonStart')).toBeTruthy()
				it "should not have the gidNavAdvancedSearchButton end class", ->
					expect(@gidqsc.$('.bv_gidNavAdvancedSearchButton').hasClass('gidAdvancedNavSearchButtonTop')).toBeFalsy()
				it "should hide the bv_searchNavbar at start", ->
					expect(@gidqsc.$('.bv_searchNavbar')).toBeHidden()


			describe "search return handling", ->
				beforeEach ->
					@gidqsc.handleSearchReturn
						results: window.geneDataQueriesTestJSON.geneIDQueryResults
				it "should have a function to call when search returns", ->
					expect(@gidqsc.handleSearchReturn).toBeDefined()
				it "should show result view", ->
					expect(@gidqsc.$('.bv_resultsView')).toBeVisible()
				it "should move search to top navbar", ->
					expect(@gidqsc.$('.bv_searchNavbar .bv_searchForm').length).toEqual 1
				it "should hide gidSearchStart", ->
					expect(@gidqsc.$('.bv_gidSearchStart')).toBeHidden()
				it "should hide ACAS badge", ->
					expect(@gidqsc.$('.bv_gidACASBadge')).toBeHidden()
				it "should show ACAS inline badge", ->
					expect(@gidqsc.$('.bv_gidACASBadgeTop')).toBeVisible()
				it "should not have the gidNavAdvancedSearchButton start class", ->
					expect(@gidqsc.$('.bv_gidNavAdvancedSearchButton').hasClass('gidAdvancedNavSearchButtonStart')).toBeFalsy()
				it "should have the gidNavAdvancedSearchButton end class", ->
					expect(@gidqsc.$('.bv_gidNavAdvancedSearchButton').hasClass('gidAdvancedNavSearchButtonTop')).toBeTruthy()
				it "should show the bv_searchNavbar", ->
					expect(@gidqsc.$('.bv_searchNavbar')).toBeVisible()


	################  Advanced-mode queries ################

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
				describe "when none selected", ->
					beforeEach ->
						runs ->
							@nextEnableRequested = false
							@etc.on 'enableNext', =>
								@nextEnableRequested = true
							@nextDisableRequested = false
							@etc.on 'disableNext', =>
								@nextDisableRequested = true
							@etc.$(".bv_tree").jstree(true).search "EXPT-00000398"
							expect(@etc.$('.bv_tree').html()).toContain "EXPT-00000398"
							@etc.$('.jstree-checkbox:eq(4)').click()
					it "should request enable button disabled when an experiment selected", ->
						waitsFor =>
							@nextEnableRequested
						, 100
						runs ->
							expect(@nextEnableRequested).toBeTruthy()
					it "should request next button disabled when all experiments de-selected", ->
						runs ->
							@etc.$('.jstree-checkbox:eq(4)').click()
						waitsFor =>
							@nextDisableRequested
						, 100
						runs ->
							expect(@nextDisableRequested).toBeTruthy()


		describe "Experiment attribute filtering panel", ->
			describe "filter term controller", ->
				describe 'when instantiated', ->
					beforeEach ->
						@erftc = new ExperimentResultFilterTermController
							el: $('#fixture')
							model: new Backbone.Model()
							filterOptions: new Backbone.Collection window.geneDataQueriesTestJSON.experimentSearchOptions.experiments
							termName: "Q1"
						@erftc.render()
					describe "basic existance tests", ->
						it 'should exist', ->
							expect(@erftc).toBeDefined()
						it 'should load a template', ->
							expect(@erftc.$('.bv_experiment').length).toEqual 1
					describe "rendering", ->
						it "should show termName", ->
							expect(@erftc.$('.bv_termName').html()).toEqual "Q1"
						it "should show experiment options", ->
							expect(@erftc.$('.bv_experiment option').length).toEqual 3
							expect(@erftc.$('.bv_experiment option:eq(0)').val()).toEqual "EXPT-00000396"
							expect(@erftc.$('.bv_experiment option:eq(0)').html()).toEqual "Experiment Name 1"
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
						it "should show correct operator options on first load", ->
							@erftc.$('.bv_experiment').val "EXPT-00000397"
							@erftc.$('.bv_experiment').change()
							expect(@erftc.$('.bv_operator option').length).toEqual 2
							expect(@erftc.$('.bv_operator option:eq(0)').val()).toEqual "equals"
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
					describe "get filter term", ->
						it "should return hash of user selections", ->
							@erftc.$('.bv_experiment').val "EXPT-00000396"
							@erftc.$('.bv_experiment').change()
							@erftc.$('.bv_kind').val "category"
							@erftc.$('.bv_kind').change()
							@erftc.$('.bv_operator').val "contains"
							@erftc.$('.bv_filterValue').val " search string "
							@erftc.updateModel()
							expect(@erftc.model.get('experimentCode')).toEqual "EXPT-00000396"
							expect(@erftc.model.get('lsKind')).toEqual "category"
							expect(@erftc.model.get('lsType')).toEqual "stringValue"
							expect(@erftc.model.get('operator')).toEqual "contains"
							expect(@erftc.model.get('filterValue')).toEqual "search string"
			describe "filter term list controller", ->
				describe 'when instantiated', ->
					beforeEach ->
						@erftlc = new ExperimentResultFilterTermListController
							el: $('#fixture')
							collection: new Backbone.Collection()
							filterOptions: new Backbone.Collection window.geneDataQueriesTestJSON.experimentSearchOptions.experiments
						@erftlc.render()
					describe "basic existance tests", ->
						it 'should exist', ->
							expect(@erftlc).toBeDefined()
						it 'should load a template', ->
							expect(@erftlc.$('.bv_addTerm').length).toEqual 1
					describe "rendering", ->
						it "should show no terms", ->
							expect(@erftlc.$('.bv_termName').length).toEqual 0
						it "should show one experiment term with term name", ->
							@erftlc.$('.bv_addTerm').click()
							expect(@erftlc.$('.bv_termName').html()).toEqual "Q1"
						it "should show one experiment term with experiment options", ->
							@erftlc.$('.bv_addTerm').click()
							expect(@erftlc.$('.bv_filterTerms .bv_experiment').length).toEqual 1
							expect(@erftlc.$('.bv_filterTerms .bv_experiment option').length).toEqual 3
							expect(@erftlc.$('.bv_filterTerms .bv_experiment option:eq(0)').val()).toEqual "EXPT-00000396"
					describe "adding and removing", ->
						it "should have two experiment terms when add is clicked", ->
							@erftlc.$('.bv_addTerm').click()
							@erftlc.$('.bv_addTerm').click()
							expect(@erftlc.$('.bv_filterTerms .bv_experiment').length).toEqual 2
							expect(@erftlc.collection.length).toEqual 2
						it "should show 2nd term with incremented termName", ->
							@erftlc.$('.bv_addTerm').click()
							@erftlc.$('.bv_addTerm').click()
							expect(@erftlc.$('.bv_termName:eq(1)').html()).toEqual "Q2"
						it "should one experiment terms when remove is clicked", ->
							@erftlc.$('.bv_addTerm').click()
							@erftlc.$('.bv_addTerm').click()
							expect(@erftlc.$('.bv_filterTerms .bv_experiment').length).toEqual 2
							@erftlc.$('.bv_delete:eq(0)').click()
							expect(@erftlc.collection.length).toEqual 1
							expect(@erftlc.$('.bv_filterTerms .bv_experiment').length).toEqual 1
					describe "update collection", ->
						it "should update the collection wehn requested", ->
							@erftlc.$('.bv_addTerm').click()
							@erftlc.$('.bv_addTerm').click()
							@erftlc.$('.bv_experiment:eq(1)').val "EXPT-00000396"
							@erftlc.$('.bv_experiment:eq(1)').change()
							@erftlc.$('.bv_kind:eq(1)').val "category"
							@erftlc.$('.bv_kind:eq(1)').change()
							@erftlc.$('.bv_operator:eq(1)').val "contains"
							@erftlc.$('.bv_filterValue:eq(1)').val " search string "
							@erftlc.updateCollection()
							expect(@erftlc.collection.length).toEqual 2
							tmodel = @erftlc.collection.at(1)
							expect(tmodel.get('termName')).toEqual "Q2"
							expect(tmodel.get('experimentCode')).toEqual "EXPT-00000396"
							expect(tmodel.get('lsKind')).toEqual "category"
							expect(tmodel.get('lsType')).toEqual "stringValue"
							expect(tmodel.get('operator')).toEqual "contains"
							expect(tmodel.get('filterValue')).toEqual "search string"
			describe "ExperimentResultFilter Controller", ->
				describe 'when instantiated', ->
					beforeEach ->
						@erfc = new ExperimentResultFilterController
							el: $('#fixture')
							filterOptions: new Backbone.Collection window.geneDataQueriesTestJSON.experimentSearchOptions.experiments
						@erfc.render()
					describe "basic existance tests", ->
						it 'should exist', ->
							expect(@erfc).toBeDefined()
						it 'should load a template', ->
							expect(@erfc.$('.bv_advancedBooleanFilter').length).toEqual 1
					describe "rendering", ->
						it "should show an experiment term list with experiment options", ->
							@erfc.$('.bv_addTerm').click()
							expect(@erfc.$('.bv_filterTerms .bv_experiment').length).toEqual 1
					describe "boolean filter radio behavior", ->
						it "should hide advanced filter input when radio set to and", ->
							@erfc.$('.bv_booleanFilter_and').attr('checked','checked')
							@erfc.$('.bv_booleanFilter_and').click()
							expect(@erfc.$('.bv_advancedBoolContainer')).toBeHidden()
						it "should hide advanced filter input when radio set to or", ->
							@erfc.$('.bv_booleanFilter_or').attr('checked','checked')
							@erfc.$('.bv_booleanFilter_or').click()
							expect(@erfc.$('.bv_advancedBoolContainer')).toBeHidden()
						it "should show advanced filter input when radio set to advanced", ->
							@erfc.$('.bv_booleanFilter_advanced').attr('checked','checked')
							@erfc.$('.bv_booleanFilter_advanced').click()
							expect(@erfc.$('.bv_advancedBoolContainer')).toBeVisible()
					describe "get filter params", ->
						it "should update the collection wehn requested", ->
							@erfc.$('.bv_addTerm').click()
							@erfc.$('.bv_addTerm').click()
							@erfc.$('.bv_experiment:eq(1)').val "EXPT-00000396"
							@erfc.$('.bv_experiment:eq(1)').change()
							@erfc.$('.bv_kind:eq(1)').val "category"
							@erfc.$('.bv_kind:eq(1)').change()
							@erfc.$('.bv_operator:eq(1)').val "contains"
							@erfc.$('.bv_filterValue:eq(1)').val " search string "
							@erfc.$('.bv_booleanFilter_advanced').attr('checked','checked')
							@erfc.$('.bv_advancedBooleanFilter').val " (Q1 AND Q2) OR Q3 "
							attrs = @erfc.getSearchFilters()
							expect(attrs.booleanFilter).toEqual "advanced"
							expect(attrs.advancedFilter).toEqual "(Q1 AND Q2) OR Q3"
							expect(attrs.filters[1].termName).toEqual "Q2"
							expect(attrs.filters[1].experimentCode).toEqual "EXPT-00000396"
							expect(attrs.filters[1].lsKind).toEqual "category"
							expect(attrs.filters[1].lsType).toEqual "stringValue"
							expect(attrs.filters[1].operator).toEqual "contains"
							expect(attrs.filters[1].filterValue).toEqual "search string"


		describe "Advanced search wizard", ->
			describe 'when instantiated', ->
				beforeEach ->
					@aerqc = new AdvancedExperimentResultsQueryController
						el: $('#fixture')
					@aerqc.render()
				describe "basic existance tests", ->
					it 'should exist', ->
						expect(@aerqc).toBeDefined()
					it 'should load a template', ->
						expect(@aerqc.$('.bv_getCodesView').length).toEqual 1

				describe "start with get codes step", ->
					it "should show only getCodes", ->
						expect(@aerqc.$('.bv_getCodesView')).toBeVisible()
						expect(@aerqc.$('.bv_getExperimentsView')).toBeHidden()
						expect(@aerqc.$('.bv_getFiltersView')).toBeHidden()
						expect(@aerqc.$('.bv_advResultsView')).toBeHidden()
						expect(@aerqc.$('.bv_noExperimentsFound')).toBeHidden()
				describe "when valid codes enter and next pressed", ->
					beforeEach ->
						runs ->
							@aerqc.$('.bv_codesField').val "12345, 6789"
							@aerqc.handleNextClicked()
					describe "experiment tree display from stub service", ->
						beforeEach ->
							waitsFor =>
								@aerqc.$('.bv_tree').length == 1
							, 500
						describe "tree view display", ->
							it "should show only getExperiments", ->
								runs ->
									expect(@aerqc.$('.bv_getCodesView')).toBeHidden()
									expect(@aerqc.$('.bv_getExperimentsView')).toBeVisible()
									expect(@aerqc.$('.bv_getFiltersView')).toBeHidden()
									expect(@aerqc.$('.bv_advResultsView')).toBeHidden()
							it "should load tree and display root node", ->
								runs ->
									expect(@aerqc.$('.bv_tree').html()).toContain "Protocols"
						describe "to filter select from experiment tree", ->
							beforeEach ->
								runs ->
									@aerqc.$(".bv_tree").jstree(true).search "EXPT-00000398"
									@aerqc.$('.jstree-checkbox:eq(4)').click()
									@aerqc.$('.jstree-checkbox:eq(5)').click()
									@aerqc.handleNextClicked()
							describe "should show only filters", ->
								beforeEach ->
									waitsFor =>
										@aerqc.$('.bv_addTerm').length == 1
									, 500
								describe "filter view display", ->
									it "should show one experiment term with experiment options", ->
										runs ->
											@aerqc.$('.bv_addTerm').click()
											expect(@aerqc.$('.bv_filterTerms .bv_experiment').length).toEqual 1
											expect(@aerqc.$('.bv_filterTerms .bv_experiment option').length).toEqual 3
											expect(@aerqc.$('.bv_filterTerms .bv_experiment option:eq(0)').val()).toEqual "EXPT-00000396"
								describe "from filter to results", ->
									beforeEach ->
										runs ->
											@requestNextToNewQuery = false
											@aerqc.on 'requestNextChangeToNewQuery', =>
												@requestNextToNewQuery = true
											@aerqc.handleNextClicked()
									describe "result display", ->
										beforeEach ->
											waitsFor =>
												@aerqc.$('.bv_resultTable').length == 1
											, 500
										describe "show results", ->
											it "should setup DOM in prep to load datatable module", ->
												runs ->
													expect(@aerqc.$('thead tr').length).toEqual 2
											it "should render the rest of the table", ->
												runs ->
													expect(@aerqc.$('tbody tr').length).toEqual 4

				describe "when invalid codes entered and next pressed (no experiments returned)", ->
					beforeEach ->
						runs ->
							@aerqc.$('.bv_codesField').val "fiona"
							@aerqc.handleNextClicked()
					describe "stay at step one and show message", ->
						beforeEach ->
							waits 200
						it "should show only getExperiments", ->
							runs ->
								expect(@aerqc.$('.bv_noExperimentsFound')).toBeVisible()


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
					expect(@gidqac.$('.bv_basicQueryView').length).toEqual 1
			describe "Launch basic mode by default", ->
				it 'should load a basic query controller', ->
					expect(@gidqac.$('.bv_inputView').length).toEqual 1
				it 'should hide advanced query view', ->
					expect(@gidqac.$('.bv_advancedQueryContainer')).toBeHidden()
				it "should hide advanced query navbar during basic mode", ->
					expect(@gidqac.$('.bv_advancedQueryNavbar')).toBeHidden()
			describe "Launch advanced mode when requested", ->
				beforeEach ->
					@gidqac.$('.bv_gidNavAdvancedSearchButton').click()
				it 'should load advanced query controller', ->
					expect(@gidqac.$('.bv_getCodesView').length).toEqual 1
					expect(@gidqac.$('.bv_advancedQueryContainer')).toBeVisible()
				it 'should hide basic query controller', ->
					expect(@gidqac.$('.bv_basicQueryView')).toBeHidden()
				it "should show advanced query navbar during advanced mode", ->
					expect(@gidqac.$('.bv_advancedQueryNavbar')).toBeVisible()
			describe "Rre-launch basic mode on cancel", ->
				it 'should load basic query controller', ->
					@gidqac.$('.bv_gidNavAdvancedSearchButton').click()
					expect(@gidqac.$('.bv_getCodesView').length).toEqual 1
					@gidqac.$('.bv_cancel').click()
					expect(@gidqac.$('.bv_inputView').length).toEqual 1
					expect(@gidqac.$('.bv_basicQueryView')).toBeVisible()
					expect(@gidqac.$('.bv_advancedQueryContainer')).toBeHidden()

#For demo
#TODO right now gear/wrench launches advanced search. Need a button or link instead that is in both start and data display

#after demo
#TODO setup download CSV service
#TODO add an enuciator to show search errors etc
#TODO Refactor to make not gene specific in names etc. Make entity type to search a configuration option
