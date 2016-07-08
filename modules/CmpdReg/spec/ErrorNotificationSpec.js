$(function () {
	describe('Error Notification System Unit Testing', function () {
		
		/* 
		 * We have to take care manually of the DOM fixture
		 * This should be put in a separate file like SpecHelper.js
		 */
		 
		/* The styling for the fixture elements is in the NewCmpdReg.css */
		
		beforeEach(function () {
			this.fixture = $.clone($('#fixture').get(0));
		});
		
		afterEach(function () {
			$('#fixture').remove();
			$('body').append($(this.fixture));
		});
		
		describe('ErrorNotification Model', function() {
		
			describe('when instantiated', function() {
				beforeEach(function () {
					this.eNot = new ErrorNotification();
				});
				it( 'should have default attributes', function() {
					expect(this.eNot.get('owner')).toEqual('system');
					expect(this.eNot.get('errorLevel')).toEqual('error');
					expect(this.eNot.get('message')).toEqual('');					
				});
				
			});
		
		
		});
		describe('ErrorNotification List', function () {
		
			beforeEach(function () {
				this.eNot1 = new ErrorNotification();
				this.eNot2 = new ErrorNotification({owner: 'system', errorLevel: 'error', message: 'system error 2'});
				this.eNot3 = new ErrorNotification({owner: 'system', errorLevel: 'warning', message: 'system warning 1'});
				this.eNot4 = new ErrorNotification({owner: 'testModule', errorLevel: 'error', message: 'testModule error 1'});
				this.eNot5 = new ErrorNotification({owner: 'testModule', errorLevel: 'warning', message: 'testModule warning 1'});
				this.eNotList = new ErrorNotificationList([
					this.eNot1, this.eNot2, this.eNot3, this.eNot4 
				]);
				this.eNotList.add(this.eNot5);
			});
			
			describe('can return all messages for an owner', function () {
				it('Should return three system errors', function () {
					expect(this.eNotList.length).toEqual(5);
					expect(this.eNotList.getMessagesForOwner('system').length).toEqual(3);
					expect(this.eNotList.getMessagesForOwner('testModule').length).toEqual(2);
				});			
			});
			describe('can return all messages of an errorLevel', function () {
				it('Should return three system errors', function () {
					expect(this.eNotList.length).toEqual(5);
					expect(this.eNotList.getMessagesOfLevel('error').length).toEqual(3);
					expect(this.eNotList.getMessagesOfLevel('warning').length).toEqual(2);
				});			
			});
			describe('can remove all messages for an owner', function () {
				it('Should remove all errors owned by system', function () {
					expect(this.eNotList.length).toEqual(5);
					this.eNotList.removeMessagesForOwner('system');
					expect(this.eNotList.length).toEqual(2);
					this.eNotList.removeMessagesForOwner('testModule');
					expect(this.eNotList.length).toEqual(0);
				});			
			});
			describe('can remove all messages', function () { // bad test, just tests Backbone.Collection, but it's all new to me
				it('Should remove all errors owned by system', function () {
					expect(this.eNotList.length).toEqual(5);
					this.eNotList.reset();
					expect(this.eNotList.length).toEqual(0);
				});			
			});
		});
		describe('Error Notification List Controller', function() {
			beforeEach(function () {
				this.eNotList = new ErrorNotificationList();
				this.eNotView = new ErrorNotificationListController({el: '#ErrrorNotificationListView', collection: this.eNotList});
			});
			describe('when new with no errors', function() {
                it('should hide show/hide control', function() {
                    expect(this.eNotView.$('.controls').is(':visible')).toBeFalsy();
                });
            });
			describe('when we add five errrors isotopes', function () {
				beforeEach(function() {
					this.eNotList.add( new ErrorNotification() );
					this.eNotList.add( new ErrorNotification({owner: 'system', errorLevel: 'error', message: 'system error 2'}));
					this.eNotList.add( new ErrorNotification({owner: 'system', errorLevel: 'warning', message: 'system warning 1'}));
					this.eNotList.add( new ErrorNotification({owner: 'testModule', errorLevel: 'error', message: 'testModule error 1'}));
					this.eNotList.add( new ErrorNotification({owner: 'testModule', errorLevel: 'info', message: 'testModule info 1'}));
				});
				it('should have 5 divs', function () {
					expect(this.eNotList.length).toEqual(5);
					expect(this.eNotView.$('.notifications div').length).toEqual(5);
				});
				it('should contain error message', function() {
					expect($(this.eNotView.$('.notifications div')[1]).html()).toEqual('system error 2');			
				});
				it('should set class of notification according to errorLevel', function() {
					expect($(this.eNotView.$('.notifications div')[1]).hasClass('errorNotification_error')).toBeTruthy();
					expect($(this.eNotView.$('.notifications div')[2]).hasClass('errorNotification_warning')).toBeTruthy();
					expect($(this.eNotView.$('.notifications div')[4]).hasClass('errorNotification_info')).toBeTruthy();				
				});
                it('should show show/hide control', function() {
                    expect(this.eNotView.$('.controls').is(':visible')).toBeTruthy();
                });
                it('should display the number of messages', function() {
                    expect(this.eNotView.$('.messageCount').html()).toContain('5');
                });
				describe('when we clear all errors from errorlist', function() {
                    beforeEach( function() {
						this.eNotList.reset();
                    })
					it('should not show any errors', function() {
						expect(this.eNotList.length).toEqual(0);
						expect(this.eNotView.$('.notifications div').length).toEqual(0);
					});
                    it('should hide show/hide control', function() {
                        expect(this.eNotView.$('.controls').is(':visible')).toBeFalsy();
                    });
				});
				describe('when we clear system errors from errorlist', function() {
					it('should not show system errors', function() {
						this.eNotList.removeMessagesForOwner('system');
						expect(this.eNotView.$('.notifications div').length).toEqual(2);
					});
				});
                describe('when user asks to hide errors hidden', function() {
                    it('shoud hide errors, but not controls', function() {
                        this.eNotView.$('.showHideButton').click();
                        expect(this.eNotView.$('.notifications').is(':visible')).toBeFalsy();
                        expect(this.eNotView.$('.controls').is(':visible')).toBeTruthy();
                    });
                })
			});					
		
		});
	});
});