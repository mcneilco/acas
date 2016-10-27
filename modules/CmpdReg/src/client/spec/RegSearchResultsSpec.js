$(function () {
    describe('Registration Search Results Unit Testing', function () {
		
		
        beforeEach(function () {
            this.fixture = $.clone($('#fixture').get(0));
        });
		
        afterEach(function () {
            $('#fixture').remove();
            $('body').append($(this.fixture));
        });
		
        /***********************************************/
		        
        describe('RegSearchResults tests', function(){
            describe('When new controller created', function(){
                beforeEach(function() {
                    this.searchResults = window.step2JSON;
                    
                    this.regSearchController = new RegSearchResultsController({
                        el: '#RegSearchResultsView',
                        json: this.searchResults
                    });
                    this.regSearchController.render();
                    this.regSearchController.show();
                });
                describe('When rendered', function() {
                    xit('should show as drawn structure', function() {
                        //TODO I don't know how to test marvinView
                        this.regSearchController.loadMarvin();
                    });
                    it('should have a parent list view', function() {
                        expect(this.regSearchController.$('.RegSearchResults_ParentView').length).toEqual(2);
                    });
                    it('shold show mol weight and formula', function() {
                        expect(this.regSearchController.$('.asDrawnMolWeight').val()).toEqual('42.35');
                        expect(this.regSearchController.$('.asDrawnMolFormula').val()).toEqual('C2');
                    });
                    it('should have register new CMPD radio enabled', function() {
	                    expect(this.regSearchController.$('[value^="new"]').attr('disabled')).toBeUndefined();
                    });
                    it('should have Virtual checkbox enabled', function() {
	                    expect(this.regSearchController.$('.isVirtual').attr('disabled')).toBeUndefined();
                    });
	                it('Should hide the virtual checkbox if that option is true', function() {
		                if (window.configuration.regSearchResults.hideVirtualOption) {
			                expect(this.regSearchController.$('.isVirtual').is(':visible')).toBeFalsy();
		                }
	                });
                })
                describe('When user clicks Is Virtual',function() {
                   it('should hide parent list view', function() {
                       expect(this.regSearchController.$('.RegSearchResults_ParentListView').is(':visible')).toBeTruthy();
                       this.regSearchController.$('.isVirtual').attr('checked', true);;
                       this.regSearchController.$('.isVirtual').click();
                       expect(this.regSearchController.$('.RegSearchResults_ParentListView').is(':visible')).toBeFalsy();
                       this.regSearchController.$('.isVirtual')[0].checked = false;
                       this.regSearchController.$('.isVirtual').click();
                       expect(this.regSearchController.$('.RegSearchResults_ParentListView').is(':visible')).toBeTruthy();
                   });
                });
                describe('When user clicks back', function(){
                    it('should request to go back a step by the app controller', function() {
                        //TODO write this test

                        });

                });
                describe('when cancel/close clicked', function() {
                    it('should alert saying changes will be lost', function() {
                        //TODO write this test
                        });
                    it('request to be closed by app controller', function() {
                        //TODO write this test
                        });
                });
                describe('when next clicked', function() {
                    describe('if data filled in with valid data', function() {
                        beforeEach(function() {
                        //TODO write this test

//                            this.mlController.$('.nextButton').click();
                        });
                        it('should collect user selection for reg controller', function() {
                            });
                        it('shold request to be closed by app controller', function() {
                        //TODO write this test
                            });

                    });
                });
            }); 
            describe('When new controller created with as drawn structure null', function(){
                beforeEach(function() {
                    this.searchResults = window.step2JSON;
                    this.searchResults.asDrawnImage = null;
                    
                    this.regSearchController = new RegSearchResultsController({
                        el: '#RegSearchResultsView',
                        json: this.searchResults
                    });
                    this.regSearchController.render();
                    this.regSearchController.show();
                });
                describe(' with no structure, options are limited', function() {
                    it('should have register new CMPD radio disabled', function() {
                        expect(this.regSearchController.$('[value^="new"]').attr('disabled')).toEqual('disabled');
                    });
                    it('should have register new CMPD radio not checked', function() {
                        expect(this.regSearchController.$('[value^="new"]').attr('checked')).toBeFalsy();
                    });
                    it('should have Virtual checkbox disabled', function() {
                        expect(this.regSearchController.$('.isVirtual').attr('disabled')).toEqual('disabled');
                    });
                });
                describe('with no as drawn, hide whole as drawn info section', function() {
                    it('should make requested structure section hidden', function() {
                        expect(this.regSearchController.$('.ReqStruc').is(':visible')).toBeFalsy();
                    });
                });
            });

        });
        
    });
});

