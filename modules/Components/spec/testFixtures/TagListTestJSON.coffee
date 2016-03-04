((exports) ->
	exports.tagList = [
		id: 1
		tagText: "tag 1"
	,
		id: 2
		tagText: "tag 2"
	]
) (if (typeof process is "undefined" or not process.versions) then window.TagListTestJSON = window.TagListTestJSON or {} else exports)

