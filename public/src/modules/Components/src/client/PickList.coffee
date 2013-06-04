class window.PickList extends Backbone.Model

class window.PickListList extends Backbone.Collection
	model: PickList

	setType: (type) ->
		@type = type

	getModelWithCode: (code) ->
		@detect (enu) ->
			enu.get("code") is code

class window.PickListOptionController extends Backbone.View
	tagName: "option"
	initialize: ->

	render: =>
		$(@el).attr("value", @model.get("code")).text @model.get("name")
		@

class window.PickListSelectController extends Backbone.View
	initialize: ->
		@rendered = false
		@collection.bind "add", @addOne
		@collection.bind "reset", @handleListReset
		@collection.fetch
			success: @handleListReset
		unless @options.selectedCode is ""
			@selectedCode = @options.selectedCode
		else
			@selectedCode = null
		if @options.insertFirstOption?
			@insertFirstOption = @options.insertFirstOption
		else
			@insertFirstOption = null

	handleListReset: =>
		if @insertFirstOption
			@collection.add @insertFirstOption,
				at: 0
				silent: true

		@render()

	render: =>
		$(@el).empty()
		self = this
		@collection.each (enm) ->
			$(self.el).append new PickListOptionController(model: enm).render().el

		$(@el).val @selectedCode  if @selectedCode

		# hack to fix IE bug where select doesn't work when dynamically inserted
		$(@el).hide()
		$(@el).show()
		@rendered = true

	addOne: (enm) =>
		$(@el).append new PickListOptionController(model: enm).render().el

	setSelectedCode: (code) ->
		@selectedCode = code
		$(@el).val @selectedCode  if @rendered

	getSelectedCode: ->
		$(@el).val()

	getSelectedModel: ->
		@collection.getModelWithCode @getSelectedCode()
