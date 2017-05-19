class window.ACASFormChemicalStructureExampleController extends Backbone.View
	template: _.template($("#ACASFormChemicalStructureExampleControllerView").html())

	events: ->
		"click .bv_getMolButton": "getMol"
		"click .bv_setMolButton": "setMol"

	render: =>
		$(@el).empty()
		$(@el).html @template()
		@sketcher = new ACASFormChemicalStructureController
			searchMode: false
		@$('.bv_sketcher').append @sketcher.render().el

		@

	getMol: =>
		mol = @sketcher.getMol()
		alert mol

	setMol: (molStr) =>
		@sketcher.setMol molStr

	getChemDoodleJSON: =>
		mol = @sketcher.getChemDoodleJSON()
		alert mol

class window.ACASFormChemicalStructureController extends Backbone.View
	tagName: "DIV"
	template: _.template($("#ACASFormChemicalStructureControllerView").html())

	render: =>
		$(@el).empty()
		$(@el).html @template()

		@$('.bv_sketcherIFrame').on 'load', @startSketcher

		searchFrameURL = "/components/ACASFormChemicalRegStructure"
		if @options.searchMode?
			if @options.searchMode
				searchFrameURL = "/components/ACASFormChemicalSearchStructure"

		@$('.bv_sketcherIFrame').attr 'src', searchFrameURL

		@

	startSketcher: =>
		@windowObj = @$('.bv_sketcherIFrame')[0].contentWindow
		@trigger 'sketcherLoaded'

	getMol: ->
		mol = @windowObj.sketcher.getMolecule();
		@windowObj.ChemDoodle.writeMOL(mol)

	setMol: (molStr) ->
		molStruct = @windowObj.ChemDoodle.readMOL molStr
		@windowObj.sketcher.loadMolecule(molStruct);

	getChemDoodleJSON: ->
		mol = @windowObj.sketcher.getMolecule();
		@windowObj.ChemDoodle.writeJSON([mol],[])


#TODO Why is it making a call to WebHQ outside our server, and make it stop

