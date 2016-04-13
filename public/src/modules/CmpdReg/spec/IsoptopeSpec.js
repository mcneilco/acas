$(function () {
	describe('Isotope Panel Unit Testing', function () {
		
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
		
		/***********************************************/
		
		describe('Isotope Model', function () {
		
			beforeEach(function () {
				this.isotope = new Isotope();
			});
			
			describe('when instantiated', function () {
			
				it('Should have default attributes', function () {
					expect(this.isotope.get('name')).toEqual('');
					expect(this.isotope.get('abbrev')).toEqual('');
					expect(this.isotope.get('massChange')).toEqual('');						
				});			
			});
			
			describe('when updated', function () {
				it('Should not update if non-numeric values set for isotope_massChange', function () {
					this.isotope.set({'massChange' : -1});
					expect(this.isotope.get('massChange')).toEqual(-1);
					this.isotope.set({'massChange' : 'fred'});
					expect(this.isotope.get('massChange')).toEqual(-1);
				});			
				it('Should not update if name is empty', function () {
					this.isotope.set({'name' : 's name'});
					expect(this.isotope.get('name')).toEqual('s name');
					this.isotope.set({'name' : ''});
					expect(this.isotope.get('name')).toEqual('s name');
				});			
				it('Should not update if isotope_abbrev is empty', function () {
					this.isotope.set({'abbrev' : 'TAbbrev'});
					expect(this.isotope.get('abbrev')).toEqual('TAbbrev');
					this.isotope.set({'abbrev' : ''});
					expect(this.isotope.get('abbrev')).toEqual('TAbbrev');
				});			
				it('Should not update if spaces in isotope_abbrev', function () {
					this.isotope.set({'abbrev' : 'TAbbrev'});
					expect(this.isotope.get('abbrev')).toEqual('TAbbrev');
					this.isotope.set({'abbrev' : 'T Abbrev'});
					expect(this.isotope.get('abbrev')).toEqual('TAbbrev');
				});			
				it('Should not update if - in isotope_abbrev', function () {
					this.isotope.set({'abbrev' : 'TAbbrev'});
					expect(this.isotope.get('abbrev')).toEqual('TAbbrev');
					this.isotope.set({'abbrev' : 'T-Abbrev'});
					expect(this.isotope.get('abbrev')).toEqual('TAbbrev');
				});			
				it('Should not update if leading or trailing white space in name', function () {
					this.isotope.set({'name' : 's name'});
					expect(this.isotope.get('name')).toEqual('s name');
					this.isotope.set({'name' : ' s name'});
					expect(this.isotope.get('name')).toEqual('s name');
					this.isotope.set({'name' : 's name '});
					expect(this.isotope.get('name')).toEqual('s name');
				});		
			});
			
			describe('when saved', function() {
				it('should get an id', function() {
					this.isotope.set({'name' : 'isotope name', 'abbrev': 'itabbrev', massChange: 1});
					expect(this.isotope.get('id')).toBeUndefined();

					runs( function() {
						this.isotope.save();
					});
					waitIfServer(2000);
					runs( function() {
						expect(this.isotope.get('id')).toBeDefined();
					});
				});
			});


		});	// End Isotope Model

		describe('Isotopes', function () {
		
			beforeEach(function () {
				this.isotope1 = new Isotope();
				this.isotope2 = new Isotope({name: 'isn1', abbrev: 'isa1', massChange: 1});
				this.isotopeList = new Isotopes([
					this.isotope1,
					this.isotope2,
					{name: 'isn2', abbrev: 'isa2', massChange: 2}
				]);
			});
			
			describe('Isotope Collection works', function () {
			
				it('Should have three isotopes', function () {
					expect(this.isotopeList.length).toEqual(3);
				});			
			});	


			describe('Isotopes.create should work', function() {
				it('Should have one Isotope', function () {
					this.isotopes = new Isotopes();
					runs(function() {
						this.isotopes.create({name: 'itn1_create', abbrev: 'ita1',  massChange: 1});
					});
					waitIfServer();
					runs( function() {
						expect(this.isotopes.length).toEqual(1);
						expect(this.isotopes.at(0).isNew()).toBeFalsy();
					});
				});
			});
			
			if(true) {
				describe('Get list from server returns isotopes', function() {
					it('should get isotopes from server', function() {
					
						runs( function() {
							this.isotopeList.fetch();
						});
						waitIfServer(500);

						runs( function() {
							expect(this.isotopeList.length).toEqual(2);
						});
														
					});
				});
			}

		});	// End Isotope List
		
		describe('Isotope Select View', function () {
		
			beforeEach(function () {			
				this.isotope1 = new Isotope({name: 'isn1', abbrev: 'isa1', massChange: 1});
				this.isotope2 = new Isotope({id: '2', name: 'isn2', abbrev: 'isa2', massChange: 2});
				this.isotopeList = new Isotopes(),
				this.isotopeSelectController = new IsotopeSelectController({el: "#LotForm_SaltFormIsotopeSelect-1View", collection: this.isotopeList});			
			});
			
			describe('when it is created', function() {
				it('isotope select should start with one option', function() {
					expect($('#LotForm_SaltFormIsotopeSelect-1View option').length).toEqual(1);
				});
				it('isotope select should start with one option - html = none', function() {
					expect($('#LotForm_SaltFormIsotopeSelect-1View option')[0].innerHTML).toEqual('none');
					expect($('#LotForm_SaltFormIsotopeSelect-1View option')[0].value).toEqual('');
				});
			});
			describe('when we add two isotopes', function () {
				beforeEach(function() {
					this.isotopeList.add(this.isotope1);
					this.isotopeList.add(this.isotope2);				
				});
				it('should have 3 options', function () {
					expect(this.isotopeList.length).toEqual(2);
					expect($('#LotForm_SaltFormIsotopeSelect-1View option').length).toEqual(3);
				});
				it('third option should show isn2', function () {
					if(window.configuration.metaLot.includeAbbrevInIsoSaltOption) {
						expect($('#LotForm_SaltFormIsotopeSelect-1View option')[2].innerHTML).toEqual('isa2: isn2');
					} else {
						expect($('#LotForm_SaltFormIsotopeSelect-1View option')[2].innerHTML).toEqual('isn2');
					}
				});			
				it('should return the currently select isotope', function(){
					this.isotopeSelectController.$('option')[1].selected = true;
					var cid1 = this.isotope1.cid;
					expect(this.isotopeSelectController.selectedCid()).toEqual(cid1);
				});		
			});					
			describe('when sort by abrrev option is enabled', function () {
				beforeEach(function() {
					this.isotopeList.add(this.isotope1);
					this.isotopeList.add(this.isotope2);				
					this.isotopeList.add(new Isotope({name: 'a1', abbrev: 'a1', massChange: 1}));				
				});
				it('should show them in alpha order by abbrev', function () {
					if(window.configuration.metaLot.sortIsotopesByAbbrev) {
						expect($('#LotForm_SaltFormIsotopeSelect-1View option')[1].innerHTML).toContain('a1');
						expect($('#LotForm_SaltFormIsotopeSelect-1View option')[2].innerHTML).toContain('isn1');
						expect($('#LotForm_SaltFormIsotopeSelect-1View option')[3].innerHTML).toContain('isn2');
					} else {
						expect($('#LotForm_SaltFormIsotopeSelect-1View option')[1].innerHTML).toContain('isn1');
						expect($('#LotForm_SaltFormIsotopeSelect-1View option')[2].innerHTML).toContain('isn2');
						expect($('#LotForm_SaltFormIsotopeSelect-1View option')[3].innerHTML).toContain('a1');
					}
				});
			});						
			describe('when there are two selects for the same isotope collection', function() {
				it('both should have 3 options', function () {
					this.isotopeSelectController2 = new IsotopeSelectController({el: "#LotForm_SaltFormIsotopeSelect-2View", collection: this.isotopeList});			
					this.isotopeList.add(this.isotope1);
					this.isotopeList.add(this.isotope2);
					expect(this.isotopeList.length).toEqual(2);
					expect($('#LotForm_SaltFormIsotopeSelect-1View option').length).toEqual(3);
					expect($('#LotForm_SaltFormIsotopeSelect-2View option').length).toEqual(3);
				});
			});
		
			
		});
		
		describe('New isotope form', function () {
			beforeEach(function () {
				//this.isotope = new Isotope({isotope_name: 'enter name', isotope_abbrev: 'enterAbbrev', isotope_massChange: 0});
				this.isotopeList = new Isotopes(),
				this.isotopeSelectController = new IsotopeSelectController({el: '#LotForm_SaltFormIsotopeSelect-1View', collection: this.isotopeList});			
				this.newIsotopeController = new NewIsotopeController({el: '#NewIsotopeView', collection: this.isotopeList});
				this.newIsotopeController.render();
			});
			
			describe('when it renders', function () {						
				it('should set its el attribute with template', function () {
					expect($(this.newIsotopeController.el).children().length).toBeGreaterThan(0);				
				});
				it('should be hidden at first render', function() {
					expect($(this.newIsotopeController.el).is(':visible')).toBeFalsy();
				});
			
			});			
		
			describe('When shown', function() {
				it(' should show the containing div', function() {
					this.newIsotopeController.hide();
					this.newIsotopeController.show();
					expect($(this.newIsotopeController.el).is(':visible')).toBeTruthy();
				});
			});

			describe('When cancel button pressed',function() {
				it(' should hide itself', function() {
					this.newIsotopeController.show();
					this.newIsotopeController.$('.cancelNewIsotopeButton').click();
					expect($(this.newIsotopeController.el).is(':visible')).toBeFalsy();
				});
			});
            //TODO clear errors on cancel should work

			describe('When successfully saved', function() {
				beforeEach(function() {
                    runs(function() {
                        this.newIsotopeController.show();
                        this.newIsotopeController.$('.isotope_name').val('isoName 1');
                        this.newIsotopeController.$('.isotope_abbrev').val('isoAbbrev1');
                        this.newIsotopeController.$('.isotope_massChange').val('1.5');
                        this.newIsotopeController.$('.saveNewIsotopeButton').click();
                     
                    });
                    waitIfServer();
                        
				});
				it('should add a new isotope to the collection', function() {
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
				it('should save the massChange as a number, not a string', function() {
					runs(function() {
                        var newIso = this.isotopeList.at(0);
                        expect(newIso.get('massChange')).toEqual(1.5); //as oppsed to '1'
                    });
				});
				it(' should clear the input fields', function() {
					runs(function() {
                        expect(this.newIsotopeController.$('.isotope_name').val()).toEqual('');
                        expect(this.newIsotopeController.$('.isotope_abbrev').val()).toEqual('');
                        expect(this.newIsotopeController.$('.isotope_massChange').val()).toEqual('');
                    });
				});
				it(' should hide the containing div', function() {
					runs(function() {
                        expect($(this.newIsotopeController.el).is(':visible')).toBeFalsy();
                    });
				});
				it(' should be a saved model', function() {
					waits(30);
                    runs(function() {
                        expect(this.isotopeList.at(0).isNew()).toBeFalsy();
                    });
				});
			});
			
			describe('When invalid values are entered' , function() {
				beforeEach(function() {
                    this.newIsotopeController.show();
                    this.newIsotopeController.$('.isotope_name').val('isoName 1');
                    this.newIsotopeController.$('.isotope_abbrev').val('isoAbbrev1');
                    this.newIsotopeController.$('.isotope_massChange').val('1');
				});
				describe('When saved with error isotope_massChange not a number', function() {
					beforeEach(function() {
						this.newIsotopeController.$('.isotope_massChange').val('fred');				
					});
					it('should not add to collection', function() {
						this.newIsotopeController.$('.saveNewIsotopeButton').click();
						expect(this.isotopeList.length).toEqual(0);
						expect($('#LotForm_SaltFormIsotopeSelect-1View option').length).toEqual(1);
					});
					it('should add input_error class to input field', function() {
						this.newIsotopeController.$('.saveNewIsotopeButton').click();
						expect(this.newIsotopeController.$('.isotope_massChange').hasClass('input_error')).toBeTruthy();
					});
				});
				describe('When saved with error isotope_abbrev has a space', function() {
					beforeEach(function() {
						this.newIsotopeController.$('.isotope_abbrev').val('iso Abbrev1');
					});
					it('should not add to collection', function() {
                        this.newIsotopeController.$('.saveNewIsotopeButton').click();
                        expect(this.isotopeList.length).toEqual(0);
                        expect($('#LotForm_SaltFormIsotopeSelect-1View option').length).toEqual(1);
					});
					it('should add input_error class to input field', function() {
						this.newIsotopeController.$('.saveNewIsotopeButton').click();
						expect(this.newIsotopeController.$('.isotope_abbrev').hasClass('input_error')).toBeTruthy();
					});
				});
				describe('When saved with error, then error corrected', function() {
					it('should clear class input_error', function() {
                        runs(function() {
                            this.newIsotopeController.$('.isotope_massChange').val('fred');
                            this.newIsotopeController.$('.saveNewIsotopeButton').click();
                            expect(this.newIsotopeController.$('.isotope_massChange').hasClass('input_error')).toBeTruthy();
                            this.newIsotopeController.$('.isotope_massChange').val('1');
                            this.newIsotopeController.$('.saveNewIsotopeButton').click();
                        });
                        waitIfServer();
                        runs(function() {
                            expect(this.newIsotopeController.$('.isotope_massChange').hasClass('input_error')).toBeFalsy();
                        });
					});
				});
			});
			describe('When name and abbreviation are entered with surrounding whitespace' , function() {
				beforeEach(function() {
					runs(function() {
                        this.newIsotopeController.show();
                        this.newIsotopeController.$('.isotope_name').val(' isotope name 1 ');
                        this.newIsotopeController.$('.isotope_abbrev').val(' isotopeAbbrev1 ');
                        this.newIsotopeController.$('.isotope_massChange').val('1');
                        this.newIsotopeController.$('.saveNewIsotopeButton').click();
                    });
                    waitIfServer();
				});
				it('should save without the surrounding whitespace', function() {
					runs(function() {
                        expect(this.isotopeList.length).toEqual(1);
                        expect(this.isotopeList.at(0).get('name')).toEqual('savedIsotope');
                        expect(this.isotopeList.at(0).get('abbrev')).toEqual('SI');
                    });
				});
			});
	
		});		
		
		
		
	});	// End Isotope Panel Unit Testing
});