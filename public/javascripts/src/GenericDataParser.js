(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  window.GenericDataParserController = (function(superClass) {
    extend(GenericDataParserController, superClass);

    function GenericDataParserController() {
      return GenericDataParserController.__super__.constructor.apply(this, arguments);
    }

    GenericDataParserController.prototype.initialize = function() {
      this.fileProcessorURL = "/api/genericDataParser";
      this.errorOwnerName = 'GenericDataParser';
      this.loadReportFile = true;
      this.loadImagesFile = true;
      GenericDataParserController.__super__.initialize.call(this);
      return this.$('.bv_moduleTitle').html('Simple Experiment Loader');
    };

    return GenericDataParserController;

  })(BasicFileValidateAndSaveController);

}).call(this);
