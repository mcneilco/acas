describe 'Curve Curator service testing', ->
	beforeEach ->
		@waitForServiceReturn = ->
			typeof @serviceReturn != 'undefined'

	describe 'Get curve stubs from experiment code', ->
		beforeEach ->
			self = @
			$.ajax
				type: 'GET'
				url: "api/curves/stub/EXPT-00000018"
				success: (json) ->
					self.serviceReturn = json
				error: (err) ->
					console.log 'got ajax error'
					self.serviceReturn = null
				dataType: 'json'
		it 'should return an array of curve stubs', ->
			waitsFor( @waitForServiceReturn, 'service did not return', 2000)
			runs ->
				expect(@serviceReturn.curves.length).toBeGreaterThan 0
		it 'should curve stubs with an id', ->
			waitsFor( @waitForServiceReturn, 'service did not return', 2000)
			runs ->
				expect(@serviceReturn.curves[0].curveid).toEqual "90807_AG-00000026"
