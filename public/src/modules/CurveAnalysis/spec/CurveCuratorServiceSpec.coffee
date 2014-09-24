describe 'Curve Curator service testing', ->
	beforeEach ->
		@waitForServiceReturn = ->
			typeof @serviceReturn != 'undefined'

	describe 'Get curve stubs from experiment code', ->
		describe "when experimentCode is valid", ->
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
					expect(@serviceReturn.curves[0].curveid).toEqual "AG-00344443_1680"
		describe "when experimentCode is invalid", ->
			beforeEach ->
				self = @
				$.ajax
					type: 'GET'
					url: "api/curves/stubs/EXPT-ERROR"
					success: (json) ->
						self.serviceReturn = json
					error: (err) ->
						console.log 'got ajax error'
						self.serviceReturn = err
					dataType: 'json'
			it 'should return status 404', ->
				waitsFor( @waitForServiceReturn, 'service did not return', 2000)
				runs ->
					console.log @serviceReturn
					expect(@serviceReturn.status).toEqual 404

	describe 'Get curve details from curve id', ->
		beforeEach ->
			self = @
			runs ->
				@syncEvent=false
				@testModel = new CurveDetail id: "AG-00344443_1680"
				@testModel.on 'change', =>
					console.log 'sync event true'
					@syncEvent=true
				@testModel.fetch()
		it 'should return curve detail with reportedValues', ->
			waitsFor ->
				@syncEvent
			, 'service did not return'
			, 2000
			runs ->
				expect(@testModel.get 'reportedValues' ).toContain "max"
		it 'should return curve detail with fitSummary', ->
			waitsFor ->
				@syncEvent
			, 'service did not return'
			, 2000
			runs ->
				expect(@testModel.get 'fitSummary').toContain 'Model&nbsp;fitted'
		it 'should return curve detail with curveErrors', ->
			waitsFor ->
				@syncEvent
			, 'service did not return'
			, 2000
			runs ->
				expect(@testModel.get 'curveErrors').toContain 'SSE'
		it 'should return curve detail with category', ->
			waitsFor ->
				@syncEvent
			, 'service did not return'
			, 2000
			runs ->
				expect(@testModel.get 'category').toContain 'sigmoid'
		it 'should return detail with approved', ->
			waitsFor ->
				@syncEvent
			, 'service did not return'
			, 2000
			runs ->
				expect(@testModel.get 'approved').toBeTruthy
		it 'should return curve detail with sessionID', ->
			waitsFor ->
				@syncEvent
			, 'service did not return'
			, 2000
			runs ->
				expect(@testModel.sessionID).tobeDefined
		it 'should return curve detail with curveAttributes', ->
			waitsFor ->
				@syncEvent
			, 'service did not return'
			, 2000
			runs ->
				expect(@testModel.get('curveAttributes').compoundCode).toEqual "CMPD-0000001-01A"
				console.log @testModel.get('curveAttributes')
				expect(@testModel.get('curveAttributes').EC50).toEqual 0.614351982526937
		it 'should return curve detail with plotData', ->
			waitsFor ->
				@syncEvent
			, 'service did not return'
			, 2000
			runs ->
				expect(@testModel.get('plotData').plotWindow.length).toEqual 4
				expect(@testModel.get('plotData').points.length).toBeGreaterThan 5
				console.log (@testModel.get('plotData').points[0].dose).toBeDefined
				console.log (@testModel.get('plotData').points[0].response).toBeDefined
				expect(@testModel.get('plotData').curve.ec50).toEqual 0.614351982526937
		it 'should return curve detail with fitSettings', ->
			waitsFor ->
				@syncEvent
			, 'service did not return'
			, 2000
			runs ->
				expect(@testModel.get('fitSettings').get('max').get('limitType')).toEqual 'none'


	goodDataRequest =
		sessionID: "/var/folders/5b/s62pqy655kx6929zhxrml5c80000gn/T//rSe-34a423d5ace7"
		save: false
		fitSettings:
			max:
				limitType: "pin"# none, pin or limit
				value: 101
			min:
				limitType: "none"# none, pin or limit
				value: null
			slope:
				limitType: "limit"# none, pin or limit
				value: 1.5
			inactiveThreshold: 20
			inverseAgonistMode: true

	describe 'Post to fit service and get response', ->
		beforeEach ->
			self = @
			$.ajax
				type: 'PUT'
				url: "/api/curve/detail/something"
				data: goodDataRequest
				success: (json) ->
					self.serviceReturn = json
				error: (err) ->
					console.log 'got ajax error'
					self.serviceReturn = null
				dataType: 'json'
		it 'should return curve detail with reportedValues', ->
			waitsFor( @waitForServiceReturn, 'service did not return', 2000)
			runs ->
				console.log @serviceReturn
				expect(@serviceReturn.reportedValues).tobeDefined
		it 'should return curve detail with fitSummary', ->
			waitsFor( @waitForServiceReturn, 'service did not return', 2000)
			runs ->
				expect(@serviceReturn.fitSummary).tobeDefined


