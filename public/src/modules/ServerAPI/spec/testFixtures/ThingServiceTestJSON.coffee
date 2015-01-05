((exports) ->

	exports.authorsList =
		[
			{
				code: "bob"
				codeName: null
				displayOrder: null
				id: 1
				ignored: false
				name: "Bob Roberts"
			},
			{
				code: "john"
				codeName: null
				displayOrder: null
				id: 2
				ignored: false
				name: "John Smith"
			},
			{
				code: "jane"
				codeName: null
				displayOrder: null
				id: 3
				ignored: false
				name: "Jane Doe"

			}
		]


) (if (typeof process is "undefined" or not process.versions) then window.thingServiceTestJSON = window.thingServiceTestJSON or {} else exports)
