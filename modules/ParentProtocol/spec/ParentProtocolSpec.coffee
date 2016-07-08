
beforeEach ->
	@fixture = $.clone($("#fixture").get(0))

afterEach ->
	$("#fixture").remove()
	$("body").append $(@fixture)

describe "Parent Protocol module testing", ->
	describe "ChildProtocolItem testing", ->
		describe "when loaded new", ->
			beforeEach ->
				@cp = new ChildProtocolItem
			it "should exist", ->
				expect(@cp).toBeDefined()
		describe "when loaded from existing", ->
			beforeEach ->
				@cp = new ChildProtocolItem parentProtocolServiceTestJSON.savedParentProtocol.childProtocols[1]
			it "should exist", ->
				expect(@cp).toBeDefined()
			it "should have values", ->
				expect(@cp.get('secondProtCodeName')).toEqual "PROT-00000002"
	describe "ChildProtocolItemList testing", ->
		beforeEach ->
			@cpl = new ChildProtocolItemList
		describe "when loaded new", ->
			it "should exist", ->
				expect(@cpl).toBeDefined()
		describe "when loaded from existing", ->
			beforeEach ->
				@cp = new ChildProtocolItemList parentProtocolServiceTestJSON.savedParentProtocol.childProtocols
			it "should exist", ->
				expect(@cp).toBeDefined()
			it "should have the models", ->
				expect(@cp.length).toEqual 3
	describe "ParentProtocol", ->
		beforeEach ->
			@pp = new ParentProtocol
		describe "when loaded new", ->
			it "should exist", ->
				expect(@pp).toBeDefined()
			it "should have defaults", ->
				expect(@pp.get('subclass')).toEqual "protocol"
			xit "should be invalid on load", ->
				expect(@pp.isValid()).toBeFalsy()
		describe "when loaded from existing", ->
			beforeEach ->
				@pp = new ParentProtocol parentProtocolServiceTestJSON.savedParentProtocol
			it "should exist", ->
				expect(@pp).toBeDefined()
			it "should have a codeName", ->
				expect(@pp.get('codeName')).toEqual "PROT-00000001"


	describe "ChildProtocolItemController", ->
		describe "when created new", ->
			beforeEach ->
				@cpi = new ChildProtocolItem
				@controller = new ChildProtocolItemController
					model: @cpi
					el: $('#fixture')
				@controller.render()
			describe "existence", ->
				it "should exist", ->
					expect(@controller).toBeDefined()
			describe "rendering", ->
				it "should load a template", ->
					expect(@controller.$('.bv_childProtocol').length).toEqual 1
				it "should show options", ->
					waitsFor ->
						@controller.$('.bv_childProtocol option').length > 0
					, 1000
					runs ->
						console.log @controller.$('.bv_childProtocol')
						expect(@controller.$('.bv_childProtocol option').length).toBeGreaterThan 1
		describe "when loaded from existing", ->
			beforeEach ->
				@cpi = new ChildProtocolItem parentProtocolServiceTestJSON.savedParentProtocol.childProtocols[1]
				@controller = new ChildProtocolItemController
					model: @cpi
					el: $('#fixture')
				@controller.render()
			describe "existence", ->
				it "should exist", ->
					expect(@controller).toBeDefined()
			describe "rendering", ->
				it "should load values", ->
					waitsFor ->
						@controller.$('.bv_childProtocol option').length > 0
					, 1000
					runs ->
						expect(@controller.$('.bv_childProtocol').val()).toEqual "PROT-00000002"
	describe "ChildProtocolListController", ->
		describe "when created new", ->
			beforeEach ->
				@cpil = new ChildProtocolItemList
				@controller = new ChildProtocolListController
					collection: @cpil
					el: $('#fixture')
				@controller.render()
			describe "existence", ->
				it "should exist", ->
					expect(@controller).toBeDefined()
			describe "rendering", ->
				it "should load a template", ->
					expect(@controller.$('.bv_addChildProtocolButton').length).toEqual 1
				it "should have a child protocol", ->
					expect(@controller.$('.bv_childProtocol').length).toEqual 1
		describe "when created from exisiting", ->
			beforeEach ->
				@cpil = new ChildProtocolItemList parentProtocolServiceTestJSON.savedParentProtocol.childProtocols
				@controller = new ChildProtocolListController
					collection: @cpil
					el: $('#fixture')
				@controller.render()
			describe "existence", ->
				it "should exist", ->
					expect(@controller).toBeDefined()
			describe "rendering", ->
				it "should load a template", ->
					expect(@controller.$('.bv_addChildProtocolButton').length).toEqual 1
				it "should have three child protocols", ->
					expect(@controller.$('.bv_childProtocol').length).toEqual 3
	describe "ParentProtocolController", ->
		describe "when created new", ->
			beforeEach ->
				@pp = new ParentProtocol
				@controller = new ParentProtocolController
					model: @pp
				@controller.render()
			describe "existence", ->
				it "should exist", ->
					expect(@controller).toBeDefined()
			describe "model updates", ->
				it "should update name", ->
					@controller.$('.bv_protocolName').val("testName")
					@controller.$('.bv_protocolName').keyup()
					bestName = @pp.get('lsLabels').pickBestName()
					expect(bestName.get('labelText')).toEqual "testName"
			describe "saving", ->
				beforeEach ->
					@controller.$('.bv_protocolName').val("testName")
					@controller.$('.bv_protocolName').keyup()
					@controller.$('.bv_save').click()
				describe "expect save to work", ->
					it "model should be valid and ready to save", ->
						runs ->
							expect(@controller.model.isValid()).toBeTruthy()
					it "should update protocol code", ->
						runs ->
							@controller.$('.bv_save').click()
						waits(1000)
						runs ->
							expect(@controller.model.get('codeName')).toEqual "PROT-00000001"
					it "should update protocol code in GUI", ->
						runs ->
							@controller.$('.bv_save').click()
						waits(1000)
						runs ->
							expect(@controller.$('.bv_protocolCode').html()).toEqual "PROT-00000001"
					it "should show the save button text as Update", ->
						runs ->
							@controller.$('.bv_save').removeAttr('disabled')
							@controller.$('.bv_save').click()
						waits(1000)
						runs ->
							expect(@controller.$('.bv_save').html()).toEqual "Update"
			describe "cancel button behavior testing", ->
				it "should enable the cancel button when model changed", ->
					expect(@controller.$('.bv_cancel').attr("disabled")).toEqual "disabled"
					@controller.$('.bv_protocolName').val("testName")
					@controller.$('.bv_protocolName').keyup()
					expect(@controller.$('.bv_cancel').attr("disabled")).toBeUndefined()
				it "should call a fetch on the model when cancel is clicked", ->
					runs ->
						@controller.$('.bv_protocolName').val("testName")
						@controller.$('.bv_protocolName').keyup()
						console.log("Cancel click")
						@controller.$('.bv_cancel').click()
					waits(1000)
					runs ->
						expect(@controller.$('.bv_protocolName').val()).toEqual ""
		describe "when loaded from existing", ->
			beforeEach ->
				@pp = new ParentProtocol parentProtocolServiceTestJSON.savedParentProtocol
				@controller = new ParentProtocolController
					model: @pp
					el: $('#fixture')
				@controller.render()
			describe "existence", ->
				it "should exist", ->
					expect(@controller).toBeDefined()
			describe "load values", ->
				it "should have loaded values", ->
					expect(@controller.$('.bv_protocolName').val()).toEqual "FLIPR target A biochemical"
					expect(@controller.$('.bv_protocolCode').html()).toEqual "PROT-00000001"
			describe "model updates", ->
				it "should update name", ->
					@controller.$('.bv_protocolName').val("testName")
					@controller.$('.bv_protocolName').keyup()
					bestName = @pp.get('lsLabels').pickBestName()
					expect(bestName.get('labelText')).toEqual "testName"
			describe "saving", ->
				beforeEach ->
					@controller.$('.bv_protocolName').val("testName")
					@controller.$('.bv_protocolName').keyup()
					@controller.$('.bv_save').click()
				describe "expect save to work", ->
					it "model should be valid and ready to save", ->
						runs ->
							expect(@controller.model.isValid()).toBeTruthy()
					it "should update protocol code", ->
						runs ->
							@controller.$('.bv_save').click()
						waits(1000)
						runs ->
							expect(@controller.model.get('codeName')).toEqual "PROT-00000001"
					it "should update protocol code in GUI", ->
						runs ->
							@controller.$('.bv_save').click()
						waits(1000)
						runs ->
							expect(@controller.$('.bv_protocolCode').html()).toEqual "PROT-00000001"
					it "should show the save button text as Update", ->
						runs ->
							console.log @controller.$('.bv_save')
							@controller.$('.bv_save').removeAttr('disabled')
							@controller.$('.bv_save').click()
						waits(1000)
						runs ->
							expect(@controller.$('.bv_save').html()).toEqual "Update"
					it "should do the correct thing when save fails", ->
						# TODO
						expect(True).toBeFalsy()
			describe "cancel button behavior testing", ->
				it "should enable the cancel button when model changed", ->
					expect(@controller.$('.bv_cancel').attr("disabled")).toEqual "disabled"
					@controller.$('.bv_protocolName').val("testName")
					@controller.$('.bv_protocolName').keyup()
					expect(@controller.$('.bv_cancel').attr("disabled")).toBeUndefined()
				it "should call a fetch on the model when cancel is clicked", ->
					runs ->
						@controller.$('.bv_protocolName').val("testName")
						@controller.$('.bv_protocolName').keyup()
						@controller.$('.bv_cancel').click()
					waits(1000)
					runs ->
						expect(@controller.model.get('lsLabels').pickBestName().get('labelText')).toEqual "FLIPR target A biochemical"
						expect(@controller.$('.bv_protocolName').val()).toEqual "FLIPR target A biochemical"