
/*
  This module is our MVC wrapper for the Blueimp jQuery fileupload() widget.
  Here are the docs: https://github.com/blueimp/jQuery-File-Upload/wiki/Options
  Much FM occurs in fileupload. This controller is designed to hide that and send events etc
  that match our general architecture
 */

(function() {
  describe('LS File Chooser Behavior Testing', function() {
    beforeEach(function() {
      return this.fixture = $.clone($('#fixture').get(0));
    });
    afterEach(function() {
      $('#fixture').remove();
      return $('body').append($(this.fixture));
    });
    describe('LSFileChooser Model', function() {
      describe('when instantiated', function() {
        beforeEach(function() {
          return this.fc = new LSFileChooserModel();
        });
        it('should have defaults', function() {
          (expect(this.fc.get('fileName'))).toEqual('');
          (expect(this.fc.get('fileNameOnServer'))).toEqual('');
          return (expect(this.fc.get('fileType'))).toEqual('');
        });
        it('should return fileName', function() {
          this.fc.set({
            'fileName': "testFile"
          });
          return expect(this.fc.get('fileName'));
        });
        return it('should be marked as dirty', function() {
          return (expect(this.fc.isDirty())).toBeTruthy();
        });
      });
      describe('when a file has been uploaded', function() {
        beforeEach(function() {
          return this.fc = new LSFileChooserModel();
        });
        it('the fileNameOnServer field should be set', function() {
          this.fc.set({
            fileNameOnServer: 'testFileName.foo'
          });
          return (expect(this.fc.get('fileNameOnServer'))).toEqual('testFileName.foo');
        });
        return it('the isDirty field should be false', function() {
          this.fc.set({
            fileNameOnServer: 'testFileName.foo'
          });
          return (expect(this.fc.isDirty())).toBeFalsy();
        });
      });
      return describe('when a file has been uploaded and then removed', function() {
        beforeEach(function() {
          return this.fc = new LSFileChooserModel();
        });
        it('the fileNameOnServer field should be set back to default', function() {
          this.fc.set({
            fileNameOnServer: 'testFileName.foo'
          });
          (expect(this.fc.get('fileNameOnServer'))).toEqual('testFileName.foo');
          this.fc.set({
            fileNameOnServer: ''
          });
          return (expect(this.fc.get('fileNameOnServer'))).toEqual('');
        });
        return it('the isDirty field should be true', function() {
          this.fc.set({
            fileNameOnServer: 'testFileName.foo'
          });
          (expect(this.fc.isDirty())).toBeFalsy();
          this.fc.set({
            fileNameOnServer: ''
          });
          return (expect(this.fc.isDirty())).toBeTruthy();
        });
      });
    });
    describe('LSFileModelCollection', function() {
      return describe('when instantiated', function() {
        beforeEach(function() {
          return this.fmc = new LSFileModelCollection();
        });
        return it('should be empty', function() {
          return (expect(this.fmc.size())).toEqual(0);
        });
      });
    });
    return describe('LSFileChooserController', function() {
      describe('when instantiated', function() {
        beforeEach(function() {
          this.fc = new LSFileChooserController({
            el: '#fixture',
            dropZoneClassId: 'field1',
            autoUpload: false,
            maxNumberOfFiles: 1,
            url: "http://" + window.conf.host + ":" + window.conf.service.file.port
          });
          return this.fc.render();
        });
        it('should have upload url', function() {
          return (expect(this.fc.url)).toContain('http://');
        });
        it('drop field should initially be hidden', function() {
          return (expect($('.field1').is(':visible'))).toBeFalsy();
        });
        it('should start with 0 files', function() {
          return (expect(this.fc.currentNumberOfFiles)).toEqual(0);
        });
        it('should have 1 file after adding a file', function() {
          this.fc.handleFileAddedEvent({}, {});
          return (expect(this.fc.currentNumberOfFiles)).toEqual(1);
        });
        it('should have 2 files after adding 2 files', function() {
          this.fc.handleFileAddedEvent({}, {});
          this.fc.handleFileAddedEvent({}, {});
          return (expect(this.fc.currentNumberOfFiles)).toEqual(2);
        });
        it('should have 1 files after adding 2 files and removing 1', function() {
          this.fc.handleFileAddedEvent({}, {});
          this.fc.handleFileAddedEvent({}, {});
          (expect(this.fc.currentNumberOfFiles)).toEqual(2);
          this.fc.handleDeleteFileUIChanges({}, {});
          return (expect(this.fc.currentNumberOfFiles)).toEqual(1);
        });
        it('should not allow additional files to be added once the maxNumberOfFiles has been reached', function() {
          this.fc.maxNumberOfFiles = 1;
          this.fc.handleFileAddedEvent({}, {});
          (expect(this.fc.currentNumberOfFiles)).toEqual(1);
          return (expect(this.fc.canAcceptAnotherFile())).toBeFalsy();
        });
        return it('should allow additional files to be added if the maxNumberOfFiles has not been reached', function() {
          this.fc.maxNumberOfFiles = 1;
          (expect(this.fc.currentNumberOfFiles)).toEqual(0);
          return (expect(this.fc.canAcceptAnotherFile())).toBeTruthy();
        });
      });
      xdescribe('drop field', function() {
        beforeEach(function() {
          this.fc = new LSFileChooserController({
            el: '#fixture',
            dropZoneClassId: 'field1',
            autoUpload: false
          });
          return this.fc.render();
        });
        it('should be displayed when dragging a file over the document', function() {
          this.fc.handleDragOverDocument();
          return (expect($('.field1').is(':visible'))).toBeTruthy();
        });
        it('should display info text when dragging a file over', function() {
          this.fc.handleDragOverDocument();
          return (expect($('.bv_dragOverMessage').html())).toEqual('Drop the file here to upload it');
        });
        return it('should be hidden when mouseout', function() {
          this.fc.handleDragOverDocument();
          (expect($('.field1').is(':visible'))).toBeTruthy();
          this.fc.handleDragLeaveDocument();
          return (expect($('.field1').is(':visible'))).toBeFalsy();
        });
      });
      return describe('upload button', function() {
        return beforeEach(function() {
          this.fc = new LSFileChooserController({
            el: '#fixture',
            dropZoneClassId: 'field1',
            autoUpload: false,
            maxNumberOfFiles: 1
          });
          return this.fc.render();
        });
      });
    });
  });

}).call(this);
