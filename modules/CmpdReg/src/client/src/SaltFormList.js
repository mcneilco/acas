$(function() {

    
    window.SaltFormOptionController = Backbone.View.extend({
		tagName: "option",
		
		initialize: function(){
		  _.bindAll(this, 'render');
		},
		
		render: function(){
		  $(this.el).attr('value', this.model.cid).html(this.model.get('corpName'));
		  return this;
		}        
    });
    
	window.SaltFormSelectController = Backbone.View.extend({
        
		initialize: function(){
			_.bindAll(this, 'render');
		},
		
		render: function() {
			$(this.el).empty();
			$(this.el).append(this.make('option', {value: -1}, 'New Salt'));
			var self = this;
			this.collection.each(function(sf){
				$(self.el).append(new SaltFormOptionController({ model: sf }).render().el);
			});
		},

		getSelectedSaltForm: function(){
            if ($(this.el).val() == -1) return null;
			return this.collection.getByCid($(this.el).val());
		}

	});	

});

