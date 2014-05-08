(function() {
  describe("Module Menu System Testing", function() {
    beforeEach(function() {
      return this.fixture = $("#fixture");
    });
    afterEach(function() {
      $("#fixture").remove();
      return $("body").append('<div id="fixture"></div>');
    });
    describe("Module Launcher Model Testing", function() {
      beforeEach(function() {
        return this.modLauncher = new ModuleLauncher();
      });
      describe("Default testing", function() {
        return it("Should have defualt values", function() {
          expect(this.modLauncher.get('isHeader')).toBeFalsy();
          expect(this.modLauncher.get('menuName')).toEqual("Menu Name Replace Me");
          expect(this.modLauncher.get('isLoaded')).toBeFalsy();
          expect(this.modLauncher.get('isActive')).toBeFalsy();
          expect(this.modLauncher.get('isDirty')).toBeFalsy();
          return expect(this.modLauncher.get('mainControllerClassName')).toEqual("controllerClassNameReplaceMe");
        });
      });
      describe("activation", function() {
        return it("should trigger activation request", function() {
          runs(function() {
            this.modLauncher.bind('activationRequested', (function(_this) {
              return function() {
                return _this.gotTrigger = true;
              };
            })(this));
            return this.modLauncher.requestActivation();
          });
          waitsFor((function(_this) {
            return function() {
              return _this.gotTrigger;
            };
          })(this));
          return runs(function() {
            return expect(this.gotTrigger).toBeTruthy();
          });
        });
      });
      describe("de-activation", function() {
        return it("should trigger deactivation request", function() {
          runs(function() {
            this.modLauncher.bind('deactivationRequested', (function(_this) {
              return function() {
                return _this.gotTrigger = true;
              };
            })(this));
            return this.modLauncher.requestDeactivation();
          });
          waitsFor((function(_this) {
            return function() {
              return _this.gotTrigger;
            };
          })(this));
          return runs(function() {
            return expect(this.gotTrigger).toBeTruthy();
          });
        });
      });
      describe("Module Launcher List Testing", function() {});
      beforeEach(function() {
        return this.modLauncherList = new ModuleLauncherList(window.moduleMenusTestJSON.testMenuItems);
      });
      return describe("Existence test", function() {
        return it("should instanitate with 6 entries", function() {
          return expect(this.modLauncherList.length).toEqual(6);
        });
      });
    });
    describe("ModuleLauncherMenuController tests", function() {
      beforeEach(function() {
        this.modLauncher = new ModuleLauncher({
          isHeader: false,
          menuName: "test launcher",
          mainControllerClassName: "testLauncherClassName"
        });
        this.modLauncherMenuController = new ModuleLauncherMenuController({
          model: this.modLauncher
        });
        return $('#fixture').append(this.modLauncherMenuController.render().el);
      });
      describe("Upon render", function() {
        it("should load the template", function() {
          return expect($('.bv_menuName')).toBeDefined();
        });
        it("Should set its menu name", function() {
          return expect(this.modLauncherMenuController.$('.bv_menuName').html()).toEqual("test launcher");
        });
        it("should show that it is not running", function() {
          return expect(this.modLauncherMenuController.$('.bv_isLoaded')).not.toBeVisible();
        });
        it("should show that it is not dirty", function() {
          return expect(this.modLauncherMenuController.$('.bv_isDirty')).not.toBeVisible();
        });
        it("should should hide disabled mode", function() {
          return expect(this.modLauncherMenuController.$('.bv_menuName_disabled')).not.toBeVisible();
        });
        return it("should should show enabled mode", function() {
          return expect(this.modLauncherMenuController.$('.bv_menuName')).toBeVisible();
        });
      });
      describe("When clicked", function() {
        beforeEach(function() {
          this.modLauncherMenuController.bind("selected", (function(_this) {
            return function() {
              return _this.gotTrigger = true;
            };
          })(this));
          return this.modLauncherMenuController.$('.bv_menuName').click();
        });
        it("should set style active", function() {
          return expect(this.modLauncherMenuController.el).toHaveClass("active");
        });
        it("should set the model to active", function() {
          return expect(this.modLauncherMenuController.model.get('isActive')).toBeTruthy();
        });
        return it("should trigger a selected event", function() {
          runs(function() {});
          waitsFor((function(_this) {
            return function() {
              return _this.gotTrigger;
            };
          })(this));
          return runs(function() {
            return expect(this.gotTrigger).toBeTruthy();
          });
        });
      });
      describe("When module is running", function() {
        return it("should show that it is running", function() {
          this.modLauncher.set({
            isLoaded: true
          });
          return expect(this.modLauncherMenuController.$('.bv_isLoaded')).toBeVisible();
        });
      });
      describe("When module has been edited and not saved", function() {
        return it("should show that it is dirty", function() {
          this.modLauncher.set({
            isDirty: true
          });
          return expect(this.modLauncherMenuController.$('.bv_isDirty')).toBeVisible();
        });
      });
      describe("when deselected", function() {
        return it("should change style", function() {
          this.modLauncherMenuController.$('.bv_menuName').click();
          expect(this.modLauncherMenuController.el).toHaveClass("active");
          this.modLauncherMenuController.clearSelected(new ModuleLauncherMenuController({
            model: new ModuleLauncher()
          }));
          expect($(this.modLauncherMenuController.el).hasClass("active")).toBeFalsy();
          return expect(this.modLauncherMenuController.model.get('isActive')).toBeFalsy();
        });
      });
      return describe("when user not authorized to launch module", function() {
        beforeEach(function() {
          this.modLauncher2 = new ModuleLauncher({
            isHeader: false,
            menuName: "test launcher",
            mainControllerClassName: "testLauncherClassName",
            requireUserRoles: ["admin", "loadData"]
          });
          return this.modLauncherMenuController2 = new ModuleLauncherMenuController({
            model: this.modLauncher2
          });
        });
        describe("with current user with no roles attribute", function() {
          return it("should enable menu item", function() {
            $('#fixture').append(this.modLauncherMenuController2.render().el);
            expect(this.modLauncherMenuController.$('.bv_menuName_disabled')).not.toBeVisible();
            return expect(this.modLauncherMenuController.$('.bv_menuName')).toBeVisible();
          });
        });
        describe("with current user with roles specified but not required role", function() {
          beforeEach(function() {
            window.AppLaunchParams.loginUser.roles = [
              {
                id: 3,
                roleEntry: {
                  id: 2,
                  roleDescription: "what Mal is not",
                  roleName: "king of all indinia",
                  version: 0
                },
                version: 0
              }
            ];
            return $('#fixture').append(this.modLauncherMenuController2.render().el);
          });
          it("should disable menu item", function() {
            expect(this.modLauncherMenuController2.$('.bv_menuName_disabled')).toBeVisible();
            return expect(this.modLauncherMenuController2.$('.bv_menuName')).not.toBeVisible();
          });
          return it("should have title set to support mouse over", function() {
            return expect($(this.modLauncherMenuController2.el).attr("title")).toContain("not authorized");
          });
        });
        return describe("with current user having allowed role specified", function() {
          beforeEach(function() {
            window.AppLaunchParams.loginUser.roles = [
              {
                id: 3,
                roleEntry: {
                  id: 2,
                  roleDescription: "data loader",
                  roleName: "loadData",
                  version: 0
                },
                version: 0
              }
            ];
            return $('#fixture').append(this.modLauncherMenuController2.render().el);
          });
          return it("should enable menu item", function() {
            expect(this.modLauncherMenuController.$('.bv_menuName_disabled')).not.toBeVisible();
            return expect(this.modLauncherMenuController.$('.bv_menuName')).toBeVisible();
          });
        });
      });
    });
    describe("ModuleLauncherMenuHeaderController tests", function() {
      beforeEach(function() {
        this.modLauncher = new ModuleLauncher({
          isHeader: true,
          menuName: "test header"
        });
        this.modLauncherMenuHeaderController = new ModuleLauncherMenuHeaderController({
          model: this.modLauncher
        });
        return $('#fixture').append(this.modLauncherMenuHeaderController.render().el);
      });
      describe("Upon render", function() {
        it("Should set its menu name", function() {
          return expect($(this.modLauncherMenuHeaderController.el).html()).toEqual("test header");
        });
        return it("should have the header class", function() {
          return expect(this.modLauncherMenuHeaderController.el).toHaveClass("nav-header");
        });
      });
      return describe("When clicked", function() {
        return it("should not set style active", function() {
          $(this.modLauncherMenuHeaderController.el).click();
          return expect(this.modLauncherMenuHeaderController.el).not.toHaveClass("active");
        });
      });
    });
    describe("ModuleLauncherMenuListController tests", function() {
      beforeEach(function() {
        this.modLauncherList = new ModuleLauncherList(window.moduleMenusTestJSON.testMenuItems);
        this.ModLauncherMenuListController = new ModuleLauncherMenuListController({
          el: '#fixture',
          collection: this.modLauncherList
        });
        return this.ModLauncherMenuListController.render();
      });
      describe("Upon render", function() {
        it("should load the template", function() {
          return expect($('.bv_navList')).toBeDefined();
        });
        it("should show 6 items", function() {
          return expect(this.ModLauncherMenuListController.$('li').length).toEqual(6);
        });
        it("should show a header as specified in the test json", function() {
          return expect(this.ModLauncherMenuListController.$('li :eq(0) ').html()).toEqual("Test Header");
        });
        it("should show a header with correct class", function() {
          return expect(this.ModLauncherMenuListController.$('li :eq(0) ')).toHaveClass("nav-header");
        });
        return it("should show the correct menu name in menu item 1", function() {
          return expect(this.ModLauncherMenuListController.$('li :eq(1) .bv_menuName').html()).toEqual("Test Launcher 1");
        });
      });
      return describe("Selection handling", function() {
        describe("when loaded", function() {
          return it("should have none active", function() {
            return expect(this.ModLauncherMenuListController.$('li .active').length).toEqual(0);
          });
        });
        describe("when second activated", function() {
          beforeEach(function() {
            this.ModLauncherMenuListController.bind("selectionUpdated", (function(_this) {
              return function() {
                return _this.gotTrigger = true;
              };
            })(this));
            return this.ModLauncherMenuListController.$('.bv_menuName :eq(1) ').click();
          });
          return it("should activate the correct menu", function() {
            expect(this.ModLauncherMenuListController.$('li :eq(1)')).not.toHaveClass('active');
            return expect(this.ModLauncherMenuListController.$('li :eq(2)')).toHaveClass('active');
          });
        });
        return describe("when second activated, then first activated", function() {
          return it("should activate the correct menu", function() {
            this.ModLauncherMenuListController.$('.bv_menuName :eq(1) ').click();
            expect(this.ModLauncherMenuListController.$('li :eq(1)')).not.toHaveClass('active');
            expect(this.ModLauncherMenuListController.$('li :eq(2)')).toHaveClass('active');
            this.ModLauncherMenuListController.$('.bv_menuName :eq(0) ').click();
            expect(this.ModLauncherMenuListController.$('li :eq(1)')).toHaveClass('active');
            return expect(this.ModLauncherMenuListController.$('li :eq(2)')).not.toHaveClass('active');
          });
        });
      });
    });
    describe("Module Launcher Controller Testing", function() {
      beforeEach(function() {
        this.modLauncher = new ModuleLauncher({
          menuName: "test menu",
          mainControllerClassName: "testClassName"
        });
        this.modLauncherCont = new ModuleLauncherController({
          el: '#fixture',
          model: this.modLauncher
        });
        return this.modLauncherCont.render();
      });
      describe("Upon render", function() {
        it("Should load its template", function() {
          return expect($('.bv_moduleContent').html()).toEqual("");
        });
        it("Should be hidden", function() {
          return expect($('#fixture')).not.toBeVisible();
        });
        return it("Should set its element className to the bv_+the controller class", function() {
          return expect($('#fixture')).toHaveClass('bv_' + this.modLauncher.get('mainControllerClassName'));
        });
      });
      return describe("When activation requested", function() {
        beforeEach(function() {
          return this.modLauncherCont.model.requestActivation();
        });
        it("should be shown", function() {
          return expect($('#fixture')).toBeVisible();
        });
        return describe("When deactivation requested", function() {
          beforeEach(function() {
            return this.modLauncherCont.model.requestDeactivation();
          });
          return it("should be hidden", function() {
            return expect($('#fixture')).not.toBeVisible();
          });
        });
      });
    });
    return describe("ModuleLauncherListController tests", function() {
      beforeEach(function() {
        this.modLauncherList = new ModuleLauncherList(window.moduleMenusTestJSON.testMenuItems);
        this.modLauncherListController = new ModuleLauncherListController({
          el: '#fixture',
          collection: this.modLauncherList
        });
        return this.modLauncherListController.render();
      });
      return describe("Upon render", function() {
        it("Should load its template", function() {
          return expect($('.bv_moduleWrapper')).toBeDefined();
        });
        return it("Should create and make divs for all the non-header ModuleLauncherControllers", function() {
          return expect(this.modLauncherListController.$('.bv_moduleWrapper div.bv_moduleContent').length).toEqual(5);
        });
      });
    });
  });

}).call(this);
