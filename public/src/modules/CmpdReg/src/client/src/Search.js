$(function () {

    window.SearchController = Backbone.View.extend({
		template: _.template($('#SearchView_template').html()),

		events: {
		},

		initialize: function(){
			_.bindAll(this, 'searchReturn', 'searchNext', 'openLot', 'newLot');
            this.render();

            this.eNotiList = this.options.errorNotifList;
            this.searchController = new SearchFormController({
                el: $(".SearchFormView")
            });


            this.searchController.bind('notifyError', this.eNotiList.add);
            this.searchController.bind('clearErrors', this.eNotiList.removeMessagesForOwner);
            this.searchController.bind('searchNext', this.searchNext);
            this.bind('notifyError', this.eNotiList.add);
            this.bind('clearErrors', this.eNotiList.removeMessagesForOwner);
            this.startSearch();
		},

        startSearch: function() {
            this.searchController.render();
            this.searchController.show();
//            this.searchController.loadMarvin();
        },

        searchNext: function(searchEntries) {
            this.trigger('clearErrors', "SearchController");
            this.searchEntries = searchEntries;

			if(window.configuration.serverConnection.connectToServer) {
                var url = window.configuration.serverConnection.baseServerURL+"search/cmpds";
            } else {
                var url = "spec/testData/Search.php";
            }
            
            this.lastSearchStruct = this.searchEntries.get('molStructure');
            this.trigger('notifyError', {
                owner: 'SearchController',
                errorLevel: 'warning',
                message: 'Searching...'
            });
            this.delegateEvents({}); // stop listening to buttons
            var self = this;
//            $.getJSON(
//                url,
//                {searchParams: JSON.stringify(this.searchEntries)},
//                this.searchReturn
//            )
//            .error(function(error) {
//                self.trigger('clearErrors', "SearchController");
//                var resp = $.parseJSON(error.responseText);
//                _.each(resp, function(err) {
//                    self.trigger('notifyError', {owner: "SearchController", errorLevel: err.level, message: err.message});
//                    self.searchController.show();
//                });
//                self.delegateEvents(); // start listening to events
//            });


            $.ajax({
                type: "POST",
                url: url,
                data: JSON.stringify(this.searchEntries),
                dataType: "json",
                contentType: 'application/json',
                success: this.searchReturn,
                error: function(error) {
                    self.trigger('clearErrors', "SearchController");
                    var resp = $.parseJSON(error.responseText);
                    _.each(resp, function(err) {
                        self.trigger('notifyError', {owner: "SearchController", errorLevel: err.level, message: err.message});
                        self.searchController.show();
                    });
                    self.delegateEvents(); // start listening to events
                }
            });

        },
        searchReturn: function(ajaxReturn) {
            this.trigger('clearErrors', "SearchController");
            this.delegateEvents(); // start listening to events
            this.searchResults = ajaxReturn;
            if(this.searchResults.length>0){
                if( this.searchResultsController !=null ) {
                    this.deleteSearchResultsController();
                }
                this.searchResultsController = new SearchResultsController({
                    el: $(".SearchResultsView"),
                    collection: new Backbone.Collection(this.searchResults)
                });

                this.searchResultsController.render();
                this.searchResultsController.bind('openLot', this.openLot);
                this.searchResultsController.bind('newLot', this.newLot);
                this.searchResultsController.show();
                if(appController) {appController.router.navigate('searchResults');}
            } else {
                this.trigger('notifyError', {owner: "SearchController", errorLevel: 'warning', message: "No lots match your search criteria"});
                this.searchController.show();
            }
        },
        openLot: function(corpName) {

            window.open("#lot/"+corpName);
        },
        newLot: function(corpName) {

            window.open("#register/"+corpName);
        },
        registerNewLot: function(id) {

        },

//        lotBack: function() {
//            this.searchResultsController.show();
//        },

        deleteSearchResultsController: function() {
            this.searchResultsController.delegateEvents({});
            this.searchResultsController = null;
            this.$('.SearchResultsView').html('');
        },

		render: function () {
            $(this.el).html(this.template());
            this.hideWrappers();
			return this;
		},
        hideWrappers: function() {
            this.$('.RegistrationSearchView').hide();
            this.$('.RegSearchResultsView').hide();
            this.$('.MetaLotView').hide();
        }
    });

});
