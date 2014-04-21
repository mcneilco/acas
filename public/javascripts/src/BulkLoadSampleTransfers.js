(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.BulkLoadSampleTransfersController = (function(_super) {
    __extends(BulkLoadSampleTransfersController, _super);

    function BulkLoadSampleTransfersController() {
      return BulkLoadSampleTransfersController.__super__.constructor.apply(this, arguments);
    }

    BulkLoadSampleTransfersController.prototype.initialize = function() {
      BulkLoadSampleTransfersController.__super__.initialize.call(this);
      this.fileProcessorURL = "/api/bulkLoadSampleTransfers";
      this.errorOwnerName = 'BulkLoadSampleTransfersController';
      return this.$('.bv_moduleTitle').html('Load Sample Transfer Log');
    };

    return BulkLoadSampleTransfersController;

  })(BasicFileValidateAndSaveController);

}).call(this);
