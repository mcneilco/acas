(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.BulkLoadContainersFromSDFController = (function(_super) {
    __extends(BulkLoadContainersFromSDFController, _super);

    function BulkLoadContainersFromSDFController() {
      return BulkLoadContainersFromSDFController.__super__.constructor.apply(this, arguments);
    }

    BulkLoadContainersFromSDFController.prototype.initialize = function() {
      this.fileProcessorURL = "/api/bulkLoadContainersFromSDF";
      this.errorOwnerName = 'BulkLoadContainersFromSDFController';
      this.allowedFileTypes = ['sdf'];
      this.loadReportFile = false;
      BulkLoadContainersFromSDFController.__super__.initialize.call(this);
      return this.$('.bv_moduleTitle').html('Load Containers From SDF');
    };

    return BulkLoadContainersFromSDFController;

  })(BasicFileValidateAndSaveController);

}).call(this);
