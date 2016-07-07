$(function() {

	window.Isotope = Backbone.Model.extend({
		initialize: function() {
//			if(window.configuration.serverConnection.connectToServer) {
//				this.urlRoot = window.configuration.serverConnection.baseServerURL+'/isotopes';
//			} else {
//				this.sync = Backbone.localSync;
//				this.localStorage = new Store('IsotopeItems');
//			}
		},

		url: function() {
			if(window.configuration.serverConnection.connectToServer) {
				return window.configuration.serverConnection.baseServerURL+'isotopes';
			} else {
				return 'spec/testData/Isotope.php';
			}
		},

		defaults: {
			name: '',
			abbrev: '',
			massChange: ''
		},
		validate: function(attr) {
			var errors = new Array();
			if (attr.massChange!=null) {
				if(isNaN(attr.massChange)) {
					errors.push({'attribute': 'massChange', 'message':  "Isotope Mass Change must be a Number"});
				}
			}
			if (attr.abbrev!=null) {
				if(/\s/g.test(attr.abbrev)) {
					errors.push({'attribute': 'abbrev', 'message': "Isotope Abbreviation must not contain whitespace"});
				}
				if(/-/g.test(attr.abbrev)) {
					errors.push({'attribute': 'abbrev', 'message': "Isotope Abbreviation must not contain -"});
				}
				if(!/\S/g.test(attr.abbrev)) {
					errors.push({'attribute': 'abbrev', 'message': "Isotope abbreviation must be provided"});
				}
			}
			if (attr.name != null) {
				if(!/\S/g.test(attr.name)) {
					errors.push({'attribute': 'name', 'message': "Isotope name must be provided"});
				}
                if(/^\s/g.test(attr.name) || /\s$/g.test(attr.name)) {
					errors.push({'attribute': 'name', 'message': "Isotope may not have spaces before or after"});
				}
			}
			if (errors.length > 0) {return errors;}
		}

	});

	window.Isotopes = Backbone.Collection.extend({

		model: Isotope,
		initialize: function() {
//			if(window.configuration.serverConnection.connectToServer) {
//				this.url = window.configuration.serverConnection.baseServerURL+'/isotopes';
//			} else {
//				this.sync = Backbone.localSync;
//				this.localStorage = new Store('Isotopes');
//			}
		},

		url: function() {
			if(window.configuration.serverConnection.connectToServer) {
				return window.configuration.serverConnection.baseServerURL+'isotopes';
			} else {
				return 'spec/testData/Isotope.php';
			}
		}
	});



	window.IsotopeOptionController = Backbone.View.extend({
		tagName: "option",

		initialize: function(){
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

	window.IsotopeSelectController = Backbone.View.extend({
		initialize: function(){
			_.bindAll(this, 'addOne','render');
			this.collection.bind('add', this.addOne);
			this.collection.bind('reset', this.render);
			if (window.configuration.metaLot.sortIsotopesByAbbrev) {
				this.collection.comparator = function(iso) {
					return iso.get('abbrev');
				};
			}
		},

		render: function() {
			$(this.el).empty();
			if(window.configuration.metaLot.isotopeListNoneOption) {
				$(this.el).append(this.make('option', {value: ''}, window.configuration.metaLot.isotopeListNoneOption));
			} else {
				$(this.el).append(this.make('option', {value: ''}, 'none'));
			}
			var self = this;
			var existingCid = "";
			this.collection.each(function(isotope){
				$(self.el).append(new SaltOptionController({model: isotope}).render().el);
				if (self.options.existingAbbrev==isotope.get('abbrev')) { existingCid = isotope.cid; }
			});
			if (existingCid != "") { $(self.el).val(existingCid); }
		},

		addOne: function(isotope){
			this.render();
			//$(this.el).append(new IsotopeOptionController({model: isotope}).render().el);
		},

		selectedCid: function(){
			return $(this.el).val();
		}

	});

	window.NewIsotopeController = Backbone.View.extend({
		template: _.template($('#NewIsotopeView_template').html()),

		events: {
			'click .saveNewIsotopeButton': 'save',
			'click .cancelNewIsotopeButton': 'cancel'
		},

		initialize: function(){
			_.bindAll(this, 'validationError', 'save');
			//TODO the template load should probably in render()
            $(this.el).html(this.template());
			this.hide();

		},

		render: function () {
			return this;
		},

		show: function() {
            $(this.el).show();
//            if(!window.testMode) {
//                $(this.el).dialog({
//                    modal: true,
//                    position: 'center',
//                    width: 200
//                });
//            }
		},

		hide: function() {
			$(this.el).hide();
			$(this.el).dialog('close');
		},

		cancel: function() {
			this.clearValidationErrorStyles();
			this.hide();
		},

		save: function() {
            this.trigger('clearErrors', "NewIsotopeController");

            var isotope = new Isotope();
            isotope.bind('error',  this.validationError);
            var isotopeSetSucceeded = isotope.set({
				name: jQuery.trim(this.$('.isotope_name').val()),
				abbrev: jQuery.trim(this.$('.isotope_abbrev').val()),
				massChange: parseFloat(jQuery.trim(this.$('.isotope_massChange').val()))
			});
			if (isotopeSetSucceeded) {
                this.trigger('notifyError', {
                    owner: 'NewIsotopeController',
                    errorLevel: 'warning',
                    message: 'Saving isotope...'
                });
                this.delegateEvents({}); // stop listening to buttons
                var self = this;
                this.collection.create(isotope,
                {
                    success: function() {
                        self.clearValidationErrorStyles();
                        self.clearInputFields();
                        self.delegateEvents(); // start listening to events
                        self.hide();
                    },
                    error: function(model, error) {
                        self.clearValidationErrorStyles();
                        var resp = $.parseJSON(error.responseText);
                        _.each(resp.errors, function(err) {
                            self.trigger('notifyError', {owner: "NewIsotopeController", errorLevel: err.level, message: err.message});
                        });
                        self.delegateEvents(); // start listening to events
                    }
                });
			}

		},

		validationError: function(model, errors) {
			this.clearValidationErrorStyles();
			var self = this;
			_.each(errors, function(err) {
				self.$('.isotope_'+err.attribute).addClass('input_error');
				self.trigger('notifyError', {owner: 'NewIsotopeController', errorLevel: 'error', message: err.message});
			});
		},

		clearValidationErrorStyles: function() {
			var errorElms = this.$('.input_error');
			this.trigger('clearErrors', 'NewIsotopeController');

			_.each(errorElms, function(ee) {
				$(ee).removeClass('input_error');
			});
		},
		clearInputFields: function() {
			this.$('.isotope_name').val('');
			this.$('.isotope_abbrev').val('');
			this.$('.isotope_massChange').val('');
		}
	});

});
