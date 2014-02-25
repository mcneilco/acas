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
			describe "search return handling", ->
				it "should have a function to call when search returns", ->
					expect(@gidqsc.handleSearchReturn).toBeDefined()
				it "should show result view", ->
					@gidqsc.handleSearchReturn
						results: window.geneDataQueriesTestJSON.geneIDQueryResults
					expect(@gidqsc.$('.bv_resultsView')).toBeVisible()

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


#TODO setup download CSV service
#TODO make login so it doesn't loose original URL request
#TODO replace non-test mode query service with call to RApache

