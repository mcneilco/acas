$(function () {
	describe('IsoSaltEquiv Unit Testing', function () {
		
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
		
		describe('IsoSaltEquiv Model', function() {
			beforeEach(function () {
				this.ise = new IsoSaltEquiv();
			});
			describe('when instantiated', function() {
				it('should have no isosalt', function() {
					expect(this.ise.get('isosalt')).toBeNull();
				});
				it('should default to type = salt', function() {
					expect(this.ise.get('type')).toEqual('salt');
				});
			});
			describe('When updated', function() {
				it('Should not update if isosalt is not saved object', function () {
					runs(function() {
                        this.salt = new Salt({'name' : 's name', 'abbrev': 'sabbrev', 'molStructure': 'mol string'});
                        expect(this.salt.isNew()).toBeTruthy();
                        this.ise.set({'equivalents' : -1});
                        this.ise.set({'isosalt' : this.salt, 'equivalents' : 1});
                        expect(this.ise.get('equivalents')).toEqual(-1);
                        this.salt.save();
                    });
                    waitIfServer();
                        runs(function() {
                        expect(this.salt.isNew()).toBeFalsy();
                        this.ise.set({'isosalt' : this.salt, 'equivalents' : 1});
                        expect(this.ise.get('equivalents')).toEqual(1);
                    });
				});			
				
				it('Should not update if equivalents is not a number', function () {
					runs(function() {
                        this.salt = new Salt({'name' : 's name', 'abbrev': 'sabbrev', 'molStructure': 'mol string'});
                        this.salt.save();
                    });
                    waitIfServer();
                    runs(function() {
                        this.ise.set({'testvar' : 'fred'});
                        this.ise.set({'isosalt' : this.salt, 'equivalents' : 'alpha', testvar:'sally'});
                        expect(this.ise.get('testvar')).toEqual('fred');
                        this.ise.set({'isosalt' : this.salt, 'equivalents' : 1, testvar:'sally'});
                        expect(this.ise.get('testvar')).toEqual('sally');
                    });
				});	
                it('should save the salt to both the isosalt property and the salt attribute', function() {
                        this.salt = new Salt({id:1, 'name' : 's name', 'abbrev': 'sabbrev', 'molStructure': 'mol string'});
                        this.ise.set({isosalt : this.salt, equivalents : 1});
                        expect(this.ise.get('salt').get('abbrev')).toEqual('sabbrev');
                });
                it('should save the isotope to both the isosalt property and the isotope attribute', function() {
                        this.isotope= new Isotope({id: 1, name: 'isn1', abbrev: 'isa1', massChange: 1});
                        this.ise.set({type: 'isotope'});
                        this.ise.set({isosalt : this.isotope, equivalents : 1});
                        //console.log(this.ise);
                        expect(this.ise.get('isotope').get('abbrev')).toEqual('isa1');
                });
			});
		});


		describe('IsoSaltEquivList Model', function() {
			beforeEach(function () {
				this.iseL = new IsoSaltEquivList()
			});
			describe('when getSetIsosalts called', function() {
				it('should have correct number of isosalts that were set not null', function() {
					this.salt = new Salt({'name' : 's name', 'abbrev': 'sabbrev', 'molStructure': 'mol string'});
					this.salt.save();
					this.ise1 = new IsoSaltEquiv({'isosalt' : this.salt, 'equivalents' : 1});
					this.ise2 = new IsoSaltEquiv();
					
					this.isotope= new Isotope({name: 'isn1', abbrev: 'isa1', massChange: 1});
					this.isotope.save();
					this.ise3 = new IsoSaltEquiv({'isosalt' : this.isotope, 'equivalents' : 1, type: 'isotope'});
					
					this.iseL.add([this.ise1, this.ise2, this.ise3]);
					expect(this.iseL.getSetIsosalts().length).toEqual(2);
				});
			});
		});


		describe('IsoSaltEquiv Controller tests with Salts and --new-- IsoSaltEquiv', function() {
			beforeEach(function () {
				this.salts = new Salts();
				this.salts.add({id: 1, name: 'isn1', abbrev: 'isa1', molStructure: 'mol string 1'});
				this.salts.add({id: 2, name: 'isn2', abbrev: 'isa2', molStructure: 'mol string 2'});
				
				this.iseController = new IsoSaltEquivController({
					el: '#testIsoSaltEquivController',
					model: new IsoSaltEquiv({type: 'salt'}),			
					isosalts: this.salts,
					errorNotificationName: 'Salt Equivalent 1'
				});

				this.iseController.render();
			});
			describe('When initialized', function() {
				it('should show salt select', function () {
					expect(this.iseController.$('.isosalts').is(':visible')).toBeTruthy();
					expect(this.iseController.$('.isosaltsField').is(':visible')).toBeFalsy();
				});			
				it('Should have a select list with two salts', function () {
					expect(this.iseController.options.isosalts.length).toEqual(2);
					expect(this.iseController.$('.isosalts option').length).toEqual(3);
				});
				it('Should have a labels Salt:', function() {
					expect(this.iseController.$('.isosaltLabel').html()).toEqual('Salt:');
				});
				
			});
			describe('When model update requested', function() {
				beforeEach(function () {

				});
				it('Should return isoSalt when salt selected and equiv is number', function () {
					this.iseController.$('.equivalents').val('1.5');
					this.iseController.$('.isosalts option')[1].selected = true;					
					this.iseController.updateModel();
					var iss = this.iseController.model;
					expect(iss.get('equivalents')).toEqual(1.5); // not '1.5'
					expect(iss.get('isosalt').get('name')).toEqual('isn1');
				});			
				it('Should return isoSalt with null salt salt selected is none', function () {
					this.iseController.$('.isosalts option')[0].selected = true;
					this.iseController.updateModel();
					var iss = this.iseController.model;
					expect(iss.get('isosalt')).toBeNull();
				});			
				it('Should return isoSalt with null salt when equivs is not number', function () {
					this.iseController.$('.equivalents').val('fred');
					this.iseController.$('.isosalts option')[1].selected = true;
					this.iseController.updateModel();
					var iss = this.iseController.model;
					expect(iss.get('isosalt')).toBeNull();
				});			
				it('Should display error if equivs is not number and salt is not none', function () {
					this.iseController.$('.equivalents').val('fred');
					this.iseController.$('.isosalts option')[1].selected = true;
					this.iseController.updateModel();
					var iss = this.iseController.model;
					expect(iss.get('isosalt')).toBeNull();
					expect(this.iseController.$('.equivalents').hasClass('input_error')).toBeTruthy();
				});			
				it('Should clear error if equivs is not number and salt is not none, then equivs is set', function () {
					this.iseController.$('.equivalents').val('');
					this.iseController.$('.isosalts option')[1].selected = true;
					this.iseController.updateModel();
					var iss = this.iseController.model;
					expect(iss.get('isosalt')).toBeNull();
					expect(this.iseController.$('.equivalents').hasClass('input_error')).toBeTruthy();

					this.iseController.$('.equivalents').val('1.5');
					this.iseController.$('.isosalts option')[1].selected = true;
					this.iseController.updateModel();
					var iss = this.iseController.model;
					expect(iss.get('equivalents')).toEqual(1.5);
					expect(iss.get('isosalt').get('name')).toEqual('isn1');
					expect(this.iseController.$('.equivalents').hasClass('input_error')).toBeFalsy();
				});			
				
			});
		});



		describe('IsoSaltEquiv Controller tests with Isotopes and --new-- IsoSaltEquiv', function() {
			beforeEach(function () {
				runs(function() {
                    this.isotopes = new Isotopes();
                    this.isotopes.add({id: 1, name: 'isn1', abbrev: 'isa1', massChange: 1});
                    this.isotopes.add({id: 2, name: 'isn2', abbrev: 'isa2', massChange: 2});
                });
				waitIfServer();
                runs(function() {
                    this.iseController = new IsoSaltEquivController({
                        el: '#testIsoSaltEquivController',
                        model: new IsoSaltEquiv({type: 'isotope'}),	
                        isosalts: this.isotopes,
                        errorNotificationName: 'Isoptope Equivalent 1'
                    });
                    this.iseController.render();
                });
            });

			describe('When initialized', function() {
				it('Should have a select list with two isotopes', function () {
					expect(this.iseController.options.isosalts.length).toEqual(2);
					expect(this.iseController.$('.isosalts option').length).toEqual(3);
				});			
				
				it('Should have a labels Isotope:', function() {
					expect(this.iseController.$('.isosaltLabel').html()).toEqual('Isotope:');
				});
			});
			describe('When model update requested', function() {
				beforeEach(function () {

				});
				it('Should return isoSalt when isotope selected and equiv is number', function () {
					this.iseController.$('.equivalents').val('1.5');
										
					this.iseController.$('.isosalts option')[1].selected = true;
					this.iseController.updateModel();
					
					var iss = this.iseController.model;
					expect(this.iseController.isValid()).toBeTruthy();
					expect(iss.get('equivalents')).toEqual(1.5); // not '1.5'
					expect(iss.get('isosalt').get('name')).toEqual('isn1');

				});			
				it('Should return null isosalt when selection is none', function () {
					this.iseController.$('.isosalts option')[0].selected = true;
					this.iseController.updateModel();
					var iss = this.iseController.model;
					expect(iss.get('isosalt')).toBeNull();
					expect(this.iseController.isValid()).toBeTruthy();
				});			
				it('Should not return isoSalt when equivs is not number', function () {
					this.iseController.$('.equivalents').val('fred');
					this.iseController.$('.isosalts option')[1].selected = true;
					this.iseController.updateModel();
					expect(this.iseController.isValid()).toBeFalsy();
				});			
				it('Should display error if equivs is not number and isotope is not none', function () {
					this.iseController.$('.equivalents').val('fred');
					this.iseController.$('.isosalts option')[1].selected = true;
					this.iseController.updateModel();
					var iss = this.iseController.model;
					expect(iss.get('isosalt')).toBeNull();
					expect(this.iseController.$('.equivalents').hasClass('input_error')).toBeTruthy();
				});			
				it('Should clear error if equivs is not number and isotope is not none, then equivs is set', function () {
					this.iseController.$('.equivalents').val('');
					this.iseController.$('.isosalts option')[1].selected = true;
					this.iseController.updateModel();
					var iss = this.iseController.model;
					expect(iss.get('isosalt')).toBeNull();
					expect(this.iseController.$('.equivalents').hasClass('input_error')).toBeTruthy();

					this.iseController.$('.equivalents').val('1.5');
					this.iseController.$('.isosalts option')[1].selected = true;
					this.iseController.updateModel();
					var iss = this.iseController.model;
					expect(iss.get('equivalents')).toEqual(1.5);
					expect(iss.get('isosalt').get('name')).toEqual('isn1');
					expect(this.iseController.$('.equivalents').hasClass('input_error')).toBeFalsy();
				});			
				
			});
		});

		describe('IsoSaltEquiv Controller tests with Salt and --saved-- IsoSaltEquiv', function() {
			beforeEach(function () {
				this.salt = new Salt({id: 1, 'name' : 's name', 'abbrev': 'sabbrev', 'molStructure': 'mol string'});
				this.ise = new IsoSaltEquiv();
				this.ise.set({id: 1, 'isosalt' : this.salt, 'equivalents' : 1.5, type: 'salt'});
				
				this.iseController = new IsoSaltEquivController({
					el: '#testIsoSaltEquivController',
					model: this.ise,			
					isosalts: this.isotopes
				});

				this.iseController.render();
			});
			describe('When initialized', function() {
				it('should hide salt select', function () {
					expect(this.iseController.$('.isosalts').is(':hidden')).toBeTruthy();
				});			
				it('should have the correct salt name', function () {
					expect(this.iseController.$('.isosaltsField').is(':visible')).toBeTruthy();
					expect(this.iseController.$('.isosaltsField').val()).toEqual('s name');
					expect(this.iseController.$('.isosaltsField').attr('disabled')).toEqual('disabled');
				});			
				it('Should have disable equivs input', function () {
					expect(this.iseController.$('.equivalents').attr('disabled')).toEqual('disabled');
				});			
				it('Should have show correct equivs', function () {
					expect(this.iseController.$('.equivalents').val()).toEqual('1.5');
				});			
				
			});
		});
		
		describe('IsoSaltEquivList Controller tests with Salts and --new-- IsoSaltEquivs', function() {
			beforeEach(function () {
				runs(function() {
                    this.salts = new Salts();
                    this.salts.create({name: 'isn1', abbrev: 'isa1', molStructure: 'mol string 1'});
                    this.salts.create({name: 'isn2', abbrev: 'isa2', molStructure: 'mol string 2'});
                    this.isotopes = new Isotopes();
                    this.isotopes.create({name: 'itn1', abbrev: 'ita1', massChange: 1});
                    this.isotopes.create({name: 'itn2', abbrev: 'ita2', massChange: 2});

                    this.iseL = new IsoSaltEquivList()
                    this.iseL.add( new IsoSaltEquiv({type: 'salt'}));
                    this.iseL.add( new IsoSaltEquiv({type: 'isotype'}));
                });
                waitIfServer();
                runs(function() {
                    this.iseListController = new IsoSaltEquivListController({
                        el: '#testIsoSaltEquivListController',
                        collection: this.iseL,
                        salts: this.salts,
                        isotopes: this.isotopes
                    });                    
                });
			});
			describe('When add two  isosaltEquivs', function() {
				beforeEach(function() {
					this.iseListController.render();				
				});
				it('should have two ise views', function() {
					expect($('#testIsoSaltEquivListController div').length).toEqual(2);
				});
				it(' first ise view should have a salt select with  3 choices', function() {
					expect($('#testIsoSaltEquivListController div:first select option').length).toEqual(3);
					//console.log(($('#testIsoSaltEquivListController div:first select option:last')));
					if(window.configuration.metaLot.includeAbbrevInIsoSaltOption) {
						expect($('#testIsoSaltEquivListController div:first select option:eq(2)').html()).toEqual('SS: savedSalt');
					} else {
						expect($('#testIsoSaltEquivListController div:first select option:eq(2)').html()).toEqual('savedSalt');
					}
				});

				describe('When model update requested', function() {
					it('should add any non-none equivalents to the isosalts collection', function() {
						this.iseL.add( new IsoSaltEquiv({type: 'salt'}));				
						expect($('#testIsoSaltEquivListController div').length).toEqual(3);
	
						//$('#testIsoSaltEquivListController div:eq(0) select option')[1].selected = true;
						$('#testIsoSaltEquivListController div:eq(1) select option')[1].selected = true;
						$('#testIsoSaltEquivListController div:eq(2) select option')[1].selected = true;
						
						
						//$('#testIsoSaltEquivListController div:eq(0) .equivalents').val('0.55');
						$('#testIsoSaltEquivListController div:eq(1) .equivalents').val('1.55');
						$('#testIsoSaltEquivListController div:eq(2) .equivalents').val('2.55');
												
						this.iseListController.updateModel();
						expect(this.iseListController.isValid()).toBeTruthy();
						var ises = this.iseL.getSetIsosalts();
						expect(ises.length).toEqual(2);	
					});
				});
				describe('When model update requested and there is an input error', function() {
					it('getSetIsosaltsContoller should not show all vaild', function() {
						this.iseL.add( new IsoSaltEquiv({type: 'salt'}));				
	
						$('#testIsoSaltEquivListController div:eq(0) select option')[0].selected = true;
						$('#testIsoSaltEquivListController div:eq(1) select option')[1].selected = true;
						$('#testIsoSaltEquivListController div:eq(2) select option')[1].selected = true;

						$('#testIsoSaltEquivListController div:eq(1) .equivalents').val('fred');
						$('#testIsoSaltEquivListController div:eq(2) .equivalents').val('');
												
						this.iseListController.updateModel();
						expect(this.iseListController.isValid()).toBeFalsy();	
					});
				});


			});

		});
		
	});

});