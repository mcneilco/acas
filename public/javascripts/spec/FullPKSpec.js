(function() {
  describe('Full PK Behavior Testing', function() {
    beforeEach(function() {
      return this.fixture = $.clone($('#fixture').get(0));
    });
    afterEach(function() {
      $('#fixture').remove();
      return $('body').append($(this.fixture));
    });
    describe('FullPK Model', function() {
      describe('when instantiated', function() {
        beforeEach(function() {
          return this.fullPK = new FullPK();
        });
        return describe("defaults tests", function() {
          return it('should have defaults', function() {
            expect(this.fullPK.get('format')).toEqual("In Vivo Full PK");
            expect(this.fullPK.get('protocolName')).toEqual("");
            expect(this.fullPK.get('experimentName')).toEqual("");
            expect(this.fullPK.get('scientist')).toEqual("");
            expect(this.fullPK.get('notebook')).toEqual("");
            expect(this.fullPK.get('inLifeNotebook')).toEqual("");
            expect(this.fullPK.get('assayDate')).toEqual(null);
            expect(this.fullPK.get('project')).toEqual("");
            expect(this.fullPK.get('bioavailability')).toEqual("");
            return expect(this.fullPK.get('aucType')).toEqual("");
          });
        });
      });
      return describe("validation tests", function() {
        beforeEach(function() {
          return this.fullPK = new FullPK(window.FullPKTestJSON.validFullPK);
        });
        it("should be valid as initialized", function() {
          return expect(this.fullPK.isValid()).toBeTruthy();
        });
        return it('should require that protocolName not be ""', function() {
          var filtErrors;

          this.fullPK.set({
            protocolName: ""
          });
          expect(this.fullPK.isValid()).toBeFalsy();
          filtErrors = _.filter(this.fullPK.validationError, function(err) {
            return err.attribute === 'protocolName';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
      });
    });
    return describe('FullPK Controller', function() {
      describe('when instantiated', function() {
        beforeEach(function() {
          this.fpkc = new FullPKController({
            model: new FullPK(),
            el: $('#fixture')
          });
          return this.fpkc.render();
        });
        describe("basic existance tests", function() {
          it('should exist', function() {
            return expect(this.fpkc).toBeDefined();
          });
          return it('should load a template', function() {
            return expect(this.fpkc.$('.bv_protocolName').length).toEqual(1);
          });
        });
        describe("it should show a picklist for projects", function() {
          beforeEach(function() {
            waitsFor(function() {
              return this.fpkc.$('.bv_project option').length > 0;
            }, 1000);
            return runs(function() {});
          });
          it("should show project options after loading them from server", function() {
            return expect(this.fpkc.$('.bv_project option').length).toBeGreaterThan(0);
          });
          return it("should default to unassigned", function() {
            return expect(this.fpkc.$('.bv_project').val()).toEqual("unassigned");
          });
        });
        return describe('update model when fields changed', function() {
          return it("should update the protocolName", function() {
            this.fpkc.$('.bv_protocolName').val("test protocol");
            this.fpkc.$('.bv_protocolName').change();
            return expect(this.fpkc.model.get('protocolName')).toEqual("test protocol");
          });
        });
      });
      return describe("validation testting", function() {
        beforeEach(function() {
          this.fpkc = new FullPKController({
            model: new FullPK(window.FullPKTestJSON.validFullPK),
            el: $('#fixture')
          });
          return this.fpkc.render();
        });
        return it('should show error if protocolName is empty', function() {
          this.fpkc.$(".bv_protocolName").val("");
          this.fpkc.$(".bv_protocolName").change();
          return expect(this.fpkc.$(".bv_group_protocolName").hasClass("error")).toBeTruthy();
        });
      });
    });
  });

}).call(this);
