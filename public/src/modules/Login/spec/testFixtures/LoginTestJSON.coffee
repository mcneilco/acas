((exports) ->

	exports.sampleLoginUser =
		id: 4
		username: "jam"
		email: "john@mcneilco.com"
		firstName: "John"
		lastName: "McNeil"
		roles: [
			{
				id: 3
				roleEntry:
					id: 2
					roleDescription: "admin role"
					roleName: "admin"
					version: 0

				version: 0
			}
			{
				id: 4
				roleEntry:
					id: 1
					roleDescription: "user role"
					roleName: "user"
					version: 0

				version: 0
			}
		]
) (if (typeof process is "undefined" or not process.versions) then window.loginTestJSON = window.loginTestJSON or {} else exports)
