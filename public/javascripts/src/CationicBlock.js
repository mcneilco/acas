(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.CationicBlockParent = (function(_super) {
    __extends(CationicBlockParent, _super);

    function CationicBlockParent() {
      return CationicBlockParent.__super__.constructor.apply(this, arguments);
    }

    CationicBlockParent.prototype.initialize = function() {
      this.set({
        lsType: "parent",
        lsKind: "cationic block"
      });
      return CationicBlockParent.__super__.initialize.call(this);
    };

    CationicBlockParent.prototype.lsProperties = {
      defaultLabels: [
        {
          key: 'cationic block name',
          type: 'name',
          kind: 'cationic block',
          preferred: true
        }
      ],
      defaultValues: [
        {
          key: 'completion date',
          stateType: 'metadata',
          stateKind: 'cationic block parent',
          type: 'dateValue',
          kind: 'completion date'
        }, {
          key: 'notebook',
          stateType: 'metadata',
          stateKind: 'cationic block parent',
          type: 'stringValue',
          kind: 'notebook'
        }, {
          key: 'molecular weight',
          stateType: 'metadata',
          stateKind: 'cationic block parent',
          type: 'numericValue',
          kind: 'molecular weight',
          unitType: 'molecular weight',
          unitKind: 'g/mol'
        }
      ]
    };

    CationicBlockParent.prototype.validate = function(attrs) {
      var bestName, cDate, errors, mw, nameError, notebook;
      console.log("validate");
      console.log(attrs);
      errors = [];
      bestName = attrs.lsLabels.pickBestName();
      nameError = true;
      if (bestName != null) {
        nameError = true;
        if (bestName.get('labelText') !== "") {
          nameError = false;
        }
      }
      if (nameError) {
        errors.push({
          attribute: 'cationicBlockName',
          message: "Name must be set"
        });
      }
      if (_.isNaN(attrs.recordedDate)) {
        errors.push({
          attribute: 'recordedDate',
          message: "Recorded date must be set"
        });
      }
      if (attrs.recordedBy === "") {
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
      mw = attrs["molecular weight"].get('value');
      if (mw === "" || mw === void 0 || isNaN(mw)) {
        errors.push({
          attribute: 'molecularWeight',
          message: "Notebook must be set"
        });
      }
      console.log(errors);
      if (errors.length > 0) {
        return errors;
      } else {
        return null;
      }
    };

    return CationicBlockParent;

  })(Thing);

  window.CationicBlockParentController = (function(_super) {
    __extends(CationicBlockParentController, _super);

    function CationicBlockParentController() {
      this.render = __bind(this.render, this);
      return CationicBlockParentController.__super__.constructor.apply(this, arguments);
    }

    CationicBlockParentController.prototype.template = _.template($("#CationicBlockParentView").html());

    CationicBlockParentController.prototype.initialize = function() {
      if (this.model == null) {
        this.model = new CationicBlockParent();
      }
      this.errorOwnerName = 'BaseEntityController';
      return this.setBindings();
    };

    CationicBlockParentController.prototype.render = function() {
      if (this.model == null) {
        this.model = new CationicBlockParent();
      }
      $(this.el).empty();
      $(this.el).html(this.template());
      this.$('.bv_cationicBlockParentCode').val(this.model.get('codeName'));
      this.$('.bv_molecularWeight').val(this.model.get('molecular weight').get("value"));
      return this.$('.bv_recordedBy').val(this.model.get('recordedBy'));
    };

    return CationicBlockParentController;

  })(AbstractFormController);

}).call(this);
