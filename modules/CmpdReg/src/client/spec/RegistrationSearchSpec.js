$(function () {
	describe('Registration Search Module Unit Testing', function () {
		
		
		beforeEach(function () {
			this.fixture = $.clone($('#fixture').get(0));
		});
		
		afterEach(function () {
			$('#fixture').remove();
			$('body').append($(this.fixture));
		});
		
		/***********************************************/
        describe('RegistrationSearch Model', function() {
          beforeEach(function() {
             this.rsModel = new RegistrationSearch(); 
          });
          it('should not have default values', function() {
             //Instead of usual practice of setting default values = '',
             //we leave them null to let validation of '' values to work
             //and let us still reset the model with clear()
             expect(this.rsModel.get('molStructure')).toBeUndefined();
             expect(this.rsModel.get('corpName')).toBeUndefined();
          });
          it('if set strucure and not corpName, should update', function() {
             this.rsModel.set({molStructure: 'my mol', corpName: ''});
             expect(this.rsModel.get('molStructure')).toEqual('my mol');
          });
          it('if set corpName and not molStructure, should update', function() {
             this.rsModel.set({molStructure: null, corpName: 'cname'});
             expect(this.rsModel.get('corpName')).toEqual('cname');
          });
          it('if corpName and struct both set, should not update', function() {
             this.rsModel.set({molStructure: 'my mol', corpName: 'cname'});
             expect(this.rsModel.get('molStructure')).toBeUndefined();
             expect(this.rsModel.get('corpName')).toBeUndefined();
          });
          it('if corpName and struct both set empty string should not update', function() {
             this.rsModel.set({molStructure: null, corpName: ''});
             expect(this.rsModel.get('molStructure')).toBeUndefined();
             expect(this.rsModel.get('corpName')).toBeUndefined();
          });
       });   
        
        
		
		describe('Registration Search Controller', function () {
		
			beforeEach(function () {
				this.rsController = new RegistrationSearchController({
                    el: "#RegistrationSearchView"
                });
                this.rsController.render();
			});
			
			describe('when rendered', function () {
                it('should be hidden new first created',function() {
                   expect($(this.rsController.el).is(':visible')).toBeFalsy(); 
                });
			});
            describe('operations',function() {
                beforeEach(function() {
                    this.rsController.show();
                });
                it('Should be shown when used', function() {
                   expect($(this.rsController.el).is(':visible')).toBeTruthy(); 
                });
				xit('Should have a marvinsktech that works, but is intitially empty', function () {
					runs( function() {
						this.rsController.loadMarvin();		
					});
					waits(1000);
					runs( function() {						
						expect(document.registrationSearch_marvinSketch.getMol('smiles')).toEqual('fred');
						document.registrationSearch_marvinSketch.setMol("C1=CC2=CC3=C(C=CC=C3)C=C2C=C1");
						document.registrationSearch_marvinSketch.setMol("C1=CC2=CC3=C(C=CC=C3)C=C2C=C1");
						expect(document.registrationSearch_marvinSketch.getMol('smiles')).toEqual("C1=CC2=CC3=C(C=CC=C3)C=C2C=C1");
					});
				});
                it('should send content when next pushed with corpName filled in', function() {
                    // i don't how to test trigger sent, sure it hides
					runs( function() {
						this.rsController.loadMarvin();		
					});
                    
					waits(700);
					runs( function() {						
                        this.rsController.$('.corpName').val('cname2');
                        this.rsController.$('.nextButton').click();
                        expect($(this.rsController.el).is(':visible')).toBeFalsy(); 
                    });
                });
                xit('Should show error when next pushed with no molStructure and no corpName', function() {
					runs( function() {
						this.rsController.loadMarvin();		
					});
					waits(700);
					runs( function() {						
						expect(document.registrationSearch_marvinSketch.getMol('smiles')).toEqual('');
                        this.rsController.$('.nextButton').click();
                        expect($(this.rsController.el).is(':visible')).toBeTruthy(); 

                        expect(this.rsController.$(".corpName").hasClass('input_error')).toBeTruthy();
					});
                });
                xit('should show error when next pushed and both molStructure and corpName filled', function() {
					runs( function() {
						this.rsController.loadMarvin();		
					});
					waits(700);
					runs( function() {						
						expect(document.registrationSearch_marvinSketch.getMol('smiles')).toEqual('');
						document.registrationSearch_marvinSketch.setMol("C1=CC2=CC3=C(C=CC=C3)C=C2C=C1");
						document.registrationSearch_marvinSketch.setMol("C1=CC2=CC3=C(C=CC=C3)C=C2C=C1");
                        this.rsController.$('.corpName').val('cname3');
                        this.rsController.$('.nextButton').click();
                        expect($(this.rsController.el).is(':visible')).toBeTruthy(); 
                        expect(this.rsController.$(".corpName").hasClass('input_error')).toBeTruthy();
					});
                });
                it('should hide and reset on cancel', function() {
					runs( function() {
						this.rsController.loadMarvin();		
					});
					waits(700);
					runs( function() {						
                        this.rsController.$('.corpName').val('cname');
                        this.rsController.$('.cancelButton').click();
                        expect($(this.rsController.el).is(':visible')).toBeFalsy(); 
                        expect(this.rsController.$('.corpName').val()).toEqual('');
                    });
                });

            });
            
        });
        describe('Registration Search Controller launched with corpName', function () {
		
			it('when initialized with corpName', function () {
				this.rsController = new RegistrationSearchController({
                    el: "#RegistrationSearchView",
                    corpName: 'CMPD-1111-Cl'
                });
                this.rsController.render();
                this.rsController.show();
                expect(this.rsController.$('.corpName').val()).toEqual('CMPD-1111-Cl');
            });
        });

    });
});



