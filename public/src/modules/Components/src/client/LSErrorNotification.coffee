
class window.LSNotificationMessageModel extends Backbone.Model
	defaults:
		content: ''
		owner: 'system'
		message: ''
		errorLevel: 'error'

class window.LSNotificatioMessageCollection extends Backbone.Collection
	model: LSNotificationMessageModel

class window.LSAbstractNotificationCounterController extends Backbone.View
	templateTypeId: null
	tagName: 'span'
	count: null
	container: null
	notificationsList: null
	
	initialize: ->
		_.bindAll(@,
			'render')
		@notificationsList = @.options.notificationsList
		@notificationsList.bind('add remove', @render)
		@container = @.options.container
	
	render: ->
		template = _.template($(@templateTypeId).html(), {count: @notificationsList.length})
		$(@el).html template
		counterPopoverText = "#{@notificationsList.length} #{@messageString}"
		unless @notificationsList.length == 1
			counterPopoverText += "s"
		@$('.bv_notificationsCount').tooltip
			title: counterPopoverText
		
		@

class window.LSErrorNotificationCounterController extends window.LSAbstractNotificationCounterController
	templateTypeId: '#LSErrorNotificationCount'
	messageString: 'error'
	
class window.LSWarningNotificationCounterController extends window.LSAbstractNotificationCounterController
	templateTypeId: '#LSWarningNotificationCount'
	messageString: 'warning'

class window.LSInfoNotificationCounterController extends window.LSAbstractNotificationCounterController
	templateTypeId: '#LSInfoNotificationCount'
	messageString: 'status update'

class window.LSMessageController extends Backbone.View
	message: null
	alertType: null
	tagName: 'div'
	
	initialize: ->
		_.bindAll(@,
			'render')
		@message = @options.message
		@alertType = @options.alertType
		
	render: ->
		template = _.template($(@alertType).html(), {message: @message})
		$(@el).html template
		@

class window.LSErrorController extends Backbone.View
	countController: null
	notificationsList: null
	badgeEl: null
	
	initialize: ->
		_.bindAll(@,
			'render')
		@notificationsList = @.options.notificationsList
		@notificationsList.bind('add remove reset', @render)
		@badgeEl = @.options.badgeEl
		@countController = new LSErrorNotificationCounterController({el: @badgeEl, notificationsList: @notificationsList})
		@countController.render()
		
	render: ->
		$(@el).empty()
		@countController.render()
		self = @
		@notificationsList.each (notification) ->
			$(self.el).append new LSMessageController({alertType: "#LSErrorNotificationMessage", message: notification.get('content')}).render().el
		

class window.LSWarningController extends Backbone.View
	countController: null
	notificationsList: null
	badgeEl: null
	
	initialize: ->
		_.bindAll(@,
			'render')
		@notificationsList = @.options.notificationsList
		@notificationsList.bind('add remove reset', @render)
		@badgeEl = @.options.badgeEl
		@countController = new LSWarningNotificationCounterController({el: @badgeEl, notificationsList: @notificationsList})
		@countController.render()
		
	render: ->
		$(@el).empty()
		self = @
		@countController.render()
		@notificationsList.each (notification) ->
			$(self.el).append new LSMessageController({alertType: "#LSWarningNotificationMessage", message: notification.get('content')}).render().el
		

class window.LSInfoController extends Backbone.View
	countController: null
	notificationsList: null
	badgeEl: null
	
	initialize: ->
		_.bindAll(@,
			'render')
		@notificationsList = @.options.notificationsList
		@notificationsList.bind('add remove reset', @render)
		@badgeEl = @.options.badgeEl
		@countController = new LSInfoNotificationCounterController({el: @badgeEl, notificationsList: @notificationsList})
		@countController.render()
		
	render: ->
		$(@el).empty()
		self = @
		@countController.render()
		@notificationsList.each (notification) ->
			$(self.el).append new LSMessageController({alertType: "#LSInfoNotificationMessage", message: notification.get('content')}).render().el
		

class window.LSNotificationController extends Backbone.View
	errorController: null
	warningController: null
	infoController: null
	errorList: null
	warningList: null
	infoList: null
	showPreview: true

	events:
		'click .bv_notificationCountContainer': 'toggleShowNotificationMessages'
	
	initialize: ->
		_.bindAll(@, 
			'render',
			'addError',
			'getErrorCount'
			'getWarningCount',
			'getInfoCount',
			'addNotification',
			'hideMessagePreview',
			'hmp')

		if @options.showPreview?
			@showPreview = @options.showPreview

		@render()
		
		@errorList = new LSNotificatioMessageCollection
		@errorController = new LSErrorController({el: '.bv_errorNotificationMessages', badgeEl: @$('.bv_errorNotificationCountContainer'), notificationsList: @errorList})
		
		@warningList = new LSNotificatioMessageCollection
		@warningController = new LSWarningController({el: '.bv_warningNotificationMessages', badgeEl: @$('.bv_warningNotificationCountContainer'), notificationsList: @warningList})
		
		@infoList = new LSNotificatioMessageCollection
		@infoController = new LSInfoController({el: '.bv_infoNotificationMessages', badgeEl: @$('.bv_infoNotificationCountContainer'), notificationsList: @infoList})
		
	
	addNotification: (notification) ->
		@$('.bv_notificationMessagePreview').html(notification.message)
		switch notification.errorLevel
			when "error" then @addError notification.message
			when "warning" then @addWarning notification.message
			when "info" then @addInfo notification.message
			#else console.log "notification.errorLevel: " + notification.get('errorLevel')

	addNotifications: (owner, notes) ->
		_.each notes, (note) =>
			note.owner = owner
			@addNotification note
	
	addError: (message) ->
		@$('.bv_notificationMessagePreview').hide()
		@$('.bv_notificationMessagePreview').html(message)
		if @showPreview then @$('.bv_notificationMessagePreview').show("slide", @hideMessagePreview)
		@errorController.notificationsList.add(new LSNotificationMessageModel({content: message}))
	
	getErrorCount: ->
		return @errorController.notificationsList.size()
	
	addWarning: (message) ->
		@$('.bv_notificationMessagePreview').hide()
		@$('.bv_notificationMessagePreview').html(message)
		if @showPreview then @$('.bv_notificationMessagePreview').show("slide", @hideMessagePreview)
		@warningController.notificationsList.add(new LSNotificationMessageModel({content: message}))
	
	getWarningCount: ->
		return @warningController.notificationsList.size()
	
	addInfo: (message) ->
		self = @
		@$('.bv_notificationMessagePreview').hide()
		@$('.bv_notificationMessagePreview').html(message)
		if @showPreview then @$('.bv_notificationMessagePreview').show("slide", @hideMessagePreview)
		@infoController.notificationsList.add(new LSNotificationMessageModel({content: message}))
	
	hideMessagePreview: ->
		#$(".bv_notificationMessagePreview").effect("highlight")
		setTimeout(@hmp, 5000)
	
	hmp: ->
		@$( ".bv_notificationMessagePreview" ).fadeOut()

	toggleShowNotificationMessages: =>
		@$('.bv_notificationMessages').toggle()
	
	getInfoCount: ->
		return @infoController.notificationsList.size()

	clearAllNotificiations: ->
		@infoList.reset()
		@warningList.reset()
		@errorList.reset()


	render: ->
		$(@el).empty
		template = _.template($("#LSNotificationView").html())
		$(@el).html template
		
		@$('.bv_notificationCountContainer').tooltip
			title: 'click to expand notification messages'
		@