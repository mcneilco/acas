describe 'User authentication Service testing', ->
	beforeEach ->
		@waitForServiceReturn = ->
			typeof @serviceReturn != 'undefined'
		console.log "got to new spec"

	describe 'when auth service called', ->
		beforeEach ->
			runs ->
				$.ajax
					type: 'POST'
					url: "api/userAuthentication"
					data:
						user: "ldap-query" # credentials for DNS test user
						password: "Est@P7uRi5SyR+"
					success: (json) =>
						@serviceReturn = json
					error: (err) =>
						console.log 'got ajax error'
						@serviceReturn = null
					dataType: 'json'

		it 'should return succesfull credentials', ->
			waitsFor( @waitForServiceReturn, 'service did not return', 2000)
			runs ->
				expect(@serviceReturn.status).toContain "Success"
