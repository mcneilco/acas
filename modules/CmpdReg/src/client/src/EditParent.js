$(function () {

    window.EditParentSearch = Backbone.Model.extend({
        // this model has attributes molStructure and corpName, but we don't want them undefined by default
        validate: function(attributes) {
            var errors = new Array();
            if (attributes.molStructure==null) {
                errors.push({attribute: 'corpName', message: "Registration panel must have a structure filled in"});
            }
            if (errors.length > 0) {return errors;}
        }
    });

    window.EditParentSearchController = Backbone.View.extend({
        template: _.template($('#EditParentSearch_template').html()),

        events: {
            'click .nextButton': 'next',
            'click .cancelEditButton': 'cancel'
        },

        initialize: function(){
            _.bindAll(this, 'next', 'cancel', 'render', 'validationError');
            this.valid = false;
            this.sketcherLoaded = false;
            this.exportFormat = "mol";
	        if(window.configuration.marvin) {
		        this.useMarvin = true;
		        if (window.configuration.marvin.exportFormat) {
			        this.exportFormat = window.configuration.marvin.exportFormat;
		        }
	        } else if(window.configuration.ketcher) {
		        this.useKetcher = true;
	        }
            this.hide();
        },

        render: function() {
            if (!this.sketcherLoaded) { // only load template once so we don't wipe out marvin
                $(this.el).html(this.template());
                if(this.options.corpName){
                    this.$('.corpName').val(this.options.corpName);
                }
            }

            this.hide();
            var self = this;
	        if (this.useMarvin) {
		        this.$('#editParentMarvinSketch').attr('src',"/CmpdReg/marvinjs/editorws.html");
		        MarvinJSUtil.getEditor("#editParentMarvinSketch").then(function (sketcherInstance) {
			        self.marvinSketcherInstance = sketcherInstance;
			        if (typeof window.marvinStructureTemplates !== 'undefined') {
				        for (i = 0; i < window.marvinStructureTemplates.length; i++) {
					        sketcherInstance.addTemplate(window.marvinStructureTemplates[i]);
				        }
			        }
			        self.show();
			        self.sketcherLoaded = true;
		        }, function (error) {
			        alert("Cannot retrieve searchMarvinSketch sketcher instance from iframe:" + error);
		        });

	        } else if (this.useKetcher) {
		        this.$('#editParentMarvinSketch').attr('src',"/lib/ketcher-2.0.0-alpha.3/ketcher.html?api_path=/api/chemStructure/ketcher/");
		        this.$('#editParentMarvinSketch').on('load', function () {
			        self.ketcher = self.$('#editParentMarvinSketch')[0].contentWindow.ketcher;
		        });
	        } else {
		        alert("No edit parent sketcher configured");
	        }

            return this;

        },

        show: function() {
            $(this.el).show();
        },

        hide: function() {
            $(this.el).hide();
        },

        cancel: function() {
            window.location.reload();
        },

        next: function() {
            this.clearValidationErrors();
            var editParentSearch = new EditParentSearch();
            editParentSearch.bind('error',  this.validationError);
            var mol;

            var self = this;
            if (this.useMarvin) {
		        this.marvinSketcherInstance.exportStructure(this.exportFormat).then(function (molecule) {
			        if (molecule.indexOf("0  0  0  0  0  0  0  0  0  0999") > -1)
				        mol = null;
			        else
				        mol = molecule;
			        editParentSearch.set({
				        molStructure: mol,
				        corpName: jQuery.trim(self.$('.corpName').val())
			        });

			        if ( self.isValid() ) {
				        self.trigger('editParentSearchNext', editParentSearch);
				        self.hide();
			        }
		        }, function(error) {
			        alert("Molecule export failed from search sketcher:"+error);
		        });

	        } else if (this.useKetcher) {
		        mol = this.ketcher.getMolfile();
		        if (mol=="")
		            mol = null;
                else
		            mol = molecule;
		        editParentSearch.set({
			        molStructure: mol,
			        corpName: jQuery.trim(self.$('.corpName').val())
		        });

		        if ( self.isValid() ) {
			        self.trigger('editParentSearchNext', editParentSearch);
			        self.hide();
		        }
            } else {
		        alert("No edit parent sketcher configured in search action");
	        }

        },
        isValid: function() {
            return this.valid;
        },
        validationError: function(model, errors) {
            this.clearValidationErrors();
            var self = this;
            _.each(errors, function(err) {
                self.$('.'+err.attribute).addClass('input_error');
                self.trigger('notifyError', {owner: "EditParentSearchController", errorLevel: 'error', message: err.message});
                self.valid = false;
            });
        },

        clearValidationErrors: function() {
            var errorElms = this.$('.input_error');
            this.trigger('clearErrors', "EditParentSearchController");
            this.valid = true;

            _.each(errorElms, function(ee) {
                $(ee).removeClass('input_error');
            });
        }


    });

    window.EditParentSearchResultsController = Backbone.View.extend({

        template: _.template($('#EditParentSearchResultsView_template').html()),

        events: {
            'click .nextButton': 'next',
            'click .cancelEditButton': 'cancel',
            'click .isVirtual': 'toggleParentsVisible',
            'click .backToSearchButton': 'back'
        },

        initialize: function(){
            _.bindAll(this, 'toggleParentsVisible', 'next');
            this.sketcherLoaded = false;
            this.hide();
            this.parentModel = this.options.parentModel;
        },

        render: function () {
            if (!this.sketcherLoaded) { // only load template once so we don't wipe out marvin
                $(this.el).html(this.template());
            }



            this.json = this.options.json;
            this.$('.asDrawnMolWeight').val(parseFloat(this.json.asDrawnMolWeight).toFixed(2));
            this.$('.asDrawnMolFormula').val(this.json.asDrawnMolFormula);
            if(this.json.asDrawnStructure==null || this.json.asDrawnStructure==''){
                this.$('.isVirtual').attr('disabled', true);
                this.$('[value^="new"]').attr('disabled', true);
                this.$('[value^="new"]').attr('checked', false);
                this.$('.ReqStruc').hide();
            } else {
                this.structImage = new StructureImageController({
                    el: this.$('.asDrawnStructure'),
                    model: new Backbone.Model({
                        molImage: this.json.asDrawnImage,
                        molStructure: this.json.asDrawnStructure
                    })
                });
                this.structImage.render();
            }

            this.parentListCont = new ParentListController({
                json: this.json.parents,
                el: '.EditParentSearchResults_ParentListView'
            });
            this.parentListCont.render()
            if(this.json.length==0) {
                this.$('.EditParentSearchResults_ParentListView').hide();
            }
            if(this.json.parents.length==0) {
                this.$('.EditParentSearchResultsWarning').hide()
            }
            if (window.configuration.regSearchResults) {
                if (window.configuration.regSearchResults.hideVirtualOption) {
                    this.$('.isVirtualContainer').hide()
                }
            }
            this.$('.EditParentSearchResults_ParentListView .RegSearchResults_ParentView .radioWrapper').hide();
            return this;
        },

        show: function() {
            $(this.el).show();
        },

        hide: function() {
            $(this.el).hide();
        },

        toggleParentsVisible: function() {
            if(this.$('.isVirtual').is(':checked')) {
                this.$('.EditParentSearchResults_ParentListView').hide();
                this.$("[name=regPick]").removeAttr("checked");
                this.$("[name=regPick]").filter("[value=new]").attr("checked","checked");
            } else {
                if(this.json.parents.length!=0) {
                    this.$('.EditParentSearchResults_ParentListView').show();
                }
            }
        },

        cancel: function() {
            window.location.reload();
        },

        back: function() {
            this.trigger('searchResultsBack');
            this.hide();
        },

        next: function() {
            this.clearValidationErrors();
            var selection = new window.Backbone.Model({
                isVirtual: this.$('.isVirtual').is(':checked'),
                parent: this.parentModel
            });
            selection.get('parent').set({
                molStructure: this.json.asDrawnStructure,
                molWeight: this.json.asDrawnMolWeight,
                molFormula: this.json.asDrawnMolFormula,
                molImage: this.json.asDrawnImage
            });
            this.trigger('editParentSearchResultsNext', selection);
            this.hide();
        },
        isValid: function() {
            return this.valid;
        },

        clearValidationErrors: function() {
            var errorElms = this.$('.input_error');
            this.trigger('clearErrors', "RegistrationSearchResultsController");
            this.valid = true;

            _.each(errorElms, function(ee) {
                $(ee).removeClass('input_error');
            });
        }
    });

    window.EditParentController = ParentController.extend({

        render: function(){
            EditParentController.__super__.render.call(this);
            this.$('.EditParentViewButtons').show();
            this.$('.editParentButtonWrapper').hide();
            this.$('.stereoCategoryCode').removeAttr('disabled');
            this.$('.stereoComment').removeAttr('disabled');
            this.$('.compoundTypeCode').removeAttr('disabled');
            this.$('.parentAnnotationCode').removeAttr('disabled');
            this.$('.parentAnnotationCode').removeAttr('disabled');
            this.$('.comment').removeAttr('disabled');
            this.$('.isMixture').removeAttr('disabled');
            return this;
        },

        renderStruct: function(){
            var structImage = new Backbone.Model({
                molImage: this.model.get('molImage'),
                molStructure: this.model.get('molStructure')
            });
            this.structImage = new StructureImageController({
                el: this.$('.parentImageWrapper'),
                model: structImage
            });
            this.structImage.render();
        }
    });

    window.EditParentWorkflowController = Backbone.View.extend({
        template: _.template($('#EditParentView_template').html()),

        initialize: function(){
            _.bindAll(
                this,
                'editParentSearchReturn',
                'editParentSearchNext',
                'editParentSearchResultsNext',
                'searchResultsBack',
                'updateParentBack');
            this.render();

            this.eNotiList = this.options.errorNotifList;
            this.parentModel = this.options.parentModel;


            this.searchController = new EditParentSearchController({
                el: $(".EditParentSearchView"),
                corpName: this.options.corpName,
                parentModel: this.parentModel
            });

            if(this.options.user) {
                this.user = this.options.user;
            } else {
                this.user = null;
            }

            this.searchController.bind('notifyError', this.eNotiList.add);
            this.searchController.bind('clearErrors', this.eNotiList.removeMessagesForOwner);
            this.searchController.bind('editParentSearchNext', this.editParentSearchNext);
            this.bind('notifyError', this.eNotiList.add);
            this.bind('clearErrors', this.eNotiList.removeMessagesForOwner);
            this.startSearch();
        },

        startSearch: function() {
            this.searchController.render();
            this.searchController.show();
        },

        editParentSearchNext: function(searchEntries) {
            this.trigger('clearErrors', "EditParentWorkflowController");
            this.searchEntries = searchEntries;
            if(window.configuration.serverConnection.connectToServer) {
                var url = window.configuration.serverConnection.baseServerURL+"regsearches/parent";
            } else {
                var url = "spec/testData/RegSearch.php";
                //TODO: add test route
            }
            this.trigger('notifyError', {
                owner: 'EditParentWorkflowController',
                errorLevel: 'warning',
                message: 'Searching...'
            });
            this.delegateEvents({}); // stop listening to buttons
            $.ajax({
                type: "POST",
                url: url,
                data: JSON.stringify(this.searchEntries),
                dataType: "json",
                contentType: 'application/json',
                success: this.editParentSearchReturn
            });

        },

        editParentSearchReturn: function(ajaxReturn) {
            this.trigger('clearErrors', "EditParentWorkflowController");
            this.delegateEvents(); // start listening to events
            this.editParentSearchResults = ajaxReturn;
            if (this.editParentSearchResults.parents.length==0 && this.searchEntries.get('molStructure')==null){
                this.trigger('notifyError', {owner: "EditParentWorkflowController", errorLevel: 'warning', message: "No parents match your search criteria, and no structure provided"});
                this.searchController.show();
            } else {
                //filter out the current parent
                var filteredParents = [];
                var self = this;
                _.each(this.editParentSearchResults.parents, function(cmpd) {
                    if (cmpd.id !== self.parentModel.id){
                        filteredParents.push(cmpd);
                    }
                });
                this.editParentSearchResults.parents = filteredParents;
                if( this.searchResultsController !=null ) {
                    this.deleteSearchResultsController();
                }
                this.searchResultsController = new EditParentSearchResultsController({
                    el: $('.EditParentSearchResultsView'),
                    json: this.editParentSearchResults,
                    parentModel: this.parentModel
                });
                this.searchResultsController.render();
                this.searchResultsController.bind('editParentSearchResultsNext', this.editParentSearchResultsNext);
                this.searchResultsController.bind('searchResultsBack', this.searchResultsBack);
                this.searchResultsController.bind('notifyError', this.eNotiList.add);
                this.searchResultsController.bind('clearErrors', this.eNotiList.removeMessagesForOwner);
                this.searchResultsController.show();
            }
            this.$('.editParentButtonWrapper').hide();
        },

        editParentSearchResultsNext: function(selection) {
            this.parentModel = selection.get('parent');
            if( this.parentController !=null ) {
                this.deleteParentController();
            }
            this.parentController = new EditParentController({
                model: this.parentModel,
                el: this.$('.ParentView'),
                errorNotifList:new ErrorNotificationList(),
                readMode: false
            });
            this.$('.ParentView').show();
            this.parentController.bind('updateParentBack', this.updateParentBack);
            this.parentController.bind('parentUpdated', this.parentUpdated);
            this.parentController.bind('clearEditParentErrors', (function(_this) {
                return function() {
                    return _this.eNotiList.reset();
                };
            })(this));
            this.parentController.render();
            this.$('.ParentView').prepend("<h1 class='formTitle EditParentStepThreeTitle'>Edit Parent Step Three: Update Parent Attributes</h1>");//fiona
        },

        parentUpdated: function(ajaxReturn){
            this.$('.ParentUpdatedPanel').show();
            this.$('.ParentUpdatedPanel').html($('#ParentUpdatedPanel_template').html());
            var updatedLotsMsg = "";
            _.each(ajaxReturn, function(lot){
            	if (updatedLotsMsg === ""){
                    updatedLotsMsg = "The following lots were affected: "+lot.name;
            	}
            	else{
                    updatedLotsMsg += ", "+lot.name;
            	}
            });
            updatedLotsMsg += ".";
            this.$('.updatedLotsMessage').html(updatedLotsMsg);

        },

        searchResultsBack: function() {
            this.eNotiList.reset();
            this.searchController.show();
        },

        updateParentBack: function() {
            this.eNotiList.reset();
            this.searchResultsController.show();
            this.$('.EditParentViewButtons').hide();
        },

        deleteSearchResultsController: function() {
            this.searchResultsController.delegateEvents({});
            this.searchResultsController = null;
            this.$('.EditParentSearchResultsView').html('');
        },

        deleteMlController: function() {
            this.mlController.delegateEvents({});
            this.mlController = null;
            this.$('.MetaLotView').html('');
        },

        deleteParentController: function() {
            this.parentController.delegateEvents({});
            this.parentController = null;
            this.$('.ParentView').html('');
        },

        render: function () {
            $(this.el).html(this.template());
            this.hideWrappers();
            return this;
        },

        hideWrappers: function() {
            this.$('.EditParentSearchView').hide();
            this.$('.EditParentSearchResultsView').hide();
            this.$('.MetaLotView').hide();
        }

    })

});
