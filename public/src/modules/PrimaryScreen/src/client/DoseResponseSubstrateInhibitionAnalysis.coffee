class window.DoseResponseSubstrateInhibitionAnalysisParameters extends Backbone.Model
	defaults:
		smartMode: true
		inactiveThresholdMode: true
		inactiveThreshold: 20
		theoreticalMaxMode: false
		theoreticalMax: null
		inverseAgonistMode: false
		vmax: new Backbone.Model limitType: 'none'
		km: new Backbone.Model limitType: 'none'
		ki: new Backbone.Model limitType: 'none'
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
		if @get('km') not instanceof Backbone.Model
			@set km: new Backbone.Model(@get('km'))
		if @get('ki') not instanceof Backbone.Model
			@set ki: new Backbone.Model(@get('ki'))
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
		limitType = attrs.km.get('limitType')
		if (limitType == "pin" || limitType == "limit") && (_.isNaN(attrs.km.get('value')) or attrs.km.get('value') == null)
			errors.push
				attribute: 'km_value'
				message: "Km threshold value must be set when limit type is pin or limit"
		limitType = attrs.ki.get('limitType')
		if (limitType == "pin" || limitType == "limit") && (_.isNaN(attrs.ki.get('value')) or attrs.ki.get('value') == null)
			errors.push
				attribute: 'ki_value'
				message: "Ki threshold value must be set when limit type is pin or limit"
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

class window.DoseResponseSubstrateInhibitionAnalysisParametersController extends AbstractFormController
	template: _.template($("#DoseResponseSubstrateInhibitionAnalysisParametersView").html())
	autofillTemplate: _.template($("#DoseResponseSubstrateInhibitionAnalysisParametersAutofillView").html())

	events:
		"change .bv_smartMode": "handleSmartModeChanged"
		"change .bv_inverseAgonistMode": "handleInverseAgonistModeChanged"
		"click .bv_vmax_limitType_none": "handleMaxLimitTypeChanged"
		"click .bv_vmax_limitType_pin": "handleMaxLimitTypeChanged"
		"click .bv_vmax_limitType_limit": "handleMaxLimitTypeChanged"
		"change .bv_vmax_value": "attributeChanged"
		"click .bv_km_limitType_none": "handleKmLimitTypeChanged"
		"click .bv_km_limitType_pin": "handleKmLimitTypeChanged"
		"click .bv_km_limitType_limit": "handleKmLimitTypeChanged"
		"change .bv_km_value": "attributeChanged"
		"click .bv_ki_limitType_none": "handleKiLimitTypeChanged"
		"click .bv_ki_limitType_pin": "handleKiLimitTypeChanged"
		"click .bv_ki_limitType_limit": "handleKiLimitTypeChanged"
		"change .bv_ki_value": "attributeChanged"
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
		@model.get('km').set
			value: parseFloat(UtilityFunctions::getTrimmedInput @$('.bv_km_value'))
		@model.get('ki').set
			value: parseFloat(UtilityFunctions::getTrimmedInput @$('.bv_ki_value'))
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

	handleKmLimitTypeChanged: =>
		radioValue = @$("input[name='bv_km_limitType']:checked").val()
		@model.get('km').set limitType: radioValue, silent: true
		if radioValue == 'none'
			@$('.bv_km_value').attr('disabled','disabled')
		else
			@$('.bv_km_value').removeAttr('disabled')
		@attributeChanged()

	handleKiLimitTypeChanged: =>
		radioValue = @$("input[name='bv_ki_limitType']:checked").val()
		@model.get('ki').set limitType: radioValue, silent: true
		if radioValue == 'none'
			@$('.bv_ki_value').attr('disabled','disabled')
		else
			@$('.bv_ki_value').removeAttr('disabled')
		@attributeChanged()

	setFormTitle: (title) ->
		if title?
			@formTitle = title
			@$(".bv_formTitle").html @formTitle
		else if @formTitle?
			@$(".bv_formTitle").html @formTitle
		else
			@formTitle = @$(".bv_formTitle").html()


class window.DoseResponsePlotCurveSubstrateInhibition extends Backbone.Model

	log10: (val) ->
		if val != 0
			return Math.log(val) / Math.LN10
		else
			return val

	render: (brd, curve, plotWindow) =>
		log10 = @log10
		fct = (x) ->
#			x = Math.pow(10,x)
			(curve.vmax*x)/(curve.km+x*(1+x/curve.ki))
		brd.create('functiongraph', [fct, plotWindow[0], plotWindow[2]], {strokeWidth:2});
