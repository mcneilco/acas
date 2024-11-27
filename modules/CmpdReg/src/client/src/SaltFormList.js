$(function() {

    
    window.SaltFormOptionController = Backbone.View.extend({
		tagName: "option",
		
		initialize: function(options){
			this.options = options;
		  _.bindAll(this, 'render');
		},
		
		render: function(){
		  $(this.el).attr('value', this.model.cid).html(this.model.get('corpName'));
		  return this;
		}        
    });
    
	window.SaltFormSelectController = Backbone.View.extend({
        
		initialize: function(options){
			this.options = options;
			_.bindAll(this, 'render');
		},
		
		render: function() {
			$(this.el).empty();
			var self = this;
			this.collection.each(function(sf){
				$(self.el).append(new SaltFormOptionController({ model: sf }).render().el);
			});
			$(this.el).append($('<option>', { value: -1 }).text('New Salt'));
		},

		getSelectedSaltForm: function(){
            if ($(this.el).val() == -1) return null;
			return this.collection.get($(this.el).val());
		}

	});	

});

