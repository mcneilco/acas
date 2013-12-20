(function() {
  beforeEach(function() {
    return this.fixture = $.clone($("#fixture").get(0));
  });

  afterEach(function() {
    $("#fixture").remove();
    return $("body").append($(this.fixture));
  });

  describe("TagList module testing", function() {
    describe("Tag model testing", function() {
      beforeEach(function() {
        return this.tag = new Tag();
      });
      describe("Basic existance", function() {
        return it('should be defined', function() {
          return expect(Tag).toBeDefined();
        });
      });
      return describe("Defaults", function() {
        return it('Should have default tagText', function() {
          return expect(this.tag.get('tagText')).toEqual("");
        });
      });
    });
    describe("TagList model testing", function() {
      beforeEach(function() {
        return this.tl = new TagList();
      });
      return describe("Basic existance", function() {
        return it('should be defined', function() {
          return expect(this.tl instanceof Backbone.Collection).toBeTruthy();
        });
      });
    });
    return describe("TagListController testing", function() {
      beforeEach(function() {
        $("#fixture").append('<input class="bv_tags" type="text" data-role="tagsinput"/>');
        this.tlc = new TagListController({
          collection: new TagList(window.TagListTestJSON.tagList),
          el: $("#fixture .bv_tags")
        });
        return this.tlc.render();
      });
      describe("Basic existance", function() {
        return it('should be defined', function() {
          return expect(this.tlc instanceof Backbone.View).toBeTruthy();
        });
      });
      describe("render from existing tag list", function() {
        return it("should show tag 1", function() {
          return expect(this.tlc.$el.tagsinput('items')[0]).toEqual("tag 1");
        });
      });
      return describe("adding new item updates model", function() {
        return it("should add new tag to collection", function() {
          this.tlc.$el.tagsinput('add', "lucy");
          this.tlc.$el.focusout();
          return expect(this.tlc.collection.at(2).get('tagText')).toEqual("lucy");
        });
      });
    });
  });

}).call(this);
