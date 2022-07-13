class OpenExperimentInQueryToolController extends Backbone.View

    code: null
    experimentStatus: null

    template: _.template($("#OpenExperimentInQueryToolView").html())

    initialize: ->
        @code = @options.code
        @experimentStatus = @options.experimentStatus

    render: => 
        $(@el).empty()
        $(@el).html @template()
        @formatOpenInQueryToolButton()
        # Some elements might be hidden to star with; check on that

        @
        

    events:
        "click .bv_openInQueryToolButton": "handleOpenInQueryToolClicked"
        "click .bv_getLinkQueryToolButton": "handleGetLinkQueryToolClicked"
        "click .bv_copyExptLink" : "handleCopyLinkClicked"

    handleOpenInQueryToolClicked: =>
        unless @$('.bv_openInQueryToolButton').hasClass 'dropdown-toggle'
            # Add Generating Link Loading Mask 
            @$('.bv_generatingLink').show()
            # Call to Route to Get URL 
            $.ajax
                type: 'GET'
                # This route priorities LD -> Seurat -> DataViewer -> CurveCurator
                # Whichever is 
                url: "/api/getLinkExptQueryTool?experiment=#{@code}"
                success: (response) => 
                    # Take Away Generating Progress Mask 
                    @$('.bv_generatingLink').hide()
                    window.open(response,'_blank')
                error: (err) =>
                    # Take Away Generating Progress Mask 
                    @$('.bv_generatingLink').hide()
                    console.log err
                datatype: 'json'

    handleGetLinkQueryToolClicked: => 
        #unless @$('.bv_openInQueryToolButton').hasClass 'dropdown-toggle'
            # Add Generating Link Loading Mask 
            @$('.bv_generatingLink').show()
            # Call to Route to Get URL 
            setTimeout(=>  
                $.ajax
                    type: 'GET'
                    url: "/api/getLinkExptQueryTool?experiment=#{@code}"
                    success: (response) => 
                        # Take Away Generating Progress Mask 
                        @$('.bv_generatingLink').hide()
                        @$('.bv_getLinkResults').show()
                        @$('.bv_exptLink').val(response)
                    error: (err) =>
                        # Take Away Generating Progress Mask 
                        @$('.bv_generatingLink').hide()
                        console.log err
                    datatype: 'json'
              , 3000);

    handleCopyLinkClicked: =>
        link = @$('.bv_exptLink').val()
        if link? # Defined and not null
            navigator.clipboard.writeText(link).then ->
                alert("Link copied to clipboard!")
        else
            alert("Unable to copy link to clipboard")

    formatOpenInQueryToolButton: =>
        @$('.bv_viewerOptions').empty()
        configuredViewers = window.conf.service.result.viewer.configuredViewers
        if configuredViewers?
            configuredViewers = configuredViewers.split(",")
        if configuredViewers? and configuredViewers.length>1
            for viewer in configuredViewers
                viewerName = $.trim viewer                    
                href = "'/openExptInQueryTool?tool=#{viewerName}&experiment=#{@code}','_blank'"
                if @experimentStatus.get('codeValue') != "approved" and viewerName is "LiveDesign"
                    @$('.bv_viewerOptions').append '<li class="disabled"><a href='+href+' target="_blank">'+viewerName+'</a></li>'
                else
                    @$('.bv_viewerOptions').append '<li><a href='+href+' target="_blank">'+viewerName+'</a></li>'
        else
            @$('.bv_openInQueryToolButton').removeAttr 'data-toggle', 'dropdown'
            @$('.bv_openInQueryToolButton').removeClass 'dropdown-toggle'
            @$('.bv_openInQueryToolButton .caret').hide()
            @$('.bv_openInQueryToolButton').html("Open In " + window.conf.service.result.viewer.displayName)
            @$('.bv_openInQueryTool').removeClass "btn-group"