(function() {
  var _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.GenericDataParserController = (function(_super) {
    __extends(GenericDataParserController, _super);

    function GenericDataParserController() {
      _ref = GenericDataParserController.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    GenericDataParserController.prototype.initialize = function() {
      BulkLoadContainersFromSDFController.__super__.initialize.apply(this, arguments);
      this.fileProcessorURL = this.serverName + ":" + SeuratAddOns.configuration.portNumber + "/api/genericDataParser";
      this.errorOwnerName = 'GenericDataParser';
      return this.$('.bv_moduleTitle').html('Generic Data Parser');
    };

    return GenericDataParserController;

  })(BasicFileValidateAndSaveController);

}).call(this);
