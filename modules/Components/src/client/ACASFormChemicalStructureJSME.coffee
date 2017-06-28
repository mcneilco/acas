
class window.ACASFormChemicalStructureJSMEController extends Backbone.View
	tagName: "DIV"
	template: _.template($("#ACASFormChemicalStructureControllerView").html())
	initialize: ->
		@didRender=false
		console.log 'initializing for jsme'

	render: =>
		console.log '@didRender'
		console.log @didRender
		$(@el).empty()
		$(@el).html @template()
		unless @didRender
			setTimeout(=>
				@sketcher = new JSApplet.JSME("bv_sketcherCanvasJSME", "500px", "350px", {"options": "star"})
			,0)
			console.log 'rendering jsme line 12'
		@didRender=true
		@trigger 'sketcherLoaded'
		@


	getMol: ->
		@sketcher.molFile(false)

	setMol: (molStr) ->
		@sketcher.readMolFile(molStruct)

	getSmiles: ->
		console.log 'calling get smiles -- line 31'
		@sketcher.smiles()

	jsmeOnLoad: ->
		@sketcher.jsmeOnLoad()

window.jsmeOnLoad = ->
	console.log 'jsme onload'

