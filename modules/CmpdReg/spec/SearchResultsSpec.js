$(function () {
	describe('Search Results Unit Testing', function () {
		
		
		beforeEach(function () {
			this.fixture = $.clone($('#fixture').get(0));
		});
		
		afterEach(function () {
			$('#fixture').remove();
			$('body').append($(this.fixture));
		});
		
		/***********************************************/
        
        describe('Search Result Controller', function() {
	        describe('In salt before batch mode', function() {
	            beforeEach(function () {
		            this.origMode = window.configuration.metaLot.saltBeforeLot;
		            window.configuration.metaLot.saltBeforeLot = true;
					this.searchResController = new SearchResultController({
	                    el: $(".SearchResView"),
	                    model: new Backbone.Model(window.searchResultJSON[0])
	                });

				});
		        afterEach(function () {
			        window.configuration.metaLot.saltBeforeLot = this.origMode;
		        });

				describe('when rendered', function () {
	                it('should display the corpName', function() {
	                   this.searchResController.render();
	                   expect(this.searchResController.$('.corpName').html()).toEqual('CMPD-1234-Na');
	                });
	                it('should show stereo category', function() {
	                    this.searchResController.render();
	                    expect(this.searchResController.$('.stereoCategory').html()).toEqual('Racemic');
	                });
	                // Russell doesn't want this feature'
	//                it('should show stereo comment', function() {
	//                    this.searchResController.render();
	//                    expect(this.searchResController.$('.stereoComment').html()).toEqual('rac comment');
	//                });
	                it('should show lots in select', function() {
	                    this.searchResController.render();
	                    expect(this.searchResController.$('.lotSelect option').length).toEqual(4);
	                    if (window.configuration.metaLot.lotCalledBatch) {
	                        expect(this.searchResController.$('.lotSelect option:eq(3)').html()).toEqual('Batch 5 - 11/27/2011');
	                    } else {
	                        expect(this.searchResController.$('.lotSelect option:eq(3)').html()).toEqual('Lot 5 - 11/27/2011');
	                    }
	                });
	                it('should show <no date> if lot date is null', function() {
	                    var tlotids = this.searchResController.model.get('lotIDs');
	                    tlotids[3].synthesisDate = null;
	                    this.searchResController.render();
	                    if (window.configuration.metaLot.lotCalledBatch) {
	                        expect(this.searchResController.$('.lotSelect option:eq(3)').html()).toEqual('Batch 5 - &lt;no date&gt;');
	                    } else {
	                        expect(this.searchResController.$('.lotSelect option:eq(3)').html()).toEqual('Lot 5 - &lt;no date&gt;');
	                    }
	                });
				});
			});
	        describe('In batch before salt mode', function() {
	            beforeEach(function () {
		            this.origMode = window.configuration.metaLot.saltBeforeLot;
		            window.configuration.metaLot.saltBeforeLot = false;
					this.searchResController = new SearchResultController({
	                    el: $(".SearchResView"),
	                    model: new Backbone.Model(window.searchResultJSON[3])
	                });

				});
		        afterEach(function () {
			        window.configuration.metaLot.saltBeforeLot = this.origMode;
		        });

				describe('when rendered', function () {
	                it('should display the corpName', function() {
	                   this.searchResController.render();
	                   expect(this.searchResController.$('.corpName').html()).toEqual('CMPD-2222-K');
	                });
	                it('should show stereo category', function() {
	                    this.searchResController.render();
	                    expect(this.searchResController.$('.stereoCategory').html()).toEqual('See Comment');
	                });
	                it('should show lot in span', function() {
	                    this.searchResController.render();
	                    if (window.configuration.metaLot.lotCalledBatch) {
	                        expect(this.searchResController.$('.lotName').html()).toEqual('- Batch 1 - 12/6/2011');
	                    } else {
	                        expect(this.searchResController.$('.lotName').html()).toEqual('- Lot 1 - 12/6/2011');
	                    }
	                });
	                it('should show <no date> if lot date is null', function() {
	                    var tlotids = this.searchResController.model.get('lotIDs');
	                    tlotids[0].synthesisDate = null;
	                    this.searchResController.render();
	                    if (window.configuration.metaLot.lotCalledBatch) {
	                        expect(this.searchResController.$('.lotName').html()).toEqual('- Batch 1 - &lt;no date&gt;');
	                    } else {
	                        expect(this.searchResController.$('.lotName').html()).toEqual('- Lot 1 - &lt;no date&gt;');
	                    }
	                });
				});
			});

        });
        describe('Search Result List Controller', function() {
 			beforeEach(function () {
				this.searchResListController = new SearchResultListController({
                    el: $(".SearchResultListView"),
                    collection: new Backbone.Collection(window.searchResultJSON)
                });
                this.searchResListController.render();
			});
			
			describe('when rendered', function () {
                it('should display resutls', function() {
                   expect(this.searchResListController.$('.corpName').length).toEqual(4);
                   expect($(this.searchResListController.$('.corpName')[1]).html()).toEqual('CMPD-1234-Cl');
                });
			});
           
        });
		
		describe('Search Results Controller', function () {
		
			beforeEach(function () {
				this.searchResultsController = new SearchResultsController({
                    el: $(".SearchResultsView"),
                    collection: new Backbone.Collection(window.searchResultJSON)
                });
                this.searchResultsController.render();
			});
			
			describe('when rendered', function () {
                it('should be hidden new first created',function() {
                   expect($(this.searchResultsController.el).is(':visible')).toBeFalsy(); 
                });
                it('should display results', function() {
                   expect(this.searchResultsController.$('.resultList .searchResult').length).toEqual(4);
                });
			});
            describe('operations',function() {
                beforeEach(function() {
                    this.searchResultsController.show();
                });
                it('Should be shown when used', function() {
                   expect($(this.searchResultsController.el).is(':visible')).toBeTruthy(); 
                });
                it('Should be hide when close pushed', function() {
                   this.searchResultsController.$('.closeButton').click();
                   expect($(this.searchResultsController.el).is(':visible')).toBeFalsy(); 
                });

            });
            
        });
    });
});



