$(function () {

    window.RegistrationController = Backbone.View.extend({
		template: _.template($('#RegistrationView_template').html()),

		events: {
		},

		initialize: function(){
			_.bindAll(
                this,
                'regSearchReturn',
                'registrationSearchNext',
                'searchResultsNext',
                'searchResultsBack',
                'lotSaved',
                'lotBack');
            this.render();

            $.ajax({
                type: 'GET',
                url: "/cmpdReg/allowCmpdRegistration",
                success: (function (_this) {
                    return function (allowRegResp) {
                        console.log("got allow cmpd registration");
                        if (allowRegResp.allowCmpdRegistration) {
                            return _this.finishSetupRegistration();
                        } else {
                            _this.$('.DisableCmpdRegistrationMessage').show();
                            _this.$('.newLotButton').hide();
                            _this.$('.editParentButtonDisabled').show();
                            return _this.$('.DisableCmpdRegistrationMessage').html(allowRegResp.message);
                        }
                    };
                })(this),
                error: (function (_this) {
                    return function (err) {
                        console.log("error allow cmpd registration");
                        _this.$('.DisableCmpdRegistrationMessage').show();
                        _this.$('.newLotButton').hide();
                        _this.$('.editParentButtonDisabled').show();
                        return _this.$('.DisableCmpdRegistrationMessage').html(JSON.parse(err.responseText).message);
                    };
                })(this)
            });
        },

        finishSetupRegistration: function() {
            this.eNotiList = this.options.errorNotifList;


            this.searchController = new RegistrationSearchController({
                el: $(".RegistrationSearchView"),
                corpName: this.options.corpName
            });

            if(this.options.user) {
                this.user = this.options.user;
            } else {
                this.user = null;
            }

            this.searchController.bind('notifyError', this.eNotiList.add);
            this.searchController.bind('clearErrors', this.eNotiList.removeMessagesForOwner);
            this.searchController.bind('registrationSearchNext', this.registrationSearchNext);
            this.bind('notifyError', this.eNotiList.add);
            this.bind('clearErrors', this.eNotiList.removeMessagesForOwner);
            this.startSearch();
		},

        startSearch: function() {
            this.searchController.render();
            this.searchController.show();
        },

        registrationSearchNext: function(searchEntries) {
            this.trigger('clearErrors', "RegistrationController");
            this.searchEntries = searchEntries;
			if(window.configuration.serverConnection.connectToServer) {
                var url = window.configuration.serverConnection.baseServerURL+"regsearches/parent";
            } else {
                var url = "spec/testData/RegSearch.php";
            }
            this.trigger('notifyError', {
                owner: 'RegistrationController',
                errorLevel: 'warning',
                message: 'Searching...'
            });
            this.delegateEvents({}); // stop listening to buttons
//            $.getJSON(
//                url,
//                {searchParams: JSON.stringify(this.searchEntries)},
//                this.regSearchReturn
//            );
            $.ajax({
                type: "POST",
                url: url,
                data: JSON.stringify(this.searchEntries),
                dataType: "json",
                contentType: 'application/json',
                success: this.regSearchReturn
            });

        },

        regSearchReturn: function(ajaxReturn) {
            this.trigger('clearErrors', "RegistrationController");
            this.delegateEvents(); // start listening to events
            this.regSearchResults = ajaxReturn;
            if (this.regSearchResults.parents.length==0 && this.searchEntries.get('molStructure')==null){
                this.trigger('notifyError', {owner: "RegistrationController", errorLevel: 'warning', message: "No parents match your search criteria, and no structure provided"});
                this.searchController.show();
            } else {
                if( this.searchResultsController !=null ) {
                    this.deleteSearchResultsController();
                }
                this.searchResultsController = new RegSearchResultsController({
                    el: $('.RegSearchResultsView'),
                    json: this.regSearchResults
                });
                this.searchResultsController.render();
                this.searchResultsController.bind('searchResultsNext', this.searchResultsNext);
                this.searchResultsController.bind('searchResultsBack', this.searchResultsBack);
                this.searchResultsController.bind('notifyError', this.eNotiList.add);
                this.searchResultsController.bind('clearErrors', this.eNotiList.removeMessagesForOwner);
                this.searchResultsController.show();
                if(appController) { appController.router.navigate('regSearchResults');}
            }
        },

        searchResultsNext: function(selection) {
            if(selection.get('selectedCorpName')=="new"){
                this.metaLot = new MetaLot({
                    parentStructure: this.regSearchResults.asDrawnStructure,
                    parentImage: this.regSearchResults.asDrawnImage,
                    molWeight: this.regSearchResults.asDrawnMolWeight,
                    molFormula: this.regSearchResults.asDrawnMolFormula,
                    isVirtual: selection.get('isVirtual')
                });
            } else {
                this.metaLot = selection.get('metaLot');
                // Note, this metaLot is assembled by RegParentController, about 3 layers down
            }
            this.metaLot.get('lot').set({asDrawnStruct: this.searchEntries.get('molStructure')});
            this.setupMetaLotController();
        },

        setupMetaLotController: function() {
            if( this.mlController != null) {
                this.deleteMlController();
            }
            this.mlController = new MetaLotController({
                el:this.$('.MetaLotView'),
                model: this.metaLot,
                errorNotifList: this.eNotiList,
                user: this.user
            });
            this.mlController.render();
            this.mlController.bind('lotSaved', this.lotSaved);
            this.mlController.bind('lotBack', this.lotBack);
//            if(!this.metaLot.get('lot').get('isVirtual')) {
//                this.mlController.saltFormController.loadMarvin(); // must load manualy post render
//            }
            this.mlController.show();
            if(appController) {appController.router.navigate('metaLotForm');}
        },

        lotSaved: function(response) {

        },

        searchResultsBack: function() {
            this.eNotiList.reset();
            this.searchController.show();
            if(appController) {appController.router.navigate('register',true);}
//            this.startSearch();
        },

        lotBack: function() {
            this.eNotiList.reset();
            this.searchResultsController.show();
            if(appController) {appController.router.navigate('regSearchResults',true);}
        },

        deleteSearchResultsController: function() {
            this.searchResultsController.delegateEvents({});
            this.searchResultsController = null;
            this.$('.RegSearchResultsView').html('');
        },

        deleteMlController: function() {
            this.mlController.delegateEvents({});
            this.mlController = null;
            this.$('.MetaLotView').html('');
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
