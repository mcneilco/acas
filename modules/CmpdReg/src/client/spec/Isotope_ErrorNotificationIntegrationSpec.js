$(function () {
	describe('Isotope Integrated with Error Notification System Testing', function () {
		
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

		describe('When setup isotope form connected to errornotification system', function() {
			beforeEach(function() {
				this.isotopeList = new Isotopes(),
				this.isotopeSelectController = new IsotopeSelectController({el: '#LotForm_SaltFormIsotopeSelect-1View', collection: this.isotopeList});			
				this.isotopeSelectController = new IsotopeSelectController({el: '#LotForm_SaltFormIsotopeSelect-2View', collection: this.isotopeList});			
				this.newIsotopeController = new NewIsotopeController({el: '#NewIsotopeView', collection: this.isotopeList});
	
				this.eNotList = new ErrorNotificationList();
				this.eNotView = new ErrorNotificationListController({el: '#ErrrorNotificationListView', collection: this.eNotList});
	
				this.newIsotopeController.bind('notifyError', this.eNotList.add);
				this.newIsotopeController.bind('clearErrors', this.eNotList.removeMessagesForOwner);
				
				this.newIsotopeController.render();
			});
			describe('When isotope form is filled out', function() {
				beforeEach(function() {
					this.newIsotopeController.$('.isotope_name').val('isoName 1');
					this.newIsotopeController.$('.isotope_abbrev').val('isoAbbrev1');
					this.newIsotopeController.$('.isotope_massChange').val('1');				
				});
				describe('When correct isotope is saved', function() {
					it('should add a new isotope to the collection', function() {
						runs(function() {
                            expect(this.isotopeList.length).toEqual(0);
                            this.newIsotopeController.$('.saveNewIsotopeButton').click();
                        });
                        waitIfServer();
						runs(function() {
                            expect(this.isotopeList.length).toEqual(1);
                            expect($('#LotForm_SaltFormIsotopeSelect-1View option').length).toEqual(2);
							if(window.configuration.metaLot.includeAbbrevInIsoSaltOption) {
	                            expect($('#LotForm_SaltFormIsotopeSelect-1View option')[1].innerHTML).toEqual('SI: savedIsotope');
	                        } else {
	                            expect($('#LotForm_SaltFormIsotopeSelect-1View option')[1].innerHTML).toEqual('savedIsotope');
	                        }
                        });
					});
				
				});
				describe('When isotope saved with string for weight', function() {
					it('should not add a new isotope to the collection', function() {
						this.newIsotopeController.$('.isotope_massChange').val('fred');
						this.newIsotopeController.$('.saveNewIsotopeButton').click();
						expect(this.isotopeList.length).toEqual(0);
						expect($('#LotForm_SaltFormIsotopeSelect-1View option').length).toEqual(1);
						});
					it('should add an error notification', function() {
						this.newIsotopeController.$('.isotope_massChange').val('fred');
						this.newIsotopeController.$('.saveNewIsotopeButton').click();
						expect(this.isotopeList.length).toEqual(0);
						expect(this.eNotView.$('.notifications div').length).toEqual(1);
					});
				});
				describe('When isotope saved with string for weight and space in abbrev', function() {
					it('should add two error notices', function() {
						this.newIsotopeController.$('.isotope_abbrev').val('iso Abbrev1');
						this.newIsotopeController.$('.isotope_massChange').val('fred');
						this.newIsotopeController.$('.saveNewIsotopeButton').click();
						expect(this.isotopeList.length).toEqual(0);
						expect($('#LotForm_SaltFormIsotopeSelect-1View option').length).toEqual(1);
						expect(this.eNotView.$('.notifications div').length).toEqual(2);
					});
				});
				describe('When isotope saved with string for weight and space in abbrev, then corrected and saved', function() {
					it('should add two error notices, then take them out', function() {
						runs(function() {
                            this.newIsotopeController.$('.isotope_name').val('isoName 2a');
                            this.newIsotopeController.$('.isotope_abbrev').val('iso Abbrev2');
                            this.newIsotopeController.$('.isotope_massChange').val('fred');
                            this.newIsotopeController.$('.saveNewIsotopeButton').click();
                            expect($('#LotForm_SaltFormIsotopeSelect-1View option').length).toEqual(1);
                            expect(this.eNotView.$('.notifications div').length).toEqual(2);
                            this.newIsotopeController.$('.isotope_abbrev').val('isoAbbrev2');
                            this.newIsotopeController.$('.isotope_massChange').val('2');
                            this.newIsotopeController.$('.saveNewIsotopeButton').click();
                        });
                        waitIfServer();
                        runs(function() {
                            expect($('#LotForm_SaltFormIsotopeSelect-1View option').length).toEqual(2);
                            expect(this.eNotView.$('.notifications div').length).toEqual(0);
                        });
					});
				});
			});
		});
	});
});