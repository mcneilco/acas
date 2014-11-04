(function() {
  beforeEach(function() {
    return this.fixture = $.clone($("#fixture").get(0));
  });

  afterEach(function() {
    $("#fixture").remove();
    return $("body").append($(this.fixture));
  });

  describe("Protocol Browser module testing", function() {
    describe("Protocol Search Model controller", function() {
      beforeEach(function() {
        return this.psm = new ProtocolSearch();
      });
      return describe("Basic existence tests", function() {
        it("should be defined", function() {
          return expect(this.psm).toBeDefined();
        });
        return it("should have defaults", function() {
          return expect(this.psm.get('protocolCode')).toBeNull();
        });
      });
    });
    return describe("Protocol Simple Search Controller", function() {
      return describe("when instantiated", function() {
        beforeEach(function() {
          this.pssc = new ProtocolSimpleSearchController({
            model: new ProtocolSearch(),
            el: $('#fixture')
          });
          return this.pssc.render();
        });
        return describe("basic existance tests", function() {
          it("should exist", function() {
            return expect(this.pssc).toBeDefined();
          });
          return it("should load a template", function() {
            return expect(this.pssc.$('.bv_protocolSearchTerm').length).toEqual(1);
          });
        });
      });
    });
  });

}).call(this);
