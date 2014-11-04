class window.PickList extends Backbone.Model

class window.PickListList extends Backbone.Collection
	model: PickList

	setType: (type) ->
		@type = type

	getModelWithCode: (code) ->
		@detect (enu) ->
			enu.get("code") is code

	getCurrent: ->
		@filter (pl) ->
			!(pl.get 'ignored')

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

		unless @options.selectedCode is ""
			@selectedCode = @options.selectedCode
		else
			@selectedCode = null

		if @options.insertFirstOption?
			@insertFirstOption = @options.insertFirstOption
		else
			@insertFirstOption = null

		if @options.autoFetch?
			@autoFetch = @options.autoFetch
		else
			@autoFetch = true

		if @autoFetch
			@collection.fetch
				success: @handleListReset
		else
			@handleListReset()


	handleListReset: =>
		if @insertFirstOption
			@collection.add @insertFirstOption,
				at: 0
				silent: true

		@render()

	render: =>
		$(@el).empty()
		self = this
		@collection.each (enm) =>
			@addOne enm

		$(@el).val @selectedCode  if @selectedCode

		# hack to fix IE bug where select doesn't work when dynamically inserted
		$(@el).hide()
		$(@el).show()
		@rendered = true

	addOne: (enm) =>
		if !enm.get 'ignored'
			$(@el).append new PickListOptionController(model: enm).render().el

	setSelectedCode: (code) ->
		@selectedCode = code
		$(@el).val @selectedCode  if @rendered

	getSelectedCode: ->
		$(@el).val()

	getSelectedModel: ->
		@collection.getModelWithCode @getSelectedCode()

