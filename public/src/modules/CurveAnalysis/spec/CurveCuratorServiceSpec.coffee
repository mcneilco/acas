describe 'Curve Curator service testing', ->
	beforeEach ->
		@waitForServiceReturn = ->
			typeof @serviceReturn != 'undefined'

	describe 'Get curve stubs from experiment code', ->
		beforeEach ->
			self = @
			$.ajax
				type: 'GET'
				url: "api/curves/stubs/EXPT-00000018"
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

	describe 'Get curve details from curve id', ->
		beforeEach ->
			self = @
			$.ajax
				type: 'GET'
				url: "api/curve/detail/AG-00068922_522"
				success: (json) ->
					self.serviceReturn = json
				error: (err) ->
					console.log 'got ajax error'
					self.serviceReturn = null
				dataType: 'json'
		it 'should return curve detail with reportedValues', ->
			waitsFor( @waitForServiceReturn, 'service did not return', 2000)
			runs ->
				expect(@serviceReturn.reportedValues).tobeDefined
		it 'should return curve detail with fitSummary', ->
			waitsFor( @waitForServiceReturn, 'service did not return', 2000)
			runs ->
				expect(@serviceReturn.fitSummary).tobeDefined
		it 'should return curve detail with curveErrors', ->
			waitsFor( @waitForServiceReturn, 'service did not return', 2000)
			runs ->
				expect(@serviceReturn.curveErrors).tobeDefined
		it 'should return curve detail with category', ->
			waitsFor( @waitForServiceReturn, 'service did not return', 2000)
			runs ->
				expect(@serviceReturn.category).tobeDefined
		it 'should return detail with approved', ->
			waitsFor( @waitForServiceReturn, 'service did not return', 2000)
			runs ->
				expect(@serviceReturn.approved).tobeDefined
		it 'should return curve detail with sessionID', ->
			waitsFor( @waitForServiceReturn, 'service did not return', 2000)
			runs ->
				expect(@serviceReturn.sessionID).tobeDefined
		it 'should return curve detail with curveAttributes', ->
			waitsFor( @waitForServiceReturn, 'service did not return', 2000)
			runs ->
				expect(@serviceReturn.curveAttributes).tobeDefined
				expect(@serviceReturn.curveAttributes.compoundCode).toEqual "CMPD-0000001-01"
				expect(@serviceReturn.curveAttributes.EC50).toEqual 0.70170549529582
		it 'should return curve detail with plotData', ->
			waitsFor( @waitForServiceReturn, 'service did not return', 2000)
			runs ->
				expect(@serviceReturn.plotData).toBeDefined()
				expect(@serviceReturn.plotData.plotWindow).toBeDefined()
				expect(@serviceReturn.plotData.points.dose).toBeDefined()
				expect(@serviceReturn.plotData.points.response).toBeDefined()
				expect(@serviceReturn.plotData.curve.dose).toBeDefined()
				expect(@serviceReturn.plotData.curve.response).toBeDefined()
		it 'should return curve detail with fitSettings', ->
			waitsFor( @waitForServiceReturn, 'service did not return', 2000)
			runs ->
				expect(@serviceReturn.fitSettings).toBeDefined()
