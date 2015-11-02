beforeEach ->
	@fixture = $.clone($("#fixture").get(0))

afterEach ->
	$("#fixture").remove()
	$("body").append $(@fixture)

describe "Custom Experiment Metadata testing", ->
	describe "Custom Experiment Metadata List Controller testing", ->
		describe "When created from a saved experiment", ->
			beforeEach ->
				@exp = new Experiment window.experimentServiceTestJSON.fullExperimentFromServer
				@cemlc = new CustomExperimentMetadataListController
					el: $('#fixture')
					model: @exp
				@cemlc.render()
			describe "property display", ->
				it "should show clob values", ->
					waitsFor ->
						@cemlc.$('.bv_clob_value').length > 0
					, 1000
					runs ->
						expect(@cemlc.$('.bv_clob_value').val()).toEqual "background text"
				it "should show code values", ->
					waitsFor ->
						@cemlc.$('.bv_code_value').val() != null
					, 1000
					runs ->
						expect(@cemlc.$('.bv_code_value option').length).toBeGreaterThan 0
						expect(@cemlc.$('.bv_code_value').val()).toEqual "mrna"
				it "should show numeric values", ->
					waitsFor ->
						@cemlc.$('.bv_numeric_value').length > 0
					, 1000
					runs ->
						expect(@cemlc.$('.bv_numeric_value').val()).toEqual "5"
				it "should show string values", ->
					waitsFor ->
						@cemlc.$('.bv_string_value').length > 0
					, 1000
					runs ->
						expect(@cemlc.$('.bv_string_value').val()).toEqual "rationale text"
				it "should show url values", ->
					waitsFor ->
						@cemlc.$('.bv_url_value').length > 0
					, 1000
					runs ->
						expect(@cemlc.$('.bv_url_value').val()).toEqual "http://www.rcsb.org"
			describe "gui descriptor", ->
				it "should sort values by gui descriptor", ->
					guiDescriptorValue = @cemlc.getGuiDescriptor()
					guiDescriptorOrder =  guiDescriptorValue.pluck("lsKind")
					toRenderOrder = @cemlc.toRender.pluck("lsKind")
					expect(guiDescriptorOrder).toEqual(toRenderOrder)
	describe "Custom Experiment Metadata Value Controller testing", ->
		describe "When created from a saved experiment", ->
			describe "Clob Value testing (serves as non-subclass testing)", ->
				beforeEach ->
						@exp = new Experiment window.experimentServiceTestJSON.fullExperimentFromServer
						@model = @exp.get('lsStates').getOrCreateValueByTypeAndKind "metadata", "custom experiment metadata", "clobValue", "Background"
						@cmvc = new CustomMetadataClobValueController
							el: $('#fixture')
							model: @model
							experiment: @exp
						@cmvc.render()
				describe "property display", ->
					it "should have a label", ->
						waitsFor ->
							@cmvc.$('.bv_label').length > 0
						, 1000
						runs ->
							expect(@cmvc.$('.bv_label').text()).toEqual "Background"
					it "should show clob values", ->
						waitsFor ->
							@cmvc.$('.bv_value').length > 0
						, 1000
						runs ->
							expect(@cmvc.$('.bv_value').val()).toEqual "background text"
				describe "model updates", ->
					it "should ignore old value when first changed and add a new value", ->
						waitsFor ->
							@cmvc.$('.bv_value').length > 0
						, 1000
						runs ->
							state = @cmvc.experiment.get('lsStates').getOrCreateStateByTypeAndKind("metadata", "custom experiment metadata")
							values = state.get('lsValues')
							originalLength =  values.length
							@cmvc.$('.bv_value').val("testing this out")
							@cmvc.$('.bv_value').change()
							newValue = state.getValuesByTypeAndKind(@model.get('lsType'), @model.get('lsKind'))
							oldValue =  values.filter (value) =>
								(value.get('ignored')) and (value.get('lsType')==@model.get('lsType')) and (value.get('lsKind')==@model.get('lsKind'))
							newLength = values.length
							expect(newLength).toEqual(originalLength + 1)
							expect(oldValue[0].get('lsKind')).toEqual(@model.get('lsKind'))
							expect(newValue[0].get('lsKind')).toEqual(@model.get('lsKind'))
			describe "Code Value testing", ->
				beforeEach ->
					@exp = new Experiment window.experimentServiceTestJSON.fullExperimentFromServer
					@model = @exp.get('lsStates').getOrCreateValueByTypeAndKind "metadata", "custom experiment metadata", "codeValue", "Original Data Level"
					@cmvc = new CustomMetadataCodeValueController
						el: $('#fixture')
						model: @model
						experiment: @exp
					@cmvc.render()
				describe "property display", ->
					it "should have a label", ->
						waitsFor ->
							@cmvc.$('.bv_label').length > 0
						, 1000
						runs ->
							expect(@cmvc.$('.bv_label').text()).toEqual "Original Data Level"
					it "should show code option picklist", ->
						waitsFor ->
							@cmvc.$('.bv_value option').length > 0
						, 1000
						runs ->
							expect(@cmvc.$('.bv_value option').val()).toEqual 'mrna'
			describe "Numeric Value testing", ->
				beforeEach ->
					@exp = new Experiment window.experimentServiceTestJSON.fullExperimentFromServer
					@model = @exp.get('lsStates').getOrCreateValueByTypeAndKind "metadata", "custom experiment metadata", "numericValue", "Weight"
					@cmvc = new CustomMetadataNumericValueController
						el: $('#fixture')
						model: @model
						experiment: @exp
					@cmvc.render()
				describe "property display", ->
					it "should have a label", ->
						waitsFor ->
							@cmvc.$('.bv_label').length > 0
						, 1000
						runs ->
							expect(@cmvc.$('.bv_label').text()).toEqual "Weight"
					it "should show numeric value", ->
						waitsFor ->
							@cmvc.$('.bv_value').length > 0
						, 1000
						runs ->
							expect(@cmvc.$('.bv_value').val()).toEqual '5'
			describe "String Value testing", ->
				beforeEach ->
					@exp = new Experiment window.experimentServiceTestJSON.fullExperimentFromServer
					@model = @exp.get('lsStates').getOrCreateValueByTypeAndKind "metadata", "custom experiment metadata", "stringValue", "Scoring Category Rationale"
					@cmvc = new CustomMetadataStringValueController
						el: $('#fixture')
						model: @model
						experiment: @exp
					@cmvc.render()
				describe "property display", ->
					it "should have a label", ->
						waitsFor ->
							@cmvc.$('.bv_label').length > 0
						, 1000
						runs ->
							expect(@cmvc.$('.bv_label').text()).toEqual "Scoring Category Rationale"
					it "should show string value", ->
						waitsFor ->
							@cmvc.$('.bv_value').length > 0
						, 1000
						runs ->
							expect(@cmvc.$('.bv_value').val()).toEqual 'rationale text'
			describe "URL Value testing", ->
				beforeEach ->
					@exp = new Experiment window.experimentServiceTestJSON.fullExperimentFromServer
					@model = @exp.get('lsStates').getOrCreateValueByTypeAndKind "metadata", "custom experiment metadata", "urlValue", "Experiment URL"
					@cmvc = new CustomMetadataURLValueController
						el: $('#fixture')
						model: @model
						experiment: @exp
					@cmvc.render()
				describe "property display", ->
					it "should have a label", ->
						waitsFor ->
							@cmvc.$('.bv_label').length > 0
						, 1000
						runs ->
							expect(@cmvc.$('.bv_label').text()).toEqual "Experiment URL"
					it "should show string value", ->
						waitsFor ->
							@cmvc.$('.bv_value').length > 0
						, 1000
						runs ->
							expect(@cmvc.$('.bv_value').val()).toEqual 'http://www.rcsb.org'
					it "should call handle button clicked when clicked", ->
						spyOn(@cmvc, 'handleLinkButtonClicked')
						@cmvc.delegateEvents()
						waitsFor ->
							@cmvc.$('.bv_value').length > 0
						, 1000
						runs ->
							@cmvc.$('.bv_link_btn').click()
							expect(@cmvc.handleLinkButtonClicked).toHaveBeenCalled()
					it "open the url when clicked", ->
						spyOn(window, 'open')
						waitsFor ->
							@cmvc.$('.bv_value').length > 0
						, 1000
						runs ->
							@cmvc.$('.bv_link_btn').click()
							expect(window.open).toHaveBeenCalledWith('http://www.rcsb.org')


