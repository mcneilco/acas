
describe 'Thing Interaction testing', ->
	describe "First Thing Itx model testing", ->
		describe 'When created from new', ->
			beforeEach ->
				@fti = new FirstThingItx()
	
			describe "Existence and Defaults", ->
				it "should be defined", ->
					expect(@fti).toBeDefined()
				it "should have a type", ->
					expect(@fti.get('lsType')).toEqual "interaction"
				it "should have a kind", ->
					expect(@fti.get('lsKind')).toEqual "interaction"
				it "should have a type and kind", ->
					expect(@fti.get('lsTypeAndKind')).toEqual "interaction_interaction"
				it "should have an empty state list", ->
					expect(@fti.get('lsStates').length).toEqual 0
					expect(@fti.get('lsStates') instanceof StateList).toBeTruthy()
				it "should have the recordedBy set to the logged in user", ->
					expect(@fti.get('recordedBy')).toEqual window.AppLaunchParams.loginUser.username
				it "should have a recordedDate set to now", ->
					expect(new Date(@fti.get('recordedDate')).getHours()).toEqual new Date().getHours()
				it "should have an empty firstLsThing attribute", ->
					expect(@fti.get('firstLsThing')).toEqual {}
					
		describe "When created from existing", ->
			beforeEach ->
				@fti = new FirstThingItx JSON.parse(JSON.stringify(window.thingInteractionTestJSON.firstLsThingItx1))
			describe "after initial load", ->
				it "should be defined", ->
					expect(@fti).toBeDefined()
				it "should have a type", ->
					expect(@fti.get('lsType')).toEqual "incorporates"
				it "should have a kind", ->
					expect(@fti.get('lsKind')).toEqual "assembly_component"
				it "should have a type and kind", ->
					expect(@fti.get('lsTypeAndKind')).toEqual "incorporates_assembly_component"
				it "should have a state list", ->
					expect(@fti.get('lsStates').length).toEqual 1
					expect(@fti.get('lsStates') instanceof StateList).toBeTruthy()
				it "should have a recordedBy set", ->
					expect(@fti.get('recordedBy')).toEqual "egao"
				it "should have a recordedDate", ->
					expect(@fti.get('recordedDate')).toEqual 1375141504000
				it "should have a firstLsThing attribute", ->
					expect(@fti.get('firstLsThing').codeName).toEqual "A000001"

		describe "other features", ->
			beforeEach ->
				@fti = new FirstThingItx()
			it "should be reformatted before being saved", ->
				@fti.reformatBeforeSaving()
				expect(@fti.get('attributes')).toBeUndefined()
			it "should be able to set an Itx thing", ->
				thingToAdd =
					codeName: "T000001"
					id: 1
					lsKind: "test"
					lsType: "component"
				@fti.setItxThing(thingToAdd)
				expect(@fti.get('firstLsThing').codeName).toEqual "T000001"

	describe "Second Thing Itx model testing", ->
		describe 'When created from new', ->
			beforeEach ->
				@sti = new SecondThingItx()

			describe "Existence and Defaults", ->
				it "should be defined", ->
					expect(@sti).toBeDefined()
				it "should have a type", ->
					expect(@sti.get('lsType')).toEqual "interaction"
				it "should have a kind", ->
					expect(@sti.get('lsKind')).toEqual "interaction"
				it "should have a type and kind", ->
					expect(@sti.get('lsTypeAndKind')).toEqual "interaction_interaction"
				it "should have an empty state list", ->
					expect(@sti.get('lsStates').length).toEqual 0
					expect(@sti.get('lsStates') instanceof StateList).toBeTruthy()
				it "should have the recordedBy set to the logged in user", ->
					expect(@sti.get('recordedBy')).toEqual window.AppLaunchParams.loginUser.username
				it "should have a recordedDate set to now", ->
					expect(new Date(@sti.get('recordedDate')).getHours()).toEqual new Date().getHours()
				it "should have an empty secondLsThing attribute", ->
					expect(@sti.get('secondLsThing')).toEqual {}

		describe "When created from existing", ->
			beforeEach ->
				@sti = new SecondThingItx JSON.parse(JSON.stringify(window.thingInteractionTestJSON.secondLsThingItx1))
			describe "after initial load", ->
				it "should be defined", ->
					expect(@sti).toBeDefined()
				it "should have a type", ->
					expect(@sti.get('lsType')).toEqual "incorporates"
				it "should have a kind", ->
					expect(@sti.get('lsKind')).toEqual "assembly_component"
				it "should have a type and kind", ->
					expect(@sti.get('lsTypeAndKind')).toEqual "incorporates_assembly_component"
				it "should have a state list", ->
					expect(@sti.get('lsStates').length).toEqual 1
					expect(@sti.get('lsStates') instanceof StateList).toBeTruthy()
				it "should have a recordedBy set", ->
					expect(@sti.get('recordedBy')).toEqual "egao"
				it "should have a recordedDate", ->
					expect(@sti.get('recordedDate')).toEqual 1375141504000
				it "should have a secondLsThing attribute", ->
					expect(@sti.get('secondLsThing').codeName).toEqual "W000001"

		describe "other features", ->
			beforeEach ->
				@sti = new SecondThingItx()
			it "should be reformatted before being saved", ->
				@sti.reformatBeforeSaving()
				expect(@sti.get('attributes')).toBeUndefined()
			it "should be able to set an Itx thing", ->
				thingToAdd =
					codeName: "T000001"
					id: 1
					lsKind: "test"
					lsType: "component"
				@sti.setItxThing(thingToAdd)
				expect(@sti.get('secondLsThing').codeName).toEqual "T000001"

	describe "FirstLsThingItxList testing", ->
		describe 'When created from new', ->
			beforeEach ->
				@fltil = new FirstLsThingItxList()
			describe "existence tests", ->
				it "should be defined", ->
					expect(@fltil).toBeDefined()
		describe "when created from existing", ->
			beforeEach ->
				@fltil = new FirstLsThingItxList JSON.parse(JSON.stringify(window.thingInteractionTestJSON.firstLsThingItxList))
			describe "get or create itx", ->
				it "should be able to get an itx by type and kind", ->
					firstThingItxList = @fltil.getItxByTypeAndKind "incorporates", "assembly_component"
					expect(firstThingItxList.length).toEqual 3
				it "should be able to create an itx by type and kind", ->
					firstThingItx = @fltil.createItxByTypeAndKind "instantiates", "batch_parent"
					expect(firstThingItx.get('lsType')).toEqual "instantiates"
					expect(firstThingItx.get('lsKind')).toEqual "batch_parent"

	describe "SecondLsThingItxList testing", ->
		describe 'When created from new', ->
			beforeEach ->
				@sltil = new SecondLsThingItxList()
			describe "existence tests", ->
				it "should be defined", ->
					expect(@sltil).toBeDefined()
		describe "when created from existing", ->
			beforeEach ->
				@sltil = new SecondLsThingItxList JSON.parse(JSON.stringify(window.thingInteractionTestJSON.secondLsThingItxList))
			describe "get or create itx", ->
				it "should be able to get an itx by type and kind", ->
					secondThingItxList = @sltil.getItxByTypeAndKind "incorporates", "assembly_component"
					expect(secondThingItxList.length).toEqual 3
				it "should be able to create an itx by type and kind", ->
					secondThingItx = @sltil.createItxByTypeAndKind "instantiates", "batch_parent"
					expect(secondThingItx.get('lsType')).toEqual "instantiates"
					expect(secondThingItx.get('lsKind')).toEqual "batch_parent"

