(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  window.AbstractFormController = (function(superClass) {
    extend(AbstractFormController, superClass);

    function AbstractFormController() {
      this.handleModelChange = bind(this.handleModelChange, this);
      this.clearValidationErrorStyles = bind(this.clearValidationErrorStyles, this);
      this.validationError = bind(this.validationError, this);
      this.attributeChanged = bind(this.attributeChanged, this);
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
          if (_this.$('.bv_' + err.attribute).attr('disabled') !== 'disabled') {
            _this.$('.bv_group_' + err.attribute).attr('data-toggle', 'tooltip');
            _this.$('.bv_group_' + err.attribute).attr('data-placement', 'bottom');
            _this.$('.bv_group_' + err.attribute).attr('data-original-title', err.message);
            _this.$("[data-toggle=tooltip]").tooltip();
            _this.$("body").tooltip({
              selector: '.bv_group_' + err.attribute
            });
            _this.$('.bv_group_' + err.attribute).addClass('input_error error');
            return _this.trigger('notifyError', {
              owner: _this.errorOwnerName,
              errorLevel: 'error',
              message: err.message
            });
          }
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
          $(ee).removeAttr('data-toggle');
          $(ee).removeAttr('data-placement');
          $(ee).removeAttr('title');
          $(ee).removeAttr('data-original-title');
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

    AbstractFormController.prototype.disableAllInputs = function() {
      this.$('input').attr('disabled', 'disabled');
      this.$('button').attr('disabled', 'disabled');
      this.$('select').attr('disabled', 'disabled');
      this.$("textarea").attr('disabled', 'disabled');
      this.$(".bv_experimentCode").css("background-color", "#eeeeee");
      this.$(".bv_experimentCode").css("color", "#333333");
      this.$(".bv_completionDateIcon").addClass("uneditable-input");
      this.$(".bv_completionDateIcon").on("click", function() {
        return false;
      });
      this.$(".bv_group_tags input").prop("placeholder", "");
      this.$(".bv_group_tags input").css("background-color", "#eeeeee");
      this.$(".bv_group_tags input").css("color", "#333333");
      this.$(".bv_group_tags div.bootstrap-tagsinput").css("background-color", "#eeeeee");
      return this.$("span.tag.label.label-info span").attr("data-role", "");
    };

    AbstractFormController.prototype.enableAllInputs = function() {
      this.$('input').removeAttr('disabled');
      this.$('select').removeAttr('disabled');
      this.$("textarea").removeAttr('disabled');
      this.$('button').removeAttr('disabled');
      this.$(".bv_group_tags input").prop("placeholder", "Add tags");
      this.$(".bv_group_tags div.bootstrap-tagsinput").css("background-color", "#ffffff");
      return this.$(".bv_group_tags input").css("background-color", "transparent");
    };

    return AbstractFormController;

  })(Backbone.View);

}).call(this);
