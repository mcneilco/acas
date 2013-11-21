describe 'User authentication Service testing', ->
	beforeEach ->
		@waitForServiceReturn = ->
			typeof @serviceReturn != 'undefined'
		@serviceType = window.conf.authentication.user.type


	describe 'when auth service called', ->
		beforeEach ->
			runs ->
				$.ajax
					type: 'POST'
					url: "api/userAuthentication"
					data:
						user: "bob" # credentials for test user
						password: "secret"
					success: (json) =>
						@serviceReturn = json
					error: (err) =>
						console.log 'got ajax error'
						@serviceReturn = null
					dataType: 'json'

		it 'should return succesfull credentials (expect to fail without valid creds in this spec file)', ->
			waitsFor( @waitForServiceReturn, 'service did not return', 2000)
			runs ->
				expect(@serviceReturn.status).toContain "Success"

	describe 'when user lookup called with valid username', ->
		beforeEach ->
			runs ->
				$.ajax
					type: 'GET'
					url: "api/users/jmcneil"
					success: (json) =>
						@serviceReturn = json
					error: (err) =>
						console.log 'got ajax error'
						@serviceReturn = null
					dataType: 'json'

		it 'should return user', ->
			waitsFor( @waitForServiceReturn, 'service did not return', 2000)
			runs ->
				expect(@serviceReturn.username).toEqual "jmcneil"
		it 'should return firstName', ->
			waitsFor( @waitForServiceReturn, 'service did not return', 2000)
			runs ->
				expect(@serviceReturn.firstName).toEqual "John"
		it 'should return lastName', ->
			waitsFor( @waitForServiceReturn, 'service did not return', 2000)
			runs ->
				expect(@serviceReturn.lastName).toEqual "McNeil"
		it 'should return email', ->
			waitsFor( @waitForServiceReturn, 'service did not return', 2000)
			runs ->
				expect(@serviceReturn.email).toContain "jmcneil"
		it 'should not return password', ->
			waitsFor( @waitForServiceReturn, 'service did not return', 2000)
			runs ->
				expect(@serviceReturn.password).toBeUndefined()

	describe 'when user lookup called with invalid username', ->
		beforeEach ->
			runs ->
				$.ajax
					type: 'GET'
					url: "api/users/starksofwesteros"
					success: (json) =>
						@serviceReturn = "got 200"
					error: (err) =>
						console.log 'got ajax error'
						@serviceReturn = null
					statusCode:
						204: =>
							@serviceReturn = "got 204"
					dataType: 'json'

		it 'should return 204', ->
			waitsFor( @waitForServiceReturn, 'service did not return', 2000)
			runs ->
				expect(@serviceReturn).toEqual "got 204"
#TODO make work with DNS services