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
      return describe("basic existance tests", function() {
        return it('should exist', function() {
          return expect(AbstractFormController).toBeDefined();
        });
      });
    });
  });

}).call(this);
