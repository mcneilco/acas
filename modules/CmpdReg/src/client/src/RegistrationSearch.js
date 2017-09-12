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

		render: function () {

			if (!this.sketcherLoaded) { // only load template once so we don't wipe out marvin
                $(this.el).html(this.template());
                if(this.options.corpName){
                    this.$('.corpName').val(this.options.corpName);
                }
            }

			this.hide();
			var self = this;

			if (this.useMarvin) {
				this.$('#registrationSearchMarvinSketch').attr('src',"/CmpdReg/marvinjs/editorws.html");
				MarvinJSUtil.getEditor("#registrationSearchMarvinSketch").then(function (sketcherInstance) {
					self.marvinSketcherInstance = sketcherInstance;
					if (typeof window.marvinStructureTemplates !== 'undefined') {
						for (i = 0; i < window.marvinStructureTemplates.length; i++) {
							sketcherInstance.addTemplate(window.marvinStructureTemplates[i]);
						}
					}
					self.show();
					self.sketcherLoaded = true;
				}, function (error) {
					alert("Cannot retrieve registrationSearchMarvinSketch sketcher instance from iframe:" + error);
				});

			} else if (this.useKetcher) {
				this.$('#registrationSearchMarvinSketch').attr('src',"/lib/ketcher-2.0.0-alpha.3/ketcher.html?api_path=/api/cmpdReg/ketcher/");
				this.$('#registrationSearchMarvinSketch').on('load', function () {
					self.ketcher = self.$('#registrationSearchMarvinSketch')[0].contentWindow.ketcher;
				});
			} else {
				alert("No registration sketcher configured");
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
            this.hide();
            this.$('.corpName').val('');
			if (this.useMarvin) {
				this.marvinSketcherInstance.clear()
			} else if (this.useKetcher) {
				mol = this.ketcher.setMolecule("");
			}
			if(appController) {appController.reset();}
		},
				
		next: function() {
            this.clearValidationErrors();
            var regSearch = new RegistrationSearch();
            regSearch.bind('error',  this.validationError);
            var mol;

			var self = this;

			if (this.useMarvin) {
				this.marvinSketcherInstance.exportStructure(this.exportFormat).then(function (molecule) {
					if (molecule.indexOf("0  0  0  0  0  0  0  0  0  0999") > -1)
						mol = '';
					else if (molecule.indexOf("M  V30 COUNTS 0 0 0 0 0") > -1)
						mol = '';
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
				}, function (error) {
					alert("Molecule export failed from search sketcher:" + error);
				});
			} else if (this.useKetcher) {
				mol = this.ketcher.getMolfile();
				if (mol.indexOf("  0  0  0     0  0            999") > -1) mol = null;
				regSearch.set({
					molStructure: mol,
					corpName: jQuery.trim(self.$('.corpName').val())
				});

				if ( this.isValid() ) {
					this.trigger('registrationSearchNext', regSearch);
					this.hide();
				}
			} else {
				alert("No registration sketcher configured in search action");
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