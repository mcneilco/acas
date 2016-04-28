$(function () {
	describe('Salt Form Unit Testing', function () {

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

		describe('SaltForm Model', function() {
			beforeEach(function () {
				this.saltForm = new SaltForm();
			});
			describe('When new SaltForm instantiated', function() {
				// nothing to interesting to test yet...
				it('It should have an IsoSaltEquivList', function () {
					expect(this.saltForm.get('isosalts').create).toBeDefined();
				});
				it('should have default values', function() {
					expect(this.saltForm.get('corpName')).toEqual('');
					expect(this.saltForm.get('casNumber')).toEqual('');
                    expect(this.saltForm.get('chemist')).toBeNull();
				});

			});

			describe('When instantiated from json', function() {
				beforeEach(function () {
					this.sfJSON = window.testJSON.saltForm;
					this.saltForm = new SaltForm({
                        json: this.sfJSON
                    });

				});
				describe('Initialization should parse JSON into correct model types', function() {
					it('should have correct objects', function() {
						expect(this.saltForm.get('isosalts').length).toEqual(2);
						expect(this.saltForm.get('isosalts').at(0).get('equivalents')).toEqual(1.7);
						expect(this.saltForm.get('isosalts').at(1).get('isosalt').get('abbrev')).toEqual('isa1');
						expect(this.saltForm.get('casNumber')).toEqual('12345');
                        expect(this.saltForm.get('corpName')).toEqual('SGD-1234-C14Na');
					});
				});
                describe('When values requested', function() {
                    it('should return saveable model from getModelForSave()', function() {
                        this.saltForm.set({
                            casNumber: '11111'
                        });

                        var modelForSave = this.saltForm.getModelForSave();
                        expect(modelForSave.get('casNumber')).toEqual('11111');
                   });
                });


			});


		});


		describe('SaltForm Controller', function() {
			beforeEach(function () {
				runs(function() {
                    this.salts = new Salts();
                    this.salts.create({name: 'isn1', abbrev: 'isa1', molStructure: 'mol string 1'});
                    this.salts.create({name: 'isn2', abbrev: 'isa2', molStructure: 'mol string 2'});

                    this.isotopes = new Isotopes();
                    this.isotopes.create({name: 'istn1', abbrev: 'ista1', massChange: 1});
                    this.isotopes.create({name: 'istn2', abbrev: 'ista2', massChange: 2});
                });
                waitIfServer();
			});

			describe('When displayed with --new-- SaltForm', function() {
				beforeEach( function() {
					this.saltForm = new SaltForm();
					this.saltFormController = new SaltFormController({
						el: '#LotForm_SaltFormView',
						model: this.saltForm,
						salts: this.salts,
						isotopes: this.isotopes
					});

				});
				describe('When it is first displayed', function() {
                    beforeEach( function() {
							this.saltFormController.render();
                    });
					it('should have 5 salt isosaltEquivs', function () {
						expect(this.saltFormController.model.get('isosalts').length).toEqual(5);
					});
					it('should have 5 visable isoSaltEquiv views', function() {
						this.saltFormController.render();
						expect(this.saltFormController.model.get('isosalts').length).toEqual(5);
						expect(this.saltFormController.$('.isosaltEquivListView div').length).toEqual(5);
					});
					it('should show add isotope and salt buttons', function() {
						expect(this.saltFormController.$('.addIsosaltButtons').hasClass('shown')).toBeTruthy();
					});
					it('should have hidden structure div', function() {
                        waits(250) // added an animate that needs to run
                        runs(function() {
                            expect(this.saltFormController.$('.structureWrapper').is(':visible')).toBeFalsy();
                        });
					});
				});

				describe('When model update requested', function() {
					it('should add any non-none equivalents to the isosalts collection', function() {
						this.saltFormController.render();

						this.saltFormController.$('.isosaltEquivListView div:eq(1) select option')[1].selected = true;
						this.saltFormController.$('.isosaltEquivListView div:eq(1) .equivalents').val('1.6');
						this.saltFormController.$('.isosaltEquivListView div:eq(2) select option')[1].selected = true;
						this.saltFormController.$('.isosaltEquivListView div:eq(2) .equivalents').val('2.6');

						this.saltFormController.$('.casNumber').val('12345');

						this.saltFormController.updateModel();
						expect(this.saltFormController.isValid()).toBeTruthy();
						var modelForSave = this.saltForm.getModelForSave();
						expect(modelForSave.get('isosalts').length).toEqual(2);
						expect(modelForSave.get('isosalts').at(1).get('equivalents')).toEqual(2.6);

						expect(modelForSave.get('casNumber')).toEqual('12345');
					});
					it('should not be valid if a sub item is not valid', function() {
						this.saltFormController.render();

						this.saltFormController.$('.isosaltEquivListView div:eq(1) select option')[1].selected = true;
						this.saltFormController.$('.isosaltEquivListView div:eq(1) .equivalents').val('fred');
						this.saltFormController.$('.isosaltEquivListView div:eq(2) select option')[1].selected = true;
						this.saltFormController.$('.isosaltEquivListView div:eq(2) .equivalents').val('2.6');

						this.saltFormController.updateModel();
						expect(this.saltFormController.isValid()).toBeFalsy();

					});

                    it('should set molStructure to empty if molStructure editor hidden', function() {
                        this.saltFormController.updateModel();
                        expect(this.saltFormController.isValid()).toBeTruthy();
                        var modelForSave = this.saltForm.getModelForSave();
                        expect(modelForSave.get('molStructure')).toEqual('');
                    });


					xit('should set molStructure property if molStructure drawn', function() {
						runs( function() {
							this.saltFormController.render();
							this.saltFormController.showStructureView();
						});
						waits(500);
						runs( function() {
							document.newSaltForm_marvinSketch.setMol("c:c");
							document.newSaltForm_marvinSketch.setMol("c:c");
							expect(document.newSaltForm_marvinSketch.getMol("smiles")).toEqual('c:c');

							this.saltFormController.updateModel();
							expect(this.saltFormController.isValid()).toBeTruthy();
							var modelForSave = this.saltForm.getModelForSave();
							expect(modelForSave.get('molStructure')).toMatch(/0.8250    0.0000    0.0000 C/);

							//console.log(JSON.stringify(modelForSave));
						});
					});


				});

				describe('When new salt button pressed', function() {
					beforeEach( function() {
						this.saltFormController.$('.addSaltButton').click();
					});
					it('should display the salt form', function() {
                        expect($(this.saltFormController.newSaltController.el).is(':visible')).toBeTruthy();
					});
					it('should add a salt if a salt correctly entered', function() {
						runs(function() {
                            expect(this.saltFormController.options.salts.length).toEqual(2);
                            this.saltFormController.newSaltController.$('.salt_name').val('salt name 1');
                            this.saltFormController.newSaltController.$('.salt_abbrev').val('saltAbbrev1');
                            this.saltFormController.newSaltController.$('.saveNewSaltButton').click();
                        });
                        waitIfServer();
                        runs(function() {
                            expect(this.saltFormController.options.salts.length).toEqual(3);
                            expect($(this.saltFormController.newSaltController.el).is(':visible')).toBeFalsy();
                        });
					});
				});
				describe('When new isotope button pressed', function() {
					beforeEach( function() {
						this.saltFormController.$('.addIsotopeButton').click();
					});
					it('should display the isotope form', function() {
                        expect($(this.saltFormController.newIsotopeController.el).is(':visible')).toBeTruthy();
					});
					it('should add an isotope if an isotope correctly entered', function() {
						runs(function() {
                            expect(this.saltFormController.options.isotopes.length).toEqual(2);
                            this.saltFormController.newIsotopeController.$('.isotope_name').val('isoName 1');
                            this.saltFormController.newIsotopeController.$('.isotope_abbrev').val('isoAbbrev1');
                            this.saltFormController.newIsotopeController.$('.isotope_massChange').val('1.5');
                            this.saltFormController.newIsotopeController.$('.saveNewIsotopeButton').click();
                        });
                        waitIfServer();
                        runs(function() {
                            expect(this.saltFormController.options.isotopes.length).toEqual(3);
                            expect($(this.saltFormController.newSaltController.el).is(':visible')).toBeFalsy();
                        });
					});
				});
				describe('When show saltform structure clicked', function() {
					beforeEach( function() {
						this.saltFormController.$('.showSaltFormMarvin').attr('checked','checked');
						this.saltFormController.$('.showSaltFormMarvin').click();
					});
					it('should display the salt structure div', function() {
						expect(this.saltFormController.$('.structureWrapper').is(':visible')).toBeTruthy();
					});
				});

			});


			describe('When displayed with --existing-- SaltForm (update mode)', function() {
				beforeEach( function() {
					this.sfJSON = window.testJSON.saltForm;
					this.saltForm = new SaltForm({json: this.sfJSON});

					this.saltFormController = new SaltFormController({
						el: '#LotForm_SaltFormView',
						model: this.saltForm
//						salts: this.salts,
//						isotopes: this.isotopes
					});
					this.saltFormController.render();
				});
				describe('structure should be shown', function() {
					it('should have shown structure div', function() {
						expect(this.saltFormController.$('.structureWrapper').is(':visible')).toBeTruthy();
					});
				});

				describe('When it is displayed', function() {
                    it('should not show structure show/hide control', function() {
						expect(this.saltFormController.$('.showSaltFormMarvinControl').is(':visible')).toBeFalsy();
                    });
					it('should have 2 visable isoSaltEquiv views', function() {
						expect(this.saltFormController.model.get('isosalts').length).toEqual(2);
						expect(this.saltFormController.$('.isosaltEquivListView div').length).toEqual(2);
						expect(this.saltFormController.$('.casNumber').val()).toEqual('12345');
					});
					it('should not show add isotope and salt buttons', function() {
						expect(this.saltFormController.$('.addIsosaltButtons').hasClass('hidden')).toBeTruthy();
					});

                    //Changed spec to disaalow CAS number update
//					it('should allow user to update cas', function() {
//						this.saltFormController.$('.casNumber').val('22345');
//
//						this.saltFormController.updateModel();
//						expect(this.saltFormController.isValid()).toBeTruthy();
//						var modelForSave = this.saltForm.getModelForSave();
//						expect(modelForSave.get('isosalts').length).toEqual(2);
//						expect(modelForSave.get('isosalts').at(1).get('equivalents')).toEqual(2.7);
//
//						expect(modelForSave.get('casNumber')).toEqual('22345');
//
//					});
                    it('should disable the CAS number field', function() {
                        expect(this.saltFormController.$('.casNumber').attr('disabled')).toEqual('disabled');
                    });
				});
			});			

			describe('When displayed with --existing-- SaltForm with no molStructure', function() {
				beforeEach( function() {
					this.sfJSON = window.testJSON.saltForm;
                    this.sfJSON.molStructure = null;
					this.saltForm = new SaltForm({json: this.sfJSON});

					this.saltFormController = new SaltFormController({
						el: '#LotForm_SaltFormView',
						model: this.saltForm
					});
					this.saltFormController.render();
				});

				describe('structure should be hidden', function() {
					it('should have hidden structure div', function() {
                        waits(250);
                        runs(function() {
                            expect(this.saltFormController.$('.structureWrapper').is(':visible')).toBeFalsy();
                        });
					});
				});
			});


		});
	});
});
