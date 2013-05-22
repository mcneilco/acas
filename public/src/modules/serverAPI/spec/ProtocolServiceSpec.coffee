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
				url: "api/protocols/codename/PROT-00000033"
				data:
					testMode: true
				success: (json) ->
					self.serviceReturn = json
				error: (err) ->
					console.log 'got ajax error'
					self.serviceReturn = null
				dataType: 'json'

		it 'should return a protocol stub', ->
			waitsFor( @waitForServiceReturn, 'service did not return', 2000)
			runs ->
				expect(@serviceReturn[0].codeName).toEqual "PROT-00000033"


	describe 'when fetching full Protocol by id', ->
		beforeEach ->
			self = @
			$.ajax
				type: 'GET'
				url: "api/protocols/8716"
				data:
					testMode: true
				success: (json) ->
					self.serviceReturn = json
				error: (err) ->
					console.log 'got ajax error'
					self.serviceReturn = null
				dataType: 'json'

		it 'should return a full protocol', ->
			waitsFor( @waitForServiceReturn, 'service did not return', 2000)
			runs ->
				expect(@serviceReturn.codeName).toEqual "PROT-00000033"

	describe 'when saving new protocol', ->
		beforeEach ->
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
			waitsFor( @waitForServiceReturn, 'service did not return', 2000)
			runs ->
				expect(@serviceReturn.id).not.toBeNull()

	describe 'when updating existing protocol', ->
		beforeEach ->
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
			waitsFor( @waitForServiceReturn, 'service did not return', 2000)
			runs ->
				expect(@serviceReturn.id).not.toBeNull()
