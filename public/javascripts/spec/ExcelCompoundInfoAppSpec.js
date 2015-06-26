(function() {
  beforeEach(function() {
    this.fixture = $.clone($("#fixture").get(0));
    window.logger = {
      log: function(message) {
        return console.log(message);
      }
    };
    window.Office = {
      context: {
        document: {
          getSelectedDataAsync: function(type, callback) {
            return callback(window.resultMockObject);
          }
        }
      }
    };
    window.successfulResultMockObject = {
      status: 'succeeded',
      value: 'mockResultValue'
    };
    return window.unsuccessfulResultMockObject = {
      status: 'failed',
      value: null,
      error: {
        name: "error message name",
        value: "mock error message"
      }
    };
  });

  afterEach(function() {
    $("#fixture").remove();
    return $("body").append($(this.fixture));
  });

  describe("Excel Compound Info App module testing", function() {
    return describe("Excel Compound Info App controller", function() {
      beforeEach(function() {
        window.insertCompoundPropertiesController = new ExcelInsertCompoundPropertiesController({
          el: $('.bv_excelInsertCompoundPropertiesView')
        });
        return insertCompoundPropertiesController.render();
      });
      describe("Basic existence tests", function() {
        return it("should be defined", function() {
          return expect(insertCompoundPropertiesController).toBeDefined();
        });
      });
      return describe("handleGetPropertiesClicked", function() {
        it("should call fetchPrepared if result.status is 'succeeded'", function() {
          window.resultMockObject = window.successfulResultMockObject;
          spyOn(insertCompoundPropertiesController, "fetchPreferred");
          insertCompoundPropertiesController.handleGetPropertiesClicked();
          return expect(insertCompoundPropertiesController.fetchPreferred).toHaveBeenCalled();
        });
        return it("should not call fetchPrepared if result.status is not 'succeeded'", function() {
          window.resultMockObject = window.unsuccessfulResultMockObject;
          spyOn(insertCompoundPropertiesController, "fetchPreferred");
          insertCompoundPropertiesController.handleGetPropertiesClicked();
          return expect(insertCompoundPropertiesController.fetchPreferred).not.toHaveBeenCalled();
        });
      });
    });
  });

}).call(this);
