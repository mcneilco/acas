(function() {
  describe('Error Notification System Unit Testing', function() {
    beforeEach(function() {
      return this.fixture = $.clone($('#fixture').get(0));
    });
    afterEach(function() {
      $('#fixture').remove();
      return $('body').append($(this.fixture));
    });
    describe('LSNotificationMessageModel', function() {
      return describe('when instantiated', function() {
        beforeEach(function() {
          return this.message = new LSNotificationMessageModel();
        });
        return it('should have defaults', function() {
          return (expect(this.message.get('content'))).toEqual('');
        });
      });
    });
    describe('LSNotificatioMessageCollection', function() {
      return describe('when instantiated', function() {
        beforeEach(function() {
          return this.messageCollection = new LSNotificatioMessageCollection();
        });
        return it('should be empty', function() {
          return (expect(this.messageCollection.size())).toEqual(0);
        });
      });
    });
    xdescribe('LSAbstractNotificatioMessageController', function() {
      return describe('when instantiated', function() {
        beforeEach(function() {
          return this.abstractMessageController = new LSAbstractNotificatioMessageController();
        });
        it('should exist', function() {
          return expect(this.abstractMessageController);
        });
        return it('should have a message collection', function() {
          return expect(this.abstractMessageController.messages);
        });
      });
    });
    xdescribe('LSNotificatioErrorController', function() {
      return describe('when instantiated', function() {
        beforeEach(function() {
          return this.errorMessageController = new LSNotificatioErrorController();
        });
        it('should exist', function() {
          return expect(this.errorMessageController);
        });
        return it('should have a message collection', function() {
          return expect(this.errorMessageController.messages);
        });
      });
    });
    xdescribe('LSNotificationController', function() {
      return describe('when instantiated', function() {
        beforeEach(function() {
          return this.notificationController = new LSNotificationController({
            el: '#fixture'
          });
        });
        it('should exist', function() {
          return expect(this.notificationController);
        });
        it('should have an empty LSNotificationMessageModels collection', function() {
          return (expect(this.notificationController.LSNotificationMessageModels.size())).toEqual(0);
        });
        it('should have an empty warningNotifications collection', function() {
          return (expect(this.notificationController.warningNotifications.size())).toEqual(0);
        });
        return it('should have an empty infoNotifications collection', function() {
          return (expect(this.notificationController.infoNotifications.size())).toEqual(0);
        });
      });
    });
    xdescribe('LSNotificationView', function() {
      return describe('when instantiated', function() {
        beforeEach(function() {
          this.notificationController = new LSNotificationController({
            el: '#fixture'
          });
          return this.notificationController.render();
        });
        it('should exist', function() {
          return expect(this.notificationController);
        });
        it('should have a div called bv_notificationContainer', function() {
          return (expect(this.notificationController.$('.bv_notificationContainer').html())).not.toBeNull();
        });
        it('should have a div called bv_messageNotificationsPanel', function() {
          return (expect(this.notificationController.$('.bv_messageNotificationsPanel').html())).not.toBeNull();
        });
        it('should have a span called bv_LSNotificationMessageModelCount with class badge badge-important', function() {
          (expect(this.notificationController.$('.bv_LSNotificationMessageModelCount').html())).not.toBeNull();
          (expect(this.notificationController.$('.bv_LSNotificationMessageModelCount').hasClass('badge'))).toBeTruthy();
          return (expect(this.notificationController.$('.bv_LSNotificationMessageModelCount').hasClass('badge-important'))).toBeTruthy();
        });
        it('element called bv_LSNotificationMessageModelCount should be set to 0', function() {
          return (expect(this.notificationController.$('.bv_LSNotificationMessageModelCount').html())).toEqual("0");
        });
        it('should have a span called bv_warningNotificationCount with class badge badge-warning', function() {
          (expect(this.notificationController.$('.bv_warningNotificationCount').html())).not.toBeNull();
          (expect(this.notificationController.$('.bv_warningNotificationCount').hasClass('badge'))).toBeTruthy();
          return (expect(this.notificationController.$('.bv_warningNotificationCount').hasClass('badge-warning'))).toBeTruthy();
        });
        it('element called bv_LSNotificationMessageModelCount should be set to 0', function() {
          return (expect(this.notificationController.$('.bv_warningNotificationCount').html())).toEqual("0");
        });
        return it('should have a span called bv_infoNotificationCount with class badge badge-info', function() {
          (expect(this.notificationController.$('.bv_infoNotificationCount').html())).not.toBeNull();
          (expect(this.notificationController.$('.bv_infoNotificationCount').hasClass('badge'))).toBeTruthy();
          return (expect(this.notificationController.$('.bv_infoNotificationCount').hasClass('badge-info'))).toBeTruthy();
        });
      });
    });
    describe('when instantiated', function() {
      beforeEach(function() {
        this.errorCountController = new LSErrorNotificationCounterController({
          container: this.fixture,
          notificationsList: new Backbone.Collection()
        });
        return this.errorCountController.render();
      });
      it('should a span called bv_notificationsCount', function() {
        return (expect(this.errorCountController.$('.badge-important').length)).toEqual(1);
      });
      it('the number of error notifications should display 0 ', function() {
        return (expect(this.errorCountController.$('.badge-important').html())).toContain("0");
      });
      return it('the number of error notifications should display 1 after adding an error notification ', function() {
        this.errorCountController.notificationsList.add(new LSNotificationMessageModel());
        return (expect(this.errorCountController.$('.badge-important').html())).toContain("1");
      });
    });
    describe('LSErrorController Unit Testing', function() {
      beforeEach(function() {
        return this.fixture = $.clone($('#fixture').get(0));
      });
      afterEach(function() {
        $('#fixture').remove();
        return $('body').append($(this.fixture));
      });
      return describe('when instantiated', function() {
        beforeEach(function() {
          this.errorController = new LSErrorController({
            el: '#fixture',
            notificationsList: new Backbone.Collection()
          });
          return this.errorController.render;
        });
        it('should be empty initially', function() {
          return (expect(this.errorController.$('.alert-error').length)).toEqual(0);
        });
        it('should contain an .alert-error div when a notification message is added to the notification list', function() {
          this.errorController.notificationsList.add(new LSNotificationMessageModel({
            message: 'foo'
          }));
          return (expect(this.errorController.$('.alert-error').length)).toEqual(1);
        });
        return xit('should display the message in an .alert-error div when a notification message is added to the notification list', function() {
          this.errorController.notificationsList.add(new LSNotificationMessageModel({
            message: 'foo'
          }));
          console.log(this.errorController.$('.alert-error').html());
          return (expect($(this.errorController.$('.alert-error')[0]).html())).toContain('foo');
        });
      });
    });
    describe('LSNotificationMessageModel Model', function() {
      return describe('when instantiated', function() {
        beforeEach(function() {
          return this.eNot = new LSNotificationMessageModel();
        });
        return it('should have default attributes', function() {
          (expect(this.eNot.get('owner'))).toEqual('system');
          (expect(this.eNot.get('errorLevel'))).toEqual('error');
          return (expect(this.eNot.get('message'))).toEqual('');
        });
      });
    });
    describe('LSNotificationMessageModel List', function() {
      return beforeEach(function() {
        this.eNot1 = new LSNotificationMessageModel();
        this.eNot2 = new LSNotificationMessageModel({
          owner: 'system',
          errorLevel: 'error',
          message: 'system error 2'
        });
        this.eNot3 = new LSNotificationMessageModel({
          owner: 'system',
          errorLevel: 'warning',
          message: 'system warning 1'
        });
        this.eNot4 = new LSNotificationMessageModel({
          owner: 'testModule',
          errorLevel: 'error',
          message: 'testModule error 1'
        });
        this.eNot5 = new LSNotificationMessageModel({
          owner: 'testModule',
          errorLevel: 'warning',
          message: 'testModule warning 1'
        });
        this.eNotList = new LSNotificatioMessageCollection([this.eNot1, this.eNot2, this.eNot3, this.eNot4]);
        this.eNotList.add(this.eNot5);
        describe('can return all messages for an owner', function() {
          return it('Should return three system errors', function() {
            (expect(this.eNotList.length)).toEqual(5);
            (expect(this.eNotList.getMessagesForOwner('system').length)).toEqual(3);
            return (expect(this.eNotList.getMessagesForOwner('testModule').length)).toEqual(2);
          });
        });
        describe('can return all messages of an errorLevel', function() {
          return it('Should return three system errors', function() {
            (expect(this.eNotList.length)).toEqual(5);
            (expect(this.eNotList.getMessagesOfLevel('error').length)).toEqual(3);
            return (expect(this.eNotList.getMessagesOfLevel('warning').length)).toEqual(2);
          });
        });
        describe('can remove all messages for an owner', function() {
          return it('Should remove all errors owned by system', function() {
            (expect(this.eNotList.length)).toEqual(5);
            this.eNotList.removeMessagesForOwner('system');
            (expect(this.eNotList.length)).toEqual(2);
            this.eNotList.removeMessagesForOwner('testModule');
            return (expect(this.eNotList.length)).toEqual(0);
          });
        });
        return describe('can remove all messages', function() {
          return it('Should remove all errors owned by system', function() {
            (expect(this.eNotList.length)).toEqual(5);
            this.eNotList.reset;
            return (expect(this.eNotList.length)).toEqual(0);
          });
        });
      });
    });
    return describe('Error Notification List Controller', function() {
      beforeEach(function() {
        return this.eNotView = new LSNotificationController({
          el: '#fixture'
        });
      });
      describe('when new with no errors', function() {
        it('should hide show/hide control', function() {
          return (expect(this.eNotView.$('.controls').is(':visible'))).toBeFalsy;
        });
        it('should have an errorList collection that is initially empty', function() {
          return (expect(this.eNotView.errorList.size())).toEqual(0);
        });
        it('should have a warningList collection that is initially empty', function() {
          return (expect(this.eNotView.warningList.size())).toEqual(0);
        });
        it('should have an infoList collection that is initially empty', function() {
          return (expect(this.eNotView.infoList.size())).toEqual(0);
        });
        return xdescribe('error count controller', function() {
          return it('should contain a span with the number of errror messages called bv_notificationsCount', function() {
            return (expect(this.eNotView.$('.bv_notificationsCount .badge-important').length)).toEqual(1);
          });
        });
      });
      describe('when we add three errror messages', function() {
        beforeEach(function() {
          this.eNotView.addNotification({
            owner: 'system',
            errorLevel: 'error',
            message: ''
          });
          this.eNotView.addNotification({
            owner: 'system',
            errorLevel: 'error',
            message: 'system error 2'
          });
          this.eNotView.addNotification({
            owner: 'system',
            errorLevel: 'error',
            message: 'testModule error 1'
          });
          this.eNotView.addNotification({
            owner: 'system',
            errorLevel: 'warning',
            message: 'system warning 1'
          });
          this.eNotView.addNotification({
            owner: 'system',
            errorLevel: 'warning',
            message: 'system warning 2'
          });
          return this.eNotView.addNotification({
            owner: 'system',
            errorLevel: 'info',
            message: 'testModule info 1'
          });
        });
        it('should have 3 alert-error divs', function() {
          console.log("@eNotView.getErrorCount(): " + this.eNotView.getErrorCount());
          (expect(this.eNotView.getInfoCount())).toEqual(1);
          (expect(this.eNotView.getWarningCount())).toEqual(2);
          (expect(this.eNotView.getErrorCount())).toEqual(3);
          return (expect(this.eNotView.$('.alert-error').length)).toEqual(3);
        });
        xit('should contain error message', function() {
          return (expect($(this.eNotView.$('.alert-error')[1]).html())).toContain('system error 2');
        });
        xit('should set class of notification according to errorLevel', function() {
          (expect($(this.eNotView.$('.bv_errorNotificationCountContainer')[0]).hasClass('alert-error'))).toBeTruthy();
          (expect($(this.eNotView.$('.bv_warningNotificationCountContainer')[0]).hasClass('alert-warning'))).toBeTruthy();
          return (expect($(this.eNotView.$('.bv_infoNotificationCountContainer')[0]).hasClass('alert-info'))).toBeTruthy();
        });
        xit('should show show/hide control', function() {
          return (expect(this.eNotView.$('.controls').is(':visible'))).toBeTruthy();
        });
        return it('should display the number of error messages', function() {
          return (expect(this.eNotView.$('.bv_errorNotificationCountContainer .bv_notificationsCount').html())).toContain('3');
        });
      });
      describe('when we add notifications as an array', function() {
        beforeEach(function() {
          var notes;

          notes = [
            {
              errorLevel: 'error',
              message: ''
            }, {
              errorLevel: 'error',
              message: 'system error 2'
            }, {
              errorLevel: 'error',
              message: 'testModule error 1'
            }, {
              errorLevel: 'warning',
              message: 'system warning 1'
            }, {
              errorLevel: 'warning',
              message: 'system warning 2'
            }, {
              errorLevel: 'info',
              message: 'testModule info 1'
            }
          ];
          return this.eNotView.addNotifications('testOwner', notes);
        });
        return it('should have 3 alert-error divs', function() {
          console.log("@eNotView.getErrorCount(): " + this.eNotView.getErrorCount());
          (expect(this.eNotView.getInfoCount())).toEqual(1);
          (expect(this.eNotView.getWarningCount())).toEqual(2);
          (expect(this.eNotView.getErrorCount())).toEqual(3);
          return (expect(this.eNotView.$('.alert-error').length)).toEqual(3);
        });
      });
      return describe('when we clear all errors from errorlist', function() {
        beforeEach(function() {
          var notes;

          notes = [
            {
              errorLevel: 'error',
              message: ''
            }, {
              errorLevel: 'error',
              message: 'system error 2'
            }, {
              errorLevel: 'error',
              message: 'testModule error 1'
            }, {
              errorLevel: 'warning',
              message: 'system warning 1'
            }, {
              errorLevel: 'warning',
              message: 'system warning 2'
            }, {
              errorLevel: 'info',
              message: 'testModule info 1'
            }
          ];
          this.eNotView.addNotifications('testOwner', notes);
          return this.eNotView.clearAllNotificiations();
        });
        it('should not show any error messages', function() {
          return (expect(this.eNotView.$('.alert-error').length)).toEqual(0);
        });
        it('should reset error counts', function() {
          return (expect(this.eNotView.$('.bv_errorNotificationCountContainer .bv_notificationsCount').html())).toContain('0');
        });
        return xdescribe('when we clear system errors from errorlist', function() {
          return it('should not show system errors', function() {
            this.eNotList.removeMessagesForOwner('system');
            return (expect(this.eNotView.$('.notifications div').length)).toEqual(2);
          });
        });
      });
    });
  });

}).call(this);
