class window.Tag extends Backbone.Model
	defaults:
		tagText: ""

class window.TagList extends Backbone.Collection
	model: Tag

class window.TagListController extends Backbone.View
	events:
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
		console.log @collection
		tagStrings = @.$el.tagsinput 'items'
		tempTags = []
		for t in tagStrings
			tempTags.push tagText: t
		@collection.set tempTags
		console.log @collection