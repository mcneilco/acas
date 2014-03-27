(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  describe('AbstractFormController Behavior Testing', function() {
    beforeEach(function() {
      return this.fixture = $.clone($('#fixture').get(0));
    });
    afterEach(function() {
      $('#fixture').remove();
      return $('body').append($(this.fixture));
    });
    return describe('when instantiated', function() {
      beforeEach(function() {
        this.TestAbstractFormController = (function(_super) {
          __extends(TestAbstractFormController, _super);

          function TestAbstractFormController() {
            return TestAbstractFormController.__super__.constructor.apply(this, arguments);
          }

          TestAbstractFormController.prototype.initialize = function() {
            this.errorOwnerName = 'TestAbstractFormController';
            return this.setBindings();
          };

          return TestAbstractFormController;

        })(AbstractFormController);
        this.tafc = new this.TestAbstractFormController({
          model: new Backbone.Model(),
          el: $('#fixture')
        });
        return this.tafc.render();
      });
      describe("basic existance tests", function() {
        return it('should exist', function() {
          return expect(AbstractFormController).toBeDefined();
        });
      });
      return describe("input formatting features", function() {
        it("get val from input and trim it", function() {
          this.tafc.$el.append("<input type='text' class='bv_testInput' />");
          this.tafc.$('.bv_testInput').val("  some input with spaces  ");
          return expect(this.tafc.getTrimmedInput('.bv_testInput')).toEqual("some input with spaces");
        });
        return it("should parse ACAS standard format yyyy-mm-dd correctly in IE8 and other browsers", function() {
          return expect(this.tafc.convertYMDDateToMs("2013-6-6")).toEqual(new Date(2013, 5, 6).getTime());
        });
      });
    });
  });

}).call(this);
