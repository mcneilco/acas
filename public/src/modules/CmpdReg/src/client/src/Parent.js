$(function() {

	window.Parent = Backbone.Model.extend({
		defaults: {
            stereoCategory: null,
            stereoComment: '',
            //commonName: '',
            compoundType: null,
            parentAnnotation: null,
            molStructure: '',
            comment: '',
            corpName: '',
            chemist: null,
			isMixture: false
		},

		initialize: function() {

			// If this was saved, we'll initialize from a json object
			// that is part of the wrapping object
			if (this.has('json') ) {
				var js = this.get('json');
				this.set({
					id: js.id,
                    corpName: js.corpName,
                    molStructure: js.molStructure,
                    stereoCategory: new PickList(js.stereoCategory),
                    stereoComment: js.stereoComment,
                    commonName: js.commonName,
                    molWeight: js.molWeight,
					exactMass: js.exactMass,
                    molFormula: js.molFormula,
					comment: js.comment,
                    chemist: new PickList(js.chemist),
					parentAliases: new AliasCollection(js.parentAliases),
					registrationDate: js.registrationDate,
					cdId: js.cdId,
					parentNumber: js.parentNumber,
					isMixture: js.isMixture

				}, {silent: true});

				if (window.configuration.metaLot.showSelectCompoundTypeList) {
					this.set({
						compoundType: new PickList(js.compoundType)
					}, {silent: true});
				};

				if (window.configuration.metaLot.showSelectParentAnnotationList) {
					this.set({
						parentAnnotation: new PickList(js.parentAnnotation)
					}, {silent: true});
				}

			};
		},

		validate: function(attr) {
			var errors = new Array();
//			if (attr.stereoCategory != null) {
//				if(!/\S/g.test(attr.stereoCategory)) {
//					errors.push({attribute: 'stereoCategory', message: "Stereo Category must be set"});
//				}
//			}
			if (attr.corpName != null) {
				if(!/\S/g.test(attr.corpName)) {
					errors.push({attribute: 'corpName', message: "Corp Name must be set"});
				}
			}
			if (attr.molStructure != null) {
				if(!/\S/g.test(attr.molStructure)) {
					errors.push({attribute: 'molStructure', message: "Structure must be set"});
				}
			}
			if (attr.stereoCategory != null && attr.stereoComment !=null) {
                if (attr.stereoCategory.get('code')=='see_comments' && attr.stereoComment=='') {
                    errors.push({attribute: 'stereoComment', message: "If stereo category is see comments, a comment must be supplied"});
                }
            }
			if (attr.stereoCategory != null) {
                if (attr.stereoCategory.get('code')=='not_set') {
                    errors.push({attribute: 'stereoCategoryCode', message: "Stereo category must be supplied"});
                }
            }
			if (window.configuration.metaLot.showSelectCompoundTypeOption && attr.compoundType != null) {
                if (attr.compoundType.get('code')=='not_set') {
                    errors.push({attribute: 'compoundTypeCode', message: "Compound type must be supplied"});
                }
            }
			if (errors.length > 0) {return errors;}
		},

		getModelForSave: function() {
			var mts = new Backbone.Model(this.attributes);
            mts.unset('json');
            mts.unset('molWeight');
            mts.unset('molFormula');
            mts.unset('molImage');
			return mts;
		}

	});



	window.ParentController = Backbone.View.extend({
		template: _.template($('#LotForm_ParentView_template').html()),

		events: {
			'click .editParentButton': 'editParent',
			'click .cancelUpdateParentButtonOn': 'cancel',
			'click .backUpdateParentButtonOn': 'back',
			'click .saveUpdateParentButtonOn': 'validateParent',
			'click .confirmUpdateParent': 'updateParentConfirmed',
			'click .cancelUpdateParent': 'cancelUpdateParent',
			'click .closeParentUpdatedPanel': 'showUpdatedMetalot'
		},

		initialize: function() {
			_.bindAll(this, 'validationError', 'setAliasToReadOnly', 'setAliasToEdit', 'render');
			this.model.bind('error',  this.validationError);
			this.valid = true;
			this.readMode = false;
			if (this.options.readMode) {
				this.readMode = this.options.readMode;
			}
			this.step = null
			if (this.options.step) {
				this.step = this.options.step;
			}

            if (this.options.errorNotifList!=null) {
				var eNoti = this.options.errorNotifList;
				if (this.model.isNew()) {
					this.bind('notifyError', eNoti.add);
					this.bind('clearErrors', eNoti.removeMessagesForOwner);
				}
			} else {
				var eNoti = null;
			}

		},

		render: function() {
			$(this.el).html(this.template());
            this.$('.radioWrapper').hide();

            if (window.configuration.metaLot.showSelectCategoryOption) {
	            var optionToInsert = new PickList({"code":"not_set","id":5,"name":"Select Category","version":0});
            } else {
	            var optionToInsert = null;
            }
            this.stereoCategoryCodeController =
                this.setupCodeController('stereoCategoryCode', 'stereoCategorys', 'stereoCategory', optionToInsert);

			if (window.configuration.metaLot.showSelectCompoundTypeList) {
				if (window.configuration.metaLot.showSelectCompoundTypeOption) {
					var optionToInsert = new PickList({
						"code": "not_set",
						"id": 6,
						"name": "Select Compound Type",
						"version": 0
					});
				} else {
					var optionToInsert = null;
				}
				this.compoundTypeCodeController =
					this.setupCodeController('compoundTypeCode', 'compoundTypes', 'compoundType', optionToInsert);

			} else {
				this.$('.bv_compoundTypeContainer').hide();
			}

			if (window.configuration.metaLot.showSelectParentAnnotationList) {
				if (window.configuration.metaLot.showSelectParentAnnotationOption) {
					var optionToInsert = new PickList({
						"code": null,
						"id": 7,
						"name": "Select High Value Annotation",
						"version": 0
					});
				} else {
					var optionToInsert = null;
				}
				this.parentAnnotationCodeController =
					this.setupCodeController('parentAnnotationCode', 'parentAnnotations', 'parentAnnotation', optionToInsert);

			} else {
				this.$('.bv_parentAnnotationContainer').hide();
			}

            this.$('.stereoComment').val(this.model.get('stereoComment'));
            this.$('.comment').val(this.model.get('comment'));
            //this.$('.commonName').val(this.model.get('commonName'));
            this.$('.molWeight').val(this.model.get('molWeight'));
            this.$('.molFormula').val(this.model.get('molFormula'));
            this.$('.exactMass').val(this.model.get('exactMass'));
			if(this.model.get('isMixture') == true) {
				this.$('.isMixture').attr('checked', true);
			}
			else {
				this.$('.isMixture').removeAttr('checked');
			}
			this.aliasController = new AliasesController({collection: this.model.get('parentAliases'), readMode: this.readMode, step: this.step})
			this.$('.bv_aliasesContainer').html(this.aliasController.render().el );
			if (!this.model.isNew()) {
                this.$('.stereoCategoryCode').attr('disabled', true);
                this.$('.stereoComment').attr('disabled', true);
                this.$('.compoundTypeCode').attr('disabled', true);
                this.$('.parentAnnotationCode').attr('disabled', true);
                this.$('.parentAnnotationCode').attr('disabled', true);
                this.$('.comment').attr('disabled', true);
				this.$('.isMixture').attr('disabled', true);
                //this.$('.commonName').attr('disabled', true);
				var user = window.AppLaunchParams.cmpdRegUser;
				if(user.code == this.model.get('chemist').get('code') || user.isAdmin)
					this.$('.editParentButtonWrapper').show();
				else
					this.$('.editParentButtonWrapper').hide();

            }
			else {
				this.$('.editParentButtonWrapper').hide();
			}
			if (this.readMode) {
				this.setAliasToReadOnly();
			} else {
				this.setAliasToEdit();
			}
            //if(window.configuration.clientUILabels.commonNameLabel) {
            //    this.$('.commonNameLabel').html(window.configuration.clientUILabels.commonNameLabel);
            //}

            if (this.model.get('molWeight') != null) {
                this.$('.molWeight').val(
                    parseFloat(this.model.get('molWeight')).toFixed(2)
                );
            }
			if (this.model.get('molStructure') != null ) {
				this.$('.copyButtonWrapper').show();
			} else {
				this.$('.copyButtonWrapper').hide();
			}

			this.renderStruct();

            return this;
		},

        setupCodeController: function(elClass, type, attribute, optionToInsert) {
            var tcode = '';
            if(this.model.get(attribute)) {
                tcode = this.model.get(attribute).get('code');
            }
			return new PickListSelectController({
				el: this.$('.'+elClass),
				type: type,
                selectedCode: tcode,
                insertFirstOption: optionToInsert
			})
        },
		setAliasToReadOnly: function() {
			this.aliasController.setToReadOnly();
		},
		setAliasToEdit: function() {
			this.aliasController.setToEditMode();
		},
        updateModel: function() {
			this.clearValidationErrors();

            this.model.set({
                stereoComment: this.$('.stereoComment').val(),
                comment: this.$('.comment').val(),
                stereoCategory: this.stereoCategoryCodeController.getSelectedModel(),
                //commonName: this.$('.commonName').val(),
				parentAliases: this.aliasController.collection.toJSON(),
				isMixture: this.$('.isMixture').attr('checked') == 'checked'
		});

			if(this.compoundTypeCodeController != null){
				this.model.set({compoundType: this.compoundTypeCodeController.getSelectedModel()})
			};
			if(this.parentAnnotationCodeController != null){
				this.model.set({parentAnnotation: this.parentAnnotationCodeController.getSelectedModel()})
			};
		},
		editParent: function() {
			var self = this;
			self.trigger('editParentRequest', self.model);
		},

		cancel: function() {
			window.location.reload();
		},

		back: function() {
			this.trigger('updateParentBack');
			this.hide()
		},

		hide: function() {
			$(this.el).hide();
		},

		isValid: function() {
			return this.valid;
		},

		validationError: function(model, errors) {
			this.clearValidationErrors();
			var self = this;
			_.each(errors, function(err) {
				self.$('.'+err.attribute).addClass('input_error');
				self.trigger('notifyError', {owner: "ParentController", errorLevel: 'error', message: err.message});
				self.valid = false;
			});
		},

		clearValidationErrors: function() {
			var errorElms = this.$('.input_error');
			this.trigger('clearErrors', "ParentController");
			this.valid = true;

			_.each(errorElms, function(ee) {
				$(ee).removeClass('input_error');
			});
		},
 		renderStruct: function(){
		    if (this.model.isNew()) {
			    var structImage = new Backbone.Model({
				    molImage: this.model.get('molImage'),
				    molStructure: this.model.get('molStructure')
			    })
		    } else {
			    var structImage =  new Backbone.Model({
				    corpName: this.model.get('corpName'),
				    corpNameType: "Parent",
				    molStructure: this.model.get('molStructure')
			    })
		    }
		    this.structImage = new StructureImageController({
			    el: this.$('.parentImageWrapper'),
			    model: structImage
		    });
		    this.structImage.render();
		},

		validateParent: function(){
			this.$('.bv_saveUpdateParentButton').removeClass('saveUpdateParentButtonOn');
			this.$('.bv_saveUpdateParentButton').addClass('saveUpdateParentButtonOff');
			this.$('.bv_cancelUpdateParentButton').removeClass('cancelUpdateParentButtonOn');
			this.$('.bv_cancelUpdateParentButton').addClass('cancelUpdateParentButtonOff');
			this.$('.bv_backUpdateParentButton').removeClass('backUpdateParentButtonOn');
			this.$('.bv_backUpdateParentButton').addClass('backUpdateParentButtonOff');
			this.updateModel();
			$.ajax({
				type: "POST",
				url: window.configuration.serverConnection.baseServerURL+"validateParent",
				data: JSON.stringify(this.model),
				dataType: "json",
				contentType: 'application/json',
				success: (function(_this)
				{
					return function(ajaxReturn){
						return _this.validateParentReturn(ajaxReturn);
					};
				})(this)
			});
		},

		validateParentReturn: function(ajaxReturn){
			this.$('.ConfirmEditParentPanel').show();
			this.$('.ConfirmEditParentPanel').html($('#ConfirmEditParentPanel_template').html());
			var lotsAffectedMsg = "";
			_.each(ajaxReturn, function(lot){
				if (lotsAffectedMsg === ""){
					lotsAffectedMsg = "The following lots will be affected: "+lot.name;
				}
				else{
					lotsAffectedMsg += ", "+lot.name;
				}
			});
			lotsAffectedMsg += ".";
			this.$('.lotsAffected').html(lotsAffectedMsg);
		},

		updateParentConfirmed: function(){
			$.ajax({
				type: "POST",
				url: window.configuration.serverConnection.baseServerURL+"updateParent",
				data: JSON.stringify(this.model),
				dataType: "json",
				contentType: 'application/json',
				success: (function(_this)
				{
					return function(ajaxReturn){
						return _this.updateParentReturn(ajaxReturn);
					};
				})(this)
			});
		},

		updateParentReturn: function(ajaxReturn){
			this.$('.ConfirmEditParentPanel').hide();
			this.trigger('parentUpdated', ajaxReturn);
		},

		cancelUpdateParent: function(){
			this.$('.ConfirmEditParentPanel').hide();
			this.$('.bv_saveUpdateParentButton').addClass('saveUpdateParentButtonOn');
			this.$('.bv_saveUpdateParentButton').removeClass('saveUpdateParentButtonOff');
			this.$('.bv_cancelUpdateParentButton').addClass('cancelUpdateParentButtonOn');
			this.$('.bv_cancelUpdateParentButton').removeClass('cancelUpdateParentButtonOff');
			this.$('.bv_backUpdateParentButton').addClass('backUpdateParentButtonOn');
			this.$('.bv_backUpdateParentButton').removeClass('backUpdateParentButtonOff');
		},

		showUpdatedMetalot: function(){
			this.$('.ParentUpdatedPanel').hide();
			window.location.reload();
		}
	});

    window.RegParentController = ParentController.extend({

		render: function() {
			RegParentController.__super__.render.call(this);
			this.$('.editParentButtonWrapper').hide();
			return this;
		},

        setupForRegSelect: function(saltForms) {
            this.$('.regPick').val(this.model.get('corpName'));
            this.$('.corpName').html(this.model.get('corpName'));
            var lisb = window.configuration.metaLot.lotCalledBatch;
            this.$('.lotOrBatch').html(lisb?'batch':'lot');
            this.$('.radioWrapper').show();
            if (saltForms != null) {
                this.saltFormSelectCont = new SaltFormSelectController({
                    el: this.$('.saltFormCorpNames'),
                    collection: saltForms
                });
                this.saltFormSelectCont.render();
            } else {
                this.saltFormSelectCont = null;
                this.$('.saltFormCorpNames').hide();
            }

        },

        getSelectedMetaLot: function() {
            if (this.saltFormSelectCont != null) {
                var sf = this.saltFormSelectCont.getSelectedSaltForm();
            } else {
                var sf = null;
            }
            if ( sf==null ) {sf = new SaltForm();}
            return new MetaLot({
                    saltForm: sf,
                    parent: this.model,
                    lot: new Lot()
            });
        }

    });




});
