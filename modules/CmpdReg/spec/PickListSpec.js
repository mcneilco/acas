$(function () {
	describe('PickList Select Unit Testing', function () {
		
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
		describe('PickList', function () {
			beforeEach(function() {
				this.pickList = new PickList();
			});
			describe('defaults', function () {
				it("Should have default ignored value of false", function() {
					expect(this.pickList.has('ignore')).toBeTruthy();
					expect(this.pickList.get('ignore')).toBeFalsy();
				});
			});
		});

		describe('PickList Collection', function () {
		
			beforeEach(function () {
				this.enm = new PickList();
				this.pickListList = new PickListList();
				this.pickListList.setType('operators');
			});
			
			describe('Upon fetch', function() {
				it('should get options from server', function() {
				
					runs( function() {
						this.pickListList.fetch({error: function(collection, response) {
						 	//console.log(response);
						 	}
						 });
					});
					waits(200);

					runs( function() {
						expect(this.pickListList.length).toEqual(3);
						//console.log(this.pickListList);
					});
													
				});
			});
			
		});
		
		describe('PickList controller', function() {
			describe('when displayed', function() {
				it('operators should have three choices', function() {
					runs(function() {
						this.pickListController = new PickListSelectController({
							el: '#pickListTestView',
							type: 'operators'
						})
					});
					waits(100);
					runs(function() {
						expect($('#pickListTestView option').length).toEqual(3);
					});
				});
				it('operators should return selected model', function() {
					runs(function() {
						this.pickListController = new PickListSelectController({
							el: '#pickListTestView',
							type: 'operators'
						})
					});
					waits(100);
					runs(function() {
						this.pickListController.$('option')[1].selected = true;
                        var mdl = this.pickListController.getSelectedModel();
						expect(mdl.get('code')).toEqual('<');
						this.pickListController.$('option')[2].selected = true;
                        var mdl = this.pickListController.getSelectedModel();
						expect(mdl.get('code')).toEqual('>');
					});
				});
				it('operators should return selected code', function() {
					runs(function() {
						this.pickListController = new PickListSelectController({
							el: '#pickListTestView',
							type: 'operators'
						})
					});
					waits(100);
					runs(function() {
						this.pickListController.$('option')[1].selected = true;
						expect(this.pickListController.getSelectedCode()).toEqual('<');
					});
				});
                it('should show selected value', function () {
					runs(function() {
						this.pickListController = new PickListSelectController({
							el: '#pickListTestView',
							type: 'operators',
                            selectedCode: '>'
						})
					});
					waits(100);
					runs(function() {
						expect($(this.pickListController.el).val()).toEqual('>');
					});
    
                });
            });
			describe('when displayed from collection with ignored values', function() {
				it('physicalStates should have three choices', function() {
					runs(function() {
						this.pickListController = new PickListSelectController({
							el: '#pickListTestView',
							type: 'physicalStates'
						})
					});
					waits(100);
					runs(function() {
						expect($('#pickListTestView option').length).toEqual(3);
					});
				});
				it('physicalStates should have four choices when ignored value is set before on setup', function() {
					runs(function() {
						this.pickListController = new PickListSelectController({
							el: '#pickListTestView',
							type: 'physicalStates',
                            selectedCode: 'gas'
						})
					});
					waits(100);
					runs(function() {
						expect($('#pickListTestView option').length).toEqual(4);
						expect($(this.pickListController.el).val()).toEqual('gas');
					});
				});
			});
			describe('when displayed from collection with ignored values and show ignored option is set', function() {
				it('physicalStates should have three choices', function() {
					runs(function() {
						this.pickListController = new PickListSelectController({
							el: '#pickListTestView',
							type: 'physicalStates',
							showIgnored: true
						})
					});
					waits(100);
					runs(function() {
						expect($('#pickListTestView option').length).toEqual(4);
					});
				});
				it('physicalStates should have four choices when ignored value is set before on setup', function() {
					runs(function() {
						this.pickListController = new PickListSelectController({
							el: '#pickListTestView',
							type: 'physicalStates',
                            selectedCode: 'gas'
						})
					});
					waits(100);
					runs(function() {
						expect($('#pickListTestView option').length).toEqual(4);
						expect($(this.pickListController.el).val()).toEqual('gas');
					});
				});
			});
			describe('when selection set', function() {
				it('should show selected value', function() {
					runs(function() {
						this.pickListController = new PickListSelectController({
							el: '#pickListTestView',
							type: 'physicalStates'
						})
					});
					waits(100);
					runs(function() {
                        this.pickListController.setSelectedCode('liquid');
						expect($(this.pickListController.el).val()).toEqual('liquid');
					});
				});
			});
			describe('when created with added option not in database', function() {
				beforeEach( function() {
					runs(function() {
						this.pickListController = new PickListSelectController({
							el: '#pickListTestView',
							type: 'operators',
							insertFirstOption: new PickList({"code":"not_set","id":5,"name":"Select Category","version":0}),
							selectedCode: 'not_set'					
						})
					});
				});
				it('operators should have four choices', function() {
					waits(100);
					runs(function() {
						expect($('#pickListTestView option').length).toEqual(4);
					});
				});
				it('operators should not set selected', function() {
					waits(100);
					runs(function() {
						expect($(this.pickListController.el).val()).toEqual('not_set');
					});
				});
			});
		});
		
	});
	
});
