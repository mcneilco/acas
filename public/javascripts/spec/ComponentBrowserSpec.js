(function() {
  beforeEach(function() {
    return this.fixture = $.clone($("#fixture").get(0));
  });

  afterEach(function() {
    $("#fixture").remove();
    return $("body").append($(this.fixture));
  });

  describe("Component Browser module testing", function() {
    describe("Component Search Model controller", function() {
      beforeEach(function() {
        return this.psm = new ComponentSearch();
      });
      return describe("Basic existence tests", function() {
        it("should be defined", function() {
          return expect(this.psm).toBeDefined();
        });
        return it("should have defaults", function() {
          return expect(this.psm.get('componentCode')).toBeNull();
        });
      });
    });
    describe("Component Simple Search Controller", function() {
      return describe("when instantiated", function() {
        beforeEach(function() {
          this.pssc = new ComponentSimpleSearchController({
            model: new ComponentSearch(),
            el: $('#fixture')
          });
          return this.pssc.render();
        });
        return describe("basic existance tests", function() {
          it("should exist", function() {
            return expect(this.pssc).toBeDefined();
          });
          return it("should load a template", function() {
            return expect(this.pssc.$('.bv_componentSearchTerm').length).toEqual(1);
          });
        });
      });
    });
    describe("ComponentRowSummaryController testing", function() {
      beforeEach(function() {
        this.prsc = new ComponentRowSummaryController({
          model: new CationicBlockBatch(window.componentBrowserServiceTestJSON.cationicBlockBatch),
          el: this.fixture
        });
        return this.prsc.render();
      });
      describe("Basic existence and rendering", function() {
        it("should be defined", function() {
          return expect(this.prsc).toBeDefined();
        });
        return it("should render the template", function() {
          return expect(this.prsc.$('.bv_componentName').length).toEqual(1);
        });
      });
      describe("It should show component values", function() {
        it("should show the component name", function() {
          return expect(this.prsc.$('.bv_componentName').html()).toEqual("cMAP10");
        });
        it("should show the component code", function() {
          return expect(this.prsc.$('.bv_componentCode').html()).toEqual("CB000001");
        });
        it("should show the component kind", function() {
          return expect(this.prsc.$('.bv_componentKind').html()).toEqual("cationic block");
        });
        it("should show the scientist", function() {
          return expect(this.prsc.$('.bv_scientist').html()).toEqual("2012-07-12");
        });
        return it("should show the completion date", function() {
          return expect(this.prsc.$('.bv_completionDate').html()).toEqual("john");
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
    describe("ComponentSummaryTableController", function() {
      beforeEach(function() {
        this.pstc = new ComponentSummaryTableController({
          collection: new ComponentList([window.componentBrowserServiceTestJSON.cationicBlockBatch]),
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
      describe("It should render a summary row for each component record", function() {
        return it("should show the component name", function() {
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
        return it("should display a message alerting the user that no matching components were found if the search returns no components", function() {
          this.searchReturned = false;
          this.searchController = new ComponentSimpleSearchController({
            model: new ComponentSearch(),
            el: this.fixture
          });
          this.searchController.on("searchReturned", (function(_this) {
            return function() {
              return _this.searchReturned = true;
            };
          })(this));
          $(".bv_ComponentSearchTerm").val("no-match");
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
    return describe("ComponentBrowserController tests", function() {
      beforeEach(function() {
        this.pbc = new ComponentBrowserController({
          el: this.fixture
        });
        return this.pbc.render();
      });
      describe("Basic existence and rendering tests", function() {
        it("should be defined", function() {
          return expect(ComponentBrowserController).toBeDefined();
        });
        return it("should have a search controller div", function() {
          return expect(this.pbc.$('.bv_componentSearchController').length).toEqual(1);
        });
      });
      describe("Startup", function() {
        return it("should initialize the search controller", function() {
          expect(this.pbc.$('.bv_componentSearchTerm').length).toEqual(1);
          return expect(this.pbc.searchController).toBeDefined();
        });
      });
      return describe("Search actions", function() {
        beforeEach(function() {
          $(".bv_ComponentSearchTerm").val("component");
          return runs((function(_this) {
            return function() {
              return _this.pbc.searchController.doSearch("component");
            };
          })(this));
        });
        return it("should show the component summary table after search is entered", function() {
          return expect($('tbody tr').length).toBeGreaterThan(0);
        });
      });
    });
  });

}).call(this);
