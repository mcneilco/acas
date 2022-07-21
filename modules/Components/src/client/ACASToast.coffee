class ACASToast extends Backbone.View
    template: _.template($("#ACASToastView").html())

    initialize: (options) ->
        # Support options are: type, title, text, duration
        # Supported types are: success, error, warning, info
        @type = options.type
        @title = options.title
        @text = options.text
        @duration = options.duration
        # If duration is not set, default to 3000ms
        if !duration?
            @duration = 3000
        # If type isn't set, default to info
        if !@type?
            @type = 'info'
        # Set icon type based on type
        if @type == "success"
            @iconType = 'icon-ok'
        if @type == "error"
            @iconType = 'icon-remove'
        if @type == "warning"
            @iconType = 'icon-warning-sign'
        if @type == "info"
            @iconType = 'icon-exclamation-sign'
        @createToastContainer()
        @render()
    
    # events: ->
    #     "click .t-close": "closeToast"
    
    render: ->
        # Build a new toast element from the template
        parser = new DOMParser()
        txt = @template
            type: @type
            title: @title
            text: @text
            iconType: @iconType
        toastElem = parser.parseFromString(txt, 'text/html').querySelector('.toast')
        # get toast-container element
        @toastContainer = document.querySelector(".toast-container")
        # append toast message to it
        @toastContainer.appendChild(toastElem)
        # wait just a bit to add active class to the message to trigger animation
        setTimeout(() ->                 
            toastElem.classList.add('active');
        , 1)
        # check duration
        setTimeout( () ->
            toastElem.classList.remove('active');
            setTimeout( () ->
                toastElem.remove();
            , 350) # 350 ms wait for the animation
        , @duration)
        #if duration is 0, toast message will not be closed
        # Bind close event to close toast message
        if @duration > 0
            closeElem = toastElem.querySelector('.t-close')
            closeElem.addEventListener('click', @closeToast)

    createToastContainer: -> 
        # Look for existing toast-container element
        toastContainer = @$(".toast-container")
        # If it doesn't exist, create it
        if(toastContainer.length == 0)
            toastContainerContent = '<div class="toast-container"></div>'
            @$("body").innerHTML += toastContainerContent
    
    closeToast: (el) ->
        # get toast element
        toastElement = el.target.parentElement;
        # remove active class from it to trigger css animation with duration of 300ms
        toastElement.classList.remove('active');
        # wait for 350ms and then remove element
        setTimeout( () ->                 
            toastElement.remove();
        , 350)