
describe 'Code Table Service testing', ->
	beforeEach ->
		@waitForServiceReturn = ->
			typeof @serviceReturn != 'undefined'

	describe 'when code table service called', ->
		beforeEach ->
			runs ->
				$.ajax
					type: 'GET'
					url: "api/dataDict/algorithm well flags"
					success: (json) =>
						@serviceReturn = json
					error: (err) =>
						console.log 'got ajax error'
						@serviceReturn = null
					dataType: 'json'

		it 'should return an array of code table values', ->
			waitsFor( @waitForServiceReturn, 'service did not return', 2000)
			runs ->
				expect(@serviceReturn.length).toBeGreaterThan 0
		it 'should return a hash with code defined', ->
			waitsFor( @waitForServiceReturn, 'service did not return', 2000)
			runs ->
				expect(@serviceReturn[0].code).toBeDefined()
		it 'should return a hash with name defined', ->
			waitsFor( @waitForServiceReturn, 'service did not return', 2000)
			runs ->
				expect(@serviceReturn[0].name).toBeDefined()
		it 'should return a hash with ignore defined', ->
			waitsFor( @waitForServiceReturn, 'service did not return', 2000)
			runs ->
				expect(@serviceReturn[0].ignored).toBeDefined()

