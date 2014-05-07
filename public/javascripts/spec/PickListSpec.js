(function() {
  describe("PickList Select Unit Testing", function() {
    beforeEach(function() {
      this.fixture = $.clone($("#fixture").get(0));
      $("#fixture").append("<select id='selectFixture'></select>");
      return this.selectFixture = $("#selectFixture");
    });
    afterEach(function() {
      $("#fixture").remove();
      return $("body").append($(this.fixture));
    });
    describe("PickList Collection", function() {
      beforeEach(function() {
        runs(function() {
          var _this = this;
          this.serviceReturn = false;
          this.pickListList = new PickListList(window.projectServiceTestJSON.projects);
          this.pickListList.url = "/api/projects";
          this.pickListList.fetch({
            success: function() {
              return _this.serviceReturn = true;
            }
          });
          return this.pickListList.fetch;
        });
        return waitsFor(function() {
          return this.serviceReturn;
        });
      });
      return describe("Upon init", function() {
        it("should get options from server", function() {
          return runs(function() {
            return expect(this.pickListList.length).toEqual(4);
          });
        });
        return it("should return non-ignored values", function() {
          return runs(function() {
            return expect(this.pickListList.getCurrent().length).toEqual(3);
          });
        });
      });
    });
    return describe("PickList controller", function() {
      beforeEach(function() {
        return runs(function() {
          this.pickListList = new PickListList();
          return this.pickListList.url = "/api/projects";
        });
      });
      return describe("when displayed", function() {
        describe("when displayed with default options", function() {
          beforeEach(function() {
            runs(function() {
              return this.pickListController = new PickListSelectController({
                el: this.selectFixture,
                collection: this.pickListList
              });
            });
            return waitsFor(function() {
              return this.pickListList.length > 0;
            });
          });
          it(" should have three choices", function() {
            return runs(function() {
              return expect(this.pickListController.$("option").length).toEqual(3);
            });
          });
          it("should return selected model", function() {
            return runs(function() {
              var mdl;
              this.pickListController.$("option")[1].selected = true;
              mdl = this.pickListController.getSelectedModel();
              expect(mdl.get("code")).toEqual("project2");
              this.pickListController.$("option")[2].selected = true;
              mdl = this.pickListController.getSelectedModel();
              return expect(mdl.get("code")).toEqual("project3");
            });
          });
          return it("should return selected code", function() {
            return runs(function() {
              this.pickListController.$("option")[1].selected = true;
              return expect(this.pickListController.getSelectedCode()).toEqual("project2");
            });
          });
        });
        describe("when displayed with pre-selected value", function() {
          beforeEach(function() {
            runs(function() {
              return this.pickListController = new PickListSelectController({
                el: this.selectFixture,
                collection: this.pickListList,
                selectedCode: "project2"
              });
            });
            return waitsFor(function() {
              return this.pickListList.length > 0;
            });
          });
          return it("should show selected value", function() {
            return runs(function() {
              return expect($(this.pickListController.el).val()).toEqual("project2");
            });
          });
        });
        describe("when created with added option not in database", function() {
          beforeEach(function() {
            runs(function() {
              return this.pickListController = new PickListSelectController({
                el: this.selectFixture,
                collection: this.pickListList,
                insertFirstOption: new PickList({
                  code: "not_set",
                  name: "Select Category"
                }),
                selectedCode: "not_set"
              });
            });
            return waitsFor(function() {
              return this.pickListList.length > 0;
            });
          });
          it("should have five choices", function() {
            return runs(function() {
              return expect(this.pickListController.$("option").length).toEqual(4);
            });
          });
          return it("should not set selected", function() {
            return runs(function() {
              return expect($(this.pickListController.el).val()).toEqual("not_set");
            });
          });
        });
        return describe("when created with populated collection and no fetch requested", function() {
          beforeEach(function() {
            return this.pickListController = new PickListSelectController({
              el: this.selectFixture,
              collection: new PickListList(window.projectServiceTestJSON.projects),
              insertFirstOption: new PickList({
                code: "not_set",
                name: "Select Category"
              }),
              selectedCode: "not_set",
              autoFetch: false
            });
          });
          it("should have five choices", function() {
            return runs(function() {
              return expect(this.pickListController.$("option").length).toEqual(4);
            });
          });
          return it("should set selected", function() {
            return runs(function() {
              return expect($(this.pickListController.el).val()).toEqual("not_set");
            });
          });
        });
      });
    });
  });

}).call(this);
