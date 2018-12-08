$(function() {

	window.MetaLot = Backbone.Model.extend({

		initialize: function() {
			if (this.has('json') ) {
				var lotjs = this.get('json');


                // Depending on mode,
                // json comes in with lot->saltForm->parent hierarchy,
                // or lot->saltForm lot->parent
                // but MetaLot is programmed flat to be compatible with other models
                // Flatten here
                if (window.configuration.metaLot.saltBeforeLot) {
                    if (lotjs.lot.saltForm){
                        if (lotjs.lot.saltForm.parent){
                            this.set({parent: new Parent({json: lotjs.lot.saltForm.parent})});
                        } else {
	                        this.set({parent: new Parent({
	                        	molStructure: this.get('parentStructure'),
				                    molWeight: this.get('molWeight'),
				                    molFormula: this.get('molFormula')
	                        	})});
                        }
                        lotjs.lot.saltForm.isosalts = lotjs.isosalts;
                        this.set({saltForm: new SaltForm({json: lotjs.lot.saltForm})});
                    } else {
                        this.set({saltForm: new SaltForm()});
                    }
                } else {
                    if (lotjs.lot.parent){
                        if (lotjs.lot.saltForm) {
                            lotjs.lot.parent.parentAliases = lotjs.lot.saltForm.parent.parentAliases;
                        }
                        this.set({parent: new Parent({json: lotjs.lot.parent})});
                    } else {
                        this.set({parent: new Parent({
                        	molStructure: this.get('parentStructure'),
			                    molWeight: this.get('molWeight'),
			                    molFormula: this.get('molFormula')
                        	})});
                    }
                    if (lotjs.lot.saltForm){
                        lotjs.lot.saltForm.isosalts = lotjs.isosalts;
                        this.set({saltForm: new SaltForm({json: lotjs.lot.saltForm})});
                    } else {
                        this.set({saltForm: new SaltForm()});
                    }
                }
				if (lotjs.fileList == undefined) {
					lotjs.lot.fileList = [];
				} else {
					lotjs.lot.fileList = lotjs.fileList;
				}

                this.set({lot: new Lot({json: lotjs.lot})});
			} else if ( this.has('parentStructure') ) {
				this.set({
                    saltForm: new SaltForm(),
                    parent: new Parent({
                    	molStructure: this.get('parentStructure'),
                    	molImage: this.get('parentImage'),
	                    molWeight: this.get('molWeight'),
	                    molFormula: this.get('molFormula')
                    }),
                    lot: new Lot({isVirtual: this.get('isVirtual')})
                });
			}
		},

		getModelForSave: function() {
            var sf = this.get('saltForm').getModelForSave()

            if (window.configuration.metaLot.saltBeforeLot) {
                sf.set({
                    parent: this.get('parent').getModelForSave()
                });
            }

            var lot = this.get('lot').getModelForSave();
            lot.set({saltForm: sf});

            if (!window.configuration.metaLot.saltBeforeLot) {
                lot.set({parent: this.get('parent').getModelForSave()});
            }
            sf.get('isosalts').each(function(isosalt){
            	if (isosalt.get('type') == 'salt') isosalt.set({salt:isosalt.get('isosalt')})
            	else if (isosalt.get('type') == 'isotope') isosalt.set({isotope:isosalt.get('isosalt')})
            	isosalt.unset('isosalt');
            })
            var mts = new Backbone.Model({
                lot: lot,
                fileList: new Backbone.Collection(lot.get('fileList')),
                isosalts: sf.get('isosalts')
            });
            mts.get('lot').unset('fileList');
            mts.get('lot').get('saltForm').unset('isosalts');
            return mts;
		}

	});


    window.MetaLotController = Backbone.View.extend({
	    template: _.template($('#MetaLotView_template').html()),

	    events: {
		    'click .saveButton': 'save',
		    'click .backButton': 'back',
		    'click .cancelButton': 'close',
		    'click .newLotButton': 'newLot'
	    },

	    initialize: function () {
		    //TODO the template load be in render(), but saltFormController won't work that way, unless I new it in the render'
		    $(this.el).html(this.template());
		    _.bindAll(this, 'save', 'back', 'newLot', 'newLotSaved', 'lotUpdated', 'editParentRequest', 'handleLotControllerReadyForRender');

		    var eNoti = this.options.errorNotifList;

		    if (this.options.user) {
			    this.user = this.options.user;
			    if (this.model.get('lot').isNew()) {
				    this.model.get('lot').set({chemist: this.user});
			    }
		    } else {
			    this.user = null;
		    }
		    this.parentController = new ParentController({
			    model: this.model.get('parent'),
			    el: this.$('.LotForm_ParentView'),
			    errorNotifList: eNoti,
			    readMode: false,
			    isEditable: this.parentAllowedToUpdate()
		    });
		    this.parentController.bind('editParentRequest', this.editParentRequest);
		    this.salts = new Salts()
		    this.salts.fetch();
		    this.isotopes = new Isotopes();
		    this.isotopes.fetch();
		    this.saltFormController = new SaltFormController({
			    model: this.model.get('saltForm'),
			    salts: this.salts,
			    isotopes: this.isotopes,
			    el: this.$('.LotForm_SaltFormView'),
			    errorNotifList: eNoti,
			    isEditable: this.saltFormAllowedToUpdate()
		    });
		    this.lotController = new LotController({
			    model: this.model.get('lot'),
			    el: this.$('.LotForm_LotView'),
			    errorNotifList: eNoti
		    });

		    if (eNoti != null) {
			    this.bind('notifyError', eNoti.add);
			    this.bind('clearErrors', eNoti.removeMessagesForOwner);
		    }

		    this.saveInProgress = false;
	    },
	    render: function () {
		    this.setupButtonsAndTitles();

		    this.parentController.render();
		    this.saltFormController.render();
		    if (this.model.get('lot').get('isVirtual')) {
			    this.saltFormController.hide();
			}
			if(typeof(this.lotController.triggerReadyForRender) == 'function') {
				this.lotController.bind('readyForRender', this.handleLotControllerReadyForRender);
				if(this.lotController.readyForRender == true) {
					this.lotController.render()
				}
			} else {
				this.lotController.render();
			}
		    if (!this.allowedToUpdate()) {
			    this.lotController.disableAll();
			    this.parentController.setAliasToReadOnly();
		    } else {
			    this.parentController.setAliasToEdit();
		    }

		    this.$('.NewLotSuccessView').hide();
		    if (appController) {
			    appController.setDocumentTitle(this.model.get('lot').get('corpName'));
		    }

		    return this;
	    },
		handleLotControllerReadyForRender: function() {
			this.lotController.render();
		},
	    setupButtonsAndTitles: function () {
		    var lisb = window.configuration.metaLot.lotCalledBatch;
		    if (this.model.get('lot').isNew()) {
			    this.$('.newLotButton').hide();
			    this.$('.saveButton').addClass('saveImage');
			    this.$('.saveButton').removeClass('updateImage');
			    this.$('.cancelButton').addClass('cancelImage');
			    this.$('.cancelButton').removeClass('closeImage');
			    if (!this.model.get('saltForm').isNew() && !this.model.get('parent').isNew()) {
				    this.$('.formTitle').html('New ' + (lisb ? 'batch' : 'lot') + ' of ' + this.model.get('saltForm').get('corpName'));
			    }
			    if (this.model.get('saltForm').isNew() && !this.model.get('parent').isNew()) {
				    if (window.configuration.metaLot.saltBeforeLot) {
					    this.$('.formTitle').html('New Salt of ' + this.model.get('parent').get('corpName'));
				    } else {
					    this.$('.formTitle').html('New ' + (lisb ? 'Batch' : 'Lot') + ' of ' + this.model.get('parent').get('corpName'));
				    }
			    }
			    if (this.model.get('parent').isNew()) {
				    this.$('.formTitle').html('New compound and ' + (lisb ? 'batch' : 'lot'));
			    }
			    if (this.model.get('lot').get('isVirtual')) {
				    this.$('.formTitle').html('New virtual ' + (lisb ? 'batch' : 'lot'));
			    }

		    } else {
			    this.$('.saveButton').removeClass('saveImage');
			    this.$('.saveButton').addClass('updateImage');
			    this.$('.cancelButton').removeClass('cancelImage');
			    this.$('.cancelButton').addClass('closeImage');
			    this.$('.backButton').hide();
			    if (this.allowedToUpdate()) {
				    this.$('.formTitle').html('Edit ' + (lisb ? 'Batch' : 'Lot') + ' ' + this.model.get('lot').get('corpName'));
			    } else {
				    this.$('.formTitle').html((lisb ? 'Batch' : 'Lot') + ' Details for ' + this.model.get('lot').get('corpName'));
			    }
			    this.$('.newLotButton').show();
			    if (this.model.get('lot').get('isVirtual')) {
				    this.$('.newLotButton').hide();
				    this.$('.saveButton').hide();
			    }
			    if (!this.allowedToUpdate()) {
				    this.$('.saveButton').hide();
			    }
			    console.log("about to load inventory");
			    console.log(window.configuration.metaLot.showLotInventory);
			    if (window.configuration.metaLot.showLotInventory) {
				    this.$('.bv_lotInventory').append("<iframe src=\"/lotInventory/index/"+this.model.get('lot').get('corpName')+"\" frameBorder=\"0\"></iframe>")
			    }

		    }

	    },

	    save: function () {
		    if (this.saveInProgress) {
			    return;
		    }
		    this.saveInProgress = true;
		    this.trigger('clearErrors', "MetaLotController");
		    this.updateModel();
		    mlself = this;
		    this.saltFormController.updateModel(function () {
			    if (mlself.saltFormController.model.isNew()) {
				    mlself.saltFormController.model.set({
					    'chemist': mlself.lotController.model.get('chemist')
				    });
			    }

			    if (!mlself.isValid()) {
				    mlself.saveInProgress = false;
				    return;
			    }

			    var mts = mlself.model.getModelForSave();

			    if (mlself.model.get('lot').isNew()) {
				    var successFunct = mlself.newLotSaved;
			    } else {
				    var successFunct = mlself.lotUpdated;
			    }

			    if (window.configuration.serverConnection.connectToServer) {
				    var url = window.configuration.serverConnection.baseServerURL + "metalots";
			    } else {
				    var url = "spec/testData/Lot.php";
			    }

			    var lisb = window.configuration.metaLot.lotCalledBatch;
			    mlself.trigger('notifyError', {
				    owner: 'MetaLotController',
				    errorLevel: 'warning',
				    message: 'Saving ' + (lisb ? 'batch' : 'lot') + '...'
			    });
			    mlself.delegateEvents({}); // stop listening to buttons

			    $.ajax({
				    type: "POST",
				    url: url,
				    data: JSON.stringify(mts),
				    dataType: "json",
				    contentType: 'application/json',
				    success: successFunct,
				    error: function (error) {
					    mlself.trigger('clearErrors', "MetaLotController");
					    var resp = $.parseJSON(error.responseText);
					    _.each(resp, function (err) {
						    mlself.trigger('notifyError', {
							    owner: "MetaLotController",
							    errorLevel: err.level,
							    message: err.message
						    });
					    });
					    mlself.saveInProgress = false;
					    mlself.delegateEvents(); // start listening to events
				    }
			    });
		    });
	    },

	    editParentRequest: function (parent) {
		    this.trigger('clearErrors', "MetaLotController");
		    this.trigger('clearErrors', "LotController");
		    $(this.el).empty();
		    this.editParentWorkflowController = new EditParentWorkflowController({
			    el: $(this.el),
			    corpName: this.model.get('corpName'),
			    errorNotifList: this.options.errorNotifList,
			    user: this.user,
			    parentModel: parent
		    });
	    },

	    newLotSaved: function (message) {
			if(message.errors.length > 0){
				var error = message.errors;
				mlself.trigger('clearErrors', "MetaLotController");
				_.each(error, function (err) {
					mlself.trigger('notifyError', {
						owner: "MetaLotController",
						errorLevel: err.level,
						message: err.message
					});
				});
				mlself.delegateEvents(); // start listening to events
			}
			else {
				this.trigger('clearErrors', "MetaLotController");
				var newLotSuccessController = new NewLotSuccessController({
					el: this.$('.NewLotSuccessView'),
					corpName: message.metalot.lot.corpName,
					buid: message.metalot.lot.buid
				});
				newLotSuccessController.render();
				this.saveInProgress = false;
			}
	    },

	    lotUpdated: function (response) {
		    this.trigger('clearErrors', "MetaLotController");
		    this.trigger('lotSaved', response.metalot);// RestratioController listens but does nothing at the moment
		    _.each(response.errors, function (err) {
			    mlself.trigger('notifyError', {
				    owner: "MetaLotController",
				    errorLevel: err.level,
				    message: err.message
			    });
		    });
		    this.trigger('notifyError', {
			    owner: "MetaLotController",
			    errorLevel: "info",
			    message: "Lot save succesful"
		    });
		    // use the router / appController to re-render the form with the updated data
		    appController.updateLot(response.metalot);
		    this.saveInProgress = false;
	    },

	    back: function () {
		    this.trigger('lotBack');
		    this.hide();
	    },

	    updateModel: function () {
		    this.lotController.updateModel();
		    if (this.lotController.model.isNew() && this.user != null) {
			    this.lotController.model.set({
				    'registeredBy': this.user.get("code")
			    });
		    }
		    this.parentController.updateModel();
		    if (this.parentController.model.isNew()) {
			    this.parentController.model.set({
				    'chemist': this.lotController.model.get('chemist')
			    });
		    }
	    },

	    isValid: function () {
		    return (this.lotController.isValid() &&
		    this.saltFormController.isValid() &&
		    this.parentController.isValid());
	    },
	    show: function () {
		    $(this.el).show();
	    },

	    hide: function () {
		    $(this.el).hide();
	    },

	    close: function () {
		    this.hide();
		    appController.reset();
	    },

	    newLot: function () {
		    window.open("#register/" + this.lotController.model.get('corpName'));

	    },

	    allowedToUpdate: function () {
				var chemist = this.model.get('lot').get('chemist');
				var registeredBy = this.model.get('lot').get('registeredBy');

		    if (this.user == null || chemist == null || this.model.get('lot').isNew()) return true; // test mode or new

		    if (this.user.get('isAdmin')) {
			    return true;
		    }else if (!window.configuration.metaLot.disableEditMyLots && (this.user.get('code') == chemist || (registeredBy != null && this.user.get('code') == registeredBy))) {
				return true;
			} else {
			    return false;
		    }
	    },

	    saltFormAllowedToUpdate: function () {
		    if (!this.allowedToUpdate()) return false;

		    if (window.configuration.metaLot.saltBeforeLot && this.model.get('lot').isNew()
			    && !this.model.get('parent').isNew() && !this.model.get('saltForm').isNew()) {
			    return false;
		    } else {
			    return true;
		    }
	    },

	    parentAllowedToUpdate: function () {
		    if (!this.allowedToUpdate()) return false;

		    if (this.model.get('lot').isNew() ) {
			    return false;
		    } else {
			    return true;
		    }
	    }
    });
});
