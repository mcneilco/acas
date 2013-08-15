describe 'Doc For Batches Behavior Testing', ->

	beforeEach ->
		@.fixture = $.clone($('#fixture').get(0))

	afterEach ->
		$('#fixture').remove()
		$('body').append $(this.fixture)

	describe 'DocForBatches model', ->
		describe 'New empty model', ->
			beforeEach ->
				@docForBatches = new DocForBatches()
			describe 'Defaults', ->
				it 'should have an empty DocUpload', ->
					expect(@docForBatches.has('docUpload')).toBeTruthy()
					expect(@docForBatches.get('docUpload') instanceof DocUpload).toBeTruthy()
				it 'should have an empty BatchNameList', ->
					expect(@docForBatches.has('batchNameList')).toBeTruthy()
					expect(@docForBatches.get('batchNameList') instanceof BatchNameList).toBeTruthy()
			describe "Validation", ->
				it "should be invalid when new", ->
					expect(@docForBatches.isValid()).toBeFalsy()

		describe "create populated experiment when docForBatches is populated but unsaved", ->
			beforeEach ->
				@docUpload = new DocUpload(window.testJSON.docUploadWithFile)
				@batchNameList = new BatchNameList(window.testJSON.batchNameList)
				@docForBatches = new DocForBatches
					docUpload: @docUpload
					batchNameList: @batchNameList
			describe "get required protocol", ->
				it "this spec should setup a valid docForBatches", ->
					expect(@docForBatches.isValid()).toBeTruthy()
				it "should be fetch the hard-wired protocol for docForBatches", ->
					# it fetches upon initialzation, so we give it a chance to load
					waitsFor ->
						@docForBatches.protocol != null
					,
						500
					runs ->
						expect(@docForBatches.protocol.get('codeName')).toContain "PROT"
						#NB this is not the correct protocol, it is just what the stubbed protocol form code service returns
			describe "when experiment update requested", ->
				beforeEach ->
					waitsFor ->
						@docForBatches.protocol != null
					,
						500
					runs ->
						@exp = @docForBatches.asExperiment()
				it "should return an Experimemnt object", ->
					runs ->
						expect(@exp instanceof Experiment).toBeTruthy()
				it "experiment should have protocol", ->
					runs ->
						expect(@exp.get('protocol').get('codeName')).toContain "PROT"
				it "experiment should have correct kind", ->
					runs ->
						expect(@exp.get('kind')).toEqual "ACAS doc for batches"
				it "experiment should have correct recordedBy", ->
					runs ->
						expect(@exp.get('recordedBy')).toEqual "jmcneil"
				it "experiment should have recordedDate", ->
					runs ->
						expect(@exp.get('recordedDate')).toBeGreaterThan 1
				it "experiment should have shortDescription", ->
					runs ->
						expect(@exp.get('shortDescription')).toEqual "test description"
				it "experiment should have label equal to file name or URL", ->
					runs ->
						expect(@exp.get('lsLabels').pickBestName().get('labelText')).toEqual "exampleUploadedFile.txt"
				it "experiment should have analysisGroup in analysisGroupList", ->
					runs ->
						expect(@exp.get('analysisGroups').at(0) instanceof AnalysisGroup).toBeTruthy()
				it "experiment should have state in analysisGroup", ->
					runs ->
						expect(@exp.get('analysisGroups').at(0).get('analysisGroupStates') instanceof AnalysisGroupStateList).toBeTruthy()
				it "experiment should have state in state list", ->
					runs ->
						expect(@exp.get('analysisGroups').at(0).get('analysisGroupStates').length).toEqual 1
				it "experiment should have statevalue list in state", ->
					runs ->
						expect(@exp.get('analysisGroups').at(0).get('analysisGroupStates').at(0).get('analysisGroupValues') instanceof AnalysisGroupValueList).toBeTruthy()
				it "experiment should have statevalues", ->
					runs ->
						expect(@exp.get('analysisGroups').at(0).get('analysisGroupStates').at(0).get('analysisGroupValues').length).toEqual 5
				it "experiment should have statevalues", ->
					runs ->
						expect(@exp.get('analysisGroups').at(0).get('analysisGroupStates').at(0).get('analysisGroupValues').at(0) instanceof AnalysisGroupValue).toBeTruthy()
				it "experiment should have statevalues kind", ->
					runs ->
						expect(@exp.get('analysisGroups').at(0).get('analysisGroupStates').at(0).get('analysisGroupValues').at(0).get('valueKind')).toEqual 'annotation'
				it "experiment should have statevalues type", ->
					runs ->
						expect(@exp.get('analysisGroups').at(0).get('analysisGroupStates').at(0).get('analysisGroupValues').at(0).get('valueType')).toEqual 'fileValue'
				it "state value should not be ignored", ->
					runs ->
						expect(@exp.get('analysisGroups').at(0).get('analysisGroupStates').at(0).get('analysisGroupValues').at(0).get('ignored')).toBeFalsy()


		describe "create a new docForBatches from experiment", ->
			beforeEach ->
				#experiment: newExperiment window.experimentServiceTestJSON.savedExperimentWithTreatmentGroup
				@exp =new Experiment window.experimentServiceTestJSON.savedExperimentWithTreatmentGroup
				@docForBatches = new DocForBatches
					experiment: @exp
			it "should have a experiment setup", ->
				expect(@docForBatches.get('experiment') instanceof Experiment).toBeTruthy()
			it "should setup a currentFileName from fileValue", ->
				console.log @docForBatches
				expect(@docForBatches.get('docUpload').get('currentFileName')).toEqual window.experimentServiceTestJSON.savedExperimentWithTreatmentGroup.analysisGroups[0].analysisGroupStates[0].analysisGroupValues[0].fileValue
			it "should not setup a url from urlValue", ->
				#window.experimentServiceTestJSON.savedExperimentWithTreatmentGroup.analysisGroups[0].analysisGroupStates[0].analysisGroupValues[0].urlValue
				expect(@docForBatches.get('docUpload').get('url')).toEqual ''
			it "should setup a documentKind from stringValue", ->
				#window.experimentServiceTestJSON.savedExperimentWithTreatmentGroup.analysisGroups[0].analysisGroupStates[2].analysisGroupValues[1].stringValue
				expect(@docForBatches.get('docUpload').get('documentKind')).toEqual 'experiment'
			it "should setup a banchNameList from analysisGroupValue", ->
				expect(@docForBatches.get('batchNameList').length).toEqual 3
			it "should setup a banchNameList from analysisGroupValue", ->
				expect(@docForBatches.get('batchNameList').at(0).get('preferredName')).toEqual 'CMPD_1112'

		#update existing saved experiment
		#TODO Replace with new from experiment
		describe 'New from JSON', ->
			beforeEach ->
				@docForBatches = new DocForBatches
					json: window.testJSON.docForBatches
			describe 'loaded JSON', ->
				it 'should have the id set', ->
					expect(@docForBatches.id).toEqual(1235)
				describe 'has a populated DocUpload', ->
					it 'should have a DocUpload class', ->
						#TODO check class name
					it 'should have a filled currentFileName', ->
						expect(@docForBatches.get('docUpload').get('currentFileName')).toEqual("exampleUploadedFile.txt")
				describe 'has a populated BatchNameList', ->
					it 'should have a BatchNameList class', ->
						#TODO check class name
					it 'should have a filled BatchNameList 0th element with preferredName: ', ->
						expect(@docForBatches.get('batchNameList').at(0).get('preferredName')).toEqual("CMPD-0000007-01")

	describe 'DocForBatches Controller', ->
		describe 'when launched with new model', ->
			beforeEach ->
				@docForBatchesController = new DocForBatchesController
					el: $('#fixture')
					model: new DocForBatches()
				@docForBatchesController.render()

			describe 'after initial render', ->
				it 'should should show "New Document Annotations" in title', ->
					expect(@docForBatchesController.$('.bv_title').html()).toEqual("New Document Annotations")
				it 'should disable file button', ->
					expect(@docForBatchesController.$(".bv_saveButton").attr("disabled")).toEqual "disabled"

			describe 'template should load', ->
				it ' should have a save button', ->
					expect(@docForBatchesController.$('.bv_saveButton').is('button')).toBeTruthy()
				it ' should have a delete button', ->
					expect(@docForBatchesController.$('.bv_deleteButton').is('button')).toBeTruthy()
				it ' should have a cancel button', ->
					expect(@docForBatchesController.$('.bv_cancelButton').is('button')).toBeTruthy()
				it ' should have a div for a batchListValidator', ->
					expect(@docForBatchesController.$('.bv_batchListValidator').is('div')).toBeTruthy()
				it ' should have a div for a docUpload', ->
					expect(@docForBatchesController.$('.bv_docUpload').is('div')).toBeTruthy()

				describe 'should show a DocUpload', ->
					it 'should have a description field', ->
						expect(@.docForBatchesController.$(".bv_description").is('input')).toBeTruthy()

				describe 'should show a batchListValidator', ->
					it 'should have a paste list area', ->
						expect(@docForBatchesController.$('.bv_pasteListArea').is("textarea")).toBeTruthy()
					it 'should have a batchListContainer', ->
						expect(@docForBatchesController.$('.batchListContainer').is("div")).toBeTruthy()

				describe 'because it is a new document', ->
					it 'should label save button "Save', ->
						expect(@docForBatchesController.$(".bv_saveButton").html()).toEqual("Save")
					it 'should hide delete button', ->
						expect(@docForBatchesController.$(".bv_deleteButton")).toBeHidden()

				describe 'invalid form state should disable save button', ->
					it "should disable the submit button when there are zero valid batches", ->
						runs ->
							expect(@docForBatchesController.$(".bv_saveButton").attr("disabled")).toEqual "disabled"
							@docForBatchesController.$(".bv_pasteListArea").val "norm_1234"
							@docForBatchesController.$(".bv_pasteListArea").change()
							@docForBatchesController.$(".bv_addButton").click()
							@docForBatchesController.docUploadController.setNewFileName("fredFile") #usually triggered from fileInput
							@docForBatchesController.$(".bv_newFileRadio").click()
						waitsFor ->
							@docForBatchesController.batchListValidator.ischeckAndAddBatchesComplete()
						,
							500
						runs ->
							@docForBatchesController.$(".bv_comment").val("my comment")
							@docForBatchesController.$(".bv_comment").change()
							expect(@docForBatchesController.$(".bv_saveButton").attr("disabled")).toBeUndefined()
							@docForBatchesController.$(".batchNameView:eq(0) .bv_removeBatch").click()
							expect(@docForBatchesController.$(".bv_saveButton").attr("disabled")).toEqual "disabled"

					it 'should disable save if URL is selected and URL field is empty', ->
						expect(@docForBatchesController.$(".bv_saveButton").attr("disabled")).toEqual "disabled"
						@docForBatchesController.$(".bv_urlRadio").click()
						expect(@docForBatchesController.$(".bv_saveButton").attr("disabled")).toEqual "disabled"

					it 'should disable save if file is selected and file is not uplaoded', ->
						expect(@docForBatchesController.$(".bv_saveButton").attr("disabled")).toEqual "disabled"
						@docForBatchesController.$(".bv_newFileRadio").click()
						expect(@docForBatchesController.$(".bv_saveButton").attr("disabled")).toEqual "disabled"

					it 'should enable save if file is selected and file is uplaoded and there are valid batches', ->
						runs ->
							expect(@docForBatchesController.$(".bv_saveButton").attr("disabled")).toEqual "disabled"
							@docForBatchesController.$(".bv_pasteListArea").val "norm_1234"
							@docForBatchesController.$(".bv_pasteListArea").change()
							@docForBatchesController.$(".bv_addButton").click()
							@docForBatchesController.docUploadController.setNewFileName("fredFile") #usually triggered from fileInput
							@docForBatchesController.$(".bv_newFileRadio").click()
						waitsFor ->
							@docForBatchesController.batchListValidator.ischeckAndAddBatchesComplete()
						,
							500
						runs ->
							@docForBatchesController.$(".bv_comment").val("my comment")
							@docForBatchesController.$(".bv_comment").change()
							expect(@docForBatchesController.$(".bv_saveButton").attr("disabled")).toBeUndefined()
				describe 'When some stuff entered and cancel button clicked', ->
					beforeEach ->
						runs ->
							@docForBatchesController.$(".bv_pasteListArea").val "norm_1234"
							@docForBatchesController.$(".bv_pasteListArea").change()
							@docForBatchesController.$(".bv_addButton").click()
							@docForBatchesController.$(".bv_urlRadio").click()
							@docForBatchesController.$(".bv_url").val("myURL")
							@docForBatchesController.$(".bv_description").val("my description")
							@docForBatchesController.$(".bv_url").val("myURL")
						waitsFor ->
							@docForBatchesController.batchListValidator.ischeckAndAddBatchesComplete()
						,
							500
					it 'should replace the model with a new empty model and clear inputs', ->
						runs ->
							@docForBatchesController.$(".bv_comment").val("my comment")
							@docForBatchesController.$(".bv_comment").change()
							expect(@docForBatchesController.$(".bv_saveButton").attr("disabled")).toEqual "disabled"
							expect(@docForBatchesController.model.get('batchNameList').length).toEqual 1
							@docForBatchesController.$(".bv_cancelButton").click()
							expect(@docForBatchesController.$(".bv_url").val()).toEqual ""
							expect(@docForBatchesController.$(".bv_description").val()).toEqual ""
							expect(@docForBatchesController.model.get('batchNameList').length).toEqual 0

		describe 'when launched with existing model', ->
			beforeEach ->
				@docForBatchesController = new DocForBatchesController
					el: $('#fixture')
					model: new DocForBatches
						json: window.testJSON.docForBatches

				@docForBatchesController.render()

			describe 'after initial render', ->
				it 'should should show "Edit Document Annotations" in title', ->
					expect(@docForBatchesController.$('.bv_title').html()).toEqual("Edit Document Annotations")

			describe 'because it is an existing document', ->
				it 'should label save button "Update', ->
					expect(@docForBatchesController.$(".bv_saveButton").html()).toEqual("Update")
				it 'should show delete button', ->
					expect(@docForBatchesController.$(".bv_deleteButton")).toBeVisible()

