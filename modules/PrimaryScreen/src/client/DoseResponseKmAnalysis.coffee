class window.DoseResponseKmAnalysisParameters extends Backbone.Model
	defaults:
		smartMode: true
		inactiveThresholdMode: true
		inactiveThreshold: 20
		theoreticalMaxMode: false
		theoreticalMax: null
		inverseAgonistMode: false
		vmax: new Backbone.Model limitType: 'none'
		et: new Backbone.Model

	initialize: (options) ->
		if options?
			if(typeof(options.inactiveThreshold) == "undefined")
				@set 'inactiveThreshold', null
			else
				@set 'inactiveThreshold', options.inactiveThreshold

			if(typeof(options.theoreticalMax) == "undefined")
				@set 'theoreticalMax', null
			else
				@set 'theoreticalMax', options.theoreticalMax

		@fixCompositeClasses()
		@on 'change:inactiveThreshold', @handleInactiveThresholdChanged
		@on 'change:theoreticalMax', @handleTheoreticalMaxChanged

	fixCompositeClasses: =>
		if @get('vmax') not instanceof Backbone.Model
			@set vmax: new Backbone.Model(@get('vmax'))
		if @get('et') not instanceof Backbone.Model
			@set et: new Backbone.Model(@get('et'))


	handleInactiveThresholdChanged: =>
		if _.isNaN(@get('inactiveThreshold')) or @get('inactiveThreshold') == null
			@set 'inactiveThresholdMode': false
		else
			@set 'inactiveThresholdMode': true

	handleTheoreticalMaxChanged: =>
		if _.isNaN(@get('theoreticalMax')) or @get('theoreticalMax') == null
			@set 'theoreticalMaxMode': false
		else
			@set 'theoreticalMaxMode': true

	validate: (attrs) ->
		errors = []
		limitType = attrs.vmax.get('limitType')
		if (limitType == "pin" || limitType == "limit") && (_.isNaN(attrs.vmax.get('value')) or attrs.vmax.get('value') == null)
			errors.push
				attribute: 'vmax_value'
				message: "VMax threshold value must be set when limit type is pin or limit"
		if (_.isNaN(attrs.et.get('value')))
			errors.push
				attribute: 'et_value'
				message: "Et value must be set as numeric"
		if  attrs.inactiveThresholdMode &&_.isNaN(attrs.inactiveThreshold)
			errors.push
				attribute: 'inactiveThreshold'
				message: "Inactive threshold value must be set to a number"
		if  attrs.theoreticalMaxMode && _.isNaN(attrs.theoreticalMax)
			errors.push
				attribute: 'theoreticalMax'
				message: "Theoretical max value must be set to a number"
		if errors.length > 0
			return errors
		else
			return null

class window.DoseResponseKmAnalysisParametersController extends AbstractFormController
	template: _.template($("#DoseResponseKmAnalysisParametersView").html())
	autofillTemplate: _.template($("#DoseResponseKmAnalysisParametersAutofillView").html())

	events:
		"change .bv_smartMode": "handleSmartModeChanged"
		"change .bv_inverseAgonistMode": "handleInverseAgonistModeChanged"
		"click .bv_vmax_limitType_none": "handleMaxLimitTypeChanged"
		"click .bv_vmax_limitType_pin": "handleMaxLimitTypeChanged"
		"click .bv_vmax_limitType_limit": "handleMaxLimitTypeChanged"
		"change .bv_vmax_value": "attributeChanged"
		"change .bv_et_value": "attributeChanged"
		"change .bv_inactiveThreshold": "attributeChanged"
		"change .bv_theoreticalMax": "attributeChanged"

	initialize: ->
		$(@el).html @template()
		@errorOwnerName = 'DoseResponseAnalysisParametersController'
		@setBindings()

	render: =>
		@$('.bv_autofillSection').empty()
		@$('.bv_autofillSection').html @autofillTemplate($.parseJSON(JSON.stringify(@model)))
		@setFormTitle()
		@setInverseAgonistModeEnabledState()
		@

	setInverseAgonistModeEnabledState: ->
		if @model.get 'smartMode'
			@$('.bv_inverseAgonistMode').removeAttr('disabled')
		else
			@$('.bv_inverseAgonistMode').attr('disabled','disabled')

	updateModel: =>
		@model.get('vmax').set
			value: parseFloat(UtilityFunctions::getTrimmedInput @$('.bv_vmax_value'))
		if UtilityFunctions::getTrimmedInput(@$('.bv_et_value')) == ""
			et = null
		else
			et = parseFloat(UtilityFunctions::getTrimmedInput @$('.bv_et_value'))
		@model.get('et').set
			value: et
		@model.set
			inverseAgonistMode: @$('.bv_inverseAgonistMode').is(":checked")
			smartMode: @$('.bv_smartMode').is(":checked")
			inactiveThreshold: parseFloat(UtilityFunctions::getTrimmedInput @$('.bv_inactiveThreshold'))
			theoreticalMax: parseFloat(UtilityFunctions::getTrimmedInput @$('.bv_theoreticalMax'))
			,
				silent: true


		@setInverseAgonistModeEnabledState()
		@model.trigger 'change'
		@trigger 'updateState'

	handleSmartModeChanged: =>
		if @$('.bv_smartMode').is(":checked")
			@$('.bv_inactiveThreshold').removeAttr 'disabled'
			@$('.bv_theoreticalMax').removeAttr 'disabled'
		else
			@$('.bv_inactiveThreshold').attr 'disabled', 'disabled'
			@$('.bv_inactiveThreshold').val ""
			@$('.bv_theoreticalMax').attr 'disabled', 'disabled'
			@$('.bv_theoreticalMax').val ""

		@attributeChanged()

	handleInverseAgonistModeChanged: =>
		@attributeChanged()

	handleMaxLimitTypeChanged: =>
		radioValue = @$("input[name='bv_vmax_limitType']:checked").val()
		@model.get('vmax').set limitType: radioValue, silent: true
		if radioValue == 'none'
			@$('.bv_vmax_value').attr('disabled','disabled')
		else
			@$('.bv_vmax_value').removeAttr('disabled')
		@attributeChanged()

	setFormTitle: (title) ->
		if title?
			@formTitle = title
			@$(".bv_formTitle").html @formTitle
		else if @formTitle?
			@$(".bv_formTitle").html @formTitle
		else
			@formTitle = @$(".bv_formTitle").html()


class window.DoseResponsePlotCurveKm extends Backbone.Model

	log10: (val) ->
		Math.log(val) / Math.LN10

	render: (brd, curve, plotWindow) =>
		log10 = @log10
		fct = (x) ->
			(x/(x+curve.km))*curve.vmax
		brd.create('functiongraph', [fct, plotWindow[0], plotWindow[2]], {strokeWidth:2});
#		if curve.curveAttributes.Km?
#			intersect = fct(curve.curveAttributes.Km)
#			if curve.curveAttributes.Operator?
#				color = '#ff0000'
#			else
#				color = '#808080'
#			#				Horizontal Line
#			brd.create('line',[[plotWindow[0],intersect],[curve.curveAttributes.Km,intersect]], {fixed: true, straightFirst:false, straightLast:false, strokeWidth:2, dash: 3, strokeColor: color});
#			#				Vertical Line
#			brd.create('line',[[curve.curveAttributes.Km,intersect],[curve.curveAttributes.Km,0]], {fixed: true, straightFirst:false, straightLast:false, strokeWidth:2, dash: 3, strokeColor: color});
