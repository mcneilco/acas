((exports) ->
	exports.codetableValues =
		[
			type: "linker"
			kind: "type"
			codes:
				[
					code: "boronic acid"
					name: "Boronic Acid"
					ignored: false
				,
					code: "adamantane"
					name: "Adamantane"
					ignored: false
				]
		]
) (if (typeof process is "undefined" or not process.versions) then window.linkerCodeTableTestJSON = window.linkerCodeTableTestJSON or {} else exports)
