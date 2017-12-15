class window.ACASFormChemicalStructureExampleController extends Backbone.View
	template: _.template($("#ACASFormChemicalStructureExampleControllerView").html())

	molToSet: "\n\n\n"+
		" 14 15  0  0  0  0  0  0  0  0999 V2000\n"+
		"    0.5089    7.8316    0.0000 C   0  0  0  0  0  0  0  0  0  0  0  0\n"+
		"    1.2234    6.5941    0.0000 C   0  0  0  0  0  0  0  0  0  0  0  0\n"+
		"    1.2234    7.4191    0.0000 C   0  0  0  0  0  0  0  0  0  0  0  0\n"+
		"   -0.2055    6.5941    0.0000 C   0  0  0  0  0  0  0  0  0  0  0  0\n"+
		"   -0.9200    7.8316    0.0000 C   0  0  0  0  0  0  0  0  0  0  0  0\n"+
		"    0.5089    5.3566    0.0000 C   0  0  0  0  0  0  0  0  0  0  0  0\n"+
		"   -0.2055    7.4191    0.0000 N   0  0  0  0  0  0  0  0  0  0  0  0\n"+
		"    0.5089    6.1816    0.0000 N   0  0  0  0  0  0  0  0  0  0  0  0\n"+
		"   -0.9200    6.1816    0.0000 O   0  0  0  0  0  0  0  0  0  0  0  0\n"+
		"    0.5089    8.6566    0.0000 O   0  0  0  0  0  0  0  0  0  0  0  0\n"+
		"    2.4929    7.0066    0.0000 C   0  0  0  0  0  0  0  0  0  0  0  0\n"+
		"    2.0080    7.6740    0.0000 N   0  0  0  0  0  0  0  0  0  0  0  0\n"+
		"    2.0080    6.3391    0.0000 N   0  0  0  0  0  0  0  0  0  0  0  0\n"+
		"    2.2630    8.4586    0.0000 C   0  0  0  0  0  0  0  0  0  0  0  0\n"+
		"  1  7  1  0  0  0  0\n"+
		"  8  2  1  0  0  0  0\n"+
		"  1  3  1  0  0  0  0\n"+
		"  2  3  2  0  0  0  0\n"+
		"  7  4  1  0  0  0  0\n"+
		"  4  8  1  0  0  0  0\n"+
		"  4  9  2  0  0  0  0\n"+
		"  7  5  1  0  0  0  0\n"+
		"  8  6  1  0  0  0  0\n"+
		"  1 10  2  0  0  0  0\n"+
		"  3 12  1  0  0  0  0\n"+
		"  2 13  1  0  0  0  0\n"+
		" 13 11  2  0  0  0  0\n"+
		" 12 11  1  0  0  0  0\n"+
		" 12 14  1  0  0  0  0\n"+
		"M  END\n"

	events: ->
		"click .bv_getMolButton": "getMol"
		"click .bv_setMolButton": "setMol"

	render: =>
		$(@el).empty()
		$(@el).html @template()
#		@sketcher = new ACASFormChemicalStructureController
		@sketcher = new KetcherChemicalStructureController
#		@sketcher = new MarvinJSChemicalStructureController
			searchMode: false
		@$('.bv_sketcher').append @sketcher.render().el

		@

	getMol: =>
		if @sketcher.getMol?
			mol = @sketcher.getMol()
			alert mol
		else
			@sketcher.getMolAsync (mol) =>
				alert mol

	setMol: =>
		@sketcher.setMol @molToSet

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

class window.KetcherChemicalStructureController extends Backbone.View
	tagName: "DIV"
	template: _.template($("#KetcherChemicalStructureControllerView").html())

	render: =>
		$(@el).empty()
		$(@el).html @template()

		searchFrameURL = "/lib/ketcher-2.0.0-alpha.3_custom/ketcher.html?api_path=/api/chemStructure/ketcher/"

		@$('.bv_sketcherIFrame').attr 'src', searchFrameURL

		@$('.bv_sketcherIFrame').on 'load', @startSketcher

		@

	startSketcher: =>
		@windowObj = @$('.bv_sketcherIFrame')[0].contentWindow
		@trigger 'sketcherLoaded'

	getMol: ->
		@windowObj.ketcher.getMolfile();

	setMol: (molStr) ->
		molStruct = @windowObj.ketcher.setMolecule molStr



# To use This MarvinJS sketcher you must uncomment four lines in
#
class window.MarvinJSChemicalStructureController extends Backbone.View
	tagName: "DIV"
	template: _.template($("#MarvinJSChemicalStructureControllerView").html())


	initialize: ->
		@exportFormat = "mol";
		if window.configuration?.marvin?.exportFormat?
			@exportFormat = window.configuration.marvin.exportFormat

	render: =>
		$(@el).empty()
		$(@el).html @template()

		searchFrameURL = "/CmpdReg/marvinjs/editorws.html"

		@marvinIFrameID = "marvinSketcher_" + new Date().getMilliseconds()
		@$('.bv_sketcherIFrame').attr 'id', @marvinIFrameID
		@$('.bv_sketcherIFrame').attr 'src', searchFrameURL

		@$('.bv_sketcherIFrame').on 'load', @startSketcher

		@

	startSketcher: =>
		MarvinJSUtil.getEditor(@marvinIFrameID).then (sketcherInstance) =>
			@marvinSketcherInstance = sketcherInstance;
			if typeof window.marvinStructureTemplates != 'undefined'
				for msTempl in window.marvinStructureTemplates
						sketcherInstance.addTemplate msTempl
			@trigger 'sketcherLoaded'
		, (error) =>
			alert("Cannot retrieve MarvinSketch sketcher instance from iframe:"+error);

	getMolAsync: (callback) ->
		@marvinSketcherInstance.exportStructure(@exportFormat).then (molecule) =>
			console.dir molecule, depth: 3
			if molecule.indexOf("0  0  0  0  0  0  0  0  0  0999")>-1
				mol = ''
			else if molecule.indexOf("M  V30 COUNTS 0 0 0 0 0")>-1
				mol = ''
			else
				mol = molecule
			callback mol
		,(error) =>
			alert("Molecule export failed from search sketcher:"+error)
			callback null


	setMol: (molStr) ->
		@marvinSketcherInstance.importStructure("mol", molStr)
