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
          return expect(this.esc.$('.bv_protocolKind').length).toEqual(1);
        });
      });
      describe("After render", function() {
        return it("should populate the protocol select", function() {
          waitsFor(function() {
            return this.esc.$('.bv_protocolKind option').length > 0;
          }, 1000);
          return runs(function() {
            return expect(this.esc.$('.bv_protocolKind').val()).toEqual("any");
          });
        });
      });
      describe("Model updates", function() {
        beforeEach(function() {
          return waitsFor(function() {
            return this.esc.$('.bv_protocolKind option').length > 0;
          }, 1000);
        });
        it("should update the protocol name", function() {
          return runs(function() {
            console.log(this.esc.$('.bv_protocolKind'));
            this.esc.$('.bv_protocolName').val("PROT-00000008");
            this.esc.$('.bv_protocolName').change();
            return expect(this.esc.model.get('protocolCode')).toEqual("PROT-00000008");
          });
        });
        return it("should update the expt code val", function() {
          this.esc.$('.bv_experimentCode').val(" EXPT-00000003 ");
          this.esc.$('.bv_experimentCode').change();
          return expect(this.esc.model.get('experimentCode')).toEqual("EXPT-00000003");
        });
      });
      describe("field behavior", function() {
        describe("when any value is entered in the experiment code field", function() {
          return it("should disable the protocol kind and protocol name select lists ", function() {
            var keyup;
            this.esc.$(".bv_experimentCode").val("EXPT-0000000");
            keyup = $.Event('keyup');
            this.esc.$('.bv_experimentCode').trigger(keyup);
            expect(this.esc.$(".bv_protocolKind").prop("disabled")).toBeTruthy();
            return expect(this.esc.$(".bv_protocolName").prop("disabled")).toBeTruthy();
          });
        });
        return describe("when the experiment code field is empty", function() {
          return it("should enable the protocol kind and protocol name select lists ", function() {
            var keyup;
            this.esc.$(".bv_experimentCode").val("EXPT-0000000");
            keyup = $.Event('keyup');
            this.esc.$('.bv_experimentCode').trigger(keyup);
            expect(this.esc.$(".bv_protocolKind").prop("disabled")).toBeTruthy();
            expect(this.esc.$(".bv_protocolName").prop("disabled")).toBeTruthy();
            this.esc.$(".bv_experimentCode").val("");
            keyup = $.Event('keyup');
            this.esc.$('.bv_experimentCode').trigger(keyup);
            expect(this.esc.$(".bv_protocolKind").prop("disabled")).toBeFalsy();
            return expect(this.esc.$(".bv_protocolName").prop("disabled")).toBeFalsy();
          });
        });
      });
      return describe("search trigger", function() {
        return it("should trigger find when find pushed", function() {
          this.findTriggered = false;
          this.esc.on('find', (function(_this) {
            return function() {
              return _this.findTriggered = true;
            };
          })(this));
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
    describe("ExperimentRowSummaryController testing", function() {
      beforeEach(function() {
        this.ersc = new ExperimentRowSummaryController({
          model: new Experiment(window.experimentServiceTestJSON.fullExperimentFromServer),
          el: this.fixture
        });
        return this.ersc.render();
      });
      xdescribe("Basic existence and rendering", function() {
        it("should be defined", function() {
          return expect(this.ersc).toBeDefined();
        });
        return it("should render the template", function() {
          return expect(this.ersc.$('.bv_experimentName').length).toEqual(1);
        });
      });
      xdescribe("It should show experiment values", function() {
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
      return describe("basic behavior", function() {
        return it("should trigger gotClick when the row is clicked", function() {
          this.clickTriggered = false;
          this.ersc.on('gotClick', (function(_this) {
            return function() {
              return _this.clickTriggered = true;
            };
          })(this));
          runs(function() {
            return $(this.ersc.el).click();
          });
          waitsFor(function() {
            return this.clickTriggered;
          }, 300);
          return runs(function() {
            return expect(this.clickTriggered).toBeTruthy();
          });
        });
      });
    });
    describe("ExperimentSummaryTableController", function() {
      beforeEach(function() {
        this.estc = new ExperimentSummaryTableController({
          collection: new ExperimentList([window.experimentServiceTestJSON.fullExperimentFromServer]),
          el: this.fixture
        });
        return this.estc.render();
      });
      describe("Basic existence and rendering", function() {
        it("should be defined", function() {
          return expect(this.estc).toBeDefined();
        });
        return it("should render the template", function() {
          return expect(this.estc.$('tbody').length).toEqual(1);
        });
      });
      describe("It should render a summary row for each experiment record", function() {
        return it("should show the experiment name", function() {
          return expect(this.estc.$('tbody tr').length).toBeGreaterThan(0);
        });
      });
      return describe("basic behavior", function() {
        it("should listen for gotClick row event and trigger selectedRowUpdated event", function() {
          this.clickTriggered = false;
          this.estc.on('selectedRowUpdated', (function(_this) {
            return function() {
              return _this.clickTriggered = true;
            };
          })(this));
          runs(function() {
            return this.estc.$("tr").click();
          });
          waitsFor(function() {
            return this.clickTriggered;
          }, 300);
          return runs(function() {
            return expect(this.clickTriggered).toBeTruthy();
          });
        });
        return it("should display a message alerting the user that no matching experiments were found if the search returns no experiments", function() {
          var estc;
          estc = new ExperimentBrowserController();
          $("#fixture").html(estc.render().el);
          estc.setupExperimentSummaryTable([]);
          console.log('$(".bv_noMatchesFoundMessage").html()');
          console.log($(".bv_noMatchesFoundMessage").html());
          expect($(".bv_noMatchesFoundMessage").hasClass("hide")).toBeFalsy();
          return expect($(".bv_noMatchesFoundMessage").html()).toContain("No Matching Experiments Found");
        });
      });
    });
    describe("ExperimentBrowserController tests", function() {
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
          return expect(this.ebc.$('.bv_doSearch').length).toEqual(1);
        });
      });
    });
    return describe("Experiment Browser Services", function() {
      beforeEach(function() {
        return this.waitForServiceReturn = function() {
          return typeof this.serviceReturn !== 'undefined';
        };
      });
      describe("Generic Search Node Proxy", function() {
        return it("should exist and return an OK status", function() {
          var searchTerm;
          searchTerm = "some experiment";
          runs(function() {
            return $.ajax({
              type: 'GET',
              url: "/api/experiments/genericSearch/" + searchTerm,
              dataType: "json",
              data: {
                testMode: true,
                fullObject: false
              },
              success: (function(_this) {
                return function(json) {
                  return _this.serviceReturn = json;
                };
              })(this),
              error: (function(_this) {
                return function(err) {
                  console.log('got ajax error');
                  return _this.serviceReturn = null;
                };
              })(this)
            });
          });
          waitsFor(this.waitForServiceReturn, 'service did not return', 10000);
          return runs(function() {
            return expect(this.serviceReturn).toBeTruthy();
          });
        });
      });
      return describe("Edit Experiment redirect proxy", function() {
        return it("should exist and return an OK status", function() {
          var experimentCodeName;
          experimentCodeName = "EXPT-00000001";
          runs(function() {
            return $.ajax({
              type: 'GET',
              url: "/api/experiments/edit/" + experimentCodeName,
              dataType: "json",
              data: {
                testMode: true,
                fullObject: false
              },
              success: (function(_this) {
                return function(json) {
                  return _this.serviceReturn = json;
                };
              })(this),
              error: (function(_this) {
                return function(err) {
                  console.log('got ajax error');
                  return _this.serviceReturn = null;
                };
              })(this)
            });
          });
          waitsFor(this.waitForServiceReturn, 'service did not return', 10000);
          return runs(function() {
            return expect(this.serviceReturn).toBeTruthy();
          });
        });
      });
    });
  });

}).call(this);
