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
          this.serviceReturn = false;
          this.pickListList = new PickListList(window.projectServiceTestJSON.projects);
          this.pickListList.url = "/api/projects";
          this.pickListList.fetch({
            success: (function(_this) {
              return function() {
                return _this.serviceReturn = true;
              };
            })(this)
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
    describe("PickList controller", function() {
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
        describe("when created with populated collection and no fetch requested", function() {
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
        return describe("when adding options to picklists", function() {
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
          return it("should be able to check if the option is in the collection", function() {
            return runs(function() {
              expect(this.pickListController.checkOptionInCollection("project1")).toBeTruthy();
              return expect(this.pickListController.checkOptionInCollection("projectZ")).toBeFalsy();
            });
          });
        });
      });
    });
    describe("AddParameterOptionPanel model testing", function() {
      beforeEach(function() {
        return this.adop = new AddParameterOptionPanel();
      });
      describe("Existence and Defaults", function() {
        it("should be defined", function() {
          return expect(this.adop).toBeDefined();
        });
        it("should have the parameter name set to null", function() {
          return expect(this.adop.get('parameter')).toBeNull();
        });
        it("should have the codeType set to null", function() {
          return expect(this.adop.get('codeType')).toBeNull();
        });
        it("should have the codeKind set to null", function() {
          return expect(this.adop.get('codeKind')).toBeNull();
        });
        it("should have the codeOrigin set to acas ddict", function() {
          return expect(this.adop.get('codeOrigin')).toEqual("acas ddict");
        });
        it("should have the label text be null", function() {
          return expect(this.adop.get('newOptionLabel')).toBeNull();
        });
        it("should have the description be set to null", function() {
          return expect(this.adop.get('newOptionDescription')).toBeNull();
        });
        return it("should have the comments be set to null", function() {
          return expect(this.adop.get('newOptionComments')).toBeNull();
        });
      });
      return describe("validation", function() {
        return it("should be invalid when the label is not filled in", function() {
          var filtErrors;
          this.adop.set({
            newOptionlabel: ""
          });
          expect(this.adop.isValid()).toBeFalsy();
          filtErrors = _.filter(this.adop.validationError, function(err) {
            return err.attribute === 'newOptionLabel';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
      });
    });
    describe("AddParameterOptionPanelController testing", function() {
      beforeEach(function() {
        this.adopc = new AddParameterOptionPanelController({
          model: new AddParameterOptionPanel({
            parameter: "projects",
            codeType: "protocolMetadata"
          }),
          el: $('#fixture')
        });
        return this.adopc.render();
      });
      describe("basic startup conditions", function() {
        it("should exist", function() {
          return expect(this.adopc).toBeDefined();
        });
        it("should set the codeKind", function() {
          return expect(this.adopc.model.get('codeKind')).toEqual("projects");
        });
        it("should load a template", function() {
          return expect(this.adopc.$('.bv_addParameterOptionModal').length).toEqual(1);
        });
        return it("should have the save button disabled", function() {
          return expect(this.adopc.$('.bv_addNewParameterOption').attr('disabled')).toEqual('disabled');
        });
      });
      describe("model updates", function() {
        it("should update the newOptionLabel", function() {
          this.adopc.$('.bv_newOptionLabel').val(" test ");
          this.adopc.$('.bv_newOptionLabel').change();
          return expect(this.adopc.model.get('newOptionLabel')).toEqual("test");
        });
        it("should update the newOptionDescription", function() {
          this.adopc.$('.bv_newOptionDescription').val(" test description ");
          this.adopc.$('.bv_newOptionDescription').change();
          return expect(this.adopc.model.get('newOptionDescription')).toEqual("test description");
        });
        return it("should update the newOptionComments", function() {
          this.adopc.$('.bv_newOptionComments').val("test comments ");
          this.adopc.$('.bv_newOptionComments').change();
          return expect(this.adopc.model.get('newOptionComments')).toEqual("test comments");
        });
      });
      describe("behavior and validation testing", function() {
        return it("should show error when the label is not filled in", function() {
          this.adopc.$('.bv_newOptionLabel').val("");
          this.adopc.$('.bv_newOptionLabel').change();
          return expect(this.adopc.$('.bv_group_newOptionLabel').hasClass("error")).toBeTruthy();
        });
      });
      return describe("form validation setup", function() {
        return it("should be valid and add button is enabled if form fully filled out", function() {
          return runs(function() {
            this.adopc.$('.bv_newOptionLabel').val("test");
            this.adopc.$('.bv_newOptionLabel').change();
            this.adopc.$('.bv_newOptionDescription').val("test2");
            this.adopc.$('.bv_newOptionDescription').change();
            this.adopc.$('.bv_newOptionComments').val("test3");
            this.adopc.$('.bv_newOptionComments').change();
            expect(this.adopc.isValid()).toBeTruthy();
            return expect(this.adopc.$('.bv_addNewParameterOption').attr('disabled')).toBeUndefined();
          });
        });
      });
    });
    return describe("EditablePickListSelectController", function() {
      beforeEach(function() {
        return runs(function() {
          this.editablePickListList = new PickListList();
          return this.editablePickListList.url = "/api/projects";
        });
      });
      return describe("when displayed for users who can add to pick list", function() {
        beforeEach(function() {
          runs(function() {
            this.editablePickListController = new EditablePickListSelectController({
              el: $('#fixture'),
              collection: this.editablePickListList,
              selectedCode: "unassigned",
              parameter: "projects",
              codeType: "protocolMetadata",
              roles: ["admin"]
            });
            return this.editablePickListController.render();
          });
          return waitsFor(function() {
            return this.editablePickListList.length > 0;
          });
        });
        describe("when initialized", function() {
          it("should have a picklist select controller", function() {
            return runs(function() {
              return expect(this.editablePickListController.pickListController).toBeDefined();
            });
          });
          return it("should have an add button", function() {
            return runs(function() {
              return expect(this.editablePickListController.$('.bv_addOptionBtn').length).toEqual(1);
            });
          });
        });
        describe("when add button is clicked", function() {
          return it(" should have an add panel controller", function() {
            return runs(function() {
              this.editablePickListController.$('.bv_addOptionBtn').click();
              return expect(this.editablePickListController.addPanelController).toBeDefined();
            });
          });
        });
        return describe("when user wants to add a parameter option", function() {
          return describe("should have the picklist controller check if the option is already in the collection", function() {
            describe("valid new option", function() {
              beforeEach(function() {
                return runs(function() {
                  this.editablePickListController.$('.bv_addOptionBtn').click();
                  this.editablePickListController.addPanelController.$('.bv_newOptionLabel').val("new option");
                  this.editablePickListController.addPanelController.$('.bv_newOptionDescription').val("new description");
                  this.editablePickListController.addPanelController.$('.bv_newOptionComments').val("new comments");
                  this.editablePickListController.addPanelController.$('.bv_newOptionComments').change();
                  return this.editablePickListController.addPanelController.$('.bv_addNewParameterOption').click();
                });
              });
              it("should have the pickListController add a new model to collection", function() {
                var newOption;
                newOption = this.editablePickListController.addPanelController.model.get('newOptionLabel');
                return expect(this.editablePickListController.pickListController.checkOptionInCollection(newOption)).toBeDefined();
              });
              return it("should show the option added message", function() {
                expect(this.editablePickListController.$('.bv_optionAddedMessage')).toBeVisible();
                return expect(this.editablePickListController.$('.bv_errorMessage')).toBeHidden();
              });
            });
            return describe("invalid new option", function() {
              beforeEach(function() {
                return runs(function() {
                  this.editablePickListController.$('.bv_addOptionBtn').click();
                  this.editablePickListController.addPanelController.$('.bv_newOptionLabel').val("project2");
                  this.editablePickListController.addPanelController.$('.bv_newOptionDescription').val("test2");
                  this.editablePickListController.addPanelController.$('.bv_newOptionComments').val("test3");
                  this.editablePickListController.addPanelController.$('.bv_newOptionComments').change();
                  return this.editablePickListController.addPanelController.$('.bv_addNewParameterOption').click();
                });
              });
              return it("should tell user that the option already exists", function() {
                expect(this.editablePickListController.$('.bv_optionAddedMessage')).toBeHidden();
                return expect(this.editablePickListController.$('.bv_errorMessage')).toBeVisible();
              });
            });
          });
        });
      });
    });
  });

}).call(this);
