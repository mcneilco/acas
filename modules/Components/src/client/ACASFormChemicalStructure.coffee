class ACASFormChemicalStructureExampleController extends Backbone.View
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
#		@sketcher = new MaestroChemicalStructureController
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

	clear: ->
		@sketcher.setMolecule("");

	getChemDoodleJSON: =>
		mol = @sketcher.getChemDoodleJSON()
		alert mol

class MaestroChemicalStructureController extends Backbone.View
	tagName: "DIV"
	template: _.template($("#MaestroChemicalStructureControllerView").html())

	initialize: (options) ->
		@options = options

	render: =>
		$(@el).empty()
		$(@el).html @template()

		searchFrameURL = "/CmpdReg/maestrosketcher/wasm_shell.html"
		@maestroIFrameID = "maestroSketcher_" + new Date().getMilliseconds()
		@$('.bv_sketcherIFrame').attr 'id', @maestroIFrameID
		@$('.bv_sketcherIFrame').attr 'src', searchFrameURL
		@$('.bv_sketcherIFrame').on 'load', @startSketcher

		@

	startSketcher: =>
		MaestroJSUtil.getSketcher("##{@maestroIFrameID}").then (maestro) =>
			@maestro = maestro
			@trigger 'sketcherLoaded'
		

	getMol: ->
		mol = await new Promise (resolve, reject) =>
			# To be backwards comatable we test for the presence of the new sketcher_export_text function
			if @maestro.sketcher_export_text?
				resolve @maestro.sketcher_export_text(@maestro.Format.MDL_MOLV3000)
			else
				# Older versions of maestro
				resolve @maestro.sketcherExportMolBlock()
		return mol

	setMol: (molStr) ->
			# To be backwards comatable we test for the presence of the new sketcher_import_text function
		if @maestro.sketcher_import_text?
			@maestro.sketcher_import_text(molStr)
		else
			# Older versions of maestro
			@maestro.sketcherImportMolBlock(molStr)

	clear: ->
		@maestro.clearSketcher()

	isEmptyMol: (molStr) ->
		if (molStr.indexOf("M  V30 COUNTS 0 0 0 0 0") > -1)
			return true 
		else 
			return false


#TODO Why is it making a call to WebHQ outside our server, and make it stop

class KetcherChemicalStructureController extends Backbone.View
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
		mol = await new Promise (resolve, reject) =>
			resolve @windowObj.ketcher.getMolfile();

	setMol: (molStr) ->
		@windowObj.ketcher.setMolecule molStr

	clear: ->
		@windowObj.ketcher.setMolecule("")

	isEmptyMol: (molStr) ->
		if (molStr.indexOf("  0  0  0     1  0            999") > -1)
			return true 
		else 
			return false



# To use This MarvinJS sketcher you must uncomment four lines in
#
class MarvinJSChemicalStructureController extends Backbone.View
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

	getMol:  -> 
		mol = await new Promise (resolve, reject) =>
			@marvinSketcherInstance.exportStructure(@exportFormat).then (molecule) =>
				console.dir molecule, depth: 3
				if molecule.indexOf("0  0  0  0  0  0  0  0  0  0999")>-1
					mol = ''
				else if molecule.indexOf("M  V30 COUNTS 0 0 0 0 0")>-1
					mol = ''
				else
					mol = molecule
				resolve mol
			,(error) =>
				alert("Molecule export failed from search sketcher:"+error)
				reject null
		return mol

	setMol: (molStr) ->
		@marvinSketcherInstance.importStructure("mol", molStr)

	clear: ->
		@marvinSketcherInstance.clear()

	isEmptyMol: (molStr) ->
		if (molStr.indexOf("M  V30 COUNTS 0 0 0 0 0") > -1)
			return true 
		else 
			return false
