$(function() {

	window.PickList = Backbone.Model.extend({
		defaults: {
			ignore: false
		}
	});

	window.PickListList = Backbone.Collection.extend({

		model: PickList,
		
		url: function() {
			if(window.configuration.serverConnection.connectToServer) {
				return window.configuration.serverConnection.baseServerURL+this.type;
			} else {
				return 'spec/testData/'+this.type+'.php';
			}
		}, 
		
		setType: function(type) {
			this.type=type;
		},
        
        getModelWithCode: function(code) {
            return this.detect(function(enu) {
                return enu.get('code')==code;
            });
        }
			
	});
	
	
	
	window.PickListOptionController = Backbone.View.extend({
		tagName: "option",
		
		initialize: function(){
		  _.bindAll(this, 'render');
		},
		
		render: function(){
		  $(this.el).attr('value', this.model.get('code')).text(this.model.get('name'));
		  return this;
		}
	});

	window.PickListSelectController = Backbone.View.extend({
		initialize: function(){	
			_.bindAll(this, 'addOne', 'render', 'handleListReset');
			this.rendered = false;
            this.collection = new PickListList();
			this.collection.setType(this.options.type);
			this.collection.bind('add', this.addOne);
			this.collection.bind('reset', this.handleListReset);
			this.collection.fetch();
            if (this.options.selectedCode !='') {
                this.selectedCode = this.options.selectedCode;
            } else {
                this.selectedCode = null;
            }
            if (this.options.insertFirstOption !=null) {
                this.insertFirstOption = this.options.insertFirstOption;
            } else {
                this.insertFirstOption = null;
            }
            if (this.options.showIgnored !=null) {
                this.showIgnored = this.options.showIgnored;
            } else {
                this.showIgnored = false;
            }
		},
		
		handleListReset: function() {
			if (this.insertFirstOption) {
	            this.collection.add(this.insertFirstOption, {at: 0, silent: true});
            }
            this.render();
		},
		
		render: function() {
			$(this.el).empty();
			var self = this;
			this.collection.each(function(enm){
				var shouldRender = self.showIgnored;

				if (enm.get('ignore')) {
					if (self.selectedCode != null) {
						if (self.selectedCode==enm.get('code')) {
							shouldRender = true;
						}
					}
				} else {
					shouldRender = true;
				}
				if (shouldRender) {
					$(self.el).append(new PickListOptionController({model: enm}).render().el);
				}
			});
            if ( this.selectedCode ) {
            	$(this.el).val(this.selectedCode);
            }
            // hack to fix IE bug where select doesn't work when dynamically inserted
        	$(this.el).hide();
        	$(this.el).show();
            this.rendered = true;
            
            return this;
		},
		
		addOne: function(enm){
			$(this.el).append(new PickListOptionController({model: enm}).render().el);
		},
		
		
        setSelectedCode: function(code) {
            this.selectedCode = code;
            if( this.rendered ) {$(this.el).val(this.selectedCode);}
        },
        
        getSelectedCode: function(){
			return $(this.el).val();
		},
        
        getSelectedModel: function() {
            return this.collection.getModelWithCode(this.getSelectedCode());
        }



	});

	window.AliasList = Backbone.Model.extend({
		defaults: {
			ignore: false
		},
		initialize: function() {
			var codeVal = this.get("lsType").typeName + ":" + this.get("kindName")
			this.set({code: codeVal});
			var nameVal = this.get("lsType").typeName + ": " + this.get("kindName");
			if (this.get("lsType").typeName == "not_set") {
				nameVal = this.get("kindName");
			}

			this.set({name: nameVal});
		}


	});

	window.AliasListList = Backbone.Collection.extend({

		model: AliasList,

		url: function() {
			if(window.configuration.serverConnection.connectToServer) {
				return window.configuration.serverConnection.baseServerURL+this.type;
			} else {
				return 'spec/testData/'+this.type+'.php';
			}
		},

		setType: function(type) {
			this.type=type;
		},

		getModelWithCode: function(code) {
			return this.detect(function(enu) {
				return enu.get('code')==code;
			});
		}

	});



	window.AliasListOptionController = Backbone.View.extend({
		tagName: "option",

		initialize: function(){
			_.bindAll(this, 'render');
		},

		render: function(){
			$(this.el).attr('value', this.model.get('code')).text(this.model.get('name'));
			return this;
		}
	});

	window.AliasListSelectController = Backbone.View.extend({
		initialize: function(){
			_.bindAll(this, 'addOne', 'render', 'handleListReset');
			this.rendered = false;
			if (this.options.collection) {
				this.collection = this.options.collection;
			} else {
				this.collection = new AliasListList();
			}
			this.collection.setType(this.options.type);
			this.collection.bind('add', this.addOne);
			this.collection.bind('reset', this.handleListReset);
			if (this.collection.length === 0) {
				this.collection.fetch();
			}
			if (this.options.selectedCode !='') {
				this.selectedCode = this.options.selectedCode;
			} else {
				this.selectedCode = null;
			}
			if (this.options.insertFirstOption !=null) {
				this.insertFirstOption = this.options.insertFirstOption;
			} else {
				this.insertFirstOption = null;
			}
			if (this.options.showIgnored !=null) {
				this.showIgnored = this.options.showIgnored;
			} else {
				this.showIgnored = false;
			}
		},

		handleListReset: function() {
			if (this.insertFirstOption) {
				this.collection.add(this.insertFirstOption, {at: 0, silent: true});
			}
			this.render();
		},

		render: function() {
			$(this.el).empty();
			var self = this;
			this.collection.each(function(enm){
				var shouldRender = self.showIgnored;

				if (enm.get('ignore')) {
					if (self.selectedCode != null) {
						if (self.selectedCode==enm.get('code')) {
							shouldRender = true;
						}
					}
				} else {
					shouldRender = true;
				}
				if (shouldRender) {
					$(self.el).append(new AliasListOptionController({model: enm}).render().el);
				}
			});
			if ( this.selectedCode ) {
				$(this.el).val(this.selectedCode);
			}
			// hack to fix IE bug where select doesn't work when dynamically inserted
			$(this.el).hide();
			$(this.el).show();
			this.rendered = true;

			return this;
		},

		addOne: function(enm){
			$(this.el).append(new AliasListOptionController({model: enm}).render().el);
		},


		setSelectedCode: function(code) {
			this.selectedCode = code;
			if( this.rendered ) {$(this.el).val(this.selectedCode);}
		},

		getSelectedCode: function(){
			return $(this.el).val();
		},

		getSelectedModel: function() {
			return this.collection.getModelWithCode(this.getSelectedCode());
		}



	});

});