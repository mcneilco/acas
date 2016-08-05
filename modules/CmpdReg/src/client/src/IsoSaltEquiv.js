$(function() {

	window.IsoSaltEquiv = Backbone.Model.extend({

		initialize: function() {
			if(window.configuration.serverConnection.connectToServer) {
				//NB We do not intend to save these seperately, rather in a single commit with new lots
				// However, we need this for testing
				this.urlRoot = window.configuration.serverConnection.baseServerURL+'isoSaltEquivs';
			} else {
				this.sync = Backbone.localSync;
				this.localStorage = new Store('IsoSaltEquivItems');
			}
		},

		defaults: {
			isosalt: null,
			equivalents: '',
			type: 'salt'
		},
		validate: function(attr) {
			var errors = new Array();
			if (attr.isosalt != null) {
				if(attr.isosalt.isNew) { // make sure it even has an isNew ('none' doesn't)
					if(attr.isosalt.isNew()) {
						errors.push({'attribute': 'isosalts', 'message': "Isotope or salt must be saved before adding to IsoSaltEquiv"});
					}
				}
			}
			if (attr.equivalents!=null) {
				if(isNaN(attr.equivalents)) {
					errors.push({'attribute': 'equivalents', 'message':  "Isotope or salt equivalents must be a Number" });
				}
			}
			if (errors.length > 0) {
                return errors;
            } else {
                // We need to copy the isosalt to a specific salt or isotope attr to somplify the server
                if(attr.isosalt!=null) {
                    if(this.get('type')=='salt') {
                        this.set({
                            salt: attr.isosalt,
                            isotope: null
                        });
                    } else {
                        this.set({
                            isotope: attr.isosalt,
                            salt: null
                        });
                    }
                }
            }
		}

	});

	window.IsoSaltEquivList = Backbone.Collection.extend({
		model: IsoSaltEquiv,

		getSetIsosalts: function() {
			var ta = this.select(function(ise) {
				return ise.get('isosalt') != null;
			});
			return new Backbone.Collection(ta);
		},

		comparator: function(member) {
			sortScrore = 0;
			if (member.get('type')=='salt') {
				if (member.isNew()) { sortScore = 1;
				} else { sortScore = 0; }
			} else {
				if (member.isNew()) { sortScore = 3;
				} else { sortScore = 2; }
			}

			return(sortScore);
		}
	});

	window.IsoSaltEquivController = Backbone.View.extend({
		template: _.template($('#LotForm_SaltForm_IsoSaltEquivView_template').html()),

		initialize: function(){
			_.bindAll(this, 'render', 'validationError', 'updateModel');
			this.model.bind('error',  this.validationError);
			this.isEditable = this.options.isEditable;
			this.valid = true;

		},

		render: function() {
			$(this.el).html(this.template());
			if(this.isEditable) {
				var existingAbbrev = "";
				if (this.model.get('isosalt')) { existingAbbrev = this.model.get('isosalt').get('abbrev'); }
				if(this.model.get('type')=='salt') {
					this.isosaltSelectController = new SaltSelectController({
						el: this.$('.isosalts'),
						collection: this.options.isosalts,
						existingAbbrev: existingAbbrev
					});
				} else {
					this.isosaltSelectController = new IsotopeSelectController({
						el: this.$('.isosalts'),
						collection: this.options.isosalts,
						existingAbbrev: existingAbbrev
					});
				}
				this.$('.isosalts').show();
				this.$('.isosaltsField').hide();
				this.$('.equivalents').removeAttr('disabled');
				this.isosaltSelectController.render();
			} else {
				this.$('.isosaltsField').val(this.model.get('isosalt').get('name'));

				this.$('.isosalts').hide();
				this.$('.isosaltsField').show();
				this.$('.isosaltsField').attr('disabled', true);
				this.$('.equivalents').attr('disabled', true);
			}
			if (!this.model.isNew()) {
				this.$('.equivalents').val(this.model.get('equivalents'));
			}
			if(this.model.get('type')=='salt') {
				this.$('.isosaltLabel').html('Salt:');
			} else {
				this.$('.isosaltLabel').html('Isotope:');
			}

			return this;
		},

		updateModel: function() {
			this.clearValidationErrors();
			this.valid = true;
			if(this.isosaltSelectController.selectedCid() == '') {
				this.model.set({
					isosalt: null,
					equivalents: null
				});
			} else {
				this.model.set({
					isosalt: this.options.isosalts.getByCid(this.isosaltSelectController.selectedCid()),
					equivalents: parseFloat(this.$('.equivalents').val())
				});
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
				self.trigger('notifyError', {owner: self.options.errorNotificationName, errorLevel: 'error', message: err.message});
				self.valid = false;
			});
		},

		clearValidationErrors: function() {
			var errorElms = this.$('.input_error');
			this.trigger('clearErrors', this.options.errorNotificationName);
			this.valid = true;

			_.each(errorElms, function(ee) {
				$(ee).removeClass('input_error');
			});
		}

	});


	window.IsoSaltEquivListController = Backbone.View.extend({

		initialize: function() {
			_.bindAll(this, 'addOne');
			this.collection.bind('add', this.addOne);

			this.isosaltEquivControllers = new Array;
			this.iseNum = 0;
		},

		render: function() {
			$(this.el).empty();

			var self = this;
			this.collection.each(function(ise) {
				$(self.el).append( self.makeIsoSaltEquivController(ise, self.iseNum++).render().el);

			});
		},

		addOne: function(isoe) {
			var isotopeEquivController = this.makeIsoSaltEquivController( isoe, this.iseNum++);
			$(this.el).append(isotopeEquivController.render().el);
		},

		updateModel: function() {
			this.trigger('updateModel');
		},

		isValid: function() {
			return _.all(this.isosaltEquivControllers, function(isec) {
				return isec.isValid();
			});
		},

		makeIsoSaltEquivController: function(model, iseNum) {
			if(model.get('type')=='salt') {
				var isos = this.options.salts;
			} else {
				var isos = this.options.isotopes;
			}
			var isec = new IsoSaltEquivController({
				model: model,
				isosalts: isos,
				errorNotificationName: model.get('type')+" equivalent "+iseNum,
				isEditable: this.options.isEditable
			});
			this.bind('updateModel',  isec.updateModel);

			if (this.options.errorNotifList!=null) {
				isec.bind('notifyError', this.options.errorNotifList.add);
				isec.bind('clearErrors', this.options.errorNotifList.removeMessagesForOwner);
			}

			this.isosaltEquivControllers.push(isec);

			return isec;
		}


	});


});
