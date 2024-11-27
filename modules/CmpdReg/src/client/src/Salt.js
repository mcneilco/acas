$(function() {

	window.Salt = Backbone.Model.extend({

		initialize: function(options) {
			this.options = options;

		},

        url: function() {
			if(window.configuration.serverConnection.connectToServer) {
				return window.configuration.serverConnection.baseServerURL+'salts';
			} else {
				return 'spec/testData/Salt.php';
			}
		},


		defaults: {
			name: '',
			abbrev: '',
			molStructure: null
		},
		validate: function(attr) {
			var errors = new Array();
			if (attr.abbrev != null) {
				if(/\s/g.test(attr.abbrev)) {
					errors.push({'attribute': 'abbrev', 'message': "Salt Abbreviation must not contain whitespace"});
				}
				if(/-/g.test(attr.abbrev)) {
					errors.push({'attribute': 'abbrev', 'message': "Salt Abbreviation must not contain -"});
				}
				if(!/\S/g.test(attr.abbrev)) {
					errors.push({'attribute': 'abbrev', 'message': "Salt abbreviation must be provided"});
				}
			}
			if (attr.name != null) {
				if(!/\S/g.test(attr.name)) {
					errors.push({'attribute': 'name', 'message': "Salt name must be provided"});
				}
                if(/^\s/g.test(attr.name) || /\s$/g.test(attr.name)) {
					errors.push({'attribute': 'name', 'message': "Salt may not have spaces before or after"});
				}
			}
			if (attr.molStructure != null) {
				if(attr.molStructure=='') {
					errors.push({'attribute': 'name', 'message': "Salt must have a molStructure"});
				}
			}
			if (errors.length > 0) {return errors;}
		}

	});

	window.Salts = Backbone.Collection.extend({

		model: Salt,

		initialize: function(options) {
			this.options = options;

		},
        url: function() {
			if(window.configuration.serverConnection.connectToServer) {
				return window.configuration.serverConnection.baseServerURL+'salts';
			} else {
				return 'spec/testData/Salt.php';
			}
		}


	});

	//TODO refactor this and IsotopeOptionController to be the same

	window.SaltOptionController = Backbone.View.extend({
		tagName: "option",

		initialize: function(options){
			this.options = options;
		  _.bindAll(this, 'render');
		},

		render: function(){
			if(window.configuration.metaLot.includeAbbrevInIsoSaltOption) {
				$(this.el).attr('value', this.model.cid).html(this.model.get('abbrev')+': '+this.model.get('name'));
			} else {
				$(this.el).attr('value', this.model.cid).html(this.model.get('name'));
			}

			return this;
		}
	});

	//TODO refactor this and IsotopeSelectController to be the same
	window.SaltSelectController = Backbone.View.extend({
		events: {
			'change': 'handleSelectChanged'
		},

		initialize: function(options){
			this.options = options;
			_.bindAll(this, 'addOne', 'render', 'handleSelectChanged');
			this.collection.bind('add', this.addOne);
			this.collection.bind('reset', this.render);
			if (window.configuration.metaLot.sortSaltsByAbbrev) {
				this.collection.comparator = function(salt) {
					return salt.get('abbrev');
				};
			}
			this.existingCid = "";
		},

		render: function() {
			$(this.el).empty();
			if(window.configuration.metaLot.sortSaltsByAbbrev) {
				$(this.el).append($('<option>', { value: '' }).text(window.configuration.metaLot.saltListNoneOption));			} else {
				$(this.el).append($('<option>', { value: '' }).text('none'));
			}
			var self = this;
			this.collection.each(function(salt){
				$(self.el).append(new SaltOptionController({ model: salt }).render().el);
				if (self.existingCid=="") {
					if (self.options.existingAbbrev == salt.get('abbrev')) {
						self.existingCid = salt.cid;
					}
				}
			});
			if (self.existingCid != "") { $(self.el).val(self.existingCid); }
		},

		addOne: function(salt){
			this.render();
			//$(this.el).append(new SaltOptionController({ model: salt }).render().el);
		},

		selectedCid: function(){
			return $(this.el).val();
		},

		handleSelectChanged: function (){
			this.existingCid = this.selectedCid();
		}


	});

	window.NewSaltController = Backbone.View.extend({
		template: _.template($('#NewSaltView_template').html()),

		events: {
			'click .saveNewSaltButton': 'saveSalt',
			'click .cancelNewSaltButton': 'cancel'
		},

		initialize: function(options){
			this.options = options;
			_.bindAll(this, 'validationError', 'saveSalt', 'render');
			$(this.el).html(this.template());
			this.exportFormat = "mol";

			this.sketcherLoaded = false;
		},

		render: function () {
			var self = this;
			var sketcher = window.configuration.sketcher
			this.chemicalStructureController = UtilityFunctions.prototype.getNewSystemChemicalSketcherController(sketcher)
			this.$('.marvinWrapper').html(this.chemicalStructureController.render().el)
			this.chemicalStructureController.bind('sketcherLoaded', function() {
				self.sketcherLoaded = true;
			});
			this.hide();
			return this;
		},

		show: function() {
			this.chemicalStructureController.clear();
			$(this.el).show();
		},

		hide: function() {
			$(this.el).hide();
			// $(this.el).dialog('close');
		},

		cancel: function() {
			this.clearValidationErrorStyles();
			this.hide();
		},

		saveSalt: async function() {
            this.trigger('clearErrors', "NewSaltController");

            var salt = new Salt();
			salt.bind('error',  this.validationError);
			var mol = null;
			self = this;

			if(this.sketcherLoaded) {
				self.exportStructComplete = false;

				var gotMol = function (mol) {
					if(self.chemicalStructureController.isEmptyMol(mol)) {
						mol = ''
					}
					
					self.exportStructComplete = true; // for spec support

					var saltSetSucceeded = salt.set({
						name: jQuery.trim(self.$('.salt_name').val()),
						abbrev: jQuery.trim(self.$('.salt_abbrev').val()),
						molStructure: mol
					});
					if (saltSetSucceeded) {
						self.trigger('notifyError', {
							owner: 'NewSaltController',
							errorLevel: 'warning',
							message: 'Saving salt...'
						});
						self.delegateEvents({}); // stop listening to buttons
						self.collection.create(salt,
							{
								success: function () {
									self.clearValidationErrorStyles();
									self.clearInputFields();
									self.delegateEvents(); // start listening to events
									self.hide();
								},
								error: function (model, error) {
									self.clearValidationErrorStyles();
									var resp = $.parseJSON(error.responseText);
									_.each(resp, function (err) {
										self.trigger('notifyError', {
											owner: "NewSaltController",
											errorLevel: err.level,
											message: err.message
										});
									});
									self.delegateEvents(); // start listening to events
								}
							});
					}
				}

				mol = await this.chemicalStructureController.getMol()
				gotMol(mol);

			}

		},

		validationError: function(model, errors) {
			this.clearValidationErrorStyles();
			var self = this;
			_.each(errors, function(err) {
				self.$('.salt_'+err.attribute).addClass('input_error');
				self.trigger('notifyError', {owner: 'NewSaltController', errorLevel: 'error', message: err.message});
			});
		},

		clearValidationErrorStyles: function() {
			var errorElms = this.$('.input_error');
			this.trigger('clearErrors', 'NewSaltController');

			_.each(errorElms, function(ee) {
				$(ee).removeClass('input_error');
			});
		},

		clearInputFields: function() {
			this.$('.salt_name').val('');
			this.$('.salt_abbrev').val('');
		}
	});

});
