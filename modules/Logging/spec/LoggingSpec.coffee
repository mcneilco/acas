beforeEach ->
	@fixture = $("#fixture")

afterEach ->
	$("#fixture").remove()
	$("body").append '<div id="fixture"></div>'




