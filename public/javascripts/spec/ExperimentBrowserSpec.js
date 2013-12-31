(function() {
  beforeEach(function() {
    return this.fixture = $.clone($("#fixture").get(0));
  });

  afterEach(function() {
    $("#fixture").remove();
    return $("body").append($(this.fixture));
  });

  describe("Experiment Browser module testing", function() {
    describe("Experiment Search Model controller", function() {
      beforeEach(function() {
        return this.esm = new ExperimentSearch();
      });
      return describe("Basic existence tests", function() {
        it("should be defined", function() {
          return expect(ExperimentSearch).toBeDefined();
        });
        return it("should have defaults", function() {
          expect(this.esm.get('protocolCode')).toBeNull();
          return expect(this.esm.get('experimentCode')).toBeNull();
        });
      });
    });
    describe("Experiment Search Controller tests", function() {
      beforeEach(function() {
        return runs(function() {
          this.esc = new ExperimentSearchController({
            model: new ExperimentSearch(),
            el: this.fixture
          });
          return this.esc.render();
        });
      });
      describe("Basic existence and rendering tests", function() {
        it("should be defined", function() {
          return expect(ExperimentSearchController).toBeDefined();
        });
        return it("should have a protocol code select", function() {
          return expect(this.esc.$('.bv_protocolCode').length).toEqual(1);
        });
      });
      describe("After render", function() {
        return it("should populate the protocol select", function() {
          waitsFor(function() {
            return this.esc.$('.bv_protocolCode option').length > 0;
          }, 1000);
          return runs(function() {
            return expect(this.esc.$('.bv_protocolCode').val()).toEqual("any");
          });
        });
      });
      describe("Model updates", function() {
        beforeEach(function() {
          return waitsFor(function() {
            return this.esc.$('.bv_protocolCode option').length > 0;
          }, 1000);
        });
        it("should update the protocol val", function() {
          return runs(function() {
            console.log(this.esc.$('.bv_protocolCode'));
            this.esc.$('.bv_protocolCode').val("PROT-00000008");
            this.esc.$('.bv_protocolCode').change();
            return expect(this.esc.model.get('protocolCode')).toEqual("PROT-00000008");
          });
        });
        return it("should update the expt code val", function() {
          this.esc.$('.bv_experimentCode').val(" EXPT-00000003 ");
          this.esc.$('.bv_experimentCode').change();
          return expect(this.esc.model.get('experimentCode')).toEqual("EXPT-00000003");
        });
      });
      return describe("search trigger", function() {
        return it("should trigger find when find pushed", function() {
          var _this = this;

          this.findTriggered = false;
          this.esc.on('find', function() {
            return _this.findTriggered = true;
          });
          runs(function() {
            return this.esc.$('.bv_find').click();
          });
          waitsFor(function() {
            return this.findTriggered;
          }, 300);
          return runs(function() {
            return expect(this.findTriggered).toBeTruthy();
          });
        });
      });
    });
    xdescribe("ExperimentRowSummaryController testing", function() {
      beforeEach(function() {
        this.ersc = new ExperimentRowSummaryController({
          model: new Experiment(window.experimentServiceTestJSON.fullExperimentFromServer),
          el: this.fixture
        });
        return this.ersc.render();
      });
      describe("Basic existance and rendering", function() {
        it("should be denifed", function() {
          return expect(this.ersc).toBeDefined();
        });
        return it("should render the template", function() {
          return expect(this.ersc.$('.bv_experimentName').length).toEqual(1);
        });
      });
      return describe("It should show experiment values", function() {
        it("should show the experiment name", function() {
          return expect(this.ersc.$('.bv_experimentName').html()).toEqual("Test Experiment 1");
        });
        it("should show the experiment code", function() {
          return expect(this.ersc.$('.bv_experimentCode').html()).toEqual("EXPT-00000001");
        });
        it("should show the protocolName", function() {
          return expect(this.ersc.$('.bv_protocolName').html()).toEqual("protocol name");
        });
        return it("should show the scientist", function() {
          return expect(this.ersc.$('.bv_recordedBy').html()).toEqual("jmcneil");
        });
      });
    });
    return describe("ExperimentBrowserController tests", function() {
      beforeEach(function() {
        this.ebc = new ExperimentBrowserController({
          el: this.fixture
        });
        return this.ebc.render();
      });
      describe("Basic existence and rendering tests", function() {
        it("should be defined", function() {
          return expect(ExperimentBrowserController).toBeDefined();
        });
        return it("should have a search controller div", function() {
          return expect(this.ebc.$('.bv_experimentSearchController').length).toEqual(1);
        });
      });
      return describe("Startup", function() {
        return it("should initialize the search controller", function() {
          return expect(this.ebc.$('.bv_find').length).toEqual(1);
        });
      });
    });
  });

}).call(this);
