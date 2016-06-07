$(function() {


    window.ParentListController = Backbone.View.extend({
		tagName: 'div',
        className: 'RegSearchResults_ParentListView',

        initialize: function(){
            this.parentControllers = new Array();
		},

		render: function() {
			var self = this;
            var parentController;
            var sfJSONList;
            var sfList;
            var sfListCont;
            var js = this.options.json;

			_.each(js, function(pc){
                parentController = self.setupParentController(pc);
				$(self.el).append(parentController.render().el);
                self.parentControllers.push(parentController);

                if (window.configuration.metaLot.saltBeforeLot) {
                    sfJSONList = pc.saltForms;
                    sfList = new Backbone.Collection();
                    _.each(sfJSONList, function(sfj) {
                        sfList.add( new SaltForm({json: sfj}));
                    });
                } else {
                    sfList = null;
                }
                parentController.setupForRegSelect(sfList);

			});
            return this;
		},

        setupParentController: function(parJSON) {
            var parent = new Parent({json: parJSON});

            var parentController = new RegParentController({
                tagName: 'div',
                className: 'RegSearchResults_ParentView',
                model: parent,
                readMode: true,
                step: 'regSearchResults'
            });
            return parentController;

        },

        getSelectedMetaLot: function() {
            var selParCont = _.detect(this.parentControllers, function(pc) {
                return pc.$('.regPick').is(':checked');
            });
            if( selParCont ) {
                return selParCont.getSelectedMetaLot();
            } else {
                return null;
            }
        }



	});

});
