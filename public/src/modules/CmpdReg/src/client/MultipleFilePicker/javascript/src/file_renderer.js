$(function () {
    window.FileViewRenderer = Backbone.View.extend({
        
        template: _.template($('#file-template-renderer').html()),
        
        initialize: function () {
            this.model.bind('change', this.render, this);
			this.model.bind('destroy', this.remove, this);
        },
        
        render: function () {
        	if (!this.model.has('description')) {
        		this.model.set({description: ''});
        	}
            $(this.el).html(this.template(this.model.toJSON()));
            return this;
        }
    });
    
    window.FileRenderer = Backbone.View.extend({
        
        initialize: function (data) {
            if (data == undefined) {
                this.fileList = new BackboneFileList();
            } else {
                this.fileList = data;
                this.render();
            }
            
            this.fileList.bind('add', this.addOne, this);
            this.fileList.bind('remove', this.render, this);
            this.fileList.bind('reset', this.render, this);
            
            (function (controller) {
                controller.fileList.each(function (file) {
                    file.bind('change:uploaded', controller.checkFileForRender, controller);
                });
            } (this))
        },
        
        addOne: function (file) {
            file.bind('change:uploaded', this.checkFileForRender, this);
            
            if (file.get('uploaded')) {
                var fileView = new FileViewRenderer({model: file});
                $(this.el).append(fileView.render().el);
            }
        },
        
        render: function () {
            $(this.el).html('');
            var addFunc = _.bind(this.addOne, this);
            this.fileList.each(addFunc);
        },
        
        checkFileForRender: function (file) {
            if (file.get('uploaded')) {
                this.render();
            }
        }
    });
});