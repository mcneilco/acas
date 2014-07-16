(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.AbstractFormController = (function(_super) {
    __extends(AbstractFormController, _super);

    function AbstractFormController() {
      this.handleModelChange = __bind(this.handleModelChange, this);
      this.clearValidationErrorStyles = __bind(this.clearValidationErrorStyles, this);
      this.validationError = __bind(this.validationError, this);
      this.attributeChanged = __bind(this.attributeChanged, this);
      return AbstractFormController.__super__.constructor.apply(this, arguments);
    }

    AbstractFormController.prototype.show = function() {
      return $(this.el).show();
    };

    AbstractFormController.prototype.hide = function() {
      return $(this.el).hide();
    };

    AbstractFormController.prototype.cancel = function() {
      this.clearValidationErrorStyles();
      return this.hide();
    };

    AbstractFormController.prototype.setModel = function(model) {
      this.model = model;
      this.setBindings();
      return this.render();
    };

    AbstractFormController.prototype.attributeChanged = function() {
      this.trigger('amDirty');
      return this.updateModel();
    };

    AbstractFormController.prototype.setBindings = function() {
      this.model.on('invalid', this.validationError);
      return this.model.on('change', this.handleModelChange);
    };

    AbstractFormController.prototype.validationError = function() {
      var errors;
      errors = this.model.validationError;
      this.clearValidationErrorStyles();
      _.each(errors, (function(_this) {
        return function(err) {
          _this.$('.bv_group_' + err.attribute).addClass('input_error error');
          return _this.trigger('notifyError', {
            owner: _this.errorOwnerName,
            errorLevel: 'error',
            message: err.message
          });
        };
      })(this));
      return this.trigger('invalid');
    };

    AbstractFormController.prototype.clearValidationErrorStyles = function() {
      var errorElms;
      errorElms = this.$('.input_error');
      this.trigger('clearErrors', this.errorOwnerName);
      return _.each(errorElms, (function(_this) {
        return function(ee) {
          return $(ee).removeClass('input_error error');
        };
      })(this));
    };

    AbstractFormController.prototype.isValid = function() {
      return this.model.isValid();
    };

    AbstractFormController.prototype.handleModelChange = function() {
      this.clearValidationErrorStyles();
      if (this.isValid()) {
        return this.trigger('valid');
      } else {
        return this.trigger('invalid');
      }
    };

    AbstractFormController.prototype.getTrimmedInput = function(selector) {
      return $.trim(this.$(selector).val());
    };

    AbstractFormController.prototype.convertYMDDateToMs = function(inStr) {
      var dateParts;
      dateParts = inStr.split('-');
      return new Date(dateParts[0], dateParts[1] - 1, dateParts[2]).getTime();
    };

    AbstractFormController.prototype.convertMSToYMDDate = function(ms) {
      var date, monthNum;
      date = new Date(ms);
      monthNum = date.getMonth() + 1;
      return date.getFullYear() + '-' + ("0" + monthNum).slice(-2) + '-' + ("0" + date.getDate()).slice(-2);
    };

    AbstractFormController.prototype.disableAllInputs = function() {
      this.$('input').attr('disabled', 'disabled');
      this.$('select').attr('disabled', 'disabled');
      return this.$("textarea").attr('disabled', 'disabled');
    };

    AbstractFormController.prototype.enableAllInputs = function() {
      this.$('input').removeAttr('disabled');
      this.$('select').removeAttr('disabled');
      return this.$("textarea").removeAttr('disabled');
    };

    return AbstractFormController;

  })(Backbone.View);

}).call(this);
