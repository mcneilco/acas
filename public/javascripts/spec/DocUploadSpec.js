(function() {
  describe('Doc Upload Behavior Testing', function() {
    beforeEach(function() {
      return this.fixture = $.clone($('#fixture').get(0));
    });
    afterEach(function() {
      $('#fixture').remove();
      return $('body').append($(this.fixture));
    });
    describe('DocUpload Model', function() {
      return describe('when instantiated', function() {
        beforeEach(function() {
          return this.docUpload = new DocUpload();
        });
        it('should have defaults', function() {
          expect(this.docUpload.get('url')).toEqual('');
          expect(this.docUpload.get('currentFileName')).toEqual('');
          expect(this.docUpload.get('description')).toEqual('');
          expect(this.docUpload.get('docType')).toEqual('');
          return expect(this.docUpload.get('documentKind')).toEqual('experiment');
        });
        it('should accept "url" for docType', function() {
          this.docUpload.set({
            docType: 'url',
            url: 'http://fred'
          });
          return expect(this.docUpload.isValid()).toBeTruthy();
        });
        it('should accept "file" for docType', function() {
          this.docUpload.set({
            docType: 'file',
            currentFileName: 'myFile'
          });
          return expect(this.docUpload.isValid()).toBeTruthy();
        });
        it('should not accept something besides "file" or "url" for docType', function() {
          var filtErrors;
          this.docUpload.set({
            docType: 'fred',
            currentFileName: 'myFile'
          });
          expect(this.docUpload.isValid()).toBeFalsy();
          filtErrors = _.filter(this.docUpload.validationError, function(err) {
            return err.attribute === 'docType';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
        it('should require currentFileName not "" when docType=file', function() {
          var filtErrors;
          this.docUpload.set({
            docType: 'file',
            currentFileName: ''
          });
          expect(this.docUpload.isValid()).toBeFalsy();
          filtErrors = _.filter(this.docUpload.validationError, function(err) {
            return err.attribute === 'currentFileName';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
        return it('should require url not "" when docType=url', function() {
          var filtErrors;
          this.docUpload.set({
            docType: 'url',
            url: ''
          });
          expect(this.docUpload.isValid()).toBeFalsy();
          filtErrors = _.filter(this.docUpload.validationError, function(err) {
            return err.attribute === 'url';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
      });
    });
    return describe('DocUpload Controller', function() {
      describe('when created with new model', function() {
        beforeEach(function() {
          this.docUploadController = new DocUploadController({
            model: new DocUpload(),
            el: $('#fixture')
          });
          return this.docUploadController.render();
        });
        return describe('after initial render', function() {
          it('should have a description field', function() {
            return expect(this.docUploadController.$(".bv_description").prop('tagName')).toEqual("INPUT");
          });
          it('should url field hidden', function() {
            return expect(this.docUploadController.$('.bv_urlInputWrapper')).toBeHidden();
          });
          it('should have new file radio selected', function() {
            return expect(this.docUploadController.$('.bv_newFileRadio').is(":checked")).toBeTruthy();
          });
          describe('since this is a new file', function() {
            return it('should hide the current file radio option', function() {
              return expect(this.docUploadController.$('.bv_currentDocContainer')).toBeHidden();
            });
          });
          describe('form events', function() {
            it('should hide URL field when radio is not selected', function() {
              this.docUploadController.$('bv_newFileRadio').click();
              return expect(this.docUploadController.$('.bv_urlInputWrapper')).toBeHidden();
            });
            it('should show URL field when radio is selected', function() {
              this.docUploadController.$('.bv_urlRadio').click();
              return expect(this.docUploadController.$('.bv_urlInputWrapper')).toBeVisible();
            });
            it('should show file control when radio is selected', function() {
              this.docUploadController.$('.bv_newFileRadio').click();
              return expect(this.docUploadController.$('.bv_fileInput')).toBeVisible();
            });
            return it('should hide file control when radio is selected', function() {
              this.docUploadController.$('.bv_urlRadio').click();
              waits(500);
              return runs(function() {
                return expect(this.docUploadController.$('.bv_fileInput')).toBeHidden();
              });
            });
          });
          return describe('form validataion', function() {
            it('should show error if URL field is empty and URL radio is selected', function() {
              this.docUploadController.$(".bv_url").val("");
              this.docUploadController.$(".bv_urlRadio").click();
              return expect(this.docUploadController.$(".bv_urlDocContainer").hasClass("error")).toBeTruthy();
            });
            it('should clear error if URL field is not empty and URL radio is selected', function() {
              this.docUploadController.$(".bv_url").val("");
              this.docUploadController.$(".bv_urlRadio").click();
              expect(this.docUploadController.$(".bv_urlDocContainer").hasClass("error")).toBeTruthy();
              this.docUploadController.$(".bv_url").val("fred");
              this.docUploadController.$(".bv_url").change();
              return expect(this.docUploadController.$(".bv_urlDocContainer").hasClass("error")).toBeFalsy();
            });
            it('should show error if file controller is empty and file radio is selected', function() {
              this.docUploadController.$(".bv_newFileRadio").click();
              this.docUploadController.clearNewFileName();
              return expect(this.docUploadController.$(".bv_newDocContainer").hasClass("error")).toBeTruthy();
            });
            return it('should clear error if file controller not empty and file radio is selected', function() {
              this.docUploadController.clearNewFileName();
              this.docUploadController.$(".bv_newFileRadio").click();
              expect(this.docUploadController.$(".bv_newDocContainer").hasClass("error")).toBeTruthy();
              this.docUploadController.setNewFileName("fredFile");
              this.docUploadController.$(".bv_newFileRadio").click();
              return expect(this.docUploadController.$(".bv_newDocContainer").hasClass("error")).toBeFalsy();
            });
          });
        });
      });
      describe('when created with existing model with docType File', function() {
        beforeEach(function() {
          this.docUploadController = new DocUploadController({
            model: new DocUpload(window.testJSON.docUploadWithFile),
            el: $('#fixture')
          });
          return this.docUploadController.render();
        });
        return describe('after initial render with docType = file', function() {
          it('should show current file container', function() {
            return expect(this.docUploadController.$('.bv_currentDocContainer')).toBeVisible();
          });
          it('should show current file name if docType is file', function() {
            return expect(this.docUploadController.$('.bv_currentFileName').html()).toEqual("exampleUploadedFile.txt");
          });
          it('should have current file name radio checked docType is file', function() {
            return expect(this.docUploadController.$('.bv_currentFileRadio').is(":checked")).toBeTruthy();
          });
          return it('should hide new file input', function() {
            return expect(this.docUploadController.$('.bv_fileInput')).toBeHidden();
          });
        });
      });
      return describe('when created with existing model with docType url', function() {
        beforeEach(function() {
          this.docUploadController = new DocUploadController({
            model: new DocUpload(window.testJSON.docForBatchesWithURl),
            el: $('#fixture')
          });
          return this.docUploadController.render();
        });
        return describe('after initial render with docType = url', function() {
          it('should hide current file container', function() {
            return expect(this.docUploadController.$('.bv_currentDocContainer')).toBeHidden();
          });
          xit('should show current url name ', function() {
            return expect(this.docUploadController.$('.bv_url').val()).toEqual("testURL");
          });
          it('should have  url  radio checked ', function() {
            return expect(this.docUploadController.$('.bv_urlRadio').is(":checked")).toBeTruthy();
          });
          return it('should hide new file input', function() {
            return expect(this.docUploadController.$('.bv_fileInput')).toBeHidden();
          });
        });
      });
    });
  });

}).call(this);
