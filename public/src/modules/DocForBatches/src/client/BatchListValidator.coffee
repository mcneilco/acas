class window.BatchName extends Backbone.Model
	defaults:
		requestName: ""
		preferredName: ""
		comment: ""

	getDisplayName: ->
		if @hasValidName()
			@get "preferredName"
		else
			@get "requestName"

	hasAlias: ->
		if @get("preferredName") is ""
			false
		else
			@get("requestName") isnt @get("preferredName")

	hasValidName: ->
		@get("preferredName") isnt ""

	hasValidComment: ->
		@get("comment") isnt ""

	isSame: (other) ->
		return true  if @get("preferredName") isnt "" and @get("preferredName") is other.get("preferredName")
		return true  if @get("preferredName") is "" and other.get("preferredName") is "" and @get("requestName") is other.get("requestName")
		false

	clear: ->
		@destroy()

	validate: (attrs) ->
		errors = []
		if attrs.preferredName is "" or attrs.comment is ""
			errors.push
				attribute: 'preferredName'
				message: "Batch name must be valid"

		if errors.length > 0
			return errors
		else
			return null

class window.BatchNameList extends Backbone.Collection
	model: BatchName
	getValidBatchNames: ->
		@filter (nm) ->
			nm.isValid()

	add: (model, options) ->
		if model instanceof Array
			_.each model, (mdl) =>
				@add mdl, options
		else
			isDupe = @any (tmod) ->
				tmod.isSame new BatchName(model)

			return false  if isDupe
			Backbone.Collection::add.call this, model

	isValid: =>
		if (@getValidBatchNames().length == @length) and (@length != 0)
			return true
		else
			return false



class window.BatchNameController extends Backbone.View
	template: _.template($("#BatchNameView").html())
	tagName: "tr"
	className: "batchNameView control-group"
	events:
		"click .bv_removeBatch": "clear"
		"change .bv_comment": "updateComment"

	initialize: ->
		@model.on "change", @render, @
		@model.on "destroy", @remove, @

	render: =>
		$(@el).html @template()
		@$(".bv_preferredName").html @model.getDisplayName()
		@$(".bv_comment").val @model.get "comment"
		unless @model.hasValidName()
			@$('.bv_preferredName').addClass "error"
		if @model.hasAlias() && @model.hasValidName()
			@$('.bv_preferredName').addClass "warning"
		unless @model.hasValidComment()
			@$('.bv_comment').addClass "error"
		else
			@$('.bv_comment').removeClass "error"

		@

	updateComment: ->
		@model.set
			comment: $.trim(@$('.bv_comment').val())

	clear: ->
		@model.clear()

class window.BatchNameListController extends Backbone.View
	initialize: ->
		@collection.bind "add", @add, @

	render: ->
		$(@el).empty()
		@collection.each (bName) =>
			$(@.el).append new BatchNameController(model: bName).render().el
		this

	add: =>
		@render()


class window.BatchListValidatorController extends Backbone.View
	template: _.template($("#BatchListValidatorView").html())
	events:
		"click .bv_addButton": "checkAndAddBatches"

	initialize: ->
		$(@el).html @template()
		_.bindAll this, "ischeckAndAddBatchesComplete", "getPreferredIdReturn"
		@batchNameListController = new BatchNameListController
			collection: @collection
			el: @$(".batchList")

		@collection.on "remove", @itemRemoved
		@collection.on "change", @itemChanged
		@currentReqArray = null
		@updateValidCount()

	render: ->
		if window.DocForBatchesConfiguration.lotCalledBatch
			@$('.bv_batchHeader').html("Batch")
		else
			@$('.bv_batchHeader').html("Lot")
		@batchNameListController.render()
		this

	checkAndAddBatches: ->
		@currentReqArray = @getCleanRequestedBatchList()
		unless @currentReqArray.length==0
			@trigger 'amDirty'
			@$(".bv_addButton").attr "disabled", true
			$.ajax
				type: "POST"
				url: window.configurationNode.serverConfigurationParams.configuration.preferredBatchIdService
				data:
					requests: @currentReqArray
					testMode: window.AppLaunchParams.testMode
				success: @getPreferredIdReturn
				error: (error) ->
					alert "can't talk to provide id server"

	getPreferredIdReturn: (data) ->
		if data.error
			alert "Preferred Batch ID service had this error: "+JSON.stringify(data.errorMessages)
			@$(".bv_addButton").removeAttr "disabled"
			return
		results = data.results
		unless @currentReqArray.length is results.length
			alert "problem where batch alias service did not return correct number of results"
			@$(".bv_addButton").removeAttr "disabled"
			return
		i = 0

		_.each data.results, (result) =>
			@batchNameListController.collection.add result

		@currentReqArray = null
		@updateValidCount()
		@$(".bv_pasteListArea").val ""
		@$(".bv_addButton").removeAttr "disabled"

	getCleanRequestedBatchList: ->
		cleanArray = new Array()
		unless $.trim(@$(".bv_pasteListArea").val()) == ""
			reqArray = @$(".bv_pasteListArea").val().split("\n")
			treq = undefined
			_.each reqArray, (bns) ->
				treq = $.trim(bns)
				cleanArray.push {requestName: treq}  unless treq is ""

		cleanArray

	ischeckAndAddBatchesComplete: ->
		# for use by the specrunner to test asynch calls
		unless @currentReqArray?
			true
		else
			false

	itemChanged: =>
		@trigger 'amDirty'
		@updateValidCount()

	itemRemoved: =>
		@updateValidCount()

	updateValidCount: (silent=false) =>
		@numValidBatches = @batchNameListController.collection.getValidBatchNames().length
		@$(".validBatchCount").html @numValidBatches
		if @isValid()
			@trigger("valid")
		else
			@trigger("invalid")

	isValid: =>
		@collection.isValid()
