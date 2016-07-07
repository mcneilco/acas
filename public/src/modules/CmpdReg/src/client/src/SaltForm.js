$(function() {

	window.SaltForm = Backbone.Model.extend({
		defaults: {
			corpName: '',
			isosalts: null,
			chemist: null,
			casNumber: ''
		},

		initialize: function() {

			// If this was saved, we'll initialize from a json object
			// that is part of the wrapping object
			if (this.has('json') ) {
				var js = this.get('json');
				var isel = new IsoSaltEquivList();
				_.each( js.isosalts, function(isoe) {
					if (isoe.type == 'salt') {
						var iso = new Salt(isoe.salt);
					} else {
						var iso = new Isotope(isoe.isotope);
					}
					var ise = new IsoSaltEquiv({
						id: isoe.id,
						type: isoe.type,
						equivalents: isoe.equivalents,
						isosalt: iso
					});
					isel.add(ise);
				});
				this.set({
					id: js.id,
					corpName: js.corpName,
					casNumber: js.casNumber,
					isosalts: isel,
					molStructure: js.molStructure
				});

			} else if( this.isNew() ) {
				this.set({
			isosalts: new IsoSaltEquivList()
		});
			}
		},

		validate: function(attr) {
			var errors = new Array();
			// no validation rules required yet
			if (errors.length > 0) {return errors;}
		},

		addIsoSaltEquiv: function(ise) {
			this.get('isosalts').add(ise);
		},

		getModelForSave: function() {
			var mts = new Backbone.Model(this.attributes);
			mts.set({isosalts: this.get('isosalts').getSetIsosalts()});
			mts.unset('json');
			return mts;
		}

	});

	window.SaltFormController = Backbone.View.extend({
		template: _.template($('#LotForm_SaltFormView_template').html()),

		events: {
			'click .addSaltButton': 'showAddSaltPanel',
			'click .addIsotopeButton': 'showAddIsotopePanel',
	  'click .showSaltFormMarvin': 'toggleStructureView',
			'click .copyButton': 'copyMol',
			'click .copyPanelCloseButton': 'hideCopyMolPanel'
		},

		initialize: function() {
	  //TODO the template load should probably in render()
	  $(this.el).html(this.template());
	  this.$('.radioWrapper').hide();

			_.bindAll(this, 'showAddSaltPanel', 'validationError', 'updateModel', 'toggleStructureView', 'render');
			this.model.bind('error',  this.validationError);
			this.valid = true;
	  this.isEditable = this.options.isEditable;

			this.marvinLoaded = false; // load on demand, not default, to make testing more reliable and fast

			if ( this.isEditable ) {
				var isList = this.model.get('isosalts');
		var saltCount = 0;
		var isotopeCount = 0;

		for (var i=0 ; i<isList.length; i++) {
		  if (isList.at(i).get('type') == "salt") {
			saltCount++;
		  } else {
			isotopeCount++;
		  }
		}
		for (var i=saltCount ; i<3 ; i++) {
					  isList.add(new IsoSaltEquiv({type: 'salt'}));
		}
		for (var i=isotopeCount ; i<2 ; i++) {
					  isList.add(new IsoSaltEquiv({type: 'isotope'}));
		}

				this.newSaltController = new NewSaltController({el: this.$('.newSaltView'), collection: this.options.salts});
				this.newIsotopeController = new NewIsotopeController({el: this.$('.newIsotopeView'), collection: this.options.isotopes});
				this.$('.addIsosaltButtons').removeClass('hidden');
				this.$('.addIsosaltButtons').addClass('shown');
				this.$('.copyButtonWrapper').hide();
			} else {
				this.$('.newSaltView').addClass('hidden');
				this.$('.newIsotopeView').addClass('hidden');
			}

			if (this.options.errorNotifList!=null) {
				var eNoti = this.options.errorNotifList;
				if (this.isEditable) {
					this.newSaltController.bind('notifyError', eNoti.add);
					this.newSaltController.bind('clearErrors', eNoti.removeMessagesForOwner);
					this.newIsotopeController.bind('notifyError', eNoti.add);
					this.newIsotopeController.bind('clearErrors', eNoti.removeMessagesForOwner);
				}
				// this controller does not yet throw errors itself, only controllers it owns do
				// therefore don't need bind it to notification controller
				// If that changes, add bind here

			} else {
				var eNoti = null;
			}


			this.isosaltEquivListController = new IsoSaltEquivListController({
				el: this.$('.isosaltEquivListView'),
				collection: this.model.get('isosalts'),
				salts: this.options.salts,
				isotopes: this.options.isotopes,
				errorNotifList: eNoti,
		isEditable: this.isEditable
			});

		},

		updateModel: function(callback) {
			this.clearValidationErrors();
			this.model.set({
				casNumber: jQuery.trim(this.$('.casNumber').val())
			});
			if (this.isEditable) {
				// update this.model's isosalts list
				this.isosaltEquivListController.updateModel();

				var mol = '';
				if(this.marvinLoaded && this.$('.structureWrapper').is(':visible')) {
					self = this;
					this.marvinSketcherInstance.exportStructure("mol").then(function(molecule) {
						if ( molecule.indexOf("0  0  0  0  0  0  0  0  0  0999")>-1)
							mol = '';
						else
							mol = molecule;
						self.model.set({molStructure: mol});
						callback();
					}, function(error) {
						alert("Molecule export failed from search sketcher:"+error);
					});
				} else {
		  this.model.set({molStructure: mol});
					callback();
				}
			} else {
				callback();
			}

		},

		isValid: function() {
			if( !this.isosaltEquivListController.isValid()) {
				this.valid = false;
			}
			return this.valid;
		},

		validationError: function(model, errors) {
			this.clearValidationErrors();
			var self = this;
			_.each(errors, function(err) {
				self.$('.'+err.attribute).addClass('input_error');
				self.trigger('notifyError', {owner: "SaltFormController", errorLevel: 'error', message: err.message});
				self.valid = false;
			});
		},

		clearValidationErrors: function() {
			var errorElms = this.$('.input_error');
			this.trigger('clearErrors', "SaltFormController");
			this.valid = true;

			_.each(errorElms, function(ee) {
				$(ee).removeClass('input_error');
			});
		},

		render: function() {
			this.isosaltEquivListController.render();
			if( this.isEditable ) {
				this.newSaltController.render();
				this.newIsotopeController.render();
				this.$('.addIsosaltButtons').removeClass('hidden');
				this.$('.addIsosaltButtons').addClass('shown');
			} else {
				this.$('.casNumber').attr('disabled', true);
				if (this.model.get('casNumber')==null || this.model.get('casNumber')=='' ) {
				  this.$('.casNumberDiv').hide();
				}
				this.$('.addIsosaltButtons').removeClass('shown');
				this.$('.addIsosaltButtons').addClass('hidden');
				this.$('.showSaltFormMarvinControl').hide();
			}
			this.$('.casNumber').val(this.model.get('casNumber'));
			if( this.model.get('molStructure')==null || this.model.get('molStructure')=='') {
				this.hideStructureView();
			} else {
				this.showStructureView();
			}

			return this;
		},

	hide: function() {
	  console.log("some peckerwood called hide");
	  $(this.el).hide();
	},

		showAddSaltPanel: function() {
			this.newSaltController.show();
		},

		showAddIsotopePanel: function() {
			this.newIsotopeController.show();
		},
	setupForRegSelect: function() {
		this.$('.regPick').val(this.model.get('corpName'));
		this.$('.corpName').html(this.model.get('corpName'));
		this.$('.structureWrapper').hide();
		this.$('.radioWrapper').show();
	},

	toggleStructureView: function() {
		if (this.$('.showSaltFormMarvin').attr('checked')=='checked') {
			this.showStructureView();
		} else {
			this.hideStructureView();
		}
	},

	hideStructureView: function() {
		$('.structureWrapper').animate({opacity: 0}, 100, function () {
			$(this).slideUp(100);
		});
		this.structureHidden = true;
	},

	showStructureView: function() {
	  this.$('.structureWrapper').show();
	  this.structureHidden = false;
	  this.$('.showSaltFormMarvin').attr('checked','checked');
	  if( this.isEditable) {
		var self = this;
		self.$('.saltFormImage').hide();
		MarvinJSUtil.getEditor("#saltFormMarvinSketch").then(function (sketcherInstance) {
			self.marvinSketcherInstance = sketcherInstance;
			if (typeof window.marvinStructureTemplates !== 'undefined') {
				for (i=0 ; i<window.marvinStructureTemplates.length; i++ ) {
					sketcherInstance.addTemplate(window.marvinStructureTemplates[i]);
				}
			}
		  if (!self.marvinLoaded) {
			if( self.model.get('molStructure')!=null && self.model.get('molStructure')!='') {
			  sketcherInstance.importStructure("mol", self.model.get('molStructure')).catch(function(error) {
					alert(error);
			  });
			}
		  }
		  self.marvinLoaded = true;
			$('.structureWrapper').animate({opacity: 100}, 100, function () {
				$(this).slideDown(100);
			});
		},function (error) {
			alert("Cannot retrieve saltFormMarvinSketch sketcher instance from iframe:"+error);
		});

	  } else {
		self.$('#saltFormMarvinSketch').hide();
		this.structImage = new StructureImageController({
			el: this.$('.saltFormImage'),
			model: new Backbone.Model({
				corpName: this.model.get('corpName'),
				corpNameType: "SaltForm",
				molStructure: this.model.get('molStructure')
			})
		});
		this.structImage.render();
		$('.structureWrapper').animate({opacity: 100}, 100, function () {
			$(this).slideDown(100);
		});
	  }
	},

		copyMol: function() {
			this.$('.copyTextPanel').show();
			this.$('.molCopyTextArea').val(this.model.get('molStructure'));
			this.$('.molCopyTextArea').select();
		},

		hideCopyMolPanel: function() {
			this.$('.copyTextPanel').hide();
		}

	});

});
