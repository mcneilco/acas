$(function() {

	window.ErrorNotification = Backbone.Model.extend({
		sync: Backbone.localSync,
		localStorage: new Store('ErrorNotificationItems'),
	
		defaults: {
			owner: 'system',
			errorLevel: 'error',
			message: ''
		}
	});
	
	window.ErrorNotificationList = Backbone.Collection.extend({
	
		sync: Backbone.localSync,
		localStorage: new Store('ErrorNotifications'),
		model: ErrorNotification,
	
		initialize: function(){
			_.bindAll(this, 'add', 'getMessagesForOwner', 'getMessagesOfLevel', 'removeMessagesForOwner');
		},
		getMessagesForOwner: function(owner) {
			return this.filter(function (erno) {return erno.get('owner')==owner;});
		},
		getMessagesOfLevel: function(level) {
			return this.filter(function (erno) {return erno.get('errorLevel')==level;});
		},
		removeMessagesForOwner: function(owner) {
			this.remove(this.getMessagesForOwner(owner));
		}
	
	});
	
	
	window.ErrorNotificationController = Backbone.View.extend({
		tagName: "div",
		
		initialize: function(){
			_.bindAll(this, 'render');
			this.model.bind('destroy', this.remove, this);
		},
		
		render: function(){
			$(this.el).html(this.model.get('message'));
			$(this.el).addClass('errorNotification_'+this.model.get('errorLevel'))
			return this;
		}

	});

	window.ErrorNotificationListController = Backbone.View.extend({
		template: _.template($('#ErrorNotificationView_template').html()),
		events: {
			'click .showHideButton': 'toggleErrorsVisible'
		},
		initialize: function(){	
			$(this.el).html(this.template());
            _.bindAll(this, 'addOne', 'toggleErrorsVisible');
			this.collection.bind('add', this.addOne, this);
			this.collection.bind('reset', this.addAll, this);
			this.collection.bind('remove',   this.removeOne, this);
            this.updateShowHideControls();
		},
		addOne: function(errorNote){
			var elm = new ErrorNotificationController({model: errorNote}).render().el;
			this.$('.notifications').append(elm);
            this.updateShowHideControls();
		},
		addAll: function(col) {
			this.$('.notifications').empty();
      		this.collection.each(this.addOne);
            this.updateShowHideControls();
    	},
    	removeOne: function (errorNote) {
    		errorNote.destroy();
            this.updateShowHideControls();
    	},
        updateShowHideControls: function() {
            if (this.collection.length == 0) {
                this.$('.controls').hide();
            } else {
                if (this.collection.length == 1) {
                    var countStr = this.collection.length + " message";
                } else {
                    var countStr = this.collection.length + " messages";
                }
                this.$('.messageCount').html(countStr);
                this.$('.controls').show();
            }
        },
        toggleErrorsVisible: function() {
            this.$('.notifications').toggle();
            if (this.$('.notifications').is(':visible')) {
                this.$('.showHideButton').html('Hide');
            } else {
                this.$('.showHideButton').html('Show');
            }
        }
	});	


});