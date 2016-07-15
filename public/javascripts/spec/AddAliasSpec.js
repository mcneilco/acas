(function() {
  describe('AddAlias', function() {
    describe('AliasModel', function() {
      beforeEach(function() {
        return this.aliasModel = new AliasModel();
      });
      describe('when instantiated', function() {
        return it('Should have default attributes', function() {
          expect(this.aliasModel.get('lsKind')).toEqual('Parent Common Name');
          expect(this.aliasModel.get('aliasName')).toEqual('');
          expect(this.aliasModel.get('lsType')).toEqual('');
          expect(this.aliasModel.get('deleted')).toEqual(false);
          expect(this.aliasModel.get('ignored')).toEqual(false);
          return expect(this.aliasModel.get('preferred')).toEqual(false);
        });
      });
      return describe('validation', function() {
        it('should be invalid if missing required valies', function() {
          return expect(this.aliasModel.validate(this.aliasModel.toJSON())).toNotEqual(null);
        });
        return it('should be valid if all required fields a filled in', function() {
          this.aliasModel.set({
            'lsType': 'alias type',
            'aliasName': 'alias name'
          });
          return expect(this.aliasModel.validate(this.aliasModel.toJSON())).toBeNull();
        });
      });
    });
    describe('AliasCollection', function() {
      beforeEach(function() {
        return this.aliasCollection = new AliasCollection();
      });
      return describe('modelsAreAllValid', function() {
        it('should return true if all the models are valid', function() {
          var coll, m1, m2;
          m1 = new AliasModel({
            'lsType': 'alias type',
            'aliasName': 'alias name1'
          });
          m2 = new AliasModel({
            'lsType': 'alias type',
            'aliasName': 'alias name2'
          });
          coll = new AliasCollection([m1, m2]);
          return expect(coll.modelsAreAllValid()).toBeTruthy();
        });
        return it('should return false if at least one model is invalid', function() {
          var coll, m1, m2;
          m1 = new AliasModel({
            'lsType': 'alias type',
            'aliasName': ''
          });
          m2 = new AliasModel({
            'lsType': 'alias type',
            'aliasName': 'alias name2'
          });
          coll = new AliasCollection([m1, m2]);
          return expect(coll.modelsAreAllValid()).toBeFalsy();
        });
      });
    });
    describe('AddAliasTableController', function() {
      beforeEach(function() {
        this.fixture = $.clone($('#fixture').get(0));
        this.aliasTableController = new AddAliasTableController({
          collection: new AliasCollection([new AliasModel()])
        });
        return $('#fixture').html(this.aliasTableController.render().el);
      });
      afterEach(function() {
        $('#fixture').remove();
        return $('body').append($(this.fixture));
      });
      return describe('initialization', function() {
        it('should render a single empty row when initialized without any aliases', function() {
          return expect(this.aliasTableController.$('tr').length).toEqual(2);
        });
        it('should render row for each entry when initialized without existing aliases', function() {
          var aliasTableController, coll, m1, m2;
          m1 = new AliasModel({
            'lsType': 'alias type',
            'aliasName': ''
          });
          m2 = new AliasModel({
            'lsType': 'alias type',
            'aliasName': 'alias name2'
          });
          coll = new AliasCollection([m1, m2]);
          $('#fixture').remove();
          $('body').append($(this.fixture));
          aliasTableController = new AddAliasTableController({
            collection: coll
          });
          $('#fixture').html(aliasTableController.render().el);
          return expect(aliasTableController.$('tr').length).toEqual(3);
        });
        it('should ignore entries where ignore is true', function() {
          var aliasTableController, coll, m1, m2;
          m1 = new AliasModel({
            'lsType': 'alias type',
            'aliasName': 'alias name2'
          });
          m2 = new AliasModel({
            'lsType': 'alias type',
            'aliasName': 'alias name2',
            ignore: true
          });
          coll = new AliasCollection([m1, m2]);
          $('#fixture').remove();
          $('body').append($(this.fixture));
          aliasTableController = new AddAliasTableController({
            collection: coll
          });
          $('#fixture').html(aliasTableController.render().el);
          return expect(aliasTableController.$('tr').length).toEqual(3);
        });
        it('should add a row when "add" button is clicked and all existing rows are valid', function() {
          var aliasTableController, coll, m1;
          m1 = new AliasModel({
            'lsType': 'alias type',
            'aliasName': 'alias name2'
          });
          coll = new AliasCollection([m1]);
          $('#fixture').remove();
          $('body').append($(this.fixture));
          aliasTableController = new AddAliasTableController({
            collection: coll
          });
          $('#fixture').html(aliasTableController.render().el);
          aliasTableController.$('.addNewAlias').click();
          return expect(aliasTableController.$('tr').length).toEqual(3);
        });
        return it('should not add a row when "add" button is clicked but at least one row is invalid', function() {
          var aliasTableController, coll, m1;
          m1 = new AliasModel({
            'lsType': 'alias type',
            'aliasName': ''
          });
          coll = new AliasCollection([m1]);
          $('#fixture').remove();
          $('body').append($(this.fixture));
          aliasTableController = new AddAliasTableController({
            collection: coll
          });
          $('#fixture').html(aliasTableController.render().el);
          aliasTableController.$('.addNewAlias').click();
          return expect(aliasTableController.$('tr').length).toEqual(2);
        });
      });
    });
    describe('AliasRowController', function() {
      beforeEach(function() {
        this.fixture = $.clone($('#fixture').get(0));
        this.aliasRowController = new AliasRowController({
          model: new AliasModel
        });
        return $('#fixture').html(this.aliasRowController.render().el);
      });
      afterEach(function() {
        $('#fixture').remove();
        return $('body').append($(this.fixture));
      });
      describe('initialization', function() {
        return it('should render appropriate template content', function() {
          expect(this.aliasRowController.$('input').length).toEqual(1);
          return expect(this.aliasRowController.$('select').length).toEqual(1);
        });
      });
      return describe('model update behavior', function() {
        it('should not set ignored to true if the alias model is noew', function() {
          var aliasRowController, m1;
          $('#fixture').remove();
          $('body').append($(this.fixture));
          m1 = new AliasModel({
            'lsType': 'alias type',
            'aliasName': 'old name'
          });
          aliasRowController = new AliasRowController({
            model: m1
          });
          $('#fixture').html(aliasRowController.render().el);
          aliasRowController.$(".bv_aliasKind").val("new name");
          aliasRowController.$(".bv_aliasKind").trigger("change");
          return expect(m1.get('ignored')).toBeFalsy();
        });
        it('should set ignored to true if an existing alias is edited', function() {
          var aliasRowController, m1;
          $('#fixture').remove();
          $('body').append($(this.fixture));
          m1 = new AliasModel({
            'lsType': 'alias type',
            'aliasName': 'old name',
            id: 1
          });
          aliasRowController = new AliasRowController({
            model: m1
          });
          $('#fixture').html(aliasRowController.render().el);
          aliasRowController.$(".bv_aliasKind").val("new name");
          aliasRowController.$(".bv_aliasKind").trigger("change");
          return expect(m1.get('ignored')).toBeTruthy();
        });
        return it('should trigger isDirty event when an existing alias is edited', function() {
          var aliasRowController, m1;
          $('#fixture').remove();
          $('body').append($(this.fixture));
          m1 = new AliasModel({
            'lsType': 'alias type',
            'aliasName': 'old name',
            id: 1
          });
          aliasRowController = new AliasRowController({
            model: m1
          });
          $('#fixture').html(aliasRowController.render().el);
          aliasRowController.$(".bv_aliasKind").val("new name");
          aliasRowController.$(".bv_aliasKind").trigger("change");
          return expect(m1.get('ignored')).toBeTruthy();
        });
      });
    });
    return describe('AliasListReadView', function() {
      beforeEach(function() {
        var a1, a2, coll;
        this.fixture = $.clone($('#fixture').get(0));
        a1 = new AliasModel({
          'lsType': 'alias type',
          'aliasName': 'alias1',
          id: 1
        });
        a2 = new AliasModel({
          'lsType': 'alias type',
          'aliasName': 'alias2',
          id: 2
        });
        coll = new AliasCollection([a1, a2]);
        this.aliasReadView = new AliasListReadView({
          collection: coll
        });
        return $('#fixture').html(this.aliasReadView.render().el);
      });
      afterEach(function() {
        $('#fixture').remove();
        return $('body').append($(this.fixture));
      });
      describe('initialization', function() {
        it('should render appropriate template content', function() {
          return expect(this.aliasReadView.$('.bv_aliasName').length).toEqual(2);
        });
        return xit('should have an "edit" button', function() {
          return expect(this.aliasReadView.$('.bv_editAliases').length).toEqual(1);
        });
      });
      return describe('behavior', function() {
        return xit('should call handleEditAliases bv_editAliases is clicked', function() {
          spyOn(this.aliasReadView, 'handleEditAliases');
          this.aliasReadView.delegateEvents();
          this.aliasReadView.$(".bv_editAliases").click();
          return expect(this.aliasReadView.handleEditAliases).toHaveBeenCalled();
        });
      });
    });
  });

}).call(this);

(function() {
  describe('AddAlias', function() {
    describe('AliasModel', function() {
      beforeEach(function() {
        return this.aliasModel = new AliasModel();
      });
      describe('when instantiated', function() {
        return it('Should have default attributes', function() {
          expect(this.aliasModel.get('lsKind')).toEqual('Parent Common Name');
          expect(this.aliasModel.get('aliasName')).toEqual('');
          expect(this.aliasModel.get('lsType')).toEqual('');
          expect(this.aliasModel.get('deleted')).toEqual(false);
          expect(this.aliasModel.get('ignored')).toEqual(false);
          return expect(this.aliasModel.get('preferred')).toEqual(false);
        });
      });
      return describe('validation', function() {
        it('should be invalid if missing required valies', function() {
          return expect(this.aliasModel.validate(this.aliasModel.toJSON())).toNotEqual(null);
        });
        return it('should be valid if all required fields a filled in', function() {
          this.aliasModel.set({
            'lsType': 'alias type',
            'aliasName': 'alias name'
          });
          return expect(this.aliasModel.validate(this.aliasModel.toJSON())).toBeNull();
        });
      });
    });
    describe('AliasCollection', function() {
      beforeEach(function() {
        return this.aliasCollection = new AliasCollection();
      });
      return describe('modelsAreAllValid', function() {
        it('should return true if all the models are valid', function() {
          var coll, m1, m2;
          m1 = new AliasModel({
            'lsType': 'alias type',
            'aliasName': 'alias name1'
          });
          m2 = new AliasModel({
            'lsType': 'alias type',
            'aliasName': 'alias name2'
          });
          coll = new AliasCollection([m1, m2]);
          return expect(coll.modelsAreAllValid()).toBeTruthy();
        });
        return it('should return false if at least one model is invalid', function() {
          var coll, m1, m2;
          m1 = new AliasModel({
            'lsType': 'alias type',
            'aliasName': ''
          });
          m2 = new AliasModel({
            'lsType': 'alias type',
            'aliasName': 'alias name2'
          });
          coll = new AliasCollection([m1, m2]);
          return expect(coll.modelsAreAllValid()).toBeFalsy();
        });
      });
    });
    describe('AddAliasTableController', function() {
      beforeEach(function() {
        this.fixture = $.clone($('#fixture').get(0));
        this.aliasTableController = new AddAliasTableController({
          collection: new AliasCollection([new AliasModel()])
        });
        return $('#fixture').html(this.aliasTableController.render().el);
      });
      afterEach(function() {
        $('#fixture').remove();
        return $('body').append($(this.fixture));
      });
      return describe('initialization', function() {
        it('should render a single empty row when initialized without any aliases', function() {
          return expect(this.aliasTableController.$('tr').length).toEqual(2);
        });
        it('should render row for each entry when initialized without existing aliases', function() {
          var aliasTableController, coll, m1, m2;
          m1 = new AliasModel({
            'lsType': 'alias type',
            'aliasName': ''
          });
          m2 = new AliasModel({
            'lsType': 'alias type',
            'aliasName': 'alias name2'
          });
          coll = new AliasCollection([m1, m2]);
          $('#fixture').remove();
          $('body').append($(this.fixture));
          aliasTableController = new AddAliasTableController({
            collection: coll
          });
          $('#fixture').html(aliasTableController.render().el);
          return expect(aliasTableController.$('tr').length).toEqual(3);
        });
        it('should ignore entries where ignore is true', function() {
          var aliasTableController, coll, m1, m2;
          m1 = new AliasModel({
            'lsType': 'alias type',
            'aliasName': 'alias name2'
          });
          m2 = new AliasModel({
            'lsType': 'alias type',
            'aliasName': 'alias name2',
            ignore: true
          });
          coll = new AliasCollection([m1, m2]);
          $('#fixture').remove();
          $('body').append($(this.fixture));
          aliasTableController = new AddAliasTableController({
            collection: coll
          });
          $('#fixture').html(aliasTableController.render().el);
          return expect(aliasTableController.$('tr').length).toEqual(3);
        });
        it('should add a row when "add" button is clicked and all existing rows are valid', function() {
          var aliasTableController, coll, m1;
          m1 = new AliasModel({
            'lsType': 'alias type',
            'aliasName': 'alias name2'
          });
          coll = new AliasCollection([m1]);
          $('#fixture').remove();
          $('body').append($(this.fixture));
          aliasTableController = new AddAliasTableController({
            collection: coll
          });
          $('#fixture').html(aliasTableController.render().el);
          aliasTableController.$('.addNewAlias').click();
          return expect(aliasTableController.$('tr').length).toEqual(3);
        });
        return it('should not add a row when "add" button is clicked but at least one row is invalid', function() {
          var aliasTableController, coll, m1;
          m1 = new AliasModel({
            'lsType': 'alias type',
            'aliasName': ''
          });
          coll = new AliasCollection([m1]);
          $('#fixture').remove();
          $('body').append($(this.fixture));
          aliasTableController = new AddAliasTableController({
            collection: coll
          });
          $('#fixture').html(aliasTableController.render().el);
          aliasTableController.$('.addNewAlias').click();
          return expect(aliasTableController.$('tr').length).toEqual(2);
        });
      });
    });
    describe('AliasRowController', function() {
      beforeEach(function() {
        this.fixture = $.clone($('#fixture').get(0));
        this.aliasRowController = new AliasRowController({
          model: new AliasModel
        });
        return $('#fixture').html(this.aliasRowController.render().el);
      });
      afterEach(function() {
        $('#fixture').remove();
        return $('body').append($(this.fixture));
      });
      describe('initialization', function() {
        return it('should render appropriate template content', function() {
          expect(this.aliasRowController.$('input').length).toEqual(1);
          return expect(this.aliasRowController.$('select').length).toEqual(1);
        });
      });
      return describe('model update behavior', function() {
        it('should not set ignored to true if the alias model is noew', function() {
          var aliasRowController, m1;
          $('#fixture').remove();
          $('body').append($(this.fixture));
          m1 = new AliasModel({
            'lsType': 'alias type',
            'aliasName': 'old name'
          });
          aliasRowController = new AliasRowController({
            model: m1
          });
          $('#fixture').html(aliasRowController.render().el);
          aliasRowController.$(".bv_aliasKind").val("new name");
          aliasRowController.$(".bv_aliasKind").trigger("change");
          return expect(m1.get('ignored')).toBeFalsy();
        });
        it('should set ignored to true if an existing alias is edited', function() {
          var aliasRowController, m1;
          $('#fixture').remove();
          $('body').append($(this.fixture));
          m1 = new AliasModel({
            'lsType': 'alias type',
            'aliasName': 'old name',
            id: 1
          });
          aliasRowController = new AliasRowController({
            model: m1
          });
          $('#fixture').html(aliasRowController.render().el);
          aliasRowController.$(".bv_aliasKind").val("new name");
          aliasRowController.$(".bv_aliasKind").trigger("change");
          return expect(m1.get('ignored')).toBeTruthy();
        });
        return it('should trigger isDirty event when an existing alias is edited', function() {
          var aliasRowController, m1;
          $('#fixture').remove();
          $('body').append($(this.fixture));
          m1 = new AliasModel({
            'lsType': 'alias type',
            'aliasName': 'old name',
            id: 1
          });
          aliasRowController = new AliasRowController({
            model: m1
          });
          $('#fixture').html(aliasRowController.render().el);
          aliasRowController.$(".bv_aliasKind").val("new name");
          aliasRowController.$(".bv_aliasKind").trigger("change");
          return expect(m1.get('ignored')).toBeTruthy();
        });
      });
    });
    return describe('AliasListReadView', function() {
      beforeEach(function() {
        var a1, a2, coll;
        this.fixture = $.clone($('#fixture').get(0));
        a1 = new AliasModel({
          'lsType': 'alias type',
          'aliasName': 'alias1',
          id: 1
        });
        a2 = new AliasModel({
          'lsType': 'alias type',
          'aliasName': 'alias2',
          id: 2
        });
        coll = new AliasCollection([a1, a2]);
        this.aliasReadView = new AliasListReadView({
          collection: coll
        });
        return $('#fixture').html(this.aliasReadView.render().el);
      });
      afterEach(function() {
        $('#fixture').remove();
        return $('body').append($(this.fixture));
      });
      describe('initialization', function() {
        it('should render appropriate template content', function() {
          return expect(this.aliasReadView.$('.bv_aliasName').length).toEqual(2);
        });
        return xit('should have an "edit" button', function() {
          return expect(this.aliasReadView.$('.bv_editAliases').length).toEqual(1);
        });
      });
      return describe('behavior', function() {
        return xit('should call handleEditAliases bv_editAliases is clicked', function() {
          spyOn(this.aliasReadView, 'handleEditAliases');
          this.aliasReadView.delegateEvents();
          this.aliasReadView.$(".bv_editAliases").click();
          return expect(this.aliasReadView.handleEditAliases).toHaveBeenCalled();
        });
      });
    });
  });

}).call(this);
