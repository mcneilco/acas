$(function () {
	describe('Salt Panel Unit Testing', function () {

		var testMrv = '<cml><MDocument><MChemicalStruct><molecule molID="m1"><atomArray><atom id="a1" elementType="Na" x2="-1.5" y2="1.6666666666666667"/></atomArray><bondArray/></molecule></MChemicalStruct></MDocument></cml>';

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
		
		describe('Salt Model', function () {
		
			beforeEach(function () {
				this.salt = new Salt();
			});
			
			describe('when instantiated', function () {
			
				it('Should have default attributes', function () {
					expect(this.salt.get('name')).toEqual('');
					expect(this.salt.get('abbrev')).toEqual('');
					expect(this.salt.get('molStructure')).toEqual(null);						
				});			
			});
			
			describe('when updated', function () {
				it('Should not update if name is empty', function () {
					this.salt.set({'name' : 's name'});
					expect(this.salt.get('name')).toEqual('s name');
					this.salt.set({'name' : ''});
					expect(this.salt.get('name')).toEqual('s name');
				});			
				it('Should not update if salt_abbrev empty', function () {
					this.salt.set({'abbrev' : 'TAbbrev'});
					expect(this.salt.get('abbrev')).toEqual('TAbbrev');
					this.salt.set({'abbrev' : ''});
					expect(this.salt.get('abbrev')).toEqual('TAbbrev');
				});			
				it('Should not update if spaces in salt_abbrev', function () {
					this.salt.set({'abbrev' : 'TAbbrev'});
					expect(this.salt.get('abbrev')).toEqual('TAbbrev');
					this.salt.set({'abbrev' : 'T Abbrev'});
					expect(this.salt.get('abbrev')).toEqual('TAbbrev');
				});			
				it('Should not update if - in salt_abbrev', function () {
					this.salt.set({'abbrev' : 'TAbbrev'});
					expect(this.salt.get('abbrev')).toEqual('TAbbrev');
					this.salt.set({'abbrev' : 'T-Abbrev'});
					expect(this.salt.get('abbrev')).toEqual('TAbbrev');
				});			
				it('Should not update if leading or trailing white space in name', function () {
					this.salt.set({'name' : 's name'});
					expect(this.salt.get('name')).toEqual('s name');
					this.salt.set({'name' : ' s name'});
					expect(this.salt.get('name')).toEqual('s name');
					this.salt.set({'name' : 's name '});
					expect(this.salt.get('name')).toEqual('s name');
				});			
				it('Should not update if molStructure is empty', function () {
					this.salt.set({'molStructure' : 'mol string'});
					expect(this.salt.get('molStructure')).toEqual('mol string');
					this.salt.set({'molStructure' : ''});
					expect(this.salt.get('molStructure')).toEqual('mol string');
				});			
			});
			
			describe('when saved', function() {
				it('should get an id', function() {
					this.salt.set({'name' : 's name', 'abbrev': 'sabbrev', 'molStructure': window.testJSON.molCl});
					expect(this.salt.get('id')).toBeUndefined();

					runs( function() {
						this.salt.save();
					});
					waitIfServer(1000);
					runs( function() {
						expect(this.salt.get('id')).toBeDefined();
					});
				});
			});
			
		});	// End Salt Model

		describe('Salts', function () {
		
			beforeEach(function () {
				this.salt1 = new Salt();
				this.salt2 = new Salt({name: 'isn1', abbrev: 'isa1'});
				this.saltList = new Salts([
					this.salt1,
					this.salt2,
					{name: 'isn2', abbrev: 'isa2'}
				]);
			});
			
			describe('Salts works', function () {
			
				it('Should have three Salts', function () {
					expect(this.saltList.length).toEqual(3);
				});			
			});	
			
			describe('Salts.create should work', function() {
				it('Should have one Salt', function () {
					this.salts = new Salts();
					runs(function() {
						this.salts.create({name: 'isn1_create', abbrev: 'isa1', molStructure: 'mol string'});
					});
					waitIfServer(1000);
					runs( function() {
						expect(this.salts.length).toEqual(1);
						expect(this.salts.at(0).isNew()).toBeFalsy();
					});
				});
			});
			
            describe('Get list from server returns salts', function() {
                it('should get salts from server', function() {

                    runs( function() {
                        //console.log('about to fetch salts for salt list');
                        this.saltList.fetch();
                    });
                    waitIfServer(500);

                    runs( function() {
                        expect(this.saltList.length).toEqual(2);
                    });

                });
            });
        });	// End Salt List
		
		describe('Salt Select View', function () {
		
			beforeEach(function () {			
				this.salt1 = new Salt({name: 'isn1', abbrev: 'isa1'});
				this.salt2 = new Salt({id: '2', name: 'isn2', abbrev: 'isa2'});
				this.saltList = new Salts(),
				this.saltSelectController = new SaltSelectController({el: "#LotForm_SaltFormSaltSelect-1View", collection: this.saltList});			
			});
			
			describe('when it is created', function() {
				it('Salt select should start with one option', function() {
					expect($('#LotForm_SaltFormSaltSelect-1View option').length).toEqual(1);
				});
				it('Salt select should start with one option - html = none', function() {
					expect($('#LotForm_SaltFormSaltSelect-1View option')[0].innerHTML).toEqual('none');
					expect($('#LotForm_SaltFormSaltSelect-1View option')[0].value).toEqual('');
				});
			});
			
			describe('when we add two Salts', function () {
				beforeEach(function() {
					this.saltList.add(this.salt1);
					this.saltList.add(this.salt2);				
				});
				it('should have 3 options', function () {
					expect(this.saltList.length).toEqual(2);
					expect($('#LotForm_SaltFormSaltSelect-1View option').length).toEqual(3);
				});
				it('third option should show isn2', function () {
					if(window.configuration.metaLot.includeAbbrevInIsoSaltOption) {
						expect($('#LotForm_SaltFormSaltSelect-1View option')[2].innerHTML).toEqual('isa2: isn2');
					} else {
						expect($('#LotForm_SaltFormSaltSelect-1View option')[2].innerHTML).toEqual('isn2');
					}
				});
				it('should return the currently select salt', function(){
					this.saltSelectController.$('option')[1].selected = true;
					var cid1 = this.salt1.cid;
					expect(this.saltSelectController.selectedCid()).toEqual(cid1);
				});		
			});		
			describe('when sort by abrrev option is enabled', function () {
				beforeEach(function() {
					this.saltList.add(this.salt1);
					this.saltList.add(this.salt2);				
					this.saltList.add(new Salt({name: 'a1', abbrev: 'a1'}));				
				});
				it('should show them in alpha order by abbrev', function () {
					if(window.configuration.metaLot.sortSaltsByAbbrev) {
						expect($('#LotForm_SaltFormSaltSelect-1View option')[1].innerHTML).toContain('a1');
						expect($('#LotForm_SaltFormSaltSelect-1View option')[2].innerHTML).toContain('isn1');
						expect($('#LotForm_SaltFormSaltSelect-1View option')[3].innerHTML).toContain('isn2');
					} else {
						expect($('#LotForm_SaltFormSaltSelect-1View option')[1].innerHTML).toContain('isn1');
						expect($('#LotForm_SaltFormSaltSelect-1View option')[2].innerHTML).toContain('isn2');
						expect($('#LotForm_SaltFormSaltSelect-1View option')[3].innerHTML).toContain('a1');
					}
				});
			});						
			describe('when we create one Salt', function () {
				beforeEach(function() {
					runs( function() {
						this.saltList.create({name: 'isn1a', abbrev: 'isa1a', molStructure: 'mol string 1a'});
					});
					waitIfServer(500);
				});
				it('should have 2 options', function () {
					runs( function() {
						expect(this.saltList.length).toEqual(1);
						//console.log($('#LotForm_SaltFormSaltSelect-1View').html());
						expect($('#LotForm_SaltFormSaltSelect-1View option').length).toEqual(2);
					});
				});
				it('third option should show isn1a', function () {
					runs(function() {
						if(window.configuration.metaLot.includeAbbrevInIsoSaltOption) {
							expect($('#LotForm_SaltFormSaltSelect-1View option')[1].innerHTML).toEqual('SS: savedSalt');
						} else {
							expect($('#LotForm_SaltFormSaltSelect-1View option')[1].innerHTML).toEqual('savedSalt');
						}
					});
				});			
			});			
					
			describe('when there are two selects for the same Salt collection', function() {
				it('both should have 3 options', function () {
					this.saltSelectController2 = new SaltSelectController({el: "#LotForm_SaltFormSaltSelect-2View", collection: this.saltList});			
					this.saltList.add(this.salt1);
					this.saltList.add(this.salt2);
					expect(this.saltList.length).toEqual(2);
					expect($('#LotForm_SaltFormSaltSelect-1View option').length).toEqual(3);
					expect($('#LotForm_SaltFormSaltSelect-2View option').length).toEqual(3);
				});
			});
		
			
		});
		
		describe('New Salt form', function () {
			beforeEach(function () {
				runs(function () {
					this.saltList = new Salts();
					this.saltSelectController = new SaltSelectController({el: '#LotForm_SaltFormSaltSelect-1View', collection: this.saltList});
					this.newSaltController = new NewSaltController({el: '#NewSaltView', collection: this.saltList});
					this.newSaltController.render();
				});
				waitsFor( function (){
					return this.newSaltController.sketcherLoaded;
				});
			});
			
			describe('when it renders', function () {						
				it('should set its el attribute with template', function () {
					expect($(this.newSaltController.el).children().length).toBeGreaterThan(0);
				});
				it('should be hidden at first render', function() {
					expect($(this.newSaltController.el).is(':visible')).toBeFalsy();
				});
			
			});			
		
			describe('When shown', function() {
				it(' should show the containing div', function() {
					this.newSaltController.hide();
					this.newSaltController.show();
					expect($(this.newSaltController.el).is(':visible')).toBeTruthy();
				});
			});
			
			describe('When cancel button pressed',function() {
				it(' should hide itself', function() {
					this.newSaltController.show();
					this.newSaltController.$('.cancelNewSaltButton').click();
					expect($(this.newSaltController.el).is(':visible')).toBeFalsy();
				});
			});

			describe('When successfully saved', function() {
				beforeEach(function() {
					runs(function() {
                        this.newSaltController.show();
                        this.newSaltController.$('.salt_name').val('savedSalt');
                        this.newSaltController.$('.salt_abbrev').val('saltAbbrev1');
                    });
					waitsFor( function (){
						return this.newSaltController.sketcherLoaded;
					});
					runs(function() {
						this.newSaltController.marvinSketcherInstance.importStructure("mrv", testMrv).catch(function(error) {
							alert(error);
						});
						this.newSaltController.$('.saveNewSaltButton').click();
					});
					waitsFor( function (){
						return this.newSaltController.exportStructComplete;
					});
				});
				it('should add a new Salt to the collection', function() {
					runs(function() {
                        expect(this.saltList.length).toEqual(1);
                        expect($('#LotForm_SaltFormSaltSelect-1View option').length).toEqual(2);
						if(window.configuration.metaLot.includeAbbrevInIsoSaltOption) {
                        	expect($('#LotForm_SaltFormSaltSelect-1View option')[1].innerHTML).toEqual('SS: savedSalt');
                        } else {
                        	expect($('#LotForm_SaltFormSaltSelect-1View option')[1].innerHTML).toEqual('savedSalt');
                        }
                    });
				});
				it(' should clear the input fields', function() {
					runs(function() {
                        expect(this.newSaltController.$('.salt_name').val()).toEqual('');
                        expect(this.newSaltController.$('.salt_abbrev').val()).toEqual('');
                    });
				});
				it(' should hide the containing div', function() {
                    runs(function() {
                        expect($(this.newSaltController.el).is(':visible')).toBeFalsy();
                    });
				});
				it(' should be a saved model', function() {
                    runs(function() {
                        expect(this.saltList.at(0).isNew()).toBeFalsy();
                    });
				});
			});
			describe('When invalid values are entered' , function() {
				beforeEach(function() {
					runs(function() {
						this.newSaltController.show();
						this.newSaltController.$('.salt_name').val('salt name 1');
						this.newSaltController.$('.salt_abbrev').val('saltAbbrev1');
					});
					waitsFor( function (){
						return this.newSaltController.sketcherLoaded;
					});
					runs(function() {
						this.newSaltController.marvinSketcherInstance.importStructure("mrv", testMrv).catch(function(error) {
							alert(error);
						});
					});
				});
				describe('When saved with error salt_abbrev has a space', function() {
					beforeEach(function() {
						runs(function(){
							this.newSaltController.$('.salt_abbrev').val('salt Abbrev1');
							this.newSaltController.$('.saveNewSaltButton').click();
						});
						waitsFor( function (){
							return this.newSaltController.exportStructComplete;
						});
					});
					it('should not add to collection', function() {
						expect(this.saltList.length).toEqual(0);
						expect($('#LotForm_SaltFormSaltSelect-1View option').length).toEqual(1);
					});
					it('should add input_error class to input field', function() {
						this.newSaltController.$('.saveNewSaltButton').click();
						expect(this.newSaltController.$('.salt_abbrev').hasClass('input_error')).toBeTruthy();
					});
				});
				describe('When saved with error, then error corrected', function() {
					it('should clear class input_error', function() {
						runs(function() {
                            this.newSaltController.$('.salt_abbrev').val('salt Abbrev1');
                            this.newSaltController.$('.saveNewSaltButton').click();
						});
						waitsFor( function (){
							return this.newSaltController.exportStructComplete;
						});
						runs(function() {
							expect(this.newSaltController.$('.salt_abbrev').hasClass('input_error')).toBeTruthy();
                            this.newSaltController.$('.salt_abbrev').val('saltAbbrev1');
                            this.newSaltController.$('.saveNewSaltButton').click();
                        });
						waitsFor( function (){
							return this.newSaltController.exportStructComplete;
						});
                        runs(function() {
                            expect(this.newSaltController.$('.salt_abbrev').hasClass('input_error')).toBeFalsy();
                        });
					});
				});
			});
			describe('When name and abbreviation are entered with surrounding whitespace' , function() {
				beforeEach(function() {
					runs(function() {
                        this.newSaltController.show();
                        this.newSaltController.$('.salt_name').val(' salt name 1 ');
                        this.newSaltController.$('.salt_abbrev').val(' saltAbbrev1 ');
					});
					waitsFor( function (){
						return this.newSaltController.sketcherLoaded;
					});
					runs(function() {
						this.newSaltController.marvinSketcherInstance.importStructure("mrv", testMrv).catch(function(error) {
							alert(error);
						});
						this.newSaltController.$('.saveNewSaltButton').click();
					});
					waitsFor( function () {
						return this.newSaltController.exportStructComplete;
					});
				});
				it('should save without the surrounding whitespace', function() {
					runs(function() {
                        expect(this.saltList.length).toEqual(1);
                        expect(this.saltList.at(0).get('name')).toEqual('savedSalt');
                        expect(this.saltList.at(0).get('abbrev')).toEqual('SS');
                    });
				});
			});
			xdescribe('When marvin has a molStructure', function() {
				it('should return a smiles', function() {
					runs( function() {
						this.newSaltController.show();
						this.newSaltController.loadMarvin();		
					});
					waits(2000);
					runs( function() {
						document.newSalt_marvinSketch.setMol("C1=CC2=CC3=C(C=CC=C3)C=C2C=C1");
						document.newSalt_marvinSketch.setMol("C1=CC2=CC3=C(C=CC=C3)C=C2C=C1");
						document.newSalt_marvinSketch.setMol("C1=CC2=CC3=C(C=CC=C3)C=C2C=C1");

						expect(document.newSalt_marvinSketch.getMol('smiles')).toEqual("C1=CC2=CC3=C(C=CC=C3)C=C2C=C1");
					});
				});
				it('should set molStructure on user save', function() {
					runs( function() {
						this.newSaltController.show();
						this.newSaltController.loadMarvin();		
						this.newSaltController.$('.salt_name').val(' salt name 1 ');
						this.newSaltController.$('.salt_abbrev').val(' saltAbbrev1 ');
					});
					waits(500);
					runs( function() {
						document.newSalt_marvinSketch.setMol("c:c");
						document.newSalt_marvinSketch.setMol("c:c");
						this.newSaltController.$('.saveNewSaltButton').click();
                    });
                    waitIfServer();
                    runs(function() {
						//expect(this.newSaltController.$(".newSalt_marvinSketchApplet")[0].getMol("smiles")).toEqual('c:c');
						expect(this.saltList.at(0).get('molStructure')).toEqual('mol string 2');                       
					});
				});
			});

		});		
		
		
		
	});	// End Salt Panel Unit Testing
});