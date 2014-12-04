###
This suite of services provides CRUD operations on Thing Objects

###

describe 'Thing Service testing', ->
	beforeEach ->
		@waitForServiceReturn = ->
			typeof @serviceReturn != 'undefined'

	describe 'Thing CRUD Tests', ->
		describe 'when fetching Thing by code', -> #TODO: should return stub or full object?
			beforeEach ->
				self = @
				$.ajax
					type: 'GET'
					url: "api/things/codeName/ExampleThing-00000021"
					data:
						testMode: true
					success: (json) ->
						self.serviceReturn = json
					error: (err) ->
						console.log 'got ajax error'
						self.serviceReturn = null
					dataType: 'json'

			it 'should return a thing stub', ->
				waitsFor( @waitForServiceReturn, 'service did not return', 2000)
				runs ->
					expect(@serviceReturn.codeName).toEqual "ExampleThing-00000001"

		describe 'when fetching full Thing by id', ->
			beforeEach ->
				self = @
				$.ajax
					type: 'GET'
					url: "api/things/1"
					success: (json) ->
						self.serviceReturn = json
					error: (err) ->
						console.log 'got ajax error'
						self.serviceReturn = null
					dataType: 'json'

			it 'should return a full thing object', ->
				waitsFor( @waitForServiceReturn, 'service did not return', 2000)
				runs ->
					expect(@serviceReturn.codeName).toEqual "ExampleThing-00000001"

		describe 'when saving new thing', ->
			beforeEach ->
				self = @
				$.ajax
					type: 'POST'
					url: "api/things"
					data: window.thingTestJSON.siRNA
					success: (json) ->
						self.serviceReturn = json
					error: (err) ->
						console.log 'got ajax error'
						self.serviceReturn = null
					dataType: 'json'

			it 'should return a thing', ->
				waitsFor( @waitForServiceReturn, 'service did not return', 2000)
				runs ->
					expect(@serviceReturn.id).not.toBeNull()

		describe 'when updating existing thing', ->
			beforeEach ->
				self = @
				$.ajax
					type: 'PUT'
					url: "api/things/1234"
					data: window.thingTestJSON.siRNA
					success: (json) ->
						self.serviceReturn = json
					error: (err) ->
						console.log 'got ajax error'
						self.serviceReturn = null
					dataType: 'json'

			it 'should return the thing', ->
				waitsFor( @waitForServiceReturn, 'service did not return', 2000)
				runs ->
					expect(@serviceReturn.id).not.toBeNull()

