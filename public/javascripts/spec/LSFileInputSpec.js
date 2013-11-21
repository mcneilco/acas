(function() {
  describe('LS File Input Behavior Testing', function() {
    beforeEach(function() {
      return this.fixture = $.clone($('#fixture').get(0));
    });
    afterEach(function() {
      $('#fixture').remove();
      return $('body').append($(this.fixture));
    });
    return describe('LSFileInput Controller', function() {
      return describe('when instantiated', function() {
        beforeEach(function() {
          this.echoFileController = new LSFileInputController({
            el: '#fixture',
            inputTitle: 'Test File',
            url: "http://" + window.conf.host + ":" + window.conf.service.file.port,
            fieldIsRequired: true
          });
          return this.echoFileController.render();
        });
        it('should load template', function() {
          expect(this.echoFileController.$('.bv_container').prop("tagName")).toEqual("DIV");
          return expect(this.echoFileController.$('.bv_fileChooserContainer').prop("tagName")).toEqual("DIV");
        });
        it('should show the correct title', function() {
          return expect(this.echoFileController.$('.bv_fileInputTitle h4').html()).toContain("Test File");
        });
        return it('should show that file is required', function() {
          return expect(this.echoFileController.$('.bv_fileInputTitle h4').html()).toContain("*");
        });
      });
    });
  });

}).call(this);
