(function() {
  beforeEach(function() {
    return this.fixture = $.clone($("#fixture").get(0));
  });

  afterEach(function() {
    $("#fixture").remove();
    return $("body").append($(this.fixture));
  });

  describe("Generic Data Parser Controller testing", function() {
    beforeEach(function() {
      this.gdpc = new GenericDataParserController({
        el: $('#fixture')
      });
      return this.gdpc.render();
    });
    return describe("Basic loading", function() {
      it("Class should exist", function() {
        return expect(this.gdpc).toBeDefined();
      });
      return it("Should load the template", function() {
        return expect($('.bv_parseFile')).not.toBeNull();
      });
    });
  });

}).call(this);
