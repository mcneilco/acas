(function() {
  beforeEach(function() {
    return this.fixture = $.clone($("#fixture").get(0));
  });

  afterEach(function() {
    $("#fixture").remove();
    return $("body").append($(this.fixture));
  });

  describe("Attach File testing", function() {
    describe("Attach file model testing", function() {
      describe("When loaded from new", function() {
        beforeEach(function() {
          return this.afm = new AttachFile();
        });
        return describe("Existence and Defaults", function() {
          it("should be defined", function() {
            return expect(this.afm).toBeDefined();
          });
          it("should have the file type be unassigned", function() {
            return expect(this.afm.get('fileType')).toEqual("unassigned");
          });
          return it("should have the fileValue be empty", function() {
            return expect(this.afm.get('fileValue')).toEqual("");
          });
        });
      });
      return describe("model validation tests", function() {
        beforeEach(function() {
          return this.afm = new AttachFile(window.attachFileTestJSON.attachFileInfo[0]);
        });
        it("should be valid as initialized", function() {
          return expect(this.afm.isValid()).toBeTruthy();
        });
        return it("should be invalid when file type is unassigned AND a file is uploaded", function() {
          var filtErrors;
          this.afm.set({
            fileType: "unassigned"
          });
          expect(this.afm.isValid()).toBeFalsy();
          filtErrors = _.filter(this.afm.validationError, function(err) {
            return err.attribute === 'fileType';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
      });
    });
    describe("Attach File List testing", function() {
      return describe("When loaded from new", function() {
        beforeEach(function() {
          return this.afl = new AttachFileList();
        });
        return describe("Existence", function() {
          return it("should be defined", function() {
            return expect(this.afl).toBeDefined();
          });
        });
      });
    });
    describe("AttachFileController testing", function() {
      return describe("when instantiated", function() {
        beforeEach(function() {
          this.afc = new AttachFileController({
            model: new AttachFile(window.attachFileTestJSON.attachFileInfo[0]),
            el: $('#fixture'),
            fileTypeListURL: "/api/codetables/analytical method/file type"
          });
          return this.afc.render();
        });
        describe("basic existance tests", function() {
          it("should exist", function() {
            return expect(this.afc).toBeDefined();
          });
          return it("should load a template", function() {
            return expect(this.afc.$('.bv_fileType').length).toEqual(1);
          });
        });
        describe("render existing parameters", function() {
          return it("should show file type", function() {
            waitsFor(function() {
              return this.afc.$('.bv_fileType option').length > 0;
            }, 1000);
            return runs(function() {
              return expect(this.afc.$('.bv_fileType').val()).toEqual("hplc");
            });
          });
        });
        return describe("model updates", function() {
          return it("should update the fileType", function() {
            waitsFor(function() {
              return this.afc.$('.bv_fileType option').length > 0;
            }, 1000);
            return runs(function() {
              this.afc.$('.bv_fileType').val('unassigned');
              this.afc.$('.bv_fileType').change();
              return expect(this.afc.model.get('fileType')).toEqual("unassigned");
            });
          });
        });
      });
    });
    return describe("AttachFileListController testing", function() {
      return describe("when instantiated with no data", function() {
        beforeEach(function() {
          this.aflc = new AttachFileListController({
            el: $('#fixture'),
            collection: new AttachFileList(),
            fileTypeListURL: "/api/codetables/analytical method/file type"
          });
          return this.aflc.render();
        });
        describe("basic existence tests", function() {
          it("should exist", function() {
            return expect(this.aflc).toBeDefined();
          });
          return it("should load a template", function() {
            return expect(this.aflc.$('.bv_attachFileInfo').length).toEqual(1);
          });
        });
        describe("rendering", function() {
          return it("should show one attachFileModel", function() {
            expect(this.aflc.$('.bv_attachFileInfo .bv_fileType').length).toEqual(1);
            return expect(this.aflc.collection.length).toEqual(1);
          });
        });
        return describe("adding and removing", function() {
          it("should be able to delete a file", function() {
            this.aflc.uploadNewAttachFile();
            expect(this.aflc.$('.bv_attachFileInfo .bv_fileType').length).toEqual(2);
            this.aflc.$('.bv_delete:eq(0)').click();
            return expect(this.aflc.$('.bv_attachFileInfo .bv_fileType').length).toEqual(1);
          });
          return it("should always have at least one attachFileModel", function() {
            this.aflc.$('.bv_delete:eq(0)').click();
            return expect(this.aflc.$('.bv_attachFileInfo .bv_fileType').length).toEqual(1);
          });
        });
      });
    });
  });

}).call(this);
