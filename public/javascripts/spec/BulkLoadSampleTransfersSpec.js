(function() {
  beforeEach(function() {
    return this.fixture = $.clone($("#fixture").get(0));
  });

  afterEach(function() {
    $("#fixture").remove();
    return $("body").append($(this.fixture));
  });

  describe("Bulk Load Sample Transfers Controller testing", function() {
    beforeEach(function() {
      this.blcc = new BulkLoadSampleTransfersController({
        el: $('#fixture')
      });
      return this.blcc.render();
    });
    return describe("Basic loading", function() {
      it("Class should exist", function() {
        return expect(this.blcc).toBeDefined();
      });
      return it("Should load the template", function() {
        return expect($('.bv_parseFile')).not.toBeNull();
      });
    });
  });

}).call(this);
