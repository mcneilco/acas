beforeEach ->
	@fixture = $.clone($("#fixture").get(0))

afterEach ->
	$("#fixture").remove()
	$("body").append $(@fixture)

describe "TagList module testing", ->
	describe "Tag model testing", ->
		beforeEach ->
			@tag = new Tag()
		describe "Basic existance", ->
			it 'should be defined', ->
				expect(Tag).toBeDefined()
		describe "Defaults", ->
			it 'Should have default tagText', ->
				expect(@tag.get('tagText')).toEqual ""

	describe "TagList model testing", ->
		beforeEach ->
			@tl = new TagList()
		describe "Basic existance", ->
			it 'should be defined', ->
				expect(@tl instanceof Backbone.Collection).toBeTruthy()

	describe "TagListController testing", ->
		beforeEach ->
			$("#fixture").append '<input class="bv_tags" type="text" data-role="tagsinput"/>'
			@tlc = new TagListController
				collection: new TagList window.TagListTestJSON.tagList
				el: $("#fixture .bv_tags")
			@tlc.render()
		describe "Basic existance", ->
			it 'should be defined', ->
				expect(@tlc instanceof Backbone.View).toBeTruthy()
		describe "render from existing tag list", ->
			it "should show tag 1", ->
				expect(@tlc.$el.tagsinput('items')[0]).toEqual "tag 1"
		describe "adding new item updates model", ->
			it "should add new tag to collection", ->
				@tlc.$el.tagsinput 'add', "lucy"
				@tlc.$el.focusout()
				expect(@tlc.collection.at(2).get('tagText')).toEqual "lucy"
