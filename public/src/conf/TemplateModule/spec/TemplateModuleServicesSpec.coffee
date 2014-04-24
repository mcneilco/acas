describe "Reagent Registration Services tests", ->
	describe 'Project list Service testing', ->
		beforeEach ->
			@waitForServiceReturn = ->
				typeof @serviceReturn != 'undefined'

		describe 'when get reagent by code service called', ->
			beforeEach ->
				runs ->
					$.ajax
						type: 'GET'
						url: "api/reagentReg/reagents/codename"
						success: (json) =>
							@serviceReturn = json
						error: (err) =>
							console.log 'got ajax error'
							@serviceReturn = null
						dataType: 'json'

			it 'should return a reagent with a barcode', ->
				waitsFor( @waitForServiceReturn, 'service did not return', 2000)
				runs ->
					expect(@serviceReturn.barcode).toBeDefined()



	describe 'Hazard category list testing', ->
		beforeEach ->
			@waitForServiceReturn = ->
				typeof @serviceReturn != 'undefined'

		describe 'when hazard category service called', ->
			beforeEach ->
				runs ->
					$.ajax
						type: 'GET'
						url: "api/reagentReg/hazardCatagories"
						success: (json) =>
							@serviceReturn = json
						error: (err) =>
							console.log 'got ajax error'
							@serviceReturn = null
						dataType: 'json'

			it 'should return an array of hazard categories', ->
				waitsFor( @waitForServiceReturn, 'service did not return', 2000)
				runs ->
					expect(@serviceReturn.length).toBeGreaterThan 0
			it 'should be a hash with code defined', ->
				waitsFor( @waitForServiceReturn, 'service did not return', 2000)
				runs ->
					expect(@serviceReturn[0].code).toBeDefined()
			it 'should be a hash with name defined', ->
				waitsFor( @waitForServiceReturn, 'service did not return', 2000)
				runs ->
					expect(@serviceReturn[0].name).toBeDefined()
			it 'should be a hash with ignore defined', ->
				waitsFor( @waitForServiceReturn, 'service did not return', 2000)
				runs ->
					expect(@serviceReturn[0].ignored).toBeDefined()
