(function() {
  var _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.FullPKParserController = (function(_super) {
    __extends(FullPKParserController, _super);

    function FullPKParserController() {
      _ref = FullPKParserController.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    FullPKParserController.prototype.initialize = function() {
      this.fileProcessorURL = "/api/genericDataParser";
      this.errorOwnerName = 'FullPKParser';
      this.loadReportFile = true;
      FullPKParserController.__super__.initialize.call(this);
      return this.$('.bv_moduleTitle').html('Full PK Experiment Loader');
    };

    return FullPKParserController;

  })(BasicFileValidateAndSaveController);

}).call(this);
