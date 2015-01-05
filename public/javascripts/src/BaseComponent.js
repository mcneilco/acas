(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.AbstractBaseComponentBatch = (function(_super) {
    __extends(AbstractBaseComponentBatch, _super);

    function AbstractBaseComponentBatch() {
      return AbstractBaseComponentBatch.__super__.constructor.apply(this, arguments);
    }

    AbstractBaseComponentBatch.prototype.validate = function(attrs) {
      var amount, cDate, errors, location, notebook;
      errors = [];
      if (_.isNaN(attrs.recordedDate)) {
        errors.push({
          attribute: 'recordedDate',
          message: "Recorded date must be set"
        });
      }
      if (attrs.recordedBy === "" || attrs.recordedBy === "unassigned") {
        errors.push({
          attribute: 'recordedBy',
          message: "Scientist must be set"
        });
      }
      cDate = attrs["completion date"].get('value');
      if (cDate === void 0 || cDate === "") {
        cDate = "fred";
      }
      if (isNaN(cDate)) {
        errors.push({
          attribute: 'completionDate',
          message: "Date must be set"
        });
      }
      notebook = attrs.notebook.get('value');
      if (notebook === "" || notebook === void 0) {
        errors.push({
          attribute: 'notebook',
          message: "Notebook must be set"
        });
      }
      amount = attrs.amount.get('value');
      if (amount === "" || amount === void 0 || isNaN(amount)) {
        errors.push({
          attribute: 'amount',
          message: "Amount must be set"
        });
      }
      location = attrs.location.get('value');
      if (location === "" || location === void 0) {
        errors.push({
          attribute: 'location',
          message: "Location must be set"
        });
      }
      if (errors.length > 0) {
        return errors;
      } else {
        return null;
      }
    };

    AbstractBaseComponentBatch.prototype.prepareToSave = function() {
      var rBy, rDate;
      rBy = this.get('recordedBy');
      rDate = new Date().getTime();
      this.set({
        recordedDate: rDate
      });
      return this.get('lsStates').each(function(state) {
        if (state.get('recordedBy') === "") {
          state.set({
            recordedBy: rBy
          });
        }
        if (state.get('recordedDate') === null) {
          state.set({
            recordedDate: rDate
          });
        }
        return state.get('lsValues').each(function(val) {
          if (val.get('recordedBy') === "") {
            val.set({
              recordedBy: rBy
            });
          }
          if (val.get('recordedDate') === null) {
            return val.set({
              recordedDate: rDate
            });
          }
        });
      });
    };

    return AbstractBaseComponentBatch;

  })(Thing);

  window.AbstractBaseComponentBatchController = (function(_super) {
    __extends(AbstractBaseComponentBatchController, _super);

    function AbstractBaseComponentBatchController() {
      this.updateModel = __bind(this.updateModel, this);
      this.handleCompletionDateIconClicked = __bind(this.handleCompletionDateIconClicked, this);
      this.render = __bind(this.render, this);
      return AbstractBaseComponentBatchController.__super__.constructor.apply(this, arguments);
    }

    AbstractBaseComponentBatchController.prototype.template = _.template($("#AbstractBaseComponentBatchView").html());

    AbstractBaseComponentBatchController.prototype.events = function() {
      return {
        "change .bv_recordedBy": "attributeChanged",
        "change .bv_completionDate": "attributeChanged",
        "click .bv_completionDateIcon": "handleCompletionDateIconClicked",
        "change .bv_notebook": "attributeChanged",
        "change .bv_amount": "attributeChanged",
        "change .bv_location": "attributeChanged"
      };
    };

    AbstractBaseComponentBatchController.prototype.initialize = function() {
      console.log("initialize batch controller");
      this.errorOwnerName = 'AbstractBaseComponentBatchController';
      this.setBindings();
      this.model.on('sync', (function(_this) {
        return function() {
          console.log("sync");
          _this.trigger('amClean');
          return _this.render();
        };
      })(this));
      this.model.on('change', (function(_this) {
        return function() {
          return _this.trigger('amDirty');
        };
      })(this));
      $(this.el).empty();
      $(this.el).html(this.template());
      return this.setupRecordedBySelect();
    };

    AbstractBaseComponentBatchController.prototype.render = function() {
      this.$('.bv_batchCode').val(this.model.get('codeName'));
      this.$('.bv_batchCode').html(this.model.get('codeName'));
      this.$('.bv_recordedBy').val(this.model.get('recordedBy'));
      this.$('.bv_completionDate').datepicker();
      this.$('.bv_completionDate').datepicker("option", "dateFormat", "yy-mm-dd");
      if (this.model.get('completion date').get('value') != null) {
        this.$('.bv_completionDate').val(UtilityFunctions.prototype.convertMSToYMDDate(this.model.get('completion date').get('value')));
      } else {
        this.$('.bv_completionDate').val("");
      }
      this.$('.bv_notebook').val(this.model.get('notebook').get('value'));
      this.$('.bv_amount').val(this.model.get('amount').get('value'));
      this.$('.bv_location').val(this.model.get('location').get('value'));
      return this;
    };

    AbstractBaseComponentBatchController.prototype.setupRecordedBySelect = function() {
      this.recordedByList = new PickListList();
      this.recordedByList.url = "/api/authors";
      return this.recordedByListController = new PickListSelectController({
        el: this.$('.bv_recordedBy'),
        collection: this.recordedByList,
        insertFirstOption: new PickList({
          code: "unassigned",
          name: "Select Scientist"
        }),
        selectedCode: this.model.get('recordedBy')
      });
    };

    AbstractBaseComponentBatchController.prototype.handleCompletionDateIconClicked = function() {
      return this.$(".bv_completionDate").datepicker("show");
    };

    AbstractBaseComponentBatchController.prototype.updateModel = function() {
      console.log("update batch model");
      this.model.set({
        recordedBy: this.$('.bv_recordedBy').val()
      });
      this.model.get("notebook").set("value", UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_notebook')));
      this.model.get("completion date").set("value", UtilityFunctions.prototype.convertYMDDateToMs(UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_completionDate'))));
      this.model.get("amount").set("value", parseFloat(UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_amount'))));
      return this.model.get("location").set("value", UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_location')));
    };

    return AbstractBaseComponentBatchController;

  })(AbstractFormController);

}).call(this);
