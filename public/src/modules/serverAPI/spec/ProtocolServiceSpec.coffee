###
Protocol Service specs

Just implenting GET for now

See ProtocolServiceTestJSON.coffee for examples

###

describe 'Protocol CRUD testing', ->
	beforeEach ->
		@waitForServiceReturn = ->
			typeof @serviceReturn != 'undefined'

	describe 'when fetching Protocol stub by code', ->
		beforeEach ->
			self = @
			$.ajax
				type: 'GET'
				url: "api/protocols/codename/PROT-00000002"
				success: (json) ->
					self.serviceReturn = json
				error: (err) ->
					console.log 'got ajax error'
					self.serviceReturn = null
				dataType: 'json'

		it 'should return a protocol stub', ->
			waitsFor( @waitForServiceReturn, 'service did not return', 2000)
			runs ->
				expect(@serviceReturn[0].codeName).toContain "PROT-"


	describe 'when fetching full Protocol by id', ->
		beforeEach ->
			if not window.AppLaunchParams.liveServiceTest
				self = @
				$.ajax
					type: 'GET'
					url: "api/protocols/8716"
					success: (json) ->
						self.serviceReturn = json
					error: (err) ->
						console.log 'got ajax error'
						self.serviceReturn = null
					dataType: 'json'

		it 'should return a full protocol', ->
			if not window.AppLaunchParams.liveServiceTest
				waitsFor( @waitForServiceReturn, 'service did not return', 2000)
				runs ->
					expect(@serviceReturn.codeName).toEqual "PROT-00000001"

	describe 'when saving new protocol', ->
		beforeEach ->
			if not window.AppLaunchParams.liveServiceTest
				self = @
				$.ajax
					type: 'POST'
					url: "api/protocols"
					data: window.protocolServiceTestJSON.protocolToSave
					success: (json) ->
						self.serviceReturn = json
					error: (err) ->
						console.log 'got ajax error'
						self.serviceReturn = null
					dataType: 'json'
		it 'should return aa protocol', ->
			if not window.AppLaunchParams.liveServiceTest
				waitsFor( @waitForServiceReturn, 'service did not return', 2000)
				runs ->
					expect(@serviceReturn.id).not.toBeNull()

	describe 'when updating existing protocol', ->
		beforeEach ->
			if not window.AppLaunchParams.liveServiceTest
				self = @
				$.ajax
					type: 'PUT'
					url: "api/protocols"
					data: window.protocolServiceTestJSON.fullSavedProtocol
					success: (json) ->
						self.serviceReturn = json
					error: (err) ->
						console.log 'got ajax error'
						self.serviceReturn = null
					dataType: 'json'
		it 'should return a protocol', ->
			if not window.AppLaunchParams.liveServiceTest
				waitsFor( @waitForServiceReturn, 'service did not return', 2000)
				runs ->
					expect(@serviceReturn.id).not.toBeNull()

	describe "Protocol related services", ->
		describe 'when protocol labels service called', ->
			beforeEach ->
				runs ->
					$.ajax
						type: 'GET'
						url: "api/protocolLabels"
						success: (json) =>
							@serviceReturn = json
						error: (err) =>
							console.log 'got ajax error'
							@serviceReturn = null
						dataType: 'json'

			it 'should return an array of lsLabels', ->
				waitsFor( @waitForServiceReturn, 'service did not return', 2000)
				runs ->
					expect(@serviceReturn.length).toBeGreaterThan 0
			it 'labels should include a protocol code', ->
				waitsFor( @waitForServiceReturn, 'service did not return', 2000)
				runs ->
					expect(@serviceReturn[0].protocol.codeName).toContain "PROT-"

		describe 'when protocol code list service called', ->
			beforeEach ->
				runs ->
					$.ajax
						type: 'GET'
						url: "api/protocolCodes"
						success: (json) =>
							@serviceReturn = json
						error: (err) =>
							console.log 'got ajax error'
							@serviceReturn = null
						dataType: 'json'

			it 'should return an array of protocols', ->
				waitsFor( @waitForServiceReturn, 'service did not return', 2000)
				runs ->
					expect(@serviceReturn.length).toBeGreaterThan 0
			it 'should a hash with code defined', ->
				waitsFor( @waitForServiceReturn, 'service did not return', 2000)
				runs ->
					expect(@serviceReturn[0].code).toContain "PROT-"
			it 'should a hash with name defined', ->
				waitsFor( @waitForServiceReturn, 'service did not return', 2000)
				runs ->
					expect(@serviceReturn[0].name).toBeDefined()
			it 'should a hash with ignore defined', ->
				waitsFor( @waitForServiceReturn, 'service did not return', 2000)
				runs ->
					expect(@serviceReturn[0].ignored).toBeDefined()
			it 'should return some names without PK', ->
				waitsFor( @waitForServiceReturn, 'service did not return', 2000)
				runs ->
					expect(@serviceReturn[@serviceReturn.length-1].name).toNotContain "PK"

		describe 'when protocol code list service called with filtering option', ->
			beforeEach ->
				runs ->
					$.ajax
						type: 'GET'
						url: "api/protocolCodes/filter/PK"
						success: (json) =>
							@serviceReturn = json
						error: (err) =>
							console.log 'got ajax error'
							@serviceReturn = null
						dataType: 'json'

			it 'should only return names with PK', ->
				waitsFor( @waitForServiceReturn, 'service did not return', 2000)
				runs ->
					expect(@serviceReturn[@serviceReturn.length-1].name).toContain "PK"
