(function() {
  var _ref, _ref1,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.DocUpload = (function(_super) {
    __extends(DocUpload, _super);

    function DocUpload() {
      _ref = DocUpload.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    DocUpload.prototype.defaults = {
      url: "",
      currentFileName: "",
      description: "",
      docType: "",
      documentKind: "experiment"
    };

    DocUpload.prototype.validate = function(attrs) {
      var errors, _ref1;

      errors = [];
      if ((_ref1 = attrs.docType) !== 'url' && _ref1 !== 'file') {
        errors.push({
          attribute: 'docType',
          message: "Type must be one of url or file"
        });
      }
      if (attrs.docType === 'file') {
        if (attrs.currentFileName === "") {
          errors.push({
            attribute: 'currentFileName',
            message: "must set file when docType is file"
          });
        }
      }
      if (attrs.docType === 'url') {
        if (attrs.url === "") {
          errors.push({
            attribute: 'url',
            message: "must set url when docType is url"
          });
        }
      }
      if (errors.length > 0) {
        return errors;
      } else {
        return null;
      }
    };

    return DocUpload;

  })(Backbone.Model);

  window.DocUploadController = (function(_super) {
    __extends(DocUploadController, _super);

    function DocUploadController() {
      this.updateModel = __bind(this.updateModel, this);
      this.attributeChanged = __bind(this.attributeChanged, this);
      this.clearNewFileName = __bind(this.clearNewFileName, this);
      this.setNewFileName = __bind(this.setNewFileName, this);
      this.docTypeChanged = __bind(this.docTypeChanged, this);
      this.render = __bind(this.render, this);      _ref1 = DocUploadController.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    DocUploadController.prototype.template = _.template($("#DocUploadView").html());

    DocUploadController.prototype.events = {
      'change [name="docTypeRadio"]': "docTypeChanged",
      'change .bv_url': "attributeChanged",
      'change .bv_description': "attributeChanged"
    };

    DocUploadController.prototype.initialize = function() {
      this.errorOwnerName = 'DocUploadController';
      $(this.el).html(this.template());
      this.fileInputController = new LSFileInputController({
        el: this.$('.bv_fileInput'),
        inputTitle: '',
        url: "http://" + window.conf.host + ":" + window.conf.service.file.port,
        fieldIsRequired: false,
        requiresValidation: false,
        maxNumberOfFiles: 1
      });
      this.fileInputController.on('fileInput:uploadComplete', this.setNewFileName);
      this.fileInputController.on('fileInput:removedFile', this.clearNewFileName);
      this.setBindings();
      if (!this.model.isNew()) {
        this.$('.bv_fileInput').hide();
        if (this.model.get('docType') === 'file') {
          $('.bv_currentFileRadio').attr('checked', true);
          return this.$('.bv_currentFileName').html(this.model.get('currentFileName'));
        } else {
          this.$('.bv_currentDocContainer').hide();
          $('.bv_urlRadio').attr('checked', true);
          return this.$('.bv_url').val(this.model.get('url'));
        }
      }
    };

    DocUploadController.prototype.render = function() {
      this.fileInputController.render();
      if (this.model.isNew()) {
        this.$('.bv_currentDocContainer').hide();
      }
      if (!this.$('.bv_urlRadio').is(":checked")) {
        this.$('.bv_urlInputWrapper').hide();
      }
      return this;
    };

    DocUploadController.prototype.docTypeChanged = function(event) {
      var currentChecked;

      currentChecked = this.$('[name="docTypeRadio"]:checked').val();
      if (currentChecked !== 'url') {
        this.$('.bv_urlInputWrapper').hide('slide');
      } else {
        this.$('.bv_urlInputWrapper').show('slide');
      }
      if (currentChecked !== 'file') {
        this.$('.bv_fileInput').hide('slide');
      } else {
        this.$('.bv_fileInput').show('slide');
      }
      return this.updateModel();
    };

    DocUploadController.prototype.setNewFileName = function(fileNameOnServer) {
      this.model.set({
        currentFileName: fileNameOnServer
      });
      return this.updateModel();
    };

    DocUploadController.prototype.clearNewFileName = function() {
      this.model.set({
        currentFileName: ""
      });
      return this.updateModel();
    };

    DocUploadController.prototype.attributeChanged = function() {
      this.trigger('amDirty');
      return this.updateModel();
    };

    DocUploadController.prototype.updateModel = function() {
      return this.model.set({
        docType: this.$('[name="docTypeRadio"]:checked').val(),
        url: this.$('.bv_url').val(),
        description: this.$('.bv_description').val()
      });
    };

    return DocUploadController;

  })(AbstractFormController);

}).call(this);
