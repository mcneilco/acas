$(function () {


    var AppRouter = Backbone.Router.extend({

        routes: {
            "search":                       "search",
            "register":                     "register",
            "register/:corpName":           "register",
            "lot/:corpName":                "lot",
/*             "":                             "reset", */
            "regSearchResults":             "showRegSearchResults"
        },

        initialize: function(options) {
            _.bindAll(this, 'search', 'register', 'lot', 'reset','showRegSearchResults');
            this.appController = options.appController;
        },

        search: function() {
            //console.log('got route to search');
            this.appController.startSearch();
        },

        register: function(corpName) {
            //console.log('got route to register '+corpName);
            this.appController.startRegister(corpName);

        },
        lot: function(corpName) {
            this.appController.openLot(corpName);
        },
        reset: function() {
            //console.log('got reset route');
            this.appController.reset();
        },
        showRegSearchResults: function() {
            this.appController.showRegSearchResults();
        }

    });


    window.AppController = Backbone.View.extend({

		template: _.template($('#AppControllerView_template').html()),

		events: {
			'click .registerButton': 'launchRegister',
            'click .searchButton': 'launchSearch',
            'click .applicationName': 'reset'
		},

		initialize: function(options){
			_.bindAll(this, 'render', 'startRegister','startSearch','launchRegister','launchSearch', 'reset', 'openLot', 'updateLot');
            this.options = options;
            this.user = this.options.user;

            this.render();

            this.eNotiList = new ErrorNotificationList();
            this.eNotiCont = new ErrorNotificationListController({
                el: this.$('.ErrrorNotificationListView'),
                collection: this.eNotiList
            });

            this.setDocumentTitle();
            this.router = new AppRouter({appController: this});
            Backbone.history.start();
        },
        render: function() {
            $(this.el).html(this.template());
            if (!this.allowedToRegister()){
                this.$('.registerButton').hide();
            } else {
                this.checkAllowCmpdRegistration();
            }

            this.$('.loggedInUser').html(this.user.get('name'));
            this.$('.logoutLink').attr("href",window.configuration.serverConnection.logoutURL);
            this.$('.applicationName').html(window.configuration.clientUILabels.applicationNameForTitleBar);
			return this;

        },
        startRegister: function(corpName) {
            if (!this.allowedToRegister()){return}

            if(this.registrationController==null) {
                this.registrationController = new RegistrationController({
                    el: '.RegistrationView',
                    corpName: corpName,
                    errorNotifList: this.eNotiList,
                    user: this.user
                });
            } else {
                this.registrationController.searchController.show();
                this.registrationController.searchResultsController.hide();
            }
            this.hideControls();
        },

        showRegSearchResults: function() {
            if(this.registrationController) {
                this.registrationController.mlController.hide();
                this.registrationController.searchResultsController.show();
            }
        },

        launchRegister: function() {
            if (!this.allowedToRegister()){return}
            this.router.navigate('register',true);
        },

        startSearch: function() {
            if(this.searchController==null) {
                this.searchController = new SearchController({
                    el: '.SearchView',
                    errorNotifList: this.eNotiList
                });
            } else {
                this.searchController.searchController.show();
                this.searchController.searchResultsController.hide();
            }
            this.hideControls();

        },
        launchSearch: function() {
            this.router.navigate('search',true);
        },

        hideControls: function() {
            this.$('.regAndSearchButtons').hide();
        },

        openLot: function(corpName) {
            this.trigger('clearErrors', "AppController");

			if(window.configuration.serverConnection.connectToServer) {
                var url = window.configuration.serverConnection.baseServerURL+"metalots/corpName/"+corpName+"/";
            } else {
                var url = "spec/testData/Lot.php?corpName="+corpName+"&saltBeforeLot="+window.configuration.metaLot.saltBeforeLot;
            }
            var self = this;
            $.getJSON(
                url,
                {},
                function(ajaxReturn) {
                    self.metaLot = new MetaLot({json: ajaxReturn});
                    self.setupMetaLotController();
                    self.$('.GetCmpdError').hide();
                }
            )
            .fail(function(error) {
                var resp = $.parseJSON(error.responseText);
                if(resp.errors != null) {
                    _.each(resp.errors, function (err) {
                        self.trigger('notifyError', {
                            owner: "AppController",
                            errorLevel: err.level,
                            message: err.message
                        });
                        self.searchResultsController.show();
                    });
                }
                else {
                    self.$('.MetaLotView').hide();
                    self.$('.GetCmpdError').show();
                }
            });
            this.hideControls();
        },

        updateLot: function(updatedLot) {
            this.metaLot = new MetaLot({json: updatedLot});
            this.setupMetaLotController();
            this.router.navigate("#lot/"+this.metaLot.get('lot').get('corpName'), {trigger: false, replace: true});
        },

        setupMetaLotController: function() {
            if (this.metaLotController != null) {
                this.metaLotController.remove();
                this.metaLotController.unbind();
                this.metaLotController.delegateEvents();
                this.$('.SearchView').after('<div class="MetaLotView"></div>');
            }
            this.metaLotController = new MetaLotController({
                el: this.$('.MetaLotView'),
                model: this.metaLot,
                errorNotifList: this.eNotiList,
                user: this.user
            });
            this.metaLotController.render();
//            this.metaLotController.bind('lotSaved', this.lotSaved);
            this.metaLotController.show();
        },

        showControls: function() {
            this.$('.regAndSearchButtons').show();
        },

        reset: function() {
            //console.log('got app controller reset');
            this.eNotiList.reset();
            this.searchController = null;
            this.$('.SearchView').empty();
            this.registrationController = null;
            this.$('.RegistrationView').empty();
            this.metaLot = null;
            this.metaLotController = null;
            this.$('.MetaLotView').empty();
            this.eNotiList.reset();
            this.showControls();
            this.router.navigate('');
            this.$('.GetCmpdError').hide();
/*             this.setDocumentTitle(); */
//			window.location.reload();
        },

        setDocumentTitle: function(title) {
            if (title==null) {
                title = window.configuration.clientUILabels.applicationNameForTitleBar;
            }
            document.title = title;
        },

        allowedToRegister: function() {
            if(this.user.get('isAdmin') || this.user.get('isChemist')) {
                return true;
            } else {
                return false;
            }
        },

        checkAllowCmpdRegistration: function() {
            this.$('.registerButton').hide();
            this.$('.searchButton').hide();
            this.$('.registerButtonDisabled').hide();
            $.ajax({
                type: 'GET',
                url: "/cmpdReg/allowCmpdRegistration",
                success: (function (_this) {
                    return function (allowRegResp) {
                        console.log("got allow cmpd registration");
                        if (!allowRegResp.allowCmpdRegistration) {
                            _this.$('.disableCmpdRegistrationMessage').show();
                            _this.$('.registerButton').hide();
                            _this.$('.registerButtonDisabled').show();
                            _this.$('.disableCmpdRegistrationMessage').html(allowRegResp.message);
                        }
                        else {
                            _this.$('.registerButton').show();
                            _this.$('.registerButtonDisabled').hide();
                        }
                        return _this.$('.searchButton').show();
                    };
                })(this),
                error: (function (_this) {
                    return function (err) {
                        console.log("error allow cmpd registration");
                        _this.$('.disableCmpdRegistrationMessage').show();
                        _this.$('.registerButton').hide();
                        _this.$('.registerButtonDisabled').show();
                        _this.$('.searchButton').show();
                        return _this.$('.disableCmpdRegistrationMessage').html(JSON.parse(err.responseText).message);
                    };
                })(this)
            });
        }

    });

});
