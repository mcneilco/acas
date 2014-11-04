###
Protocol Service specs

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
				url: "api/protocols/codename/PROT-00000001"
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
				waitsFor( @waitForServiceReturn, 'service did not return', 5000)
				runs ->
					expect(@serviceReturn.length).toBeGreaterThan 0
			it 'should a hash with code defined', ->
				waitsFor( @waitForServiceReturn, 'service did not return', 5000)
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
			it 'should not return protocols where protocol itself is set to ignore', ->
				waitsFor( @waitForServiceReturn, 'service did not return', 2000)
				runs ->
					matches = _.filter @serviceReturn, (label) ->
						label.name == "Ignore this protocol"
					expect(matches.length).toEqual 0
		describe 'when protocol code list service called with label filtering option', ->
			describe "With matching case", ->
				beforeEach ->
					runs ->
						$.ajax
							type: 'GET'
							url: "api/protocolCodes/?protocolName=PK"
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
			describe "With non-matching case", ->
				beforeEach ->
					runs ->
						$.ajax
							type: 'GET'
							url: "api/protocolCodes/?protocolName=pk"
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
		describe 'when protocol code list service called with protocol lsKind filtering option', ->
			beforeEach ->
				runs ->
					$.ajax
						type: 'GET'
						url: "api/protocolCodes/?protocolKind=KD"
						success: (json) =>
							@serviceReturn = json
						error: (err) =>
							console.log 'got ajax error'
							@serviceReturn = null
						dataType: 'json'

			it 'should only return names with PK', ->
				waitsFor( @waitForServiceReturn, 'service did not return', 2000)
				runs ->
					expect(@serviceReturn[@serviceReturn.length-1].name).toContain "KD"

		describe 'when protocol kind list service called', ->
			beforeEach ->
				runs ->
					$.ajax
						type: 'GET'
						url: "api/protocolKindCodes"
						success: (json) =>
							@serviceReturn = json
						error: (err) =>
							console.log 'got ajax error'
							@serviceReturn = null
						dataType: 'json'

			it 'should array of protocolKinds', ->
				waitsFor( @waitForServiceReturn, 'service did not return', 2000)
				runs ->
					expect(@serviceReturn.length).toBeGreaterThan 0
			it 'should array of protocolKinds', ->
				waitsFor( @waitForServiceReturn, 'service did not return', 2000)
				runs ->
					console.log @serviceReturn
					expect(@serviceReturn[0].code).toBeDefined()
					expect(@serviceReturn[0].name).toBeDefined()
					expect(@serviceReturn[0].ignored).toBeDefined()

