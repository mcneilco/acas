$(function () {
	describe('Parent Unit Testing', function () {
		
		
		beforeEach(function () {
			this.fixture = $.clone($('#fixture').get(0));
		});
		
		afterEach(function () {
			$('#fixture').remove();
			$('body').append($(this.fixture));
		});
		
		/***********************************************/
		
		describe('New unsaved Parent Model', function() {
			beforeEach(function () {
				this.parent = new Parent();
			});
            describe(' When instantiated', function() {               
                it('should have default values', function() {
                    expect(this.parent.get('stereoCategory')).toBeNull();
                    expect(this.parent.get('stereoComment')).toEqual('');
                    expect(this.parent.get('molStructure')).toEqual('');
                    expect(this.parent.get('corpName')).toEqual('');
                    expect(this.parent.get('commonName')).toEqual('');
                    expect(this.parent.get('chemist')).toBeNull();

                });
           });

			describe('When values set', function() {
				it('should return saveable model from getModelForSave()', function() {
					this.parent.set({
						corpName: 'cname',
                        stereoComment: 'comment',
						stereoCategory: new PickList({"code":"see_comments","id":4,"name":"See Comments","version":0}),
                        molStructure: 'mymol',
                        commonName: 'common'
					});
					
					var modelForSave = this.parent.getModelForSave();
					expect(modelForSave.get('stereoCategory').get('code')).toEqual('see_comments');
					expect(modelForSave.get('stereoComment')).toEqual('comment');
					expect(modelForSave.get('molStructure')).toEqual('mymol');
					expect(modelForSave.get('corpName')).toEqual('cname');
					expect(modelForSave.get('commonName')).toEqual('common');
				});
			});
			describe('When incorrect values set', function() {
				it('Should not update if corpName is empty', function () {
					this.parent.set({corpName : 'fred'});
					expect(this.parent.get('corpName')).toEqual('fred');
					this.parent.set({corpName : ''});
					expect(this.parent.get('corpName')).toEqual('fred');
					this.parent.set({corpName : ' '});
					expect(this.parent.get('corpName')).toEqual('fred');
				});			
				it('Should not update if molStructure is empty', function () {
					this.parent.set({molStructure : 'mymol'});
					expect(this.parent.get('molStructure')).toEqual('mymol');
					this.parent.set({molStructure : ''});
					expect(this.parent.get('molStructure')).toEqual('mymol');
					this.parent.set({molStructure : ' '});
					expect(this.parent.get('molStructure')).toEqual('mymol');
				});			
				it('Should not update if stereoCategory is "see comments" and stereoComment is empty', function () {
					this.parent.set({corpName : 'fred'});
					expect(this.parent.get('corpName')).toEqual('fred');
					this.parent.set({
                        corpName : 'sally',
                        stereoCategory: new PickList({"code":"see_comments","id":4,"name":"See Comments","version":0}), 
                        stereoComment: ''
                    });
					expect(this.parent.get('corpName')).toEqual('fred');
				});			
				it('Should not update if stereoCategory is "Select Category"', function () {
					this.parent.set({corpName : 'fred'});
					expect(this.parent.get('corpName')).toEqual('fred');
					this.parent.set({
                        corpName : 'sally',
                        stereoCategory: new PickList({"code":"not_set","id":5,"name":"Select Category","version":0}), 
                        stereoComment: ''
                    });
					expect(this.parent.get('corpName')).toEqual('fred');
				});			
			});
        });

        describe('New parent from json', function() {
            beforeEach(function () {
                this.parentJSON = window.testJSON.parent;
				this.parentJSON.molStructure = window.testJSON.mol.molStructure;
                this.parent = new Parent({
                    json: this.parentJSON
                });

            });
            describe('Initialization should parse JSON into correct model types', function() {
                it('should have correct objects', function() {
                    expect(this.parent.get('corpName')).toEqual('cName');
                    expect(this.parent.get('molStructure')).toMatch('V2000\n    0.8250');
                    expect(this.parent.get('stereoCategory').get('code')).toEqual('scalemic');
                });
            });

        });


		describe('Parent Controller', function() {
			beforeEach(function () {
				
			});
			describe('When displayed with --new-- Parent', function() {
				beforeEach( function() {
                    // all parents will have molStructure since this is filled by previous steps
					this.parent = new Parent({molStructure: window.testJSON.mol.molStructure});
					this.parentController = new ParentController({
						el: '#LotForm_ParentView',
						model: this.parent
					});
					this.parentController.render();
				
				});
				describe('When it is first displayed', function() {
					it('should have a stereoComment Field', function () {
						expect(this.parentController.$('.stereoComment').val()).toEqual('');
						expect(this.parentController.$('.stereoComment').attr('disabled')).toBeUndefined();
					});
					it('should have a commonName Field', function () {
						expect(this.parentController.$('.commonName').val()).toEqual('');
						expect(this.parentController.$('.commonName').attr('disabled')).toBeUndefined();
					});
                    it('should hide registration search result radio', function() {
                        expect(this.parentController.$('.radioWrapper').is(':visible')).toBeFalsy();
                    });

                    it('should have a stereo category  select',function() {
						waits(200);
						runs(function() {
                            expect(this.parentController.$('.stereoCategoryCode').is(':visible')).toBeTruthy();
							expect(this.parentController.$('.stereoCategoryCode option').length).toEqual(4);					
						});
					});
                    xit('should show parent molStructure', function() {
                        runs( function() {
                            this.parentController.loadMarvin();		
                        });
                        waits(500);
                        runs( function() {
                            //console.log(this.parentController.$(".marvinViewApplet"));
                            //TODO I don't know how to test this'
                            //expect(this.parentController.$(".marvinViewApplet").name()).toEqual('Parent_marvinView');
                        });
                    });
				});

				describe('When model update requested', function() {
					beforeEach( function() {
						waits(200); // let selects load
						runs( function() {
							this.parentController.$('.stereoComment').val('my comment');
                            this.parentController.stereoCategoryCodeController.$('option')[1].selected = true;
							this.parentController.$('.commonName').val('common name');
						});
					});
					it('should produce valid parent model', function() {
						this.parentController.updateModel();
						expect(this.parentController.isValid()).toBeTruthy();
						var ms = this.parent.getModelForSave();
						expect(ms.get('stereoComment')).toEqual('my comment');
						expect(ms.get('stereoCategory').get('code')).toEqual('racemic');
						expect(ms.get('commonName')).toEqual('common name');
					});
                });

            });
			describe('When displayed with --new-- Parent and showSelectCategoryOption true', function() {
				beforeEach( function() {
                    // all parents will have molStructure since this is filled by previous steps
                    window.configuration.metaLot.showSelectCategoryOption = true;
					this.parent = new Parent({molStructure: window.testJSON.mol.molStructure});
					this.parentController = new ParentController({
						el: '#LotForm_ParentView',
						model: this.parent
					});
					this.parentController.render();
				
				});
                it('should have a stereo category  select',function() {
					waits(100);
					runs(function() {
                        expect(this.parentController.$('.stereoCategoryCode').is(':visible')).toBeTruthy();
						expect(this.parentController.$('.stereoCategoryCode option').length).toEqual(5);					
					});
				});
				it('stereo category should have a please select option selected if the option is set', function() {
					waits(100);
					runs(function() {
						expect(this.parentController.$('.stereoCategoryCode').val()).toEqual('not_set');
					});
				});
			});
			describe('When displayed with --saved-- Parent', function() {
				beforeEach( function() {
                    this.parentJSON = window.testJSON.parent;
                    this.parent = new Parent({
                        json: this.parentJSON
                    });
					this.parentController = new ParentController({
						el: '#LotForm_ParentView',
						model: this.parent
					});
					this.parentController.render();
				
				});
				describe('When it is first displayed', function() {
					it('should have a disabled stereoComment Field', function () {
						expect(this.parentController.$('.stereoComment').val()).toEqual('comment');
						expect(this.parentController.$('.stereoComment').attr('disabled')).toEqual('disabled');
					});

					it('should have a diasbled commonName Field', function () {
						expect(this.parentController.$('.commonName').val()).toEqual('common name');
						expect(this.parentController.$('.commonName').attr('disabled')).toEqual('disabled');
					});
					it('should have a diasbled molWeight Field', function () {
						expect(this.parentController.$('.molWeight').val()).toEqual('42.42');
						expect(this.parentController.$('.molWeight').attr('disabled')).toEqual('disabled');
					});
					it('should have a diasbled molFormula Field', function () {
						expect(this.parentController.$('.molFormula').val()).toEqual('C2H6');
						expect(this.parentController.$('.molFormula').attr('disabled')).toEqual('disabled');
					});
					it('should have show stereo category value set to correct value',function() {
                        waits(100);
                        runs( function(){
                            expect(this.parentController.$('.stereoCategoryCode').attr('disabled')).toEqual('disabled');
                            expect(this.parentController.$('.stereoCategoryCode').val()).toEqual('scalemic');                          
                        });
					});
                    it('should have button that opens children of the parent in a new window', function(){
                         // TODO parent controller should have button that opens children of the parent in a new window
                    });
				});
            });
        });
              
		describe('Reg Parent Controller', function() {
			describe('When RegParentController displayed with --saved-- Parent', function() {
				beforeEach( function() {
                    this.parentJSON = window.testJSON.parent;
                    this.parent = new Parent({
                        json: this.parentJSON
                    });
					this.parentController = new RegParentController({
						el: '#LotForm_ParentView',
						model: this.parent
					});
					this.parentController.render();
				
				});
                
                describe('When used in registration search results', function() {
                    beforeEach( function() {
                        this.sfJSONList = window.step2JSON.parents[0].saltForms;
                        var sfList = new Backbone.Collection();
                        var self = this;
                        _.each(this.sfJSONList, function(sfj) {
                            sfList.add( new SaltForm({json: sfj}));
                        });
                        this.parentController.setupForRegSelect(sfList);
                    });
                    it('should show selection radio',function() {
                        expect(this.parentController.$('.radioWrapper').is(':visible')).toBeTruthy();
                        expect(this.parentController.$('.regPick').val()).toEqual('cName');
                    });
                    it('should return MetaLot of just parent if no salt form selected', function() {
                        if (window.configuration.metaLot.saltBeforeLot) {
                            this.parentController.saltFormSelectCont.$('option')[0].selected = true;
                        }
                        var ml = this.parentController.getSelectedMetaLot();
                        expect(ml.get('parent').get('corpName')).toEqual('cName');
                        expect(ml.get('saltForm').get('corpName')).toEqual('');
                        
                    });
                    it('should return MetaLot of selected parent + salt form if salt form selected', function() {
                        if (window.configuration.metaLot.saltBeforeLot) {
                            this.parentController.saltFormSelectCont.$('option')[1].selected = true;
                        }
                        var ml = this.parentController.getSelectedMetaLot();
                            if (window.configuration.metaLot.saltBeforeLot) {
                                expect(ml.get('saltForm').get('corpName')).toEqual('SGD-0001-C14Na');
                                expect(ml.get('parent').get('corpName')).toEqual('cName');
                            } else {
                                expect(ml.get('parent').get('corpName')).toEqual('cName');
                            }
                        
                    });
                });




            });

        });

    });
});

