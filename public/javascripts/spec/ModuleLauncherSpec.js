(function() {
  describe("Module Menu System Testing", function() {
    beforeEach(function() {
      this.fixture = $.clone($("#fixture").get(0));
      return this.testMenuItems = [
        {
          isHeader: true,
          menuName: "Test Header"
        }, {
          isHeader: false,
          menuName: "Test Launcher 1",
          mainControllerClassName: "controllerClassName1"
        }, {
          isHeader: false,
          menuName: "Test Launcher 2",
          mainControllerClassName: "controllerClassName2"
        }, {
          isHeader: false,
          menuName: "Test Launcher 3",
          mainControllerClassName: "controllerClassName3"
        }
      ];
    });
    afterEach(function() {
      $("#fixture").remove();
      return $("body").append($(this.fixture));
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
          var _this = this;

          runs(function() {
            var _this = this;

            this.modLauncher.bind('activationRequested', function() {
              return _this.gotTrigger = true;
            });
            return this.modLauncher.requestActivation();
          });
          waitsFor(function() {
            return _this.gotTrigger;
          });
          return runs(function() {
            return expect(this.gotTrigger).toBeTruthy();
          });
        });
      });
      describe("de-activation", function() {
        return it("should trigger deactivation request", function() {
          var _this = this;

          runs(function() {
            var _this = this;

            this.modLauncher.bind('deactivationRequested', function() {
              return _this.gotTrigger = true;
            });
            return this.modLauncher.requestDeactivation();
          });
          waitsFor(function() {
            return _this.gotTrigger;
          });
          return runs(function() {
            return expect(this.gotTrigger).toBeTruthy();
          });
        });
      });
      describe("Module Launcher List Testing", function() {});
      beforeEach(function() {
        return this.modLauncherList = new ModuleLauncherList(this.testMenuItems);
      });
      return describe("Existence test", function() {
        return it("should instanitate with 4 entries", function() {
          return expect(this.modLauncherList.length).toEqual(4);
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
        return it("should show that it is not dirty", function() {
          return expect(this.modLauncherMenuController.$('.bv_isDirty')).not.toBeVisible();
        });
      });
      describe("When clicked", function() {
        beforeEach(function() {
          var _this = this;

          this.modLauncherMenuController.bind("selected", function() {
            return _this.gotTrigger = true;
          });
          return $(this.modLauncherMenuController.el).click();
        });
        it("should set style active", function() {
          return expect(this.modLauncherMenuController.el).toHaveClass("active");
        });
        it("should set the model to active", function() {
          return expect(this.modLauncherMenuController.model.get('isActive')).toBeTruthy();
        });
        return it("should trigger a selected event", function() {
          var _this = this;

          runs(function() {});
          waitsFor(function() {
            return _this.gotTrigger;
          });
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
      return describe("when deselected", function() {
        return it("should change style", function() {
          $(this.modLauncherMenuController.el).click();
          expect(this.modLauncherMenuController.el).toHaveClass("active");
          this.modLauncherMenuController.clearSelected(new ModuleLauncherMenuController({
            model: new ModuleLauncher()
          }));
          expect($(this.modLauncherMenuController.el).hasClass("active")).toBeFalsy();
          return expect(this.modLauncherMenuController.model.get('isActive')).toBeFalsy();
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
        this.modLauncherList = new ModuleLauncherList(this.testMenuItems);
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
        it("should show 4 items", function() {
          return expect(this.ModLauncherMenuListController.$('li').length).toEqual(4);
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
            var _this = this;

            this.ModLauncherMenuListController.bind("selectionUpdated", function() {
              return _this.gotTrigger = true;
            });
            return this.ModLauncherMenuListController.$('li :eq(2) ').click();
          });
          return it("should activate the correct menu", function() {
            expect(this.ModLauncherMenuListController.$('li :eq(1)')).not.toHaveClass('active');
            return expect(this.ModLauncherMenuListController.$('li :eq(2)')).toHaveClass('active');
          });
        });
        return describe("when second activated, then first activated", function() {
          return it("should activate the correct menu", function() {
            this.ModLauncherMenuListController.$('li :eq(2) ').click();
            expect(this.ModLauncherMenuListController.$('li :eq(1)')).not.toHaveClass('active');
            expect(this.ModLauncherMenuListController.$('li :eq(2)')).toHaveClass('active');
            this.ModLauncherMenuListController.$('li :eq(1) ').click();
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
        this.modLauncherList = new ModuleLauncherList(this.testMenuItems);
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
          return expect(this.modLauncherListController.$('.bv_moduleWrapper div.bv_moduleContent').length).toEqual(3);
        });
      });
    });
  });

}).call(this);
