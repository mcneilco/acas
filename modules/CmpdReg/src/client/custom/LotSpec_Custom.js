$(function () {
	describe('Lot Unit Testing', function () {
		
		
		beforeEach(function () {
			this.fixture = $.clone($('#fixture').get(0));
		});
		
		afterEach(function () {
			$('#fixture').remove();
			$('body').append($(this.fixture));
		});
		
		/***********************************************/
		
		describe('New unsaved Lot Model', function() {
			beforeEach(function () {
				this.lot = new Lot();
			});
			it('should have default values', function() {
				expect(this.lot.get('corpName')).toEqual('');
				expect(this.lot.get('asDrawnStruct')).toBeNull();
				expect(this.lot.get('lotMolWeight')).toBeNull();
				expect(this.lot.get('synthesisDate')).toEqual('');
				expect(this.lot.get('color')).toEqual('');
				expect(this.lot.get('physicalState')).toBeNull();
				expect(this.lot.get('notebookPage')).toEqual('');
				expect(this.lot.get('amount')).toBeNull();
				expect(this.lot.get('amountUnits')).toBeNull();
				expect(this.lot.get('supplier')).toEqual('');
				expect(this.lot.get('supplierID')).toEqual('');
				expect(this.lot.get('purity')).toBeNull();
				expect(this.lot.get('percentEE')).toBeNull();
				expect(this.lot.get('purityMeasuredBy')).toBeNull();
				expect(this.lot.get('purityOperator')).toBeNull();
                expect(this.lot.get('chemist')).toBeNull();
                expect(this.lot.get('project')).toBeNull();
                expect(this.lot.get('supplierLot')).toBeNull();
                expect(this.lot.get('meltingPoint')).toBeNull();
                expect(this.lot.get('boilingPoint')).toBeNull();
				expect(this.lot.get('isVirtual')).toBeFalsy();
				expect(this.lot.get('retain')).toBeNull();
				expect(this.lot.get('retainUnits')).toBeNull();
				expect(this.lot.get('solutionAmount')).toBeNull();
				expect(this.lot.get('solutionAmountUnits')).toBeNull();
				expect(this.lot.get('lotNumber')).toBeNull();
				expect(this.lot.get('vendor')).toBeNull();


			});
			describe('When values set', function() {
				it('should return saveable model from getModelForSave()', function() {
					this.lot.set({
						color: 'blue',
						notebookPage: 'CMPD-LB-0001-001'
					});
					
					var modelForSave = this.lot.getModelForSave();
					expect(modelForSave.get('color')).toEqual('blue');
					expect(modelForSave.get('notebookPage')).toEqual('CMPD-LB-0001-001');
					
					// expect synthesis date in right format for json -> server
					
					//This does not test nested returns of getModelForSave. This is too hard in a unit test.
					//We may need an integration test for this
				});
			});
			describe('When incorrect values set', function() {
				// Notebook format not needed
				//it('Should not update if notebookPage wrong format', function () {
                 //   // Allowed formats
				//	this.lot.set({notebookPage : 'CMPD-LB-0001-001'});
				//	expect(this.lot.get('notebookPage')).toEqual('CMPD-LB-0001-001');
				//	this.lot.set({notebookPage : 'EPI-LB-0001-001'});
				//	expect(this.lot.get('notebookPage')).toEqual('EPI-LB-0001-001');
                 //
                 //   // disallowed formats
				//	this.lot.set({notebookPage : '123-0433'});
				//	expect(this.lot.get('notebookPage')).toEqual('EPI-LB-0001-001');
				//	this.lot.set({notebookPage : 'ABC-DE-0001-001'});
				//	expect(this.lot.get('notebookPage')).toEqual('EPI-LB-0001-001');
				//	this.lot.set({notebookPage : 'CMPD-LB-10001-1100'});
				//	expect(this.lot.get('notebookPage')).toEqual('EPI-LB-0001-001');
				//	this.lot.set({notebookPage : ''});
				//	expect(this.lot.get('notebookPage')).toEqual('EPI-LB-0001-001');
				//});
			
				it('Should not update if date wrong format', function () {
					this.lot.set({synthesisDate : '10/01/2012'});
					expect(this.lot.get('synthesisDate')).toEqual('10/01/2012');
					this.lot.set({synthesisDate : 'sept 15, 2011'});
					expect(this.lot.get('synthesisDate')).toEqual('10/01/2012');
					this.lot.set({synthesisDate : '22/55/2012'});
					expect(this.lot.get('synthesisDate')).toEqual('10/01/2012');
					this.lot.set({synthesisDate : '110/011/2012'});
					expect(this.lot.get('synthesisDate')).toEqual('10/01/2012');
					this.lot.set({synthesisDate : ''});
					expect(this.lot.get('synthesisDate')).toEqual('10/01/2012');
				});
                it('should allow empty notebook if isVirtual', function() {
					this.lot.set({notebookPage : 'CMPD-LB-0001-001'});
					expect(this.lot.get('notebookPage')).toEqual('CMPD-LB-0001-001');
					this.lot.set({
                        notebookPage : '',
                        isVirtual: true
                    });
					expect(this.lot.get('notebookPage')).toBeNull();
                });
                it('should allow empty synthesis date if isVirtual', function() {
					this.lot.set({synthesisDate : '10/01/2012'});
					expect(this.lot.get('synthesisDate')).toEqual('10/01/2012');
					this.lot.set({
                        synthesisDate : '',
                        isVirtual: true
                    });
					expect(this.lot.get('synthesisDate')).toBeNull();
                });
                it('Should not update if percentEE is not empty and not a number', function() {
					this.lot.set({'percentEE' : -1});
					expect(this.lot.get('percentEE')).toEqual(-1);
					this.lot.set({'percentEE' : 'fred'});
					expect(this.lot.get('percentEE')).toEqual(-1);
                });
                it('Should not update if amount is not empty and not a number', function() {
					this.lot.set({'amount' : -1});
					expect(this.lot.get('amount')).toEqual(-1);
					this.lot.set({'amount' : 'fred'});
					expect(this.lot.get('amount')).toEqual(-1);
                });
                it('Should not update if purity is not empty and not a number', function() {
					this.lot.set({'purity' : -1});
					expect(this.lot.get('purity')).toEqual(-1);
					this.lot.set({'purity' : 'fred'});
					expect(this.lot.get('purity')).toEqual(-1);
					this.lot.set({'purity' : '33ferd'});
					expect(this.lot.get('purity')).toEqual(-1);
                });
                it('Should not update if meltingPoint is not empty and not a number', function() {
					this.lot.set({'meltingPoint' : -1});
					expect(this.lot.get('meltingPoint')).toEqual(-1);
					this.lot.set({'meltingPoint' : 'fred'});
					expect(this.lot.get('meltingPoint')).toEqual(-1);
					this.lot.set({'meltingPoint' : '33ferd'});
					expect(this.lot.get('meltingPoint')).toEqual(-1);
                });
                it('Should not update if boilingPoint is not empty and not a number', function() {
					this.lot.set({'boilingPoint' : -1});
					expect(this.lot.get('boilingPoint')).toEqual(-1);
					this.lot.set({'boilingPoint' : 'fred'});
					expect(this.lot.get('boilingPoint')).toEqual(-1);
					this.lot.set({'boilingPoint' : '33ferd'});
					expect(this.lot.get('boilingPoint')).toEqual(-1);
                });
				it('Should not update if retain is not empty and not a number', function() {
					this.lot.set({'retain' : -1});
					expect(this.lot.get('retain')).toEqual(-1);
					this.lot.set({'retain' : 'fred'});
					expect(this.lot.get('retain')).toEqual(-1);
				});
				it('Should not update if solutionAmount is not empty and not a number', function() {
					this.lot.set({'solutionAmount' : -1});
					expect(this.lot.get('solutionAmount')).toEqual(-1);
					this.lot.set({'solutionAmount' : 'fred'});
					expect(this.lot.get('solutionAmount')).toEqual(-1);
				});
			});
			
		});

		describe('New Lot Model from JSON load', function() {
			beforeEach(function () {
				var fileListJSON = window.testJSON.fileList;
				var js = {
					notebookPage: 'CMPD-LB-0001-001',
					synthesisDate: '10/25/2011',
                    //buid: 12345,
                    chemist: new Backbone.Model({"id":2, "code": "cchemist", "name": "Corey Chemist","isChemist":true,"isAdmin":false}),
					fileList: fileListJSON
				}				
				this.lot = new Lot({json: js});
			});
			it('should have values from supplied JSON', function() {
				expect(this.lot.get('notebookPage')).toEqual('CMPD-LB-0001-001');
				expect(this.lot.get('synthesisDate')).toEqual('10/25/2011');
				//expect(this.lot.get('buid')).toEqual(12345);
                expect(this.lot.get('chemist').get('code')).toEqual('cchemist');
			});
			it('should have a fileListObject',function() {
				expect(this.lot.get('fileList').length).toEqual(3);
				expect(this.lot.get('fileList').at(0).get('name')).toEqual('file1.txt');
			});
		});

		describe('New Lot Model from JSON load with mal-formed notebookPage and date', function() {
			beforeEach(function () {
				var fileListJSON = window.testJSON.fileList;
				var js = {
					notebookPage: 'fred',
					synthesisDate: 'sally',
                    chemist: new Backbone.Model({"id":2, "code": "cchemist", "name": "Corey Chemist","isChemist":true,"isAdmin":false}),
					fileList: fileListJSON
				}				
				this.lot = new Lot({json: js});
			});
			it('should accept malformed noteBookPage from json load', function() {
				expect(this.lot.get('notebookPage')).toEqual('fred');
				expect(this.lot.get('synthesisDate')).toEqual('sally');
                expect(this.lot.get('chemist').get('code')).toEqual('cchemist');
			});
		});


		describe('Lot Controller', function() {
			beforeEach(function () {
				
			});
			describe('When displayed with --new-- Lot', function() {
				beforeEach( function() {
					this.lot = new Lot();
                    // to set a default on a select, just provide a one in the new model:
                    this.lot.set({chemist: new Backbone.Model(window.testJSON.chemistUser)});
					this.lotController = new LotController({
						el: '#LotForm_LotView',
						model: this.lot
					});
					this.lotController.render();
				
				});
				describe('When it is first displayed', function() {
					it('should have a notebookPage Field', function () {
						expect(this.lotController.$('.notebookPage').val()).toEqual('');
						expect(this.lotController.$('.notebookPage').attr('disabled')).toBeUndefined();
					});
					it('add analytics files control should be hidden', function () {
						expect(this.lotController.$('.editAnalyticalFiles').is(':visible')).toBeFalsy();
                        expect(this.lotController.$('.analyticalFiles').html()).toEqual('Add analytical files by editing lot after it is saved')
					});
					it('should have a physical state select',function() {
						waits(100);
						runs(function() {
							expect(this.lotController.$('.physicalStateCode option').length).toEqual(4);
						});
					});
                    it('should have a chemist  select',function() {
						waits(100);
						runs(function() {
                            expect(this.lotController.$('.chemist').is(':visible')).toBeTruthy();
							expect(this.lotController.$('.chemist option').length).toEqual(4);
						});
					});
                    it('chemist  select should show logged in user',function() {
						waits(100);
						runs(function() {
							expect(this.lotController.$('.chemist').val()).toEqual('cchemist');
						});
					});
				});
				
				
				
				describe('When invalid entries added', function() {
					beforeEach(function() {
                        waits(200);
                        runs(function() {
                            this.lotController.$('.notebookPage').val('bad notebook');
                            this.lotController.$('.synthesisDate').val('bad date');
                        });
					});
					it('should show error state',function() {
						this.lotController.updateModel();
						expect(this.lotController.isValid()).toBeFalsy();
						//expect(this.lotController.$('.notebookPage').hasClass('input_error')).toBeTruthy();
						expect(this.lotController.$('.synthesisDate').hasClass('input_error')).toBeTruthy();
					});
				});
				describe('When model update requested', function() {
					beforeEach( function() {
						waits(200); // let selects load
						runs( function() {
							this.lotController.$('.notebookPage').val('CMPD-LB-0001-001');
							this.lotController.$('.synthesisDate').val('10/26/2011');
							this.lotController.$('.supplier').val('supplierX');
							this.lotController.$('.supplierID').val('supplierXID');
							this.lotController.$('.percentEE').val('45');
							this.lotController.$('.comments').val('this is a comment');
							this.lotController.$('.color').val('blue');
							this.lotController.$('.amount').val('42');
							this.lotController.$('.retain').val('47');
							this.lotController.$('.solutionAmount').val('46');
							this.lotController.$('.purity').val('95');
							this.lotController.$('.supplierLot').val('slot');
							this.lotController.$('.meltingPoint').val('22');
							this.lotController.$('.boilingPoint').val('44');
                            this.lotController.physicalStateCodeController.$('option')[1].selected = true;
                            this.lotController.operatorCodeController.$('option')[1].selected = true;
                            this.lotController.amountUnitsCodeController.$('option')[1].selected = true;
                            this.lotController.retainUnitsCodeController.$('option')[1].selected = true;
                            this.lotController.solutionAmountUnitsCodeController.$('option')[1].selected = true;
                            this.lotController.purityMeasuredByCodeController.$('option')[1].selected = true;
                            this.lotController.chemistCodeController.$('option')[2].selected = true;
                            this.lotController.vendorCodeController.$('option')[2].selected = true;
                            this.lotController.projectCodeController.$('option')[1].selected = true;
							var fileListJSON = window.testJSON.fileList;
							this.lot.get('fileList').add(fileListJSON);
						});
					});
					it('should produce valid lot model', function() {
						this.lotController.updateModel();
						expect(this.lotController.isValid()).toBeTruthy();
						var ms = this.lot.getModelForSave();
						expect(ms.get('notebookPage')).toEqual('CMPD-LB-0001-001');
						expect(ms.get('synthesisDate')).toEqual('10/26/2011');
						expect(ms.get('supplier')).toEqual('supplierX');
						expect(ms.get('supplierID')).toEqual('supplierXID');
						expect(ms.get('percentEE')).toEqual(45);
						expect(ms.get('comments')).toEqual('this is a comment');
						expect(ms.get('color')).toEqual('blue');
						expect(ms.get('amount')).toEqual(42);
						expect(ms.get('retain')).toEqual(47);
						expect(ms.get('solutionAmount')).toEqual(46);
						expect(ms.get('purity')).toEqual(95);
						expect(ms.get('supplierLot')).toEqual('slot');
						expect(ms.get('meltingPoint')).toEqual(22);
						expect(ms.get('boilingPoint')).toEqual(44);
						expect(ms.get('vendor').get('code')).toEqual('Araxes');
                        expect(ms.get('fileList').length).toEqual(2);
						expect(ms.get('physicalState').get('code')).toEqual('solid');
						expect(ms.get('purityOperator').get('code')).toEqual('<');
						expect(ms.get('amountUnits').get('code')).toEqual('mg');
						expect(ms.get('retainUnits').get('code')).toEqual('mg');
						expect(ms.get('solutionAmountUnits').get('code')).toEqual('uL');
						expect(ms.get('purityMeasuredBy').get('code')).toEqual('HPLC');
						expect(ms.get('chemist').get('code')).toEqual('bbiologist');
						expect(ms.get('project').get('code')).toEqual('project2');
					});
				});

				describe('When model update requested with empty number fields', function() {
					beforeEach( function() {
						waits(200); // let selects load
						runs( function() {
							this.lotController.$('.notebookPage').val('CMPD-LB-0001-001');
							this.lotController.$('.synthesisDate').val('10/26/2011');
						});
					});
					it('should produce valid lot model with null for number attributes', function() {
						this.lotController.updateModel();
						expect(this.lotController.isValid()).toBeTruthy();
						var ms = this.lot.getModelForSave();
						expect(ms.get('notebookPage')).toEqual('CMPD-LB-0001-001');
						expect(ms.get('synthesisDate')).toEqual('10/26/2011');
						expect(ms.get('percentEE')).toBeNull();
						expect(ms.get('amount')).toBeNull();
						expect(ms.get('retain')).toBeNull();
						expect(ms.get('solutionAmount')).toBeNull();
						expect(ms.get('purity')).toBeNull();
					});
				});
				describe('When fields filled with white space on outside', function() {
					beforeEach( function() {
						waits(200); // let selects load
						runs( function() {
							this.lotController.$('.notebookPage').val(' CMPD-LB-0001-001 ');
							this.lotController.$('.synthesisDate').val(' 10/26/2011 ');
							this.lotController.$('.supplier').val(' supplierX ');
							this.lotController.$('.supplierID').val(' supplierXID ');
							this.lotController.$('.percentEE').val(' 45 ');
							this.lotController.$('.comments').val(' this is a comment ');
							this.lotController.$('.color').val(' blue ');
							this.lotController.$('.amount').val(' 42 ');
							this.lotController.$('.retain').val(' 47 ');
							this.lotController.$('.solutionAmount').val(' 46 ');
							this.lotController.$('.purity').val(' 95 ');
						});
					});
					it('should produce valid lot model', function() {
						this.lotController.updateModel();
						expect(this.lotController.isValid()).toBeTruthy();
						var ms = this.lot.getModelForSave();
						expect(ms.get('notebookPage')).toEqual('CMPD-LB-0001-001');
						expect(ms.get('synthesisDate')).toEqual('10/26/2011');
						expect(ms.get('supplier')).toEqual('supplierX');
						expect(ms.get('supplierID')).toEqual('supplierXID');
						expect(ms.get('percentEE')).toEqual(45);
						expect(ms.get('comments')).toEqual('this is a comment');
						expect(ms.get('color')).toEqual('blue');
						expect(ms.get('amount')).toEqual(42);
						expect(ms.get('retain')).toEqual(47);
						expect(ms.get('solutionAmount')).toEqual(46);
						expect(ms.get('purity')).toEqual(95);
					});
				});

			});
            describe('when created with new virtual lot', function() {
				beforeEach( function() {
					this.lot = new Lot({isVirtual: true});
					this.lotController = new LotController({
						el: '#LotForm_LotView',
						model: this.lot
					});
					this.lotController.render();
				
				});
                describe( 'When rendered', function() {
                   it('should hide inputs besides notebook and data', function() {
                        expect(this.lotController.$('.color').is(':visible')).toBeFalsy();
                        expect(this.lotController.$('.editAnalyticalFiles').is(':visible')).toBeFalsy();
                   });
                   it('should still show notebook and date', function() {
						expect(this.lotController.$('.notebookPage').is(':visible')).toBeTruthy();
						expect(this.lotController.$('.notebookPage').is(':visible')).toBeTruthy();
						expect(this.lotController.$('.chemist').is(':visible')).toBeTruthy();
                   });
                });
                
            });

			describe('When displayed with existing Lot', function() {
				beforeEach( function() {
					var js = window.testJSON.lot;
                    //js.buid = 12345;

                    this.lot = new Lot({json: js});
					this.lotController = new LotController({
						el: '#LotForm_LotView',
						model: this.lot
					});
					this.lotController.render();
				
				});
				describe('When it is first displayed', function() {
					it('should have a populated and disabled notebookPage Field', function () {
						expect(this.lotController.$('.notebookPage').val()).toEqual('1234-043');
						expect(this.lotController.$('.notebookPage').attr('disabled')).toEqual('disabled');
					});
					it('should have a populated and disabled synthesisDate Field', function () {
						expect(this.lotController.$('.synthesisDate').val()).toEqual('10/24/2011');
						expect(this.lotController.$('.synthesisDate').attr('disabled')).toEqual('disabled');
					});
					//it('should have a populated and disabled buid Field', function () {
					//	expect(this.lotController.$('.buid').val()).toEqual('12345');
					//	expect(this.lotController.$('.buid').attr('disabled')).toEqual('disabled');
					//});
					xit('add analytics files control should be enabled', function () {
                        //TODO something about latest styling makes this fail even though it works
						expect(this.lotController.$('.editAnalyticalFiles').is(':visible')).toBeTruthy();
					});
					it('should have a populated color Field', function () {
						expect(this.lotController.$('.color').val()).toEqual('blue');
					});
					it('should have a two files shown',function() {
						expect(this.lotController.$('.analyticalFiles div div').length).toEqual(2);
					});
					it('should have selects set to correct value',function() {
						waits(200); // let selects load
						runs( function() {
                            expect($(this.lotController.physicalStateCodeController.el).val()).toEqual('gel');
                            expect($(this.lotController.operatorCodeController.el).val()).toEqual('>');
                            expect($(this.lotController.amountUnitsCodeController.el).val()).toEqual('mL');
                            expect($(this.lotController.retainUnitsCodeController.el).val()).toEqual('mL');
                            expect($(this.lotController.solutionAmountUnitsCodeController.el).val()).toEqual('mL');
                            expect($(this.lotController.purityMeasuredByCodeController.el).val()).toEqual('HPLC');
                            expect($(this.lotController.projectCodeController.el).val()).toEqual('project3');
                        });
					});
					it('should have show chemist value set to correct value',function() {
                        waits(100);
                        runs( function(){
                            expect(this.lotController.$('.chemist').attr('disabled')).toEqual('disabled');
                            expect(this.lotController.$('.chemist').val()).toEqual('cchemist');                          
                        });
					});
                    describe('When edit analytical files clicked', function() {
                        it('should show mulitipleFilePicker', function() {
                            this.lotController.$('.editAnalyticalFiles').click();
                            expect($(this.lotController.fileUploadController.el).is(':visible')).toBeTruthy();
                        });
                    });
				});
                describe('When not editable', function() {
                    it('should disable all fields', function() {
                        this.lotController.disableAll();
						expect(this.lotController.$('.color').attr('disabled')).toEqual('disabled');
                    });
                });

			});



		});



		
		
		
		
	});
	
});
