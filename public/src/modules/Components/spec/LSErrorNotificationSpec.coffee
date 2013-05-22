describe 'Error Notification System Unit Testing', ->
	beforeEach ->
		@fixture = $.clone($('#fixture').get 0)

	afterEach ->
		$('#fixture').remove();
		$('body').append($(@fixture));


	describe 'LSNotificationMessageModel', ->
		describe 'when instantiated', ->
			beforeEach ->
				@message = new LSNotificationMessageModel()
			
			it 'should have defaults', ->
				(expect @message.get('content')).toEqual ''
	
	describe 'LSNotificatioMessageCollection', ->
		describe 'when instantiated', ->
			beforeEach ->
				@messageCollection = new LSNotificatioMessageCollection()
			
			it 'should be empty', ->
				(expect @messageCollection.size()).toEqual 0
	
	xdescribe 'LSAbstractNotificatioMessageController', ->
		describe 'when instantiated', ->
			beforeEach ->
				@abstractMessageController = new LSAbstractNotificatioMessageController()
			
			it 'should exist', ->
				(expect @abstractMessageController)
			
			it 'should have a message collection', ->
				(expect @abstractMessageController.messages)
				
	xdescribe 'LSNotificatioErrorController', ->
		describe 'when instantiated', ->
			beforeEach ->
				@errorMessageController = new LSNotificatioErrorController()
			
			it 'should exist', ->
				(expect @errorMessageController)
			
			it 'should have a message collection', ->
				(expect @errorMessageController.messages)			
				
	
	xdescribe 'LSNotificationController', ->
		describe 'when instantiated', ->
			beforeEach ->
				@notificationController = new LSNotificationController({el: '#fixture'})
			
			it 'should exist', ->
				(expect @notificationController)
			
			it 'should have an empty LSNotificationMessageModels collection', ->
				(expect @notificationController.LSNotificationMessageModels.size()).toEqual(0)
				
			it 'should have an empty warningNotifications collection', ->
				(expect @notificationController.warningNotifications.size()).toEqual(0)
			
			it 'should have an empty infoNotifications collection', ->
				(expect @notificationController.infoNotifications.size()).toEqual(0)
					
	xdescribe 'LSNotificationView', ->
		describe 'when instantiated', ->
			beforeEach ->
				@notificationController = new LSNotificationController({el: '#fixture'})
				@notificationController.render()
			
			it 'should exist', ->
				(expect @notificationController)
			
			it 'should have a div called bv_notificationContainer', ->
				(expect @notificationController.$('.bv_notificationContainer').html()).not.toBeNull()
			
			it 'should have a div called bv_messageNotificationsPanel', ->
				(expect @notificationController.$('.bv_messageNotificationsPanel').html()).not.toBeNull()
			
			it 'should have a span called bv_LSNotificationMessageModelCount with class badge badge-important', ->
				(expect @notificationController.$('.bv_LSNotificationMessageModelCount').html()).not.toBeNull()
				(expect @notificationController.$('.bv_LSNotificationMessageModelCount').hasClass('badge')).toBeTruthy()
				(expect @notificationController.$('.bv_LSNotificationMessageModelCount').hasClass('badge-important')).toBeTruthy()
			
			it 'element called bv_LSNotificationMessageModelCount should be set to 0', ->
				(expect @notificationController.$('.bv_LSNotificationMessageModelCount').html()).toEqual("0")
			
			it 'should have a span called bv_warningNotificationCount with class badge badge-warning', ->
				(expect @notificationController.$('.bv_warningNotificationCount').html()).not.toBeNull()
				(expect @notificationController.$('.bv_warningNotificationCount').hasClass('badge')).toBeTruthy()
				(expect @notificationController.$('.bv_warningNotificationCount').hasClass('badge-warning')).toBeTruthy()
			
			it 'element called bv_LSNotificationMessageModelCount should be set to 0', ->
				(expect @notificationController.$('.bv_warningNotificationCount').html()).toEqual("0")
			
			it 'should have a span called bv_infoNotificationCount with class badge badge-info', ->
				(expect @notificationController.$('.bv_infoNotificationCount').html()).not.toBeNull()
				(expect @notificationController.$('.bv_infoNotificationCount').hasClass('badge')).toBeTruthy()
				(expect @notificationController.$('.bv_infoNotificationCount').hasClass('badge-info')).toBeTruthy()

		

	describe 'when instantiated', ->
		beforeEach ->
			@errorCountController = new LSErrorNotificationCounterController({container: @fixture, notificationsList: new Backbone.Collection()});
			@errorCountController.render()
			
		it 'should a span called bv_notificationsCount', ->
			(expect @errorCountController.$('.badge-important').length).toEqual 1
		
		it 'the number of error notifications should display 0 ', ->
			(expect @errorCountController.$('.badge-important').html()).toContain("0")
		
		it 'the number of error notifications should display 1 after adding an error notification ', ->
			@errorCountController.notificationsList.add(new LSNotificationMessageModel())
			(expect @errorCountController.$('.badge-important').html()).toContain("1")


	describe 'LSErrorController Unit Testing', ->

		beforeEach ->
			@fixture = $.clone($('#fixture').get 0)

		afterEach ->
			$('#fixture').remove();
			$('body').append($(@fixture));

		describe 'when instantiated', ->
			beforeEach ->
				@errorController = new LSErrorController({el: '#fixture', notificationsList: new Backbone.Collection()});
				@errorController.render

			it 'should be empty initially', ->
				(expect @errorController.$('.alert-error').length).toEqual 0

			it 'should contain an .alert-error div when a notification message is added to the notification list', ->
				@errorController.notificationsList.add(new LSNotificationMessageModel({message: 'foo'}))
				(expect @errorController.$('.alert-error').length).toEqual 1

			xit 'should display the message in an .alert-error div when a notification message is added to the notification list', ->
				@errorController.notificationsList.add(new LSNotificationMessageModel({message: 'foo'}))
				console.log @errorController.$('.alert-error').html()
				(expect $(@errorController.$('.alert-error')[0]).html()).toContain 'foo'
		
		


	describe 'LSNotificationMessageModel Model', ->
	
		describe 'when instantiated', ->
			beforeEach ->
				@eNot = new LSNotificationMessageModel();
			
			it 'should have default attributes', ->
				(expect @eNot.get('owner')).toEqual 'system'
				(expect @eNot.get('errorLevel')).toEqual 'error'
				(expect @eNot.get('message')).toEqual ''
	
	describe 'LSNotificationMessageModel List', ->
	
		beforeEach ->
			@eNot1 = new LSNotificationMessageModel()
			@eNot2 = new LSNotificationMessageModel({owner: 'system', errorLevel: 'error', message: 'system error 2'})
			@eNot3 = new LSNotificationMessageModel({owner: 'system', errorLevel: 'warning', message: 'system warning 1'})
			@eNot4 = new LSNotificationMessageModel({owner: 'testModule', errorLevel: 'error', message: 'testModule error 1'})
			@eNot5 = new LSNotificationMessageModel({owner: 'testModule', errorLevel: 'warning', message: 'testModule warning 1'})
			@eNotList = new LSNotificatioMessageCollection([ @eNot1, @eNot2, @eNot3, @eNot4]);
			@eNotList.add(@eNot5)
		
			describe 'can return all messages for an owner', ->
				it 'Should return three system errors', ->
					(expect @eNotList.length).toEqual 5
					(expect @eNotList.getMessagesForOwner('system').length).toEqual 3 
					(expect @eNotList.getMessagesForOwner('testModule').length).toEqual 2
			
			describe 'can return all messages of an errorLevel', ->
				it 'Should return three system errors', ->
					(expect @eNotList.length).toEqual 5
					(expect @eNotList.getMessagesOfLevel('error').length).toEqual 3
					(expect @eNotList.getMessagesOfLevel('warning').length).toEqual 2
	
			describe 'can remove all messages for an owner', ->
				it 'Should remove all errors owned by system', ->
					(expect @eNotList.length).toEqual 5
					@eNotList.removeMessagesForOwner 'system'
					(expect @eNotList.length).toEqual 2
					@eNotList.removeMessagesForOwner 'testModule'
					(expect @eNotList.length).toEqual 0
					
			describe 'can remove all messages', -> # bad test, just tests Backbone.Collection, but it's all new to me
				it 'Should remove all errors owned by system', ->
					(expect @eNotList.length).toEqual 5
					@eNotList.reset
					(expect @eNotList.length).toEqual 0
		
	describe 'Error Notification List Controller', ->
		beforeEach ->
			@eNotView = new LSNotificationController({el: '#fixture'})
	
		describe 'when new with no errors', ->
			it 'should hide show/hide control', ->
				(expect @eNotView.$('.controls').is(':visible')).toBeFalsy
			
			it 'should have an errorList collection that is initially empty', ->
				(expect @eNotView.errorList.size()).toEqual 0
			
			it 'should have a warningList collection that is initially empty', ->
				(expect @eNotView.warningList.size()).toEqual 0
			
			it 'should have an infoList collection that is initially empty', ->
				(expect @eNotView.infoList.size()).toEqual 0
			
			xdescribe 'error count controller', ->
				it 'should contain a span with the number of errror messages called bv_notificationsCount', -> 	
					(expect @eNotView.$('.bv_notificationsCount .badge-important').length).toEqual 1
					
		describe 'when we add three errror messages', ->
			beforeEach ->
				@eNotView.addNotification(({owner: 'system', errorLevel: 'error', message: ''}))
				@eNotView.addNotification(({owner: 'system', errorLevel: 'error', message: 'system error 2'}))
				@eNotView.addNotification(({owner: 'system', errorLevel: 'error', message: 'testModule error 1'}))
				
				@eNotView.addNotification(({owner: 'system', errorLevel: 'warning', message: 'system warning 1'}))
				@eNotView.addNotification(({owner: 'system', errorLevel: 'warning', message: 'system warning 2'}))
				
				@eNotView.addNotification(({owner: 'system', errorLevel: 'info', message: 'testModule info 1'}))
				
			it 'should have 3 alert-error divs', ->
				console.log "@eNotView.getErrorCount(): " + @eNotView.getErrorCount()
				(expect @eNotView.getInfoCount()).toEqual 1
				(expect @eNotView.getWarningCount()).toEqual 2
				(expect @eNotView.getErrorCount()).toEqual 3
				(expect @eNotView.$('.alert-error').length).toEqual 3
				
			xit 'should contain error message', ->
				(expect $(@eNotView.$('.alert-error')[1]).html()).toContain 'system error 2'                  

			xit 'should set class of notification according to errorLevel', ->
				(expect $(@eNotView.$('.bv_errorNotificationCountContainer')[0]).hasClass('alert-error')).toBeTruthy()
				(expect $(@eNotView.$('.bv_warningNotificationCountContainer')[0]).hasClass('alert-warning')).toBeTruthy()
				(expect $(@eNotView.$('.bv_infoNotificationCountContainer')[0]).hasClass('alert-info')).toBeTruthy()                           
			
			xit 'should show show/hide control', ->
				(expect @eNotView.$('.controls').is(':visible')).toBeTruthy()
			
			it 'should display the number of error messages', ->
				(expect @eNotView.$('.bv_errorNotificationCountContainer .bv_notificationsCount').html()).toContain '3'

		describe 'when we add notifications as an array', ->
			beforeEach ->
				notes = [
					{errorLevel: 'error', message: ''}
					{errorLevel: 'error', message: 'system error 2'}
					{errorLevel: 'error', message: 'testModule error 1'}
					{errorLevel: 'warning', message: 'system warning 1'}
					{errorLevel: 'warning', message: 'system warning 2'}
					{errorLevel: 'info', message: 'testModule info 1'}
				]
				@eNotView.addNotifications 'testOwner', notes
			it 'should have 3 alert-error divs', ->
				console.log "@eNotView.getErrorCount(): " + @eNotView.getErrorCount()
				(expect @eNotView.getInfoCount()).toEqual 1
				(expect @eNotView.getWarningCount()).toEqual 2
				(expect @eNotView.getErrorCount()).toEqual 3
				(expect @eNotView.$('.alert-error').length).toEqual 3


		describe 'when we clear all errors from errorlist', ->
			beforeEach ->
				notes = [
					{errorLevel: 'error', message: ''}
					{errorLevel: 'error', message: 'system error 2'}
					{errorLevel: 'error', message: 'testModule error 1'}
					{errorLevel: 'warning', message: 'system warning 1'}
					{errorLevel: 'warning', message: 'system warning 2'}
					{errorLevel: 'info', message: 'testModule info 1'}
				]
				@eNotView.addNotifications 'testOwner', notes
				@eNotView.clearAllNotificiations()
			
			it 'should not show any error messages', ->
				(expect @eNotView.$('.alert-error').length).toEqual 0

			it 'should reset error counts', ->
				(expect @eNotView.$('.bv_errorNotificationCountContainer .bv_notificationsCount').html()).toContain '0'


			xdescribe 'when we clear system errors from errorlist', ->
				#TODO implement this feature
				it 'should not show system errors', ->
					@eNotList.removeMessagesForOwner 'system'
					(expect @eNotView.$('.notifications div').length).toEqual 2
			

