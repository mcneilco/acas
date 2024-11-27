$(function() {
	window.SearchForm = Backbone.Model.extend({
        // this model has attributes molStructure and corpName, but we don't want them undefined by default
        validate: function(attributes) {
			var errors = new Array();
            var allEmpty = true;
            _.each(attributes, function(att, key) {
                if( (att != '' && att!=null) && key!='aliasContSelect' && key!='searchType' && key!='percentSimilarity' && key!='maxResults' && key!='loggedInUser' ) {
                    if( key=='chemist') {
                        if( att!='anyone') {
                            allEmpty = false;
                        }
                    } else {
                        allEmpty = false;
                    }
                }
            });
            if(allEmpty) {
                errors.push({'attribute': 'corpNameFrom', 'message': "At least one search term must be filled in"});
            }

			if (attributes.percentSimilarity!=null) {
				if(isNaN(attributes.percentSimilarity) && attributes.percentSimilarity!='') {
					errors.push({'attribute': 'percentSimilarity', 'message':  "% Similarity must be a number if provided"});
				}
			}
			if (attributes.maxResults!=null) {
				if(isNaN(attributes.maxResults) && attributes.maxResults!='') {
					errors.push({'attribute': 'maxResults', 'message':  "Max. no. of search results must be a number if provided"});
				}
			}

            if (errors.length > 0) {return errors;}
        }
    });



    window.SearchFormController = Backbone.View.extend({
		template: _.template($('#SearchFormView_template').html()),

		events: {
			'click .searchButton': 'search',
			'keyup': 'keyupHandler',
            'click .searchType': 'updatePercentSimilarityDisabled',
			'click .cancelButton': 'cancel'
		},

		initialize: function(options){
			this.options = options;
			_.bindAll(this, 'search', 'cancel', 'validationError', 'updatePercentSimilarityDisabled','chemistsLoaded');
            this.valid = false;
			this.sketcherLoaded = false;
		},

		render: function () {
			if (!this.sketcherLoaded) { // only load template once so we don't wipe out marvin
                $(this.el).html(this.template());
            }
			this.hide();
			if(window.configuration.clientUILabels.corpNameLabel) {
				this.$('.corpNameLabel').html(window.configuration.clientUILabels.corpNameLabel+" Range");
				this.$('.corpNameListLabel').html(window.configuration.clientUILabels.corpNameLabel+" List");
            }
            this.$('.dateFrom').datepicker( );
            this.$('.dateFrom').datepicker( "option", "dateFormat", "mm/dd/yy" );
            this.$('.dateTo').datepicker( );
            this.$('.dateTo').datepicker( "option", "dateFormat", "mm/dd/yy" );

			this.$('.maxResults').val(100);
			if(window.configuration.searchForm) {
				if (window.configuration.searchForm.defaultMaxResults) {
					this.$('.maxResults').val(window.configuration.searchForm.defaultMaxResults);
				}
			}

            this.updatePercentSimilarityDisabled();
            this.chemistCodeController =
                this.setupCodeController('chemist', 'scientists?withLots=true', 'chemist', true);
            this.chemistCodeController.collection.bind('reset', this.chemistsLoaded);

			var self = this;

			var sketcher = window.configuration.sketcher
			this.chemicalStructureController = UtilityFunctions.prototype.getNewSystemChemicalSketcherController(sketcher)
			this.$('.marvinContainer').html(this.chemicalStructureController.render().el)
			this.chemicalStructureController.bind('sketcherLoaded', function() {
				self.show();
				self.sketcherLoaded = true;
			});
			
			// Maestro deployments don't support similarity search currently so hide the option
			if(sketcher == "maestro") {
				$('.bv_similaritySearchGroup').hide();
			}

			return this;
		},

        updatePercentSimilarityDisabled: function() {
            if (this.$('.searchType:checked').val()=="similarity") {
                this.$('.percentSimilarity').removeAttr('disabled');
            } else {
                this.$('.percentSimilarity').attr('disabled', true);
            }

        },

		show: function() {
            $(this.el).show();
		},

		hide: function() {
            $(this.el).hide();
		},

		cancel: function() {
            this.hide();
            if(appController) {appController.reset();}
		},

		search: async function() {
			mol = await this.chemicalStructureController.getMol()
			if (this.chemicalStructureController.isEmptyMol(mol))  mol = '';
			var sf = this.makeSearchFormModel(mol);
			if (this.isValid()) {
				this.trigger('searchNext', sf);
				this.hide();
			}
		},

        makeSearchFormModel: function(molecule) {
            this.clearValidationErrors();
            var searchForm = new SearchForm();
            searchForm.bind('error',  this.validationError);

            searchForm.set({
                corpNameList: jQuery.trim(this.$('.corpNameList').val()),
                corpNameFrom: jQuery.trim(this.$('.corpNameFrom').val()),
                corpNameTo: jQuery.trim(this.$('.corpNameTo').val()),
                aliasContSelect: this.$('.aliasContSelect').val(),
                alias: jQuery.trim(this.$('.alias').val()),
                dateFrom: jQuery.trim(this.$('.dateFrom').val()),
                dateTo: jQuery.trim(this.$('.dateTo').val()),
                searchType: this.$('.searchType:checked').val(),
                percentSimilarity:
                    (jQuery.trim(this.$('.percentSimilarity').val())=='') ? null :
                    parseFloat(jQuery.trim(this.$('.percentSimilarity').val())),
                chemist: this.chemistCodeController.getSelectedModel().get("code"),
                maxResults:
                    (jQuery.trim(this.$('.maxResults').val())=='') ? null :
                    parseFloat(jQuery.trim(this.$('.maxResults').val())),
                molStructure: molecule,
                loggedInUser: window.appController.user.get("code")
            });

            return searchForm;

        },

        isValid: function() {
            return this.valid;
        },

        validationError: function(model, errors) {
			this.clearValidationErrors();
			var self = this;
			_.each(errors, function(err) {
				self.$('.'+err.attribute).addClass('input_error');
				self.trigger('notifyError', {owner: "SearchFormController", errorLevel: 'error', message: err.message});
				self.valid = false;
			});
		},

		clearValidationErrors: function() {
			var errorElms = this.$('.input_error');
			this.trigger('clearErrors', "SearchFormController");
			this.valid = true;

			_.each(errorElms, function(ee) {
				$(ee).removeClass('input_error');
			});
		},

        chemistsLoaded: function() {
            this.chemistCodeController.collection.add({
                "id":0,
                "code": "anyone",
                "name": "anyone",
                "isChemist":false,
                "isAdmin":false
            });
            this.chemistCodeController.setSelectedCode('anyone');
        },

        setupCodeController: function(elClass, type, attribute, showIgnored) {
            var tcode = '';

            return new PickListSelectController({
				el: this.$('.'+elClass),
				type: type,
                selectedCode: tcode,
                showIgnored: showIgnored
			})
        },

	    keyupHandler: function(e) {
		    if(e.which === 13 && !this.$('.corpNameList').is(":focus")) {// enter key
			    this.search();
		    }
	    }


	});

});
