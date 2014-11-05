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
    describe("Protocol Simple Search Controller", function() {
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
    describe("ProtocolRowSummaryController testing", function() {
      beforeEach(function() {
        this.prsc = new ProtocolRowSummaryController({
          model: new Protocol(window.protocolServiceTestJSON.fullSavedProtocol),
          el: this.fixture
        });
        return this.prsc.render();
      });
      describe("Basic existence and rendering", function() {
        it("should be defined", function() {
          return expect(this.prsc).toBeDefined();
        });
        return it("should render the template", function() {
          return expect(this.prsc.$('.bv_protocolName').length).toEqual(1);
        });
      });
      describe("It should show protocol values", function() {
        it("should show the protocol name", function() {
          return expect(this.prsc.$('.bv_protocolName').html()).toEqual("FLIPR target A biochemical");
        });
        it("should show the protocol code", function() {
          return expect(this.prsc.$('.bv_protocolCode').html()).toEqual("PROT-00000001");
        });
        it("should show the protocol kind", function() {
          return expect(this.prsc.$('.bv_protocolKind').html()).toEqual("default");
        });
        return it("should show the scientist", function() {
          return expect(this.prsc.$('.bv_recordedBy').html()).toEqual("nxm7557");
        });
      });
      return describe("basic behavior", function() {
        return it("should trigger gotClick when the row is clicked", function() {
          this.clickTriggered = false;
          this.prsc.on('gotClick', (function(_this) {
            return function() {
              return _this.clickTriggered = true;
            };
          })(this));
          runs(function() {
            return $(this.prsc.el).click();
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
    describe("ProtocolSummaryTableController", function() {
      beforeEach(function() {
        this.pstc = new ProtocolSummaryTableController({
          collection: new ProtocolList([window.protocolServiceTestJSON.fullSavedProtocol]),
          el: this.fixture
        });
        return this.pstc.render();
      });
      describe("Basic existence and rendering", function() {
        it("should be defined", function() {
          return expect(this.pstc).toBeDefined();
        });
        return it("should render the template", function() {
          return expect(this.pstc.$('tbody').length).toEqual(1);
        });
      });
      describe("It should render a summary row for each protocol record", function() {
        return it("should show the protocol name", function() {
          return expect(this.pstc.$('tbody tr').length).toBeGreaterThan(0);
        });
      });
      return describe("basic behavior", function() {
        it("should listen for gotClick row event and trigger selectedRowUpdated event", function() {
          this.clickTriggered = false;
          this.pstc.on('selectedRowUpdated', (function(_this) {
            return function() {
              return _this.clickTriggered = true;
            };
          })(this));
          runs(function() {
            return this.pstc.$("tr").click();
          });
          waitsFor(function() {
            return this.clickTriggered;
          }, 300);
          return runs(function() {
            return expect(this.clickTriggered).toBeTruthy();
          });
        });
        return it("should display a message alerting the user that no matching protocols were found if the search returns no protocols", function() {
          this.searchReturned = false;
          this.searchController = new ProtocolSimpleSearchController({
            model: new ProtocolSearch(),
            el: this.fixture
          });
          this.searchController.on("searchReturned", (function(_this) {
            return function() {
              return _this.searchReturned = true;
            };
          })(this));
          $(".bv_ProtocolSearchTerm").val("no-match");
          runs((function(_this) {
            return function() {
              return _this.searchController.doSearch("no-match");
            };
          })(this));
          waitsFor(function() {
            return this.searchReturned;
          }, 300);
          return runs(function() {
            return expect($(".bv_noMatchesFoundMessage").hasClass("hide")).toBeFalsy();
          });
        });
      });
    });
    return describe("ProtocolBrowserController tests", function() {
      beforeEach(function() {
        this.pbc = new ProtocolBrowserController({
          el: this.fixture
        });
        return this.pbc.render();
      });
      describe("Basic existence and rendering tests", function() {
        it("should be defined", function() {
          return expect(ProtocolBrowserController).toBeDefined();
        });
        return it("should have a search controller div", function() {
          return expect(this.pbc.$('.bv_protocolSearchController').length).toEqual(1);
        });
      });
      describe("Startup", function() {
        return it("should initialize the search controller", function() {
          expect(this.pbc.$('.bv_protocolSearchTerm').length).toEqual(1);
          return expect(this.pbc.searchController).toBeDefined();
        });
      });
      return describe("Search actions", function() {
        beforeEach(function() {
          $(".bv_ProtocolSearchTerm").val("protocol");
          return runs((function(_this) {
            return function() {
              return _this.pbc.searchController.doSearch("protocol");
            };
          })(this));
        });
        return it("should show the protocol summary table after search is entered", function() {
          return expect($('tbody tr').length).toBeGreaterThan(0);
        });
      });
    });
  });

}).call(this);
