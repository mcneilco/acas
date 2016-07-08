(function() {
  beforeEach(function() {
    return this.fixture = $.clone($("#fixture").get(0));
  });

  afterEach(function() {
    $("#fixture").remove();
    return $("body").append($(this.fixture));
  });

  describe('Project testing', function() {
    describe(" Project model testing", function() {
      describe("when loaded from new", function() {
        beforeEach(function() {
          return this.proj = new Project();
        });
        describe("Existence and Defaults", function() {
          it("should be defined", function() {
            return expect(this.proj).toBeDefined();
          });
          it("should have a type", function() {
            return expect(this.proj.get('lsType')).toEqual("project");
          });
          it("should have a kind", function() {
            return expect(this.proj.get('lsKind')).toEqual("project");
          });
          it("should have the recordedBy set to the logged in user", function() {
            return expect(this.proj.get('recordedBy')).toEqual(window.AppLaunchParams.loginUser.username);
          });
          it("should have a recordedDate set to now", function() {
            return expect(new Date(this.proj.get('recordedDate')).getHours()).toEqual(new Date().getHours());
          });
          it("Should have a lsLabels with two labels", function() {
            expect(this.proj.get('lsLabels')).toBeDefined();
            expect(this.proj.get("lsLabels").length).toEqual(2);
            expect(this.proj.get("lsLabels").getLabelByTypeAndKind("name", "project name").length).toEqual(1);
            return expect(this.proj.get("lsLabels").getLabelByTypeAndKind("name", "project alias").length).toEqual(1);
          });
          it("Should have a model attribute for the labels in defaultLabels", function() {
            expect(this.proj.get("project name")).toBeDefined();
            return expect(this.proj.get("project alias")).toBeDefined();
          });
          it("Should have a lsStates with the states in defaultStates", function() {
            expect(this.proj.get('lsStates')).toBeDefined();
            expect(this.proj.get("lsStates").length).toEqual(1);
            return expect(this.proj.get("lsStates").getStatesByTypeAndKind("metadata", "project metadata").length).toEqual(1);
          });
          return describe("model attributes for each value in defaultValues", function() {
            it("Should have a model attribute for start date", function() {
              return expect(this.proj.get("start date")).toBeDefined();
            });
            it("Should have a model attribute for project status", function() {
              return expect(this.proj.get("project status")).toBeDefined();
            });
            it("Should have a model attribute for short description", function() {
              return expect(this.proj.get("short description")).toBeDefined();
            });
            it("Should have a model attribute for project details", function() {
              return expect(this.proj.get("project details")).toBeDefined();
            });
            it("Should have a model attribute for live design id", function() {
              return expect(this.proj.get("live design id")).toBeDefined();
            });
            return it("Should have a model attribute for is restricted", function() {
              return expect(this.proj.get("live design id")).toBeDefined();
            });
          });
        });
        return describe("model validation", function() {
          it("should be invalid when project name is empty", function() {
            var filtErrors;
            this.proj.get("project name").set("labelText", "");
            expect(this.proj.isValid()).toBeFalsy();
            filtErrors = _.filter(this.proj.validationError, function(err) {
              return err.attribute === 'projectName';
            });
            return expect(filtErrors.length).toBeGreaterThan(0);
          });
          return it("should be invalid when project alias is empty", function() {
            var filtErrors;
            this.proj.get("project alias").set("labelText", "");
            expect(this.proj.isValid()).toBeFalsy();
            filtErrors = _.filter(this.proj.validationError, function(err) {
              return err.attribute === 'projectAlias';
            });
            return expect(filtErrors.length).toBeGreaterThan(0);
          });
        });
      });
      return describe("When created from existing", function() {
        beforeEach(function() {
          return this.proj = new Project(JSON.parse(JSON.stringify(window.projectTestJSON.project)));
        });
        describe("after initial load", function() {
          it("should be defined", function() {
            return expect(this.proj).toBeDefined();
          });
          it("should have a type", function() {
            return expect(this.proj.get('lsType')).toEqual("project");
          });
          it("should have a kind", function() {
            return expect(this.proj.get('lsKind')).toEqual("project");
          });
          it("should have a recordedBy set", function() {
            return expect(this.proj.get('recordedBy')).toEqual("bob");
          });
          it("should have a recordedDate set", function() {
            return expect(this.proj.get('recordedDate')).toEqual(1462553966814);
          });
          it("Should have labels set", function() {
            var label;
            expect(this.proj.get("project name").get("labelText")).toEqual("Test Project 1");
            label = this.proj.get("lsLabels").getLabelByTypeAndKind("name", "project name");
            expect(label[0].get('labelText')).toEqual("Test Project 1");
            expect(this.proj.get("project alias").get("labelText")).toEqual("Project 1");
            label = this.proj.get("lsLabels").getLabelByTypeAndKind("name", "project alias");
            return expect(label[0].get('labelText')).toEqual("Project 1");
          });
          it("Should have a lsStates with the states in defaultStates", function() {
            expect(this.proj.get('lsStates')).toBeDefined();
            expect(this.proj.get("lsStates").length).toEqual(1);
            return expect(this.proj.get("lsStates").getStatesByTypeAndKind("metadata", "project metadata").length).toEqual(1);
          });
          it("Should have a start date value", function() {
            return expect(this.proj.get("start date").get("value")).toEqual(1462518000000);
          });
          it("Should have a project status value", function() {
            return expect(this.proj.get("project status").get("value")).toEqual("active");
          });
          it("Should have a short description value", function() {
            return expect(this.proj.get("short description").get("value")).toEqual("Example short description");
          });
          it("Should have a project details value", function() {
            return expect(this.proj.get("project details").get("value")).toEqual("Example project details");
          });
          return it("Should have a is restricted value", function() {
            return expect(this.proj.get("is restricted").get("value")).toEqual("true");
          });
        });
        return describe("model validation", function() {
          beforeEach(function() {
            return this.proj = new Project(window.projectTestJSON.project);
          });
          it("should be valid when loaded from saved", function() {
            return expect(this.proj.isValid()).toBeTruthy();
          });
          it("should be invalid when project name is empty", function() {
            var filtErrors;
            this.proj.get("project name").set("labelText", "");
            expect(this.proj.isValid()).toBeFalsy();
            filtErrors = _.filter(this.proj.validationError, function(err) {
              return err.attribute === 'projectName';
            });
            return expect(filtErrors.length).toBeGreaterThan(0);
          });
          return it("should be invalid when project alias is empty", function() {
            var filtErrors;
            this.proj.get("project alias").set("labelText", "");
            expect(this.proj.isValid()).toBeFalsy();
            filtErrors = _.filter(this.proj.validationError, function(err) {
              return err.attribute === 'projectAlias';
            });
            return expect(filtErrors.length).toBeGreaterThan(0);
          });
        });
      });
    });
    return describe("Project Controller testing", function() {
      describe("When instantiated from new", function() {
        beforeEach(function() {
          this.proj = new Project();
          this.projc = new ProjectController({
            model: this.proj,
            el: $('#fixture')
          });
          return this.projc.render();
        });
        return describe("basic existence tests", function() {
          it("should exist", function() {
            return expect(this.projc).toBeDefined();
          });
          return it("should load the template", function() {
            return expect(this.projc.$('.bv_projectCode').html()).toEqual("");
          });
        });
      });
      return describe("When instantiated from existing", function() {
        beforeEach(function() {
          this.proj = new Project(JSON.parse(JSON.stringify(window.projectTestJSON.project)));
          this.projc = new ProjectController({
            model: this.proj,
            el: $('#fixture')
          });
          return this.projc.render();
        });
        describe("render existing parameters", function() {
          it("should fill the project status field", function() {
            waitsFor(function() {
              return this.projc.$('.bv_status option').length > 0;
            }, 1000);
            return runs(function() {
              return expect(this.projc.$('.bv_status').val()).toEqual("active");
            });
          });
          it("should show the project code", function() {
            return expect(this.projc.$('.bv_projectCode').val()).toEqual("PROJ-00000001");
          });
          it("should fill the project name", function() {
            return expect(this.projc.$('.bv_projectName').val()).toEqual("Test Project 1");
          });
          it("should check the restricted data box", function() {
            return expect(this.projc.$('.bv_restrictedData').attr("checked")).toEqual("checked");
          });
          it("should fill the project alias", function() {
            return expect(this.projc.$('.bv_projectAlias').val()).toEqual("Project 1");
          });
          it("should fill the start date field", function() {
            return expect(this.projc.$('.bv_startDate').val()).toEqual("2016-05-06");
          });
          it("should fill the short description field", function() {
            return expect(this.projc.$('.bv_shortDescription').val()).toEqual("Example short description");
          });
          return it("should fill the project details field", function() {
            return expect(this.projc.$('.bv_projectDetails').val()).toEqual("Example project details");
          });
        });
        describe("model updates", function() {
          it("should update model when the project status is changed", function() {
            waitsFor(function() {
              return this.projc.$('.bv_status option').length > 0;
            }, 1000);
            return runs(function() {
              this.projc.$('.bv_status').val('inactive');
              this.projc.$('.bv_status').change();
              return expect(this.projc.model.get('project status').get('value')).toEqual("inactive");
            });
          });
          it("should update model when project name is changed", function() {
            this.projc.$('.bv_projectName').val('Test Project 2');
            this.projc.$('.bv_projectName').keyup();
            return expect(this.projc.model.get('project name').get('labelText')).toEqual("Test Project 2");
          });
          it("should update model when project alias is changed", function() {
            this.projc.$('.bv_projectAlias').val('Project 2');
            this.projc.$('.bv_projectAlias').keyup();
            return expect(this.projc.model.get('project alias').get('labelText')).toEqual("Project 2");
          });
          it("should update model when start date is changed", function() {
            this.projc.$('.bv_startDate').val(" 2013-3-16   ");
            this.projc.$('.bv_startDate').keyup();
            return expect(this.projc.model.get('start date').get('value')).toEqual(new Date(2013, 2, 16).getTime());
          });
          it("should update model when restricted data checkbox is clicked", function() {
            this.projc.$('.bv_restrictedData').click();
            return expect(this.projc.model.get('is restricted').get('value')).toEqual("false");
          });
          it("should update model when short description is changed", function() {
            this.projc.$('.bv_shortDescription').val(" Updated short description  ");
            this.projc.$('.bv_shortDescription').keyup();
            return expect(this.projc.model.get('short description').get('value')).toEqual("Updated short description");
          });
          return it("should update model when project details is changed", function() {
            this.projc.$('.bv_projectDetails').val(" Updated project details  ");
            this.projc.$('.bv_projectDetails').keyup();
            return expect(this.projc.model.get('project details').get('value')).toEqual("Updated project details");
          });
        });
        return describe("controller validation rules", function() {
          describe("when name field not filled in", function() {
            return it("should show error if name not filled in", function() {
              this.projc.$('.bv_projectName').val("");
              this.projc.$('.bv_projectName').keyup();
              return expect(this.projc.$('.bv_group_projectName').hasClass('error')).toBeTruthy();
            });
          });
          return describe("when alias field not filled in", function() {
            return it("should show error if alias not filled in", function() {
              this.projc.$('.bv_projectAlias').val("");
              this.projc.$('.bv_projectAlias').keyup();
              return expect(this.projc.$('.bv_group_projectAlias').hasClass('error')).toBeTruthy();
            });
          });
        });
      });
    });
  });

}).call(this);
