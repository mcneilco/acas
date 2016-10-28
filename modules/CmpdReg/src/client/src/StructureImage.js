$(function() {

	window.StructureImageController = Backbone.View.extend({
		template: _.template($('#StructureImage_template').html()),

		events: {
			'click .copyButton': 'copyMol',
			'click .copyPanelCloseButton': 'hideCopyMolPanel'
		},

		initialize: function() {
			_.bindAll(this, 'render');

		},

		render: function() {
			$(this.el).html(this.template());
			if (this.model.has('molImage') ) {
				this.$('.structImage').attr('src',"data:image/png;base64,"+this.model.get('molImage'));
			} else {
				if(window.configuration.serverConnection.connectToServer) {
					if( this.model.get('corpNameType') == "SaltForm") {
						var src = window.configuration.serverConnection.baseServerURL+"structureimage/saltForm/";
					} else if( this.model.get('corpNameType') == "Parent") {
						var src = window.configuration.serverConnection.baseServerURL+"structureimage/parent/";
					} else if( this.model.get('corpNameType') == "Lot") {
						var src = window.configuration.serverConnection.baseServerURL+"structureimage/lot/";
					} else {
						console.log("unexpected corpNameType in search reults")
					}
					src += this.model.get('corpName');
					src += "?hSize=300";
					src += "&wSize=600";
					this.$('.structImage').attr('src', src);
				} else {
					this.$('.structImage').attr('src', "spec/testData/molecule.png");
				}
			}
			if (!this.model.has('molStructure')){
				this.$('.copyButtonWrapper').hide();
			}
			return(this);
		},

		copyMol: function() {
			this.$('.structWrapper').hide();
			this.$('.copyTextPanel').show();
			this.$('.molCopyTextArea').val(this.model.get('molStructure'));
			this.$('.molCopyTextArea').select();
		},

		hideCopyMolPanel: function() {
			this.$('.copyTextPanel').hide();
			this.$('.structWrapper').show();
		}
	});
});
