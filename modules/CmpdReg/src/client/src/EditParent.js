$(function () {

    window.EditParentSearch = Backbone.Model.extend({
        // this model has attributes molStructure and corpName, but we don't want them undefined by default
        validate: function(attributes) {
            var errors = new Array();
            if (attributes.molStructure==null && (attributes.corpName == "")) {
                errors.push({attribute: 'corpName', message: "Registration panel must have a structure OR corp name filled in"});
            } else if (attributes.molStructure!=null && (attributes.corpName != "")) {
                errors.push({attribute: 'corpName', message: "Registration panel must have a structure OR corp name filled in but not both"});
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
	        if(window.configuration.sketcher == 'marvin') {
		        this.useMarvin = true;
		        if (window.configuration.marvin.exportFormat) {
			        this.exportFormat = window.configuration.marvin.exportFormat;
		        }
	        } else if(window.configuration.sketcher == 'ketcher') {
		        this.useKetcher = true;
	        } else if(window.configuration.sketcher == 'maestro') {
		        this.useMaestro = true;
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
						var pastePromise = sketcherInstance.importStructure(null, self.options.parentModel.get('molStructure'));
						pastePromise.then(function() {}, function(error) {
							alert(error);
						});
			        }
			        self.show();
			        self.sketcherLoaded = true;
		        }, function (error) {
			        alert("Cannot retrieve searchMarvinSketch sketcher instance from iframe:" + error);
		        });

	        } else if (this.useKetcher) {
		        this.$('#editParentMarvinSketch').attr('src',"/lib/ketcher-2.0.0-alpha.3_custom/ketcher.html?api_path=/api/cmpdReg/ketcher/");
		        this.$('#editParentMarvinSketch').on('load', function () {
			        self.ketcher = self.$('#editParentMarvinSketch')[0].contentWindow.ketcher;
					self.ketcher.setMolecule(self.options.parentModel.get('molStructure'));
		        });
			} else if (this.useMaestro) {
				this.$('#editParentMarvinSketch').attr('src',"/CmpdReg/maestrosketcher/wasm_shell.html");
                MaestroJSUtil.getSketcher('#editParentMarvinSketch').then(function (maestro) {
					self.maestro = maestro;
                    if(self.options.parentModel.get('molStructure') != null && self.options.parentModel.get('molStructure') != "") {
						self.maestro.sketcherImportText(self.options.parentModel.get('molStructure'));
                    }
			        self.show();
			        self.sketcherLoaded = true;
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
					else if (molecule.indexOf("M  V30 COUNTS 0 0 0 0 0") > -1)
						mol = null;
			        else
				        mol = molecule;
			        editParentSearch.set({
				        molStructure: mol,
				        corpName: jQuery.trim(self.$('.corpName').val())
			        });
                    self.checkEditParentSearchNext(editParentSearch);
		        }, function(error) {
			        alert("Molecule export failed from search sketcher:"+error);
		        });

	        } else if (this.useKetcher) {
		        mol = this.ketcher.getMolfile();
				if (mol.indexOf("  0  0  0     1  0            999") > -1) mol = null;
		        editParentSearch.set({
			        molStructure: mol,
			        corpName: jQuery.trim(self.$('.corpName').val())
		        });

                self.checkEditParentSearchNext(editParentSearch);


	        } else if (this.useMaestro) {
				mol = this.maestro.sketcherExportMolBlock();
				if (mol.indexOf("M  V30 COUNTS 0 0 0 0 0") > -1) mol = null;
		        editParentSearch.set({
			        molStructure: mol,
			        corpName: jQuery.trim(self.$('.corpName').val())
		        });

                self.checkEditParentSearchNext(editParentSearch);
            } else {
		        alert("No edit parent sketcher configured in search action");
	        }

        },

        searchForParentCorpName: async function(corpName) {
            var editParentSearch = new EditParentSearch();
            editParentSearch.set({
                corpName: jQuery.trim(corpName)
            }, { silent: true });
            var url = window.configuration.serverConnection.baseServerURL+"regsearches/parent";

            response = await fetch( url, {
                method: 'POST',
                body: JSON.stringify(editParentSearch.attributes),
                headers: {
                    'Content-Type': 'application/json'
                }
            }).catch(function(error) {
                return null
            });
            json = await response.json();
            if(json.parents.length == 1) {
                return json.parents[0];
            } else {
                return null;
            }
        },

        checkEditParentSearchNext: async function(editParentSearch) {
            // If not valid then the validation error will be shown to the user as the errors are bound to the view.
            if(this.isValid()) {
                // In order to be able to show the structure in the next step, we need to do the main Edit Parent Search by mol structure and not by corp name
                // This is because the service fills in the image to the search results based on the mol structure passed to the search.
                // So if the structure is null, we need to search by name, fetch the structure and then trigger the main search with the structure.
                if(editParentSearch.get("molStructure") == null) {
                    parent = await this.searchForParentCorpName(editParentSearch.get('corpName'));
                    if(parent != null) {
                        molStructure = parent.molStructure;
                        editParentSearch.set({
                            molStructure: molStructure,
                            corpName: ""
                        }, { silent: true });
                        this.hide();
                    } else {
                        this.trigger('notifyError', {owner: "EditParentSearchController", errorLevel: 'error', message: "Could not find parent with name: " + editParentSearch.get('corpName')});
                        return
                    }
                }
                this.hide();
                this.trigger('editParentSearchNext', editParentSearch);
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
            'click .backToSearchButton': 'back',
            'click .reparentLotPick': 'reparentLotPick'
        },

        initialize: function(){
            _.bindAll(this, 'toggleParentsVisible', 'next', 'back', 'reparentLotPick');
            this.sketcherLoaded = false;
            this.hide();
            this.parentModel = this.options.parentModel;
            if(this.options.showReparentLot) {
                this.showReparentLot = true;
            }
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
                showReparentLot: this.showReparentLot,
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

        reparentLotPick: function(e) {
            el = $(e.target)
            newSelectedParentCorpName = el.val()
            if(typeof(this.reparentCorpNamePick) != 'undefined' && this.reparentCorpNamePick != null) {
                if(this.reparentCorpNamePick == newSelectedParentCorpName) {
                    el.prop('checked', false);
                    this.reparentCorpNamePick = null;
                } else {
                    this.reparentCorpNamePick = newSelectedParentCorpName;
                }
            } else {
                this.reparentCorpNamePick = newSelectedParentCorpName
            }
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

            // Determine if reparent lot is selected on any of the search results
            // If so, then pass the selected reparent name to the next step
            var reparentLotSelection = null
            if(this.showReparentLot) {
                reparentCorpName = this.$('.reparentLotPick:checked').val()
                if(typeof(reparentCorpName) != 'undefined' && reparentCorpName != null && reparentCorpName != '') {
                    reparentLotSelection = new window.Backbone.Model({
                        selectedCorpName: this.$('.reparentLotPick:checked').val(),
                        isVirtual: this.$('.isVirtual').is(':checked')
                    });
                }
            }
            this.trigger('editParentSearchResultsNext', selection, reparentLotSelection);
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
                'editParentSearchError',
                'editParentSearchNext',
                'editParentSearchResultsNext',
                'searchResultsBack',
                'updateParentBack');
            this.render();

            this.eNotiList = this.options.errorNotifList;
            this.parentModel = this.options.parentModel;

            // If passed a lot a re-parent lot workflow is shown as an option to the user
            this.lotModel = this.options.lotModel;

            this.searchController = new EditParentSearchController({
                el: $(".EditParentSearchView"),
                corpName: this.options.corpName,
                parentModel: this.parentModel,
                lotModel: this.lotModel
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

        editParentSearchNext: async function(searchEntries) {
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
                success: this.editParentSearchReturn,
                error: this.editParentSearchError
            });

        },

        editParentSearchError: function(jqXHR, textStatus, errorThrown) {
            this.trigger('clearErrors', "EditParentWorkflowController");
            this.delegateEvents(); // start listening to events
            this.trigger('notifyError', {owner: "EditParentWorkflowController", errorLevel: 'error', message: jqXHR.responseText});
            this.searchController.show();
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
                    parentModel: this.parentModel,
                    showReparentLot: this.lotModel != null
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

        editParentSearchResultsNext: function(selection, reparentLotSelection) {
            if(reparentLotSelection != null) {
                // Reparent lot workflow
                this.editParentSearchResultsToReparentLotStep(selection, reparentLotSelection);
            } else {
                this.editParentSearchResultsToEditParentStep(selection);
            }
        },

        editParentSearchResultsToEditParentStep: function(selection) {
            // Edit parent workflow
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

        editParentSearchResultsToReparentLotStep: function(selection, reparentLotSelection) {
            // Edit parent workflow
            if( this.reparentLotController !=null ) {
                this.deleteReparentLotController();
            }
		    this.reparentLotController = new ReparentLotController({
                el: this.$('.ReparentLotView'),
                buttons: this.$('.ParentView .buttons'),
			    corpName: this.lotModel.get("corpName"),
			    parentCorpName: reparentLotSelection.get("selectedCorpName"),
			    errorNotifList: this.options.errorNotifList,
			    user: this.user
		    });
            this.reparentLotController.show();
            this.reparentLotController.bind('back', this.updateParentBack);

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

        deleteReparentLotController: function() {
            this.reparentLotController.delegateEvents({});
            this.reparentLotController = null;
            this.$('.ReparentLotView').html('');
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
