class ACASToast extends Backbone.View
    template: _.template($("#ACASToastView").html())

    initialize: (options) ->
        @options = options
        # Support options are: type, title, text, duration, and position
        # Supported types are: success, error, warning, info
        @type = options.type
        @title = options.title
        @text = options.text
        # On close function to be run if user initiates close
        @onClose = options.onClose
        # Duration is in milliseconds
        @duration = options.duration
        # Supported positions are: top-right, top-center, top-left, bottom-right, bottom-center, bottom-left
        @position = options.position
        # If duration is not set, default to 3000ms
        if !@duration?
            @duration = 3000
        # If type isn't set, default to info
        if !@type?
            @type = 'info'
        # Set icon type based on type
        if @type == "success"
            @iconType = 'icon-ok'
        if @type == "error"
            @iconType = 'icon-white icon-remove'
        if @type == "warning"
            @iconType = 'icon-warning-sign'
        if @type == "info"
            @iconType = 'icon-exclamation-sign'
        @getToastContainer()
        @render()
    
    render: ->
        # Build a new toast element from the template
        parser = new DOMParser()
        txt = @template
            type: @type
            title: @title
            text: @text
            iconType: @iconType
        @toastElem = parser.parseFromString(txt, 'text/html').querySelector('.toast')
        # append toast message to it
        @toastContainer.appendChild(@toastElem)
        # wait just a bit to add active class to the message to trigger animation
        setTimeout(() =>                 
            @toastElem.classList.add('active');
        , 1)
        # grab the close button
        closeElem = @toastElem.querySelector('.t-close')
        # Bind close event to close toast message
        closeElem.addEventListener('click', @handleCloseToastClicked.bind(@))
        # check duration. if duration is 0, toast message will not be closed
        if @duration > 0
            setTimeout( () =>

                @closeToast()
            , @duration)
        

    getToastContainer: -> 
        # Get toast container based on position
        @toastContainer = document.querySelector(".toast-container.#{@position}")
        return @toastContainer
    
    handleCloseToastClicked: (el) ->
        # remove active class from it to trigger css animation with duration of 300ms
        @toastElem.classList.remove('active');
        # wait for 350ms and then remove element
        setTimeout( () =>                 
            @toastElem.remove();
            if @onClose?
                @onClose()
        , 350)
    
    closeToast: () ->
        # remove active class from it to trigger css animation with duration of 300ms
        @toastElem.classList.remove('active');
        # wait for 350ms and then remove element
        setTimeout( () =>                 
            @toastElem.remove();
        , 350)

    isActive: () ->
        $(@.toastElem).hasClass("active")
