$(function() {
	window.RegSearchResultsController = Backbone.View.extend({

		template: _.template($('#RegSearchResultsView_template').html()),

		events: {
 			'click .nextButton': 'next',
			'click .cancelButton': 'cancel',
            'click .isVirtual': 'toggleParentsVisible',
            'click .backButton': 'back'
		},

		initialize: function(){
			_.bindAll(this, 'toggleParentsVisible', 'next');
			this.sketcherLoaded = false;
            this.hide();
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
                el: '.RegSearchResults_ParentListView'
            });
//            $(this.el).append(this.parentListCont.render().el);
            this.parentListCont.render()
            if(this.json.parents.length==0) {
                this.$('.RegSearchResults_ParentListView').hide();
            }
//			console.log(window.configuration);
			if (window.configuration.regSearchResults) {
				if (window.configuration.regSearchResults.hideVirtualOption) {
					this.$('.isVirtualContainer').hide()
				}
			}
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
                this.$('.RegSearchResults_ParentListView').hide();
                this.$("[name=regPick]").removeAttr("checked");
                this.$("[name=regPick]").filter("[value=new]").attr("checked","checked");
            } else {
                if(this.json.parents.length!=0) {
                    this.$('.RegSearchResults_ParentListView').show();
                }
            }
        },

		cancel: function() {
            this.clearValidationErrors();
            this.hide();
            appController.reset();
		},

        back: function() {
            this.trigger('searchResultsBack');
            this.hide();
        },

		next: function() {
            this.clearValidationErrors();
            var selection = new window.Backbone.Model({
                selectedCorpName: this.$('.regPick:checked').val(),
                isVirtual: this.$('.isVirtual').is(':checked')
            });
            this.getSelectedMetaLot(selection);
            if(selection.get('metaLot')==null && selection.get('selectedCorpName')!="new") {
                this.trigger('notifyError', {owner: "RegistrationSearchResultsController", errorLevel: 'error', message: "No parent or salt form selected"});
                return;
            }
            this.trigger('searchResultsNext', selection);
            this.hide();
		},
        isValid: function() {
            return this.valid;
        },
        getSelectedMetaLot: function(selection) {

            var selectedName = selection.get('selectedCorpName');
            if(selectedName!="new") {
                selection.set({
                    metaLot: this.parentListCont.getSelectedMetaLot()
                });
            }
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

});
