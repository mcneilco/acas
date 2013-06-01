(function() {
  var _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.BulkLoadContainersFromSDFController = (function(_super) {
    __extends(BulkLoadContainersFromSDFController, _super);

    function BulkLoadContainersFromSDFController() {
      _ref = BulkLoadContainersFromSDFController.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    BulkLoadContainersFromSDFController.prototype.initialize = function() {
      BulkLoadContainersFromSDFController.__super__.initialize.call(this);
      this.fileProcessorURL = "/api/bulkLoadContainersFromSDF";
      this.errorOwnerName = 'BulkLoadContainersFromSDFController';
      return this.$('.bv_moduleTitle').html('Load Containers From SDF');
    };

    return BulkLoadContainersFromSDFController;

  })(BasicFileValidateAndSaveController);

}).call(this);
