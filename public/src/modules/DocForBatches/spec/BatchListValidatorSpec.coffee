describe "Batch List Validator Behavior Testing", ->
	beforeEach ->
		@fixture = $.clone($("#fixture").get(0))

	afterEach ->
		$("#fixture").remove()
		$("body").append $(@fixture)

	describe "BatchName Model", ->
		describe "when instantiated", ->
			beforeEach ->
				@bn = new BatchName()

			it "should have defaults", ->
				expect(@bn.get("requestName")).toEqual ""
				expect(@bn.get("preferredName")).toEqual ""
				expect(@bn.get("comment")). toEqual ""

			it "should return a display name", ->
				@bn.set
					requestName: "batchName"
					preferredName: "batchName"
				expect(@bn.getDisplayName()).toEqual "batchName"
				@bn.set
					requestName: "batchName"
					preferredName: "aliasName"
				expect(@bn.getDisplayName()).toEqual "aliasName"
				@bn.set
					requestName: "batchName"
					preferredName: ""
				expect(@bn.getDisplayName()).toEqual "batchName"

			it "should have test for valid comment", ->
				@bn.set
					preferredName: "cmpd_123:1"
					comment: "my comment"
				expect(@bn.hasValidComment()).toBeTruthy()
				@bn.set
					comment: ""
				expect(@bn.hasValidComment()).toBeFalsy()

			it "should tell if two are the same", ->
				bn1 = new BatchName(
					requestName: "reqName1"
					preferredName: "reqName1"
				)
				bn2 = new BatchName(
					requestName: "reqName2"
					preferredName: "reqName2"
				)
				bn3 = new BatchName(
					requestName: "reqName3"
					preferredName: "reqName1"
				)
				bn4 = new BatchName(
					requestName: "reqName4"
					preferredName: ""
				)
				bn5 = new BatchName(
					requestName: "reqName5"
					preferredName: ""
				)
				expect(bn1.isSame(bn2)).toBeFalsy
				expect(bn1.isSame(bn3)).toBeTruthy
				expect(bn4.isSame(bn5)).toBeFalsy
			it "should return isValid true when it is valid", ->
				bn1 = new BatchName
					requestName: "reqName1"
					preferredName: "reqName1"
					comment: "comment"
				expect( bn1.isValid()).toBeTruthy()
			it "should return isValid false when preferredName missing", ->
				bn1 = new BatchName
					requestName: "reqName1"
					preferredName: ""
					comment: "comment"
				expect( bn1.isValid()).toBeFalsy()

	describe "BatchNameList Model", ->
		describe "when instantiated", ->
			beforeEach ->
				@bnl = new BatchNameList([
					requestName: "reqName1"
					preferredName: "batchName1"
					comment: "comment 1"
				,
					requestName: "reqName2"
					preferredName: "aliasName2"
					comment: "comment 2"
				,
					requestName: "reqName3"
					preferredName: ""
					comment: "comment 3"
				])
			it "should have three batches when instantiated with 3 models", ->
				expect(@bnl.length).toEqual 3
			it "should return set list of valid models", ->
				expect(@bnl.getValidBatchNames().length).toEqual 2
			it "should be invalid when has any invalid batchnames", ->
				expect(@bnl.isValid()).toBeFalsy()
			it "should not add models that are the same", ->
				expect(@bnl.length).toEqual 3
				@bnl.add
					requestName: "reqName2"
					preferredName: "aliasName2"
				@bnl.add
					requestName: "reqName2other"
					preferredName: "aliasName2"
				expect(@bnl.length).toEqual 3
			it "should be valid when all batchnames valid", ->
				@bnl.pop()
				expect(@bnl.isValid()).toBeTruthy()

	describe "BatchName Controller", ->
		describe "when instantiated", ->
			beforeEach ->
				@bnc = new BatchNameController(
					model: new BatchName(
						requestName: "reqName1"
						preferredName: "batchName1"
						comment: "myComment"
					)
					el: @fixture
				)
				@bnc.render()

			it "should show the batch name", ->
				expect(@bnc.$(".bv_preferredName").html()).toEqual "batchName1"

			it "if alias set should show the alias name", ->
				@bnc.model.set
					requestName: "reqName1"
					preferredName: "aliasName1"
				@bnc.render()
				expect(@bnc.$(".bv_preferredName").html()).toEqual "aliasName1"

			it "should show the comment", ->
				expect(@bnc.$(".bv_comment").val()).toEqual "myComment"

			it "Should have alias substituted style if is alias name", ->
				@bnc.model.set
					requestName: "reqName1"
					preferredName: "aliasName"
				@bnc.render()
				expect(@bnc.$('.bv_preferredName').hasClass("warning")).toBeTruthy()

			it "Should have name not found style if no name or alias in model", ->
				@bnc.model.set
					requestName: "reqName1"
					preferredName: ""
				@bnc.render()
				expect(@bnc.$('.bv_preferredName').hasClass("error")).toBeTruthy()
			it "should show an error if comment is not set", ->
				@bnc.$('.bv_comment').val("")
				@bnc.$('.bv_comment').change()
				expect( @bnc.$('.bv_comment').hasClass('error')).toBeTruthy()
			it "should not show an error if comment is set", ->
				@bnc.$('.bv_comment').val("")
				@bnc.$('.bv_comment').change()
				@bnc.$('.bv_comment').val(" my comment ")
				@bnc.$('.bv_comment').change()
				expect( @bnc.$('.bv_comment').hasClass('error')).toBeFalsy()

	describe "BatchNameList Controller", ->
		describe "when instantiated", ->
			beforeEach ->
				@bnl = new BatchNameList [
					requestName: "reqName1"
					preferredName: "batchName1"
					comment: "comment 1"
				,
					requestName: "reqName2"
					preferredName: "aliasName2"
					comment: "comment 2"
				,
					requestName: "reqName3"
					preferredName: ""
					comment: "comment 3"
				]
				@bnlc = new BatchNameListController(
					collection: @bnl
					el: @fixture
				)
				@bnlc.render()

			it "should have as many batch divs as in collection", ->
				expect(@bnlc.$("tr").length).toEqual 3
				expect(@bnlc.$(".bv_preferredName:eq(1)").html()).toEqual "aliasName2"

			it "should remove list entry when a remove button clicked", ->
				@bnlc.$(".batchNameView:eq(1) .bv_removeBatch").click()
				expect(@bnlc.$("tr").length).toEqual 2
				expect(@bnlc.collection.length).toEqual 2

			it "should show new batchnames when new added to existing list", ->
				expect(@bnlc.$("tr").length).toEqual 3
				@bnlc.collection.add [
					requestName: "reqName4"
					preferredName: "batchName4"
				,
					requestName: "reqName5"
					preferredName: "aliasName5"
				]
				expect(@bnlc.$("tr").length).toEqual 5

			it "should update view if a members preferred name is changed", ->
				expect(@bnlc.$(".bv_preferredName:eq(1)").html()).toEqual "aliasName2"
				@bnlc.collection.at(1).set preferredName: "fred"
				expect(@bnlc.$(".bv_preferredName:eq(1)").html()).toEqual "fred"

			it "should update view if a members preferred name is changed", ->
				expect(@bnlc.$(".bv_comment:eq(1)").val()).toEqual "comment 2"
				@bnlc.collection.at(1).set comment: "fred"
				expect(@bnlc.$(".bv_comment:eq(1)").val()).toEqual "fred"


	describe "BatchListValidator Controller", ->
		describe "when instantiated with empty collection list", ->
			beforeEach ->
				@origConfig = window.DocForBatchesConfiguration
				@blvc = new BatchListValidatorController
					el: @fixture
					collection: new BatchNameList()
				@blvc.render()

			afterEach ->
				window.DocForBatchesConfiguration = @origConfig

			describe 'after it is rendered', ->
				it 'should have a paste list area', ->
					expect(@blvc.$('.bv_pasteListArea').prop("tagName")).toEqual "TEXTAREA"
				it 'should have a batchListContainer', ->
					expect(@blvc.$('.batchListContainer').prop("tagName")).toEqual "DIV"
				it 'should have a set the batch column head to Lot if configured that way', ->
					window.DocForBatchesConfiguration.lotCalledBatch = true
					@blvc.render()
					expect(@blvc.$('.bv_batchHeader').html()).toEqual "Batch"
					window.DocForBatchesConfiguration.lotCalledBatch = false
					@blvc.render()
					expect(@blvc.$('.bv_batchHeader').html()).toEqual "Lot"
				it "should start with an empty batchname list", ->
					expect(@blvc.$(".batchListContainer .batchList tr").length).toEqual 0
			it "should show valid batchNames when valid entries added to text input and add is clicked", ->
				runs ->
					@blvc.$(".bv_pasteListArea").val "norm_1234\nnorm_1236\nnorm_1238\n"
					@blvc.$(".bv_pasteListArea").change()
					@blvc.$(".bv_addButton").click()

				waitsFor ->
					@blvc.ischeckAndAddBatchesComplete()

				runs ->
					expect(@blvc.$(".batchListContainer .batchList tr").length).toEqual 3


			it "should empty paste input area after batches are added", ->
				@blvc.$(".bv_pasteListArea").val "norm_1234\nnorm_1236\nnorm_1238"
				@blvc.$(".bv_pasteListArea").change()
				@blvc.$(".bv_addButton").click()
				waitsFor ->
					@blvc.ischeckAndAddBatchesComplete()

				runs ->
					expect(@blvc.$(".bv_pasteListArea").val()).toEqual ""


			it "should set error class if batch returns no valid name", ->
				@blvc.$(".bv_pasteListArea").val "norm_1234\nnone_1236\nnorm_1238"
				@blvc.$(".bv_pasteListArea").change()
				@blvc.$(".bv_addButton").click()
				waitsFor ->
					@blvc.ischeckAndAddBatchesComplete()

				runs ->
					expect(@blvc.$(".batchListContainer .batchList tr").length).toEqual 3
					expect(@blvc.$(".batchList .batchNameView:eq(1) .bv_preferredName").hasClass("error")).toBeTruthy()


			it "should set alias class if batch returns no valid name", ->
				@blvc.$(".bv_pasteListArea").val "norm_1234\nalias_1236\nnorm_1238"
				@blvc.$(".bv_pasteListArea").change()
				@blvc.$(".bv_addButton").click()
				waitsFor ->
					@blvc.ischeckAndAddBatchesComplete()

				runs ->
					expect(@blvc.$(".batchListContainer .batchList tr").length).toEqual 3
					expect(@blvc.$(".batchList .batchNameView:eq(1) .bv_preferredName").hasClass("warning")).toBeTruthy()


			it "should show the correct number of valid batche names", ->
				@blvc.$(".bv_pasteListArea").val "norm_1234\nalias_1236\nnorm_1238\nnone_445"
				@blvc.$(".bv_pasteListArea").change()
				@blvc.$(".bv_addButton").click()
				waitsFor ->
					@blvc.ischeckAndAddBatchesComplete()

				runs ->
					expect(@blvc.$(".batchListContainer .batchList tr").length).toEqual 4
					expect(@blvc.$(".bv_preferredName.error").length).toEqual 1
					expect(@blvc.$(".bv_preferredName.warning").length).toEqual 1


			it "should update valid batch count when items are removed", ->
				@blvc.$(".bv_pasteListArea").val "norm_1234\nalias_1236\nalias_1238"
				@blvc.$(".bv_pasteListArea").change()
				@blvc.$(".bv_addButton").click()
				waitsFor ->
					@blvc.ischeckAndAddBatchesComplete()

				runs ->
					expect(@blvc.$(".batchListContainer .batchList tr").length).toEqual 3
					expect(@blvc.$(".bv_preferredName.warning").length).toEqual 2
					@blvc.$(".bv_removeBatch:eq(1)").click()
					expect(@blvc.$(".batchListContainer .batchList tr").length).toEqual 2
					expect(@blvc.$(".bv_preferredName.warning").length).toEqual 1

			it "should disable the add button while the update is running", ->
				@blvc.$(".bv_pasteListArea").val "norm_1234\nalias_1236\nalias_1238"
				@blvc.$(".bv_pasteListArea").change()
				@blvc.$(".bv_addButton").click()
				expect(@blvc.$(".bv_addButton").attr("disabled")).toEqual "disabled"
				waitsFor ->
					@blvc.ischeckAndAddBatchesComplete()
				runs ->
					expect(@blvc.$(".bv_addButton").attr("disabled")).toBeUndefined()

		describe "when instantiated with existing collection", ->
			beforeEach ->
				@blvc = new BatchListValidatorController
					el: @fixture
					collection: new BatchNameList(window.testJSON.batchNameList)
				@blvc.render()


			describe 'when rendered', ->
				it 'should show the proper count', ->
					expect(@blvc.$(".validBatchCount").html()).toEqual "3"

				it 'should show filled in batchName', ->
					expect(@blvc.$('.batchList tr :eq(1) .bv_preferredName').html()).toEqual('CMPD_1112')

			describe "when invalid batches added but there are valid bathes in list, should trigger invalid", ->
				it "should trigger activation request", ->
					runs ->
						expect(@blvc.$(".validBatchCount").html()).toEqual "3"
						@blvc.bind 'invalid', =>
							@gotTrigger = true
						@blvc.$('.batchList tr :eq(1) .bv_comment').val("")
						@blvc.$('.batchList tr :eq(1) .bv_comment').change()
						expect(@blvc.$(".validBatchCount").html()).toEqual "2"
					waitsFor =>
						@gotTrigger
					runs ->
						expect(@gotTrigger).toBeTruthy()
