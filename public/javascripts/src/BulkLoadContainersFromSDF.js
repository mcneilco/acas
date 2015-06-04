(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  window.BulkLoadContainersFromSDFController = (function(superClass) {
    extend(BulkLoadContainersFromSDFController, superClass);

    function BulkLoadContainersFromSDFController() {
      return BulkLoadContainersFromSDFController.__super__.constructor.apply(this, arguments);
    }

    BulkLoadContainersFromSDFController.prototype.initialize = function() {
      this.fileProcessorURL = "/api/bulkLoadContainersFromSDF";
      this.errorOwnerName = 'BulkLoadContainersFromSDFController';
      this.allowedFileTypes = ['sdf', 'csv'];
      this.loadReportFile = false;
      BulkLoadContainersFromSDFController.__super__.initialize.call(this);
      return this.$('.bv_moduleTitle').html('Load Containers From SDF');
    };

    return BulkLoadContainersFromSDFController;

  })(BasicFileValidateAndSaveController);

}).call(this);
