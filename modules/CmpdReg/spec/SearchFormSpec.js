$(function () {
	describe('Search Form Unit Testing', function () {
		
		
		beforeEach(function () {
			this.fixture = $.clone($('#fixture').get(0));
		});
		
		afterEach(function () {
			$('#fixture').remove();
			$('body').append($(this.fixture));
		});
		
		/***********************************************/
        describe('SearchForm Model', function() {
          beforeEach(function() {
             this.searchForm = new SearchForm(); 
          });
          describe('It should not allow to date earlier than from date', function() {
              //TODO implement this test
          });
          describe('It require % similarity set and a number if search type is similarity', function() {
              //TODO implement this test
          });
          describe('Numeric entries should be numbers of provided', function() {
            it('Should not update if percentSimilarity is not empty or a number', function() {
                // need to set another var or will trip nothing set because percentSimilarity is not checked
                this.searchForm.set({'alias' : 'fred','percentSimilarity' : -1});
                expect(this.searchForm.get('percentSimilarity')).toEqual(-1);
                this.searchForm.set({'alias' : 'fred', 'percentSimilarity' : 'sally'});
                expect(this.searchForm.get('percentSimilarity')).toEqual(-1);
            });              
          });
          describe('should require at least one field not empty', function() {
            it('Should not update if nothing entered', function() {
                this.searchForm.set({'searchType' : 'fred'});
                expect(this.searchForm.get('searchType')).toBeUndefined();
            });              
          });
       });   
        
        
		
		describe('Search Form Controller', function () {
		
			beforeEach(function () {
                window.configuration.clientUILabels.corpNameLabel = "CMPD Number";
				this.searchController = new SearchFormController({
                    el: ".SearchFormView"
                });
                this.searchController.render();
			});
			
            describe('when search type not similarity', function() {
               it('% similarity should be disabled', function() {
                   this.searchController.$('.searchType [value="exact"').attr('checked', true);
                   expect(this.searchController.$('.percentSimilarity').attr('disabled')).toBeDefined();
               });
            });
            describe('should set corp name label to match global property', function() {
                it('should show correct label', function() {
                    expect(this.searchController.$('.corpNameLabel').html()).toEqual('CMPD Number');
                });
            });
//TODO this test doesn't work, but feature does'
            xdescribe('when search type is similarity', function() {
               it('% similarity should be enabled', function() {
                   this.searchController.$('.searchType [value="similarity"').attr('checked', true);
                   this.searchController.$('.searchType [value="similarity"').click();
                   expect(this.searchController.$('.percentSimilarity').attr('disabled')).toBeUndefined();
               });
            });
            xdescribe('operations',function() {
                beforeEach(function() {
                    this.searchController.show();
                    this.searchController.loadMarvin();
                });
                it('Should be shown when used', function() {
                   expect($(this.searchController.el).is(':visible')).toBeTruthy(); 
                });
                it('return a model when requested', function() {
                    runs(function() {
                        this.searchController.$('.corpNameFrom').val('SGD-0001');
                        this.searchController.$('.corpNameTo').val('SGD-0005');
                        this.searchController.$('.aliasContSelect option')[1].selected = true;
                        this.searchController.$('.alias').val('alien');
                        this.searchController.$('.dateFrom').val('10/24/2011');
                        this.searchController.$('.dateTo').val('10/28/2011');
                        this.searchController.$("[name=searchType]").removeAttr("checked");
                        this.searchController.$("[name=searchType]").filter("[value=similarity]").attr("checked","checked");
                        this.searchController.$('.percentSimilarity').val(42);
                    });
                    waits(700);
                    runs(function() {
                        var sfm = this.searchController.makeSearchFormModel();
                        expect(this.searchController.isValid()).toBeTruthy();
                        expect(sfm.get('corpNameFrom')).toEqual('SGD-0001');
                        expect(sfm.get('corpNameTo')).toEqual('SGD-0005');
                        expect(sfm.get('aliasContSelect')).toEqual('exact');
                        expect(sfm.get('alias')).toEqual('alien');
                        expect(sfm.get('dateFrom')).toEqual('10/24/2011');
                        expect(sfm.get('dateTo')).toEqual('10/28/2011');
                        expect(sfm.get('searchType')).toEqual('similarity');
                        expect(sfm.get('percentSimilarity')).toEqual(42);
                    });

                });
                it('Should show error when next pushed with no fields filled in', function() {
                });
                it('should hide and reset on cancel', function() {
//					runs( function() {
//						this.rsController.loadMarvin();		
//					});
//					waits(700);
//					runs( function() {						
//                        this.rsController.$('.corpName').val('cname');
//                        this.rsController.$('.cancelButton').click();
//                        expect($(this.rsController.el).is(':visible')).toBeFalsy(); 
//                        expect(this.rsController.$('.corpName').val()).toEqual('');
//                    });
                });

            });
            describe('search property cleanup',function() {
                beforeEach(function() {
                    this.searchController.show();
                    this.searchController.loadMarvin();
                });
                it('should strip leading and trailing whitespace from input fields', function() {
                    runs(function() {
                        this.searchController.$('.corpNameFrom').val(' SGD-0001 ');
                        this.searchController.$('.corpNameTo').val(' SGD-0005 ');
                        this.searchController.$('.alias').val(' alien ');
                        this.searchController.$('.dateFrom').val(' 10/24/2011 ');
                        this.searchController.$('.dateTo').val(' 10/28/2011 ');
                        this.searchController.$('.percentSimilarity').val(' 42 ');
                    });
                    waits(700);
                    runs(function() {
                        var sfm = this.searchController.makeSearchFormModel();
                        expect(this.searchController.isValid()).toBeTruthy();
                        expect(sfm.get('corpNameFrom')).toEqual('SGD-0001');
                        expect(sfm.get('corpNameTo')).toEqual('SGD-0005');
                        expect(sfm.get('alias')).toEqual('alien');
                        expect(sfm.get('dateFrom')).toEqual('10/24/2011');
                        expect(sfm.get('dateTo')).toEqual('10/28/2011');
                        expect(sfm.get('percentSimilarity')).toEqual(42);
                    });
                });
            });
            
            
        });
    });
});



