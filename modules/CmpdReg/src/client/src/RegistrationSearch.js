$(function() {
	window.RegistrationSearch = Backbone.Model.extend({
        // this model has attributes molStructure and corpName, but we don't want them undefined by default
        validate: function(attributes) {
			var errors = new Array();
			if (attributes.molStructure==null && attributes.corpName=='') {
                errors.push({attribute: 'corpName', message: "Registration panel must have either structure or corporate ID filled in"});
            }
			if (attributes.molStructure!=null && attributes.corpName!='') {
                errors.push({attribute: 'corpName', message: "Registration panel must have either structure or corporate ID, but not both"});
            }
            if (errors.length > 0) {return errors;}
        }
    });
    
    
    
    window.RegistrationSearchController = Backbone.View.extend({
		template: _.template($('#RegistrationSearch_template').html()),
		
		events: {
			'click .nextButton': 'next',
			'click .cancelButton': 'cancel'
		},
		
		initialize: function(){
			_.bindAll(this, 'next', 'cancel', 'render', 'validationError');
            this.valid = false;
			this.marvinLoaded = false;
			this.exportFormat = "mol";
			if(window.configuration.marvin) {
				if (window.configuration.marvin.exportFormat) {
					this.exportFormat = window.configuration.marvin.exportFormat;
				}
			}
			this.hide();
		},

		render: function () {

			if (!this.marvinLoaded) { // only load template once so we don't wipe out marvin
                $(this.el).html(this.template());
                if(this.options.corpName){
                    this.$('.corpName').val(this.options.corpName);
                }
            }

			this.hide();
			var self = this;
			MarvinJSUtil.getEditor("#registrationSearchMarvinSketch").then(function (sketcherInstance) {
				self.marvinSketcherInstance = sketcherInstance;
				if (typeof window.marvinStructureTemplates !== 'undefined') {
					for (i=0 ; i<window.marvinStructureTemplates.length; i++ ) {
						sketcherInstance.addTemplate(window.marvinStructureTemplates[i]);
					}
				}
				self.show();
				self.marvinLoaded = true;
			},function (error) {
				alert("Cannot retrieve registrationSearchMarvinSketch sketcher instance from iframe:"+error);
			});

			return this;
		},

		show: function() {
            $(this.el).show();
		},
		
		hide: function() {
            $(this.el).hide();
		},
		
		cancel: function() {
            this.hide();
            this.$('.corpName').val('');
			this.marvinSketcherInstance.clear()
			if(appController) {appController.reset();}
		},
				
		next: function() {
            this.clearValidationErrors();
            var regSearch = new RegistrationSearch();
            regSearch.bind('error',  this.validationError);
            var mol;

			var self = this;
			this.marvinSketcherInstance.exportStructure(this.exportFormat).then(function(molecule) {
				if ( molecule.indexOf("0  0  0  0  0  0  0  0  0  0999")>-1)
					mol = null;
				else
					mol = molecule;
				regSearch.set({
					molStructure: mol,
					corpName: jQuery.trim(self.$('.corpName').val())
				});

				if ( self.isValid() ) {
					self.trigger('registrationSearchNext', regSearch);
					self.hide();
				}
			}, function(error) {
				alert("Molecule export failed from search sketcher:"+error);
			});


		},
        isValid: function() {
            return this.valid;
        },
        validationError: function(model, errors) {
			this.clearValidationErrors();
			var self = this;
			_.each(errors, function(err) {
				self.$('.'+err.attribute).addClass('input_error');
				self.trigger('notifyError', {owner: "RegistrationSearchController", errorLevel: 'error', message: err.message});
				self.valid = false;
			});
		},
		
		clearValidationErrors: function() {
			var errorElms = this.$('.input_error');
			this.trigger('clearErrors', "RegistrationSearchController");
			this.valid = true;
			
			_.each(errorElms, function(ee) {
				$(ee).removeClass('input_error');
			});
		}

	});

});