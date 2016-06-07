$(function () {
    window.BackboneFile = Backbone.Model.extend({

        defaults : {
            uploaded: false
        },
		sync: Backbone.localSync,
		localStorage: new Store('FileListItems'),

        initialize: function (data) {
            if (data.file != undefined) {
                var file = data.file;
                
                // Code duplication, refactor.
                if (file.name == undefined
                        || file.size == undefined || file.type == undefined) {

                    throw new Error('MissingArgumentError');

                } else if (!this._nameIsValid(file.name)
                        || !this._sizeIsValid(file.size) || !this._typeIsValid(file.type)) {

                    throw new Error('IllegalArgumentError');
                }

                this.set({name: file.name});
                this.set({size: file.size});
                this.set({type: file.type});
                this.set({file: file});
                this.set({url: ''});

            // else we are unit testing
            } else if (data.name == undefined
                    || data.size == undefined || data.type == undefined) {

                throw new Error('MissingArgumentError');

            } else if (!this._nameIsValid(data.name)
                    || !this._sizeIsValid(data.size) || !this._typeIsValid(data.type)) {

                throw new Error('IllegalArgumentError');
            } else {
                // for unit testing replace the file prop
                // with the file content
                this.set({file: data.content})
            }
        },

        _nameIsValid: function (name) {
            if (typeof name != 'string') {
                return false;
            }

            return true;
        },

        _sizeIsValid: function (size) {
            if (isNaN(size)) {
                return false;
            }

            return true;

        },

        _typeIsValid: function (type) {
            if (typeof type != 'string') {
                return false;
            }

            return true;
        }
    });
    
    window.BackboneFileDesc = BackboneFile.extend({
        defaults: $.extend(
            { description: '' },
            window.BackboneFile.prototype.defaults
        )
    });

    window.FileView = Backbone.View.extend({
        className: 'file-view',

        initialize: function () {
            this.model.bind('change', this.render, this);
			this.model.bind('destroy', this.fade_remove, this);
        },

     	template: _.template($('#file-template').html()),

        render: function () {
            $(this.el).html(this.template(this.model.toJSON()));
            return this;
        },

        events: {
            'click .delete': 'clear'
        },

        clear: function () {
            this.model.destroy();
        },
        
        fade_remove: function () {
            $(this.el).animate({opacity: 0}, 100, function () {
                $(this).slideUp(100, function () {
                    $(this).remove();
                });
            });
        }
    });
    
    window.FileViewDesc = window.FileView.extend({
        template: _.template($('#file-template-desc').html()),
        className: 'fileRow',
        tagName: "tr",
        
        events: $.extend(
            {
                'change .description': 'saveDescription'
            },
            window.FileView.prototype.events
        ),
        initialize: function() {
            this.constructor.__super__.initialize.apply(this);
            this.descriptionCodeController = null;
            _.bindAll(this, 'render', 'saveDescription');
        },
        render: function(){
            if (this.descriptionCodeController==null) {
                this.constructor.__super__.render.apply(this); // can't replace whole el or lose the select that the picklist is bound to'
                this.descriptionCodeController = 
                    this.setupCodeController(this.$('.description'), 'fileTypes', 'description');
            }
            return this;
        },
            
        saveDescription: function (event) {
            this.model.set({ description: this.descriptionCodeController.getSelectedCode() });
        },

        setupCodeController: function(elem, type, attribute) {
            var tcode = '';
            if (this.model.get(attribute)) {
                tcode = this.model.get(attribute);
            }
			return new PickListSelectController({
				el: elem,
				type: type,
                selectedCode: tcode
			})
        }

    });

    window.BackboneFileList = Backbone.Collection.extend({
        model: BackboneFile,
		sync: Backbone.localSync,
		localStorage: new Store('FileList'),
        
        initialize: function (data) {
            this.bind('add', this.checkFileMimeType, this);
        },

        upload: function (target, serverDestDir) {
            var count = 0;
            var len = this.getNotUploadedFiles().length;

            this.each(function (file) {
                if (file.get('uploaded') == false) {
                    var fileObj = file.get('file');

                    var xhr = new XMLHttpRequest();
                    xhr.open('POST', target+'?serverDestDir='+serverDestDir, true);
                    xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
                    xhr.setRequestHeader('FILENAME', file.get('name'));
                    xhr.setRequestHeader('SIZE', file.get('size'));
                    xhr.setRequestHeader('TYPE', file.get('type'));
                    xhr.onreadystatechange = _.bind(function () {
                        if (xhr.readyState != 4)  {
                            return;
                        }

                        $resp = $.parseJSON(xhr.responseText);

                        if ($resp.status == 'error') {
                            // the file has not been uploaded
                            // output to the error notification system when it exists
                            alert('Your files could not be uploaded');
                        } else {
                            count++;
                            file.set({uploaded: true, url: $resp.url});

                            
//                            console.log(count);
//                            console.log(this.length);
                            
                            if (count == len) {
                                this.trigger('uploaded');
                            }
                        }
                        // Should we drop the file attribute of our model?

                    }, this);

                    xhr.send(fileObj);
                }
            }, this);
        },
        
        checkFileMimeType: function (model) {
            var index = 0;
            
            if (this.validMimeTypes != undefined) {
                index = $.inArray(model.get('type'), this.validMimeTypes);
            }
                
            if (index == -1) {
                // Should use the error notification system
//                alert('Invalid File Type: ' + model.get('type'));
                throw new Error('InvalidFileType');
            }
        },
        
        getUploadedFiles: function () {
            return this.filter(function (file) {
                return file.get('uploaded');
            });
        },
        
        getNotUploadedFiles: function () {
            return this.without.apply(
                    this, this.getUploadedFiles());
        }
    });

    window.DropView = Backbone.View.extend({
        id: 'drop-view',
        className: 'drop-view',
		template: _.template($('#DropView_template').html()),
        
        initialize: function (data) {
            $(this.el).html(this.template());
            if (data != undefined) {
                this.desc = data.desc == undefined ? false : data.desc;
            }
            
            if (data != undefined && data.fileList != undefined) {
                this.fileList = data.fileList;
                var rendfunc = _.bind(this.renderFile, this);
                this.fileList.each(rendfunc);
            } else {
                this.fileList = new BackboneFileList();
            }

            this.fileList.bind('add', this.renderFile, this);
            this.fileList.bind('remove', this.addHint, this);
            
            // If the browser doesn't supports html5 drag and drop
            // append a form in the view
            if(!('draggable' in document.createElement('span'))
                    || (data != undefined && data.compatibilityMode == true)) {
                
                this.ie = true;
                var target;
                
                if (data != undefined) {
                    target = data.target;
                }
                
                this.form = $('<form method="post" target="' + target + '" '
                    + 'enctype="multipart/form-data" class="fileForm">'
                    + '<table class="fileInputTable"></table>'
                    + '</form>');
                $(this.el).append(this.form);
                this.addInput();
            } else {
                
                
                
                // This makes it a valid drop element
                $(this.el).attr('ondragenter', 'return false');
                $(this.el).attr('ondragover', 'return false');
                if (this.fileList.length == 0) {
                    $(this.el).append('<span class="drop-text">Drop files here...</span>');
                }
            }
        },

        events: {
            'drop': 'elementDropped',
            'dragover': 'dragin',
            'dragleave': 'dragout',
            'change input.file-upload': 'addInput',
            'click input.file-upload': 'addInputIE',
            'click .cancel': 'removeInput'
        },

        elementDropped: function (event) {
            event.preventDefault();
            $(this.el).removeClass('hover');
            
            var dt = event.originalEvent.dataTransfer;
            var files = dt.files;
            
            for (i = 0; i < files.length; i++) {
                if(this.dec) {
                    var bbFile = new BackboneFileDesc({
                        file: files[i]
                    });
                } else {
                    var bbFile = new BackboneFile({
                        file: files[i]
                    });
                }
                this.fileList.add(bbFile);
            }
        },
        
        dragin: function () {
            if ('draggable' in document.createElement('span') &&
                        (this.ie == false || this.ie == undefined)) {
                $(this.el).addClass('hover');
                $('.drop-text').remove();
            }
        },
        
        dragout: function () {
            if ('draggable' in document.createElement('span') &&
                        (this.ie == false || this.ie == undefined)) {
                $(this.el).removeClass('hover');
            
                if (this.fileList.length == 0) {
                    $(this.el).append('<span class="drop-text">Drop files here...</span>');
                }
            }
        },
        
        addHint: function () {
            if (this.fileList.length == 0 && 'draggable' in document.createElement('span') &&
                    (this.ie == false || this.ie == undefined)) {
                $(this.el).append('<span class="drop-text">Drop files here...</span>');
            }
        },
        
        // If browser doesn't support html5 drag and drop
        // add a new input field when the user adds a file in
        // a the current input field
        addInput: function (event) {
            if (this.$('form input.file-upload:last').val() != "") {
//                if (event != undefined) {
//                    $(event.target).after('<span class="cancel">cancel</span>');
//                }
//                if(this.$('form .fileInputTable .fileInputRow').length==0){
                if(false){
                    this.$('form .fileInputTable').append('<tr class="fileInputRow"><td class="fileInput"><input type="file" class="file-upload" name="file[]"/></td><td class="fileType"><select class="ie-description" name="description[]"></select></td><td></td></tr>');
                } else {
                    this.$('form .fileInputTable').append('<tr class="fileInputRow"><td class="fileInput"><input type="file" class="file-upload" name="file[]"/></td><td class="fileType"><select class="ie-description" name="description[]"></select></td><td class="cancel">cancel</td></tr>');
                }
                var desController = this.setupCodeController(this.$('.ie-description:last'), 'fileTypes', 'description');
            }
        },
        
        // Forces IE to trigger the change event
        // on the input field if a file is selected
        addInputIE: function (event) {
            if ($.browser.msie) {
                setTimeout(function () {
                    $(event.target).blur();
                }, 0);
            }
        },
        
        removeInput: function (event) {
            $(event.target).parent().animate({opacity: 0}, 100, function () {
                $(this).slideUp(100, function () {
                    $(this).remove();
                });
            });
        },
        
        renderFile: function (model) {
            var fileView = this.desc ? new FileViewDesc({model: model}) : new FileView({model: model});
            this.$('.fileTable').append(fileView.render().el);
            if (this.fileList.length > 0) {
                this.$('.drop-text').remove();
            }
        },
        setupCodeController: function(elem, type) {
			return new PickListSelectController({
				el: elem,
				type: type,
                selectedCode: ''
			})
        }

    });
    
    window.UploadAppView = Backbone.View.extend({
        id: 'upload-app',

        initialize: function (data) {
            // checking for provided app options
            var showButtons = true;
            
            if (data) {
                if (data.target == undefined) {
                    this.options.target = 'file_upload.php';
                }

                if (data.compatibilityMode == undefined) {
                    this.options.compatibilityMode = false;
                }
                
                if (data.showButtons != undefined) {
                    showButtons = data.showButtons;
                }

                
                this.options = data;
            }
            if (this.options.closeOnUpload ==null ) {this.options.closeOnUpload=true;}
            this.dropView = new DropView({
                compatibilityMode:  this.options.compatibilityMode,
                desc: this.options.descriptions,
                fileList: this.options.fileList
            });
            
            $(this.el).append(this.dropView.el);
            
            if (showButtons) {
                $(this.el).append('<input type="button" class="upload btn"/>');
                $(this.el).append('<input type="button" class="reset btn"/>');
                $(this.el).append('<input type="button" class="cancelBtn btn"/>');
            }
            // Reset feature is confusing, so hide button
            this.$('input.reset').hide();
                        
            if (showButtons) {
                this.$('input.btn').css({
                    'margin-top': '10px'
                });
            }
            
            this.dropView.fileList.bind('uploaded', this._done, this);
            this.dropView.fileList.validMimeTypes = this.options.validMimeTypes;
        },
        
        events: {
            'click input.upload': 'upload',
            'click input.reset': 'reset',
            'click input.cancelBtn': 'fadeOut'
        },
        
        upload: function () {
            var self = this;
            if(!('draggable' in document.createElement('span')) || this.options.compatibilityMode == true) {
                (function (appView) {
                    appView.dropView.form.ajaxSubmit({
                        url: appView.options.target,
                        type: 'post',
                        data: {ie: true, subdir:self.options.serverDestDir},
                        dataType: 'json',
                        contentType: "application/x-www-form-urlencoded;charset=utf-8",
                        success: function (resp) {
                            if (resp.length > 0) {
                                var input = $('form tr:last');
                                // The input needs to be wrapped into a div
                                var inputDiv = $('<table class="fileInputTable"></table>');
                                inputDiv.append(input);
                                var form = appView.dropView.$('form').empty().remove();
                                form.append(inputDiv);
                                
                                for(i = 0; i < resp.length; i++) {
                                    if (appView.options.descriptions == true) {
                                        appView.dropView.fileList.model = BackboneFileDesc;
//                                        console.log(appView.dropView.el);
//                                        resp[i].description = appView.dropView;
                                    }
                                    
                                    appView.dropView.fileList.add(resp[i]);
                                }
                                
                                $(appView.dropView.el).append(form)
                            }
                            appView._done();
                        },
                        error: function (resp, a2, a3) {
                            alert('error...');
//                            alert(resp);
//                            alert(a2);
//                            alert(a3);
                        }
                    });
                }(this));
                
            } else {
                this.dropView.fileList.upload(this.options.target, this.options.serverDestDir);
            }
        },
        
        show: function () {
            $(this.el).show();
        },
        
        hide: function () {
            $(this.el).hide();
        },
        
        fadeIn: function (duration) {
            $(this.el).fadeIn(duration);
        },
        
        fadeOut: function (duration) {
            if (isNaN(duration)) {
                duration = 100;
            }
            $(this.el).fadeOut(duration);
        },
        
        reset: function () {
            this.dropView.fileList.each(function (model) {
                // We need to set the timeout because
                // of the destroy animation
                setTimeout(function () {model.destroy();}, 200);
            });
        },
        
        getFiles: function() {
            var files = [];
            
            this.dropView.fileList.each(function (file) {
                files.push(file);
            });
            
            return files;
        },
        
        filesLength: function () {
            return this.dropView.fileList.length;
        },
        
        getUploadedFiles: function () {
            return this.dropView.fileList.getUploadedFiles();
        },
        
        getNotUploadedFiles: function () {
            return this.dropView.fileList.getNotUploadedFiles();
        },
        
        _done: function (files) {
            this.trigger('uploaded');
            if (this.options.closeOnUpload) {
            	this.fadeOut(100);
            }
        }
    });
});