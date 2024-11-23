class OpenExperimentInQueryToolController extends Backbone.View

    code: null
    experimentStatus: null

    template: _.template($("#OpenExperimentInQueryToolView").html())

    initialize: (options) ->
        @options = options
        @code = @options.code
        @experimentStatus = @options.experimentStatus

    render: => 
        $(@el).empty()
        $(@el).html @template()
        @formatOpenInQueryToolButton()

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
                url: "/api/getLinkExptQueryTool?experiment=#{@code}"
                success: (response) => 
                    # Take Away Generating Progress Mask 
                    @$('.bv_generatingLink').hide()
                    UtilityFunctions::openURL(response)
                error: (err) =>
                    # Take Away Generating Progress Mask 
                    @$('.bv_generatingLink').hide()
                    toast = new ACASToast
                        type: "error"
                        title: "Cannot Open Experiment"
                        text: "ACAS encountered an error when trying to open the experiment in the Query Tool. Please contact your administrator with this error: #{err.responseText}"
                        position: "top-middle"
                        duration: 10000
                datatype: 'json'

    handleGetLinkQueryToolClicked: => 
        # Add Generating Link Loading Mask 
        @$('.bv_generatingLink').show()
        # Call to Route to Get URL 
        $.ajax
            type: 'GET'
            url: "/api/getLinkExptQueryTool?experiment=#{@code}"
            success: (response) => 
                # Take Away Generating Progress Mask 
                @$('.bv_generatingLink').hide()
                @$('.bv_getLinkResults').show()
                @$('.bv_exptLink').val(response)
                @$('.bv_getLinkQueryToolButton').attr("disabled", true)
            error: (err) =>
                # Take Away Generating Progress Mask 
                @$('.bv_generatingLink').hide()
                toast = new ACASToast
                    type: "error"
                    title: "Cannot Generate Link"
                    text: "ACAS encountered an error when trying to generate a link for the experiment in the Query Tool. Please contact your administrator with this error: #{err.responseText}"
                    position: "top-middle"
                    duration: 10000
            datatype: 'json'

    handleCopyLinkClicked: =>
        link = @$('.bv_exptLink').val()
        if link? # Defined and not null
            navigator.clipboard.writeText(link).then ->
                toast = new ACASToast
                    type: "success"
                    title: "Link Copied"
                    text: "The link has been copied to your clipboard."
                    position: "top-middle"
        else
            toast = new ACASToast
                type: "error"
                title: "Copy Failed"
                text: "Unable to copy link to clipboard."
                position: "top-middle"

    formatOpenInQueryToolButton: =>
        @$('.bv_viewerOptions').empty()
        configuredViewers = window.conf.service.result.viewer.configuredViewers
        if configuredViewers?
            configuredViewers = configuredViewers.split(",")
        if configuredViewers? and configuredViewers.length>1
            for viewer in configuredViewers
                viewerName = $.trim viewer                    
                href = "'/openExptInQueryTool?tool=#{viewerName}&experiment=#{@code}','_blank'"
                if @experimentStatus != "approved" and viewerName is "LiveDesign"
                    @$('.bv_viewerOptions').append '<li class="disabled"><a href='+href+' target="_blank">'+viewerName+'</a></li>'
                else
                    @$('.bv_viewerOptions').append '<li><a href='+href+' target="_blank">'+viewerName+'</a></li>'
        else
            @$('.bv_openInQueryToolButton').removeAttr 'data-toggle', 'dropdown'
            @$('.bv_openInQueryToolButton').removeClass 'dropdown-toggle'
            @$('.bv_openInQueryToolButton .caret').hide()
            @$('.bv_openInQueryToolButton').html("Open In " + window.conf.service.result.viewer.displayName)
            @$('.bv_openInQueryTool').removeClass "btn-group"