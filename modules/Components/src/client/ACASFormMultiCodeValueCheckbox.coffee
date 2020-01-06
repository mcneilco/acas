class window.ACASFormCodeValueCheckboxController extends ACASFormAbstractFieldController
    ###
        Launched by ACASFormMultiCodeValueCheckboxController to control one checkbox in the list
    ###

    template: _.template($("#ACASFormCodeValueCheckbox").html())

    events: ->
        "change input": "handleInputChanged"

    initialize: ->
        @stateRef = @options.stateRef
        @thingRef = @options.thingRef
        @keyBase = @options.keyBase
        @code = @options.codeTable.get 'code'
        @codeType = @options.codeTable.get 'codeType'
        @codeKind = @options.codeTable.get 'codeKind'
        @stateType = @options.stateType
        @stateKind = @options.stateKind
        @valueType = @options.valueType
        @valueKind = @options.valueKind
        @rowNumber = @options.rowNumber
        @rowNumberKind = @options.rowNumberKind
        @

    render: ->
        super()
        @

    handleInputChanged: ->
        @clearError()
        @userInputEvent = true
        isChecked = @$('input').is(":checked")
        if isChecked
            value = @getState().getOrCreateValueByTypeAndKind @valueType, @valueKind
            value.set
                codeValue: @code
                codeType: @codeType
                codeKind: @codeKind
                codeOrigin: @codeOrigin
                ignored: false
            newKey = @keyBase + value.cid
            value.set key: newKey
            @thingRef.set newKey, value
            @getState().get('lsValues').add value
        else
            # Find existing value with codeValue matching this controller's code, and mark as ignored.
            value = @getState().get('lsValues').findWhere({lsType: @valueType, lsKind: @valueKind, codeValue: @code, ignored: false})
            value.set
                ignored: true 
        super()

    renderModelContent: =>
        # Check for value matching this controller's code, and mark as checked if found
        if @getState().get('lsValues').findWhere({lsType: @valueType, lsKind: @valueKind, codeValue: @code, ignored: false})?
            @$('input').attr 'checked', 'checked'
        else
            @$('input').removeAttr 'checked'
        super()
    
    getState: () ->
        if @rowNumber? and @rowNumberKind?
            # If rowNumber is specified, assume operating within a stateTable / stateTableForm and pick the right state
            return @getStateForRow()
        else
            # Otherwise assume operating with only one state of given type/kind on the Thing
            return @thingRef.get('lsStates').getOrCreateStateByTypeAndKind @stateType, @stateKind
    
    getStateForRow: () ->
        currentStates = @getCurrentStates()
        for state in currentStates
            if @getRowNumberForState(state) == @rowNumber
                return state
        #if we get to here without returning, we need a new state
        newState = @thingRef.get('lsStates').createStateByTypeAndKind @stateType, @stateKind
        return newState

    getCurrentStates: ->
        @thingRef.get('lsStates').getStatesByTypeAndKind @stateType, @stateKind

    getRowNumberForState: (state) ->
        rowValues = state.getValuesByTypeAndKind 'numericValue', @rowNumberKind
        if rowValues.length == 1
            return rowValues[0].get('numericValue')
        else
            return null
    
    disableInput: ->
		@$('input').attr 'disabled', 'disabled'

	enableInput: ->
		@$('input').removeAttr 'disabled'


class window.ACASFormMultiCodeValueCheckboxController extends ACASFormAbstractFieldController
    ###
      Launching controller must instantiate with the full field conf including modelDefaults, not just the fieldDefinition.
    Specifying rowNumber and rowNumberKind are optional, and will make this controller act on a specific state.
      Controls a list of 
    ###
    template: _.template($("#ACASFormMultiCodeValueCheckbox").html())

    initialize: ->
        @opts = @options
        @thingRef = @opts.thingRef
        mdl = @opts.modelDefaults
        if @opts.stateType?
            @stateType = @opts.stateType
        else
            @stateType = mdl.stateType
        if @opts.stateKind?
            @stateKind = @opts.stateKind
        else
            @stateKind = mdl.stateKind
        @keyBase = @opts.modelKey
        @codeTableCollection = new PickListList()
        if @url?
            @codeTableCollection.url = @url
        else
            @codeTableCollection.url = "/api/codetables/#{mdl.codeType}/#{mdl.codeKind}"
        @checkboxControllerList = []
        super()
        @



    render: ->
        $(@el).empty()
        $(@el).html @template()
        @codeTableCollection.fetch
            success: @finishRender
        @
    
    renderModelContent: ->
        @checkboxControllerList.forEach (controller) ->
            controller.renderModelContent()

    finishRender: (collection) =>
        # setup single controllers for each fetched codeTable
        collection.each (codeTable) =>
            @addOneCodeValueSelect codeTable

    addOneCodeValueSelect: (codeTable) ->
        # setup single controllers for each fetched codeTable, call renderModelContent on each
        opts =
            codeTable: codeTable
            stateType: @stateType
            stateKind: @stateKind
            valueType: @opts.modelDefaults.type
            valueKind: @opts.modelDefaults.kind
            formLabel: codeTable.get 'name'
            keyBase: @keyBase
            rowNumber: @opts.rowNumber
            rowNumberKind: @opts.rowNumberKind
            thingRef: @thingRef
        checkboxController = new ACASFormCodeValueCheckboxController opts
        @checkboxControllerList.push checkboxController
        checkBoxEl = checkboxController.render().el
        checkBoxEl.style.float = "left"
        @$('.bv_multiCodeValueCheckboxWrapper').append checkBoxEl

    disableInput: ->
        @checkboxControllerList.forEach (controller) ->
            controller.disableInput()

	enableInput: ->
		@checkboxControllerList.forEach (controller) ->
            controller.enableInput()