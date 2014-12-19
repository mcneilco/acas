beforeEach ->
	@fixture = $.clone($("#fixture").get(0))

afterEach ->
	$("#fixture").remove()
	$("body").append $(@fixture)

describe 'Cationic Block testing', ->
	describe "Cationic Block Parent model testing", ->
		describe "when loaded from new", ->
			beforeEach ->
				@cbp = new CationicBlockParent()
			describe "Existence and Defaults", ->
				it "should be defined", ->
					expect(@cbp).toBeDefined()
				it "should have a type", ->
					expect(@cbp.get('lsType')).toEqual "parent"
				it "should have a kind", ->
					expect(@cbp.get('lsKind')).toEqual "cationic block"
				it "should have an empty scientist", ->
					expect(@cbp.get('recordedBy')).toEqual ""
				it "should have a recordedDate set to now", ->
					expect(new Date(@cbp.get('recordedDate')).getHours()).toEqual new Date().getHours()
				it "Should have a lsLabels with one label", ->
					expect(@cbp.get('lsLabels')).toBeDefined()
					expect(@cbp.get("lsLabels").length).toEqual 1
					expect(@cbp.get("lsLabels").getLabelByTypeAndKind("name", "cationic block").length).toEqual 1
				it "Should have a model attribute for the label in defaultLabels", ->
					expect(@cbp.get("cationic block name")).toBeDefined()
				it "Should have a lsStates with the states in defaultStates", ->
					expect(@cbp.get('lsStates')).toBeDefined()
					expect(@cbp.get("lsStates").length).toEqual 1
					expect(@cbp.get("lsStates").getStatesByTypeAndKind("metadata", "cationic block parent").length).toEqual 1
				describe "model attributes for each value in defaultValues", ->
					it "Should have a model attribute for completion date", ->
						expect(@cbp.get("completion date")).toBeDefined()
					it "Should have a model attribute for notebook", ->
						expect(@cbp.get("notebook")).toBeDefined()
					it "Should have a model attribute for molecular weight", ->
						expect(@cbp.get("molecular weight")).toBeDefined()

		describe "When created from existing", ->
			beforeEach ->
				@cbp = new CationicBlockParent JSON.parse(JSON.stringify(window.cationicBlockTestJSON.cationicBlockParent))
			describe "after initial load", ->
				it "should be defined", ->
					expect(@cbp).toBeDefined()
				it "should have a type", ->
					expect(@cbp.get('lsType')).toEqual "parent"
				it "should have a kind", ->
					expect(@cbp.get('lsKind')).toEqual "cationic block"
				it "should have a scientist set", ->
					expect(@cbp.get('recordedBy')).toEqual "egao"
				it "should have a recordedDate set", ->
					expect(@cbp.get('recordedDate')).toEqual 1375141508000
				it "Should have label set", ->
					console.log @cbp
					expect(@cbp.get("cationic block name").get("labelText")).toEqual "cMAP10"
					label = (@cbp.get("lsLabels").getLabelByTypeAndKind("name", "cationic block"))
					console.log label[0]
					expect(label[0].get('labelText')).toEqual "cMAP10"
				it "Should have a lsStates with the states in defaultStates", ->
					expect(@cbp.get('lsStates')).toBeDefined()
					expect(@cbp.get("lsStates").length).toEqual 1
					expect(@cbp.get("lsStates").getStatesByTypeAndKind("metadata", "cationic block parent").length).toEqual 1
				it "Should have a completion date value", ->
					expect(@cbp.get("completion date").get("value")).toEqual "1342080000000"
				it "Should have a notebook value", ->
					expect(@cbp.get("notebook").get("value")).toEqual "Notebook 1"
				it "Should have a molecular weight value", ->
					expect(@cbp.get("molecular weight").get("value")).toEqual 231

		describe "model validation", ->
			beforeEach ->
				@cbp = new CationicBlockParent window.cationicBlockTestJSON.cationicBlockParent
			it "should be valid when loaded from saved", ->
				expect(@cbp.isValid()).toBeTruthy()
			it "should be invalid when name is empty", ->
				@cbp.get("cationic block name").set("labelText", "")
				expect(@cbp.isValid()).toBeFalsy()
				filtErrors = _.filter(@cbp.validationError, (err) ->
					err.attribute=='cationicBlockName'
				)
				expect(filtErrors.length).toBeGreaterThan 0
			it "should be invalid when recorded date is empty", ->
				@cbp.set recordedDate: new Date("").getTime()
				expect(@cbp.isValid()).toBeFalsy()
				filtErrors = _.filter(@cbp.validationError, (err) ->
					err.attribute=='recordedDate'
				)
				expect(filtErrors.length).toBeGreaterThan 0
			it "should be invalid when scientist not selected", ->
				@cbp.set recordedBy: ""
				expect(@cbp.isValid()).toBeFalsy()
				filtErrors = _.filter(@cbp.validationError, (err) ->
					err.attribute=='recordedBy'
				)
			it "should be invalid when completion date is empty", ->
				@cbp.get("completion date").set("value", new Date("").getTime())
				expect(@cbp.isValid()).toBeFalsy()
				filtErrors = _.filter(@cbp.validationError, (err) ->
					err.attribute=='completionDate'
				)
				expect(filtErrors.length).toBeGreaterThan 0
			it "should be invalid when notebook is empty", ->
				@cbp.get("notebook").set("value", "")
				expect(@cbp.isValid()).toBeFalsy()
				filtErrors = _.filter(@cbp.validationError, (err) ->
					err.attribute=='notebook'
				)
				expect(filtErrors.length).toBeGreaterThan 0
			it "should be invalid when molecular weight is NaN", ->
				@cbp.get("molecular weight").set("value", "fred")
				expect(@cbp.isValid()).toBeFalsy()
				filtErrors = _.filter(@cbp.validationError, (err) ->
					err.attribute=='molecularWeight'
				)
				expect(filtErrors.length).toBeGreaterThan 0

	describe "Cationic Block Parent Controller testing", ->
		describe "When instantiated", ->
			beforeEach ->
				@cbp = new CationicBlockParent JSON.parse(JSON.stringify(window.cationicBlockTestJSON.cationicBlockParent))
				@cbpc = new CationicBlockParentController
					model: @cbp
					el: $('#fixture')
				@cbpc.render()
			describe "basic existence tests", ->
				it "should exist", ->
					expect(@cbpc).toBeDefined()
				it "should load the template", ->
					expect(@cbpc.$('.bv_cationicBlockParentCode').html()).toEqual "autofill when saved"
			describe "render existing parameters", ->
				it "should show the cationic block parent id", ->
					expect(@cbpc.$('.bv_cationicBlockParentCode').val()).toEqual "CB000001"
				it "should show the cationic block parent name", ->
					expect(@cbpc.$('.bv_cationicBlockParentName').val()).toEqual "cMAP10"
				it "should fill the scientist field", ->
					expect(@cbpc.$('.bv_recordedBy').val()).toEqual "egao"
				it "should fill the completion date field", ->
					expect(@cbpc.$('.bv_completionDate').val()).toEqual "2012-07-12"
				it "should fill the notebook field", ->
					expect(@cbpc.$('.bv_notebook').val()).toEqual "Notebook 1"
				it "should fill the molecular weight field", ->
					expect(@cbpc.$('.bv_molecularWeight').val()).toEqual "231"
