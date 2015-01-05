describe 'Cationic Block Service testing', ->
	beforeEach ->
		@waitForServiceReturn = ->
			typeof @serviceReturn != 'undefined'

	describe 'Cationic Block Parent CRUD Tests', ->
		describe 'when fetching parent by code', ->
			beforeEach ->
				self = @
				$.ajax
					type: 'GET'
					url: "api/cationicBlockParents/codeName/CB000001"
					data:
						testMode: true
					success: (json) ->
						self.serviceReturn = json
					error: (err) ->
						console.log 'got ajax error'
						self.serviceReturn = null
					dataType: 'json'

			it 'should return a cationic block parent', ->
				waitsFor( @waitForServiceReturn, 'service did not return', 2000)
				runs ->
					expect(@serviceReturn.codeName).toEqual "CB000001"

		describe 'when saving new parent', ->
			beforeEach ->
				self = @
				$.ajax
					type: 'POST'
					url: "api/cationicBlockParents"
					data: window.cationicBlockTestJSON.cationicBlockParent
					success: (json) ->
						self.serviceReturn = json
					error: (err) ->
						console.log 'got ajax error'
						self.serviceReturn = null
					dataType: 'json'

			it 'should return a parent', ->
				waitsFor( @waitForServiceReturn, 'service did not return', 2000)
				runs ->
					expect(@serviceReturn.id).not.toBeNull()

		describe 'when updating existing parent', ->
			beforeEach ->
				self = @
				$.ajax
					type: 'PUT'
					url: "api/cationicBlockParents/1234"
					data: window.cationicBlockTestJSON.cationicBlockParent
					success: (json) ->
						self.serviceReturn = json
					error: (err) ->
						console.log 'got ajax error'
						self.serviceReturn = null
					dataType: 'json'
			it 'should return a parent', ->
				waitsFor( @waitForServiceReturn, 'service did not return', 2000)
				runs ->
					expect(@serviceReturn.id).not.toBeNull()


	describe 'Cationic Block Batch CRUD Tests', ->
		describe 'when fetching Cationic Block batch codeNames by cationic block parent codeName', ->
			beforeEach ->
				self = @
				$.ajax
					type: 'GET'
					url: "api/batches/parentCodeName/CB000001"
					data:
						testMode: true
					success: (json) ->
						self.serviceReturn = json
					error: (err) ->
						console.log 'got ajax error'
						self.serviceReturn = null
					dataType: 'json'

			it 'should return an array of cationic block batch codeNames', ->
				waitsFor( @waitForServiceReturn, 'service did not return', 2000)
				runs ->
					console.log "done"
					console.log @serviceReturn
					expect(@serviceReturn[0].codeName).toEqual "CB000001-1"

		describe 'when fetching batch by codeName', ->
			beforeEach ->
				self = @
				$.ajax
					type: 'GET'
					url: "api/batches/codeName/CB000001-1"
					data:
						testMode: true
					success: (json) ->
						self.serviceReturn = json
					error: (err) ->
						console.log 'got ajax error'
						self.serviceReturn = null
					dataType: 'json'

			it 'should return the batch model', ->
				waitsFor( @waitForServiceReturn, 'service did not return', 2000)
				runs ->
					console.log "done"
					console.log @serviceReturn
					expect(@serviceReturn.codeName).toEqual "CB000001-1"

		describe 'when saving new batch', ->
			beforeEach ->
				self = @
				$.ajax
					type: 'POST'
					url: "api/cationicBlockBatches"
					data: window.cationicBlockTestJSON.cationicBlockBatch
					success: (json) ->
						self.serviceReturn = json
					error: (err) ->
						console.log 'got ajax error'
						self.serviceReturn = null
					dataType: 'json'

			it 'should return a batch', ->
				waitsFor( @waitForServiceReturn, 'service did not return', 2000)
				runs ->
					expect(@serviceReturn.id).not.toBeNull()

		describe 'when updating existing batch', ->
			beforeEach ->
				self = @
				$.ajax
					type: 'PUT'
					url: "api/cationicBlockBatches/1234"
					data: window.cationicBlockTestJSON.cationicBlockBatch
					success: (json) ->
						self.serviceReturn = json
					error: (err) ->
						console.log 'got ajax error'
						self.serviceReturn = null
					dataType: 'json'
			it 'should return a parent', ->
				waitsFor( @waitForServiceReturn, 'service did not return', 2000)
				runs ->
					expect(@serviceReturn.id).not.toBeNull()


