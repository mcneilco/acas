$(function() {
    
    window.NewLotSuccessController = Backbone.View.extend({
        template: _.template($('#NewLotSuccessView_template').html()),

        events: {
            'click .editLotButton': 'openLot',
            'click .newLotButton': 'newLot',
            'click .closeButton': 'closeLot'
        },

        initialize: function(){
            _.bindAll(this, 'render', 'openLot', 'newLot','closeLot');
        },
        
        render: function() {
            $(this.el).html(this.template());
            this.$('.corpName').html(this.options.corpName);
            $(this.el).show();
            var lisb = window.configuration.metaLot.lotCalledBatch;
            this.$('.lotOrBatch').html(lisb?'Batch':'Lot');
            if (window.configuration.metaLot.showBuid) {
                this.$('.buid').html(this.options.buid);
                this.$('.labelBuid').show();
            }
            return this;
        },
        
        openLot: function() {
            console.log("about to open new lot window");
	        window.open("#lot/"+this.options.corpName, '_blank');
            this.closeLot();
//	        appController.reset();
//            if(appController) {appController.router.navigate('lot/'+this.options.corpName,true);}
        },
        
        newLot: function() {
            // Need to strip away lot suffix to prevent error on Cmpd ID search 
            corpName = this.options.corpName;
			corpNameArr = corpName.split("-");
			corpNameArr.pop(); // Removes lot suffix 
			corpName = corpNameArr.join("-");
	        window.open("#register/"+corpName, '_blank');
            this.closeLot();
            // if(appController) {appController.router.navigate('register/'+this.options.corpName,true);}
        },
        
        closeLot: function() {
//            $(this.el).hide();
	        console.log("about to reset the controller");
            appController.reset();
        }
    });
});
