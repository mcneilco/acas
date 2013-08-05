(function() {
  var _ref,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.AbstractParserFormController = (function(_super) {
    __extends(AbstractParserFormController, _super);

    function AbstractParserFormController() {
      this.attributeChanged = __bind(this.attributeChanged, this);
      this.render = __bind(this.render, this);      _ref = AbstractParserFormController.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    AbstractParserFormController.prototype.initialize = function() {
      $(this.el).html(this.template());
      return this.setBindings();
    };

    AbstractParserFormController.prototype.render = function() {
      this.$('.bv_csvPreviewContainer').hide();
      return this;
    };

    AbstractParserFormController.prototype.attributeChanged = function() {
      this.trigger('amDirty');
      return this.updateModel();
    };

    AbstractParserFormController.prototype.setupProjectSelect = function() {
      this.projectList = new PickListList();
      this.projectList.url = "/api/projects";
      return this.projectListController = new PickListSelectController({
        el: this.$('.bv_project'),
        collection: this.projectList,
        insertFirstOption: new PickList({
          code: "unassigned",
          name: "Select Project"
        }),
        selectedCode: "unassigned"
      });
    };

    AbstractParserFormController.prototype.setupProtocolSelect = function(search) {
      this.protocolList = new PickListList();
      this.protocolList.url = "api/protocolCodes/filter/" + search;
      return this.protocolListController = new PickListSelectController({
        el: this.$('.bv_protocolName'),
        collection: this.protocolList,
        insertFirstOption: new PickList({
          code: "unassigned",
          name: "Select Protocol"
        }),
        selectedCode: "unassigned"
      });
    };

    AbstractParserFormController.prototype.disableAllInputs = function() {
      this.$('input').attr('disabled', 'disabled');
      return this.$('select').attr('disabled', 'disabled');
    };

    AbstractParserFormController.prototype.enableAllInputs = function() {
      this.$('input').removeAttr('disabled');
      this.$('select').removeAttr('disabled');
      return this.$('.bv_csvPreviewContainer').hide();
    };

    AbstractParserFormController.prototype.showCSVPreview = function(csv) {
      var csvRows, headCells, r, rowCells, val, _i, _j, _k, _len, _len1, _ref1;

      this.$('.csvPreviewTHead').empty();
      this.$('.csvPreviewTBody').empty();
      csvRows = csv.split('\n');
      headCells = csvRows[0].split(',');
      this.$('.csvPreviewTHead').append("<tr></tr>");
      for (_i = 0, _len = headCells.length; _i < _len; _i++) {
        val = headCells[_i];
        this.$('.csvPreviewTHead tr').append("<th>" + val + "</th>");
      }
      for (r = _j = 1, _ref1 = csvRows.length - 2; 1 <= _ref1 ? _j <= _ref1 : _j >= _ref1; r = 1 <= _ref1 ? ++_j : --_j) {
        this.$('.csvPreviewTBody').append("<tr></tr>");
        rowCells = csvRows[r].split(',');
        for (_k = 0, _len1 = rowCells.length; _k < _len1; _k++) {
          val = rowCells[_k];
          this.$('.csvPreviewTBody tr:last').append("<td>" + val + "</td>");
        }
      }
      return this.$('.bv_csvPreviewContainer').show();
    };

    return AbstractParserFormController;

  })(AbstractFormController);

}).call(this);
