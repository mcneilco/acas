class Tag extends Backbone.Model
	defaults:
		tagText: ""

class TagList extends Backbone.Collection
	model: Tag

class TagListController extends Backbone.View
	events:
		#TODO this doesn't really work
		'focusout': 'handleTagsChanged'


	render: =>
		#requesting items will force initialization of the bootstrap-tagsinput
		@.$el.tagsinput 'items'
		tagStr = ""
		@collection.each (tag) =>
			tagStr += tag.get('tagText') + ","
		@.$el.tagsinput 'add', tagStr.slice(0, -1)

		@

	handleTagsChanged: =>
		tagStrings = @.$el.tagsinput 'items'
		tempTags = []
		for t in tagStrings
			tempTags.push tagText: t
		@collection.set tempTags

if typeof(exports) != "undefined"
	exports.Tag = Tag
	exports.TagList = TagList
