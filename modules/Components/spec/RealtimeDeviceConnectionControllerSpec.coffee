describe 'Realtime Device Connection Controller testing', ->
	beforeEach ->
		@fixture = $.clone($("#fixture").get(0))
		@waitForServiceReturn = ->
			typeof @serviceReturn != 'undefined'

	afterEach ->
		$("#fixture").remove()
		$(".modal-backdrop").remove()
		$("body").append $(@fixture)

	describe 'when instantiated', ->
		beforeEach ->
			@rtdc = new RealtimeDeviceConnectionController()
			@rtdc.subFormTemplate = _.template("<h3>Subform...</h3>")
			$("#fixture").html @rtdc.render().el

		it 'should exist', ->
			expect(@rtdc).toBeTruthy()

		it 'should have template content', ->
			expect($("#fixture").find('.bv_deviceSelectContainer').length).toEqual(1)

	describe 'connecting to a device server', ->
		beforeEach ->
			@rtdc = new RealtimeDeviceConnectionController()
			@rtdc.subFormTemplate = _.template("<h3>Subform...</h3>")
			$("#fixture").html @rtdc.render().el

		describe 'and device status is "not_available"', ->
			beforeEach ->
				@rtdc.connectToDeviceCallback({status: "not_available", userName: 'bob'}, null)

			it 'should display a message indicating the device is in use', ->
				expect($('.bv_deviceServerInUseButIdle').hasClass('hide')).toBeFalsy()

			it 'should display the username of the user currently using the device', ->
				expect($('.bv_deviceUsedBy').html()).toContain('bob')

			describe 'disconnect other user and reserve balance workflow', ->
				describe 'clicking the "Kick off user" button', ->
					it 'should prompt the user to verify that they want to kick the current user off', ->
						expect($('.bv_deviceInUse').css('display') is 'none').toBeTruthy()
						$('.bv_kickUserOff').click()
						expect($('.bv_deviceInUse').css('display') is 'none').toBeFalsy()

					describe 'clicking the "no" button', ->
						beforeEach ->
							$('.bv_deviceInUseDismiss').click()
						it 'should close the modal', ->
							expect($('.bv_deviceInUse').css('display') is 'none').toBeTruthy()

						it 'should continue displaying a message indicating the device is in use', ->
							expect($('.bv_deviceServerInUseButIdle').hasClass('hide')).toBeFalsy()

						it 'should continue displaying a message indicating the user currently using the device', ->
							expect($('.bv_deviceUsedBy').html()).toContain('bob')

					describe 'clicking the "yes" button', ->
						beforeEach ->
							$('.bv_bootCurrentUserOffDevice').click()
							@rtdc.handleBootCurrentUserOffDeviceCallback()
						it 'should close the modal', ->
							expect($('.bv_deviceInUse').css('display') is 'none').toBeTruthy()

						it 'should displaying a message indicating the user is currently connected to the selected device', ->
							expect($('.bv_deviceServerInUseButIdle').hasClass('hide')).toBeTruthy()
							expect($('.bv_connected').hasClass('hide')).toBeFalsy()

		describe 'and device status is "device_not_connected"', ->
			beforeEach ->
				@rtdc.connectToDeviceCallback({status: "device_not_connected"}, null)

			it 'should display a message indicating the device is not connected', ->
				expect($('.bv_deviceNotConnected').hasClass('hide')).toBeFalsy()

		describe 'and device status is "device_server_offline"', ->
			beforeEach ->
				@rtdc.connectToDeviceCallback({status: "device_server_offline"}, null)

			it 'should display a message indicating the device is not connected', ->
				expect($('.bv_deviceServerOffline').hasClass('hide')).toBeFalsy()

		describe 'and device status is "in_use"', ->
			beforeEach ->
				@rtdc.connectToDeviceCallback({status: "in_use"}, null)

			it 'should display a message indicating the device is not connected', ->
				expect($('.bv_deviceServerInUse').hasClass('hide')).toBeFalsy()

		describe 'and device is available and not in use', ->
			beforeEach ->
				@rtdc.connectToDeviceCallback(null, null)

			it 'should display a message indicating the user is connected to the device', ->
				expect($('.bv_connected').hasClass('hide')).toBeFalsy()