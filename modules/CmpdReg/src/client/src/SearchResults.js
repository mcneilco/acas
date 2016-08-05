$(function() {

    window.SearchResultController = Backbone.View.extend({
        template: _.template($('#SearchResultView_template').html()),
        tagName: 'div',
        className: 'searchResult',

        events: {
            'click .detailsButton': 'openLot',
            'click .newLotButton': 'newLot'
        },

        initialize: function(){
            $(this.el).html(this.template());
            _.bindAll(this, 'render', 'openLot', 'newLot');
        },

        render: function() {
            this.$('.corpName').html(this.model.get('corpName'));
            this.$('.stereoCategory').html(this.model.get('stereoCategoryName'));
//            this.$('.stereoComment').html(this.model.get('stereoComment'));
            this.setupLotSelect();
	        this.structImage = new StructureImageController({
		        el: this.$('.resultImageWrapper'),
		        model: new Backbone.Model({
			        corpName: this.model.get('corpName'),
			        corpNameType: this.model.get('corpNameType'),
			        molStructure: this.model.get('molStructure')
		        })
	        });
	        this.structImage.render();
            var aliasController = new AliasesController({collection: new AliasCollection(this.model.get('parentAliases')), readMode: true})
            this.$('.bv_aliasesContainer').html(aliasController.render().el )

            return this;
        },

        setupLotSelect: function() {
            var lisb = window.configuration.metaLot.lotCalledBatch;
            var self = this;
	        if ( !window.configuration.metaLot.saltBeforeLot && this.model.get('lotIDs').length==1) {
		        this.$('.lotSelect').hide()
		        lid = this.model.get('lotIDs')[0];
		        if (lid.synthesisDate == null) {
			        var sd = "&lt;no date&gt;";
		        } else {
			        var sd = lid.synthesisDate;
		        }
		        this.$('.lotName').html("- "+(lisb?'Batch':'Lot')+' '+lid.lotNumber+" - "+sd);
	        } else {
		        this.$('.lotName').hide()
			    _.each(this.model.get('lotIDs'), function(lid) {
	                if (lid.synthesisDate == null) {
	                    var sd = "&lt;no date&gt;";
	                } else {
	                    var sd = lid.synthesisDate;
	                }
		            self.$('.lotSelect').append(self.make(
			            "option",
			            {value: lid.corpName},
			            (lisb?'Batch':'Lot')+' '+lid.lotNumber+" - "+sd
		            ));
	            });
	        }
        },

        openLot: function() {
	        if ( !window.configuration.metaLot.saltBeforeLot && this.model.get('lotIDs').length==1) {
		        this.trigger('openLot', this.model.get('lotIDs')[0].corpName);
	        } else {
                this.trigger('openLot', this.$('.lotSelect').val());
	        }
        },

        newLot: function() {
	        if ( !window.configuration.metaLot.saltBeforeLot && this.model.get('lotIDs').length==1) {
		        this.trigger('newLot', this.model.get('lotIDs')[0].corpName);
	        } else {
		        this.trigger('newLot', this.$('.lotSelect').val());
	        }
        }

    });

    window.SearchResultListController = Backbone.View.extend({
		initialize: function(){
            _.bindAll(this, 'openLot', 'newLot');
		},

		render: function() {
			$(this.el).empty();
			var self = this;

			this.collection.each(function(res){
        var resCont = new SearchResultController({model: res});
				$(self.el).append(resCont.render().el);
        resCont.bind('openLot', self.openLot);
        resCont.bind('newLot', self.newLot);
			});
		},
        openLot: function(id) {
            this.trigger('openLot', id);
        },
        newLot: function(id) {
            this.trigger('newLot', id);
        }
    });

    window.SearchResultsController = Backbone.View.extend({
        template: _.template($('#SearchResultsView_template').html()),

        events: {
            'click .backButton': 'back',
            'click .closeButton': 'close',
            'click .exportButton': 'exportSDF',
            'click .closeExportSDF': 'closeExportSDFPopUp'

        },

        initialize: function(){
            $(this.el).html(this.template());
            _.bindAll(this, 'render', 'close', 'back', 'openLot', 'newLot', 'exportSDF');
            if (this.options.searchResults != null) {
                this.searchResults = this.options.searchResults;
            } else {
                this.searchResults = {foundCompounds:[],lotsWithheld:false};
            }
            this.searchResListController = new SearchResultListController({
                el: this.$(".resultList"),
                collection: this.collection
            });
            this.searchResListController.bind('openLot', this.openLot);
            this.searchResListController.bind('newLot', this.newLot);
            this.hide();

        },

        render: function () {
            this.searchResListController.render();
            if (appController) {
                if (!appController.allowedToRegister()) {
                    this.$('.newLotButton').hide();
                }
            }

            return this;
        },

        show: function() {
            $(this.el).show();
        },

        hide: function() {
            $(this.el).hide();
        },

        close: function() {
            this.hide();
            if(appController) {appController.reset();}
        },

        back: function() {
            this.hide();
            if(appController) {appController.router.navigate('search',true);}
        },

        openLot: function(corpName) {
            this.trigger('openLot', corpName);

        },

        newLot: function(corpName) {
            this.trigger('newLot', corpName);

        },

        exportSDF: function() {
            $.ajax({
                type: "POST",
                url: "/cmpdReg/export/searchResults",
                data: JSON.stringify(this.searchResults),
                dataType: "json",
                contentType: 'application/json',
                success: (function(_this)
                {
                    return function(ajaxReturn){
                        return _this.exportedResults(ajaxReturn);
                    };
                })(this),
                //error: function(error) {
                //    console.log("error");
                //    console.log(error);
                //}

                error: (function(_this)
                {
                    return function(error){
                        return _this.errorExportingResults(error);
                    };
                })(this)
            });


        },

        exportedResults: function(ajaxReturn) {
            console.log("exportedResults");
            console.log(ajaxReturn);
            this.$('.bv_downloadSearchResultsSdf').show();
            this.$('.bv_exportSearchResultsMessage').html(ajaxReturn.summary);
            this.$('.bv_downloadSearchResultsMessage').show();
            this.$('.bv_downloadSearchResultsLink').attr("href",ajaxReturn.reportFilePath);
        },

        closeExportSDFPopUp: function() {
            this.$('.bv_downloadSearchResultsSdf').hide();
        },

        errorExportingResults: function(error) {
            console.log("error exporting results");
            console.log(error);
            this.$('.bv_downloadSearchResultsSdf').show();
            this.$('.bv_exportSearchResultsMessage').html(error.responseText);
            this.$('.bv_downloadSearchResultsMessage').hide();
        }

        });
});
