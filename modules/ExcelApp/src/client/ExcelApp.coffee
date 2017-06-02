marked = require 'marked'

window.onload = ->
	window.excelAppController = new ExcelAppController
		el: $('.bv_excelAppView')
	excelAppController.render()

class window.ExcelAppController extends Backbone.View
	initialize: ->
		@template = _.template($("#ExcelAppView").html())

	render: =>
		@$el.empty()
		@$el.html @template()
		$.ajax
			type: 'GET'
			url: "/conf/ExcelApp/main.md"
			success: (markdown) =>
				console.log markdown
				appHTML = marked(markdown)
				@$('.bv_excelApp').html appHTML
