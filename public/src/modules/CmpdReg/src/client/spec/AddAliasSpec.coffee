describe 'AddAlias', ->
  describe 'AliasModel', ->
    beforeEach ->
      @aliasModel = new AliasModel()

    describe 'when instantiated', ->
      it 'Should have default attributes', ->
        expect(@aliasModel.get('lsKind')).toEqual 'Parent Common Name'
        expect(@aliasModel.get('aliasName')).toEqual ''
        expect(@aliasModel.get('lsType')).toEqual ''
        expect(@aliasModel.get('deleted')).toEqual false
        expect(@aliasModel.get('ignored')).toEqual false
        expect(@aliasModel.get('preferred')).toEqual false

    describe 'validation', ->
      it 'should be invalid if missing required valies', ->
        expect(@aliasModel.validate(@aliasModel.toJSON())).toNotEqual null

      it 'should be valid if all required fields a filled in', ->
        @aliasModel.set({'lsType': 'alias type', 'aliasName': 'alias name'})
        expect(@aliasModel.validate(@aliasModel.toJSON())).toBeNull()

  describe 'AliasCollection', ->
    beforeEach ->
      @aliasCollection = new AliasCollection()

    describe 'modelsAreAllValid', ->
      it 'should return true if all the models are valid', ->
        m1 = new AliasModel({'lsType': 'alias type', 'aliasName': 'alias name1'})
        m2 = new AliasModel({'lsType': 'alias type', 'aliasName': 'alias name2'})
        coll  = new AliasCollection([m1, m2])
        expect(coll.modelsAreAllValid()).toBeTruthy()

      it 'should return false if at least one model is invalid', ->
        m1 = new AliasModel({'lsType': 'alias type', 'aliasName': ''})
        m2 = new AliasModel({'lsType': 'alias type', 'aliasName': 'alias name2'})
        coll  = new AliasCollection([m1, m2])
        expect(coll.modelsAreAllValid()).toBeFalsy()

  describe 'AddAliasTableController', ->
    beforeEach ->
      @fixture = $.clone($('#fixture').get(0))
      @aliasTableController = new AddAliasTableController({collection: new AliasCollection([new AliasModel()])})
      $('#fixture').html @aliasTableController.render().el

    afterEach ->
      $('#fixture').remove()
      $('body').append($(@fixture))

    describe 'initialization', ->
      it 'should render a single empty row when initialized without any aliases', ->
        expect(@aliasTableController.$('tr').length).toEqual 2

      it 'should render row for each entry when initialized without existing aliases', ->
        m1 = new AliasModel({'lsType': 'alias type', 'aliasName': ''})
        m2 = new AliasModel({'lsType': 'alias type', 'aliasName': 'alias name2'})
        coll  = new AliasCollection([m1, m2])
        $('#fixture').remove()
        $('body').append($(@fixture))
        aliasTableController = new AddAliasTableController({collection: coll})
        $('#fixture').html aliasTableController.render().el
        expect(aliasTableController.$('tr').length).toEqual 3

      it 'should ignore entries where ignore is true', ->
        m1 = new AliasModel({'lsType': 'alias type', 'aliasName': 'alias name2'})
        m2 = new AliasModel({'lsType': 'alias type', 'aliasName': 'alias name2', ignore: true})
        coll  = new AliasCollection([m1, m2])
        $('#fixture').remove()
        $('body').append($(@fixture))
        aliasTableController = new AddAliasTableController({collection: coll})
        $('#fixture').html aliasTableController.render().el
        expect(aliasTableController.$('tr').length).toEqual 3

      it 'should add a row when "add" button is clicked and all existing rows are valid', ->
        m1 = new AliasModel({'lsType': 'alias type', 'aliasName': 'alias name2'})
        coll  = new AliasCollection([m1])
        $('#fixture').remove()
        $('body').append($(@fixture))
        aliasTableController = new AddAliasTableController({collection: coll})
        $('#fixture').html aliasTableController.render().el
        aliasTableController.$('.addNewAlias').click()
        expect(aliasTableController.$('tr').length).toEqual 3

      it 'should not add a row when "add" button is clicked but at least one row is invalid', ->
        m1 = new AliasModel({'lsType': 'alias type', 'aliasName': ''})
        coll  = new AliasCollection([m1])
        $('#fixture').remove()
        $('body').append($(@fixture))
        aliasTableController = new AddAliasTableController({collection: coll})
        $('#fixture').html aliasTableController.render().el
        aliasTableController.$('.addNewAlias').click()
        expect(aliasTableController.$('tr').length).toEqual 2

  describe 'AliasRowController', ->
    beforeEach ->
      @fixture = $.clone($('#fixture').get(0))
      @aliasRowController = new AliasRowController({model: new AliasModel})
      $('#fixture').html @aliasRowController.render().el

    afterEach ->
      $('#fixture').remove()
      $('body').append($(@fixture))

    describe 'initialization', ->
      it 'should render appropriate template content', ->
        expect(@aliasRowController.$('input').length).toEqual 1
        expect(@aliasRowController.$('select').length).toEqual 1

    describe 'model update behavior', ->
      it 'should not set ignored to true if the alias model is noew', ->
        $('#fixture').remove()
        $('body').append($(@fixture))
        m1 = new AliasModel({'lsType': 'alias type', 'aliasName': 'old name'})
        aliasRowController = new AliasRowController({model: m1})
        $('#fixture').html aliasRowController.render().el
        aliasRowController.$(".bv_aliasKind").val "new name"
        aliasRowController.$(".bv_aliasKind").trigger "change"

        expect(m1.get('ignored')).toBeFalsy()

      it 'should set ignored to true if an existing alias is edited', ->
        $('#fixture').remove()
        $('body').append($(@fixture))
        m1 = new AliasModel({'lsType': 'alias type', 'aliasName': 'old name', id: 1})
        aliasRowController = new AliasRowController({model: m1})
        $('#fixture').html aliasRowController.render().el
        aliasRowController.$(".bv_aliasKind").val "new name"
        aliasRowController.$(".bv_aliasKind").trigger "change"

        expect(m1.get('ignored')).toBeTruthy()

      it 'should trigger isDirty event when an existing alias is edited', ->
        $('#fixture').remove()
        $('body').append($(@fixture))
        m1 = new AliasModel({'lsType': 'alias type', 'aliasName': 'old name', id: 1})
        aliasRowController = new AliasRowController({model: m1})
        #eventSpy = spyOn(aliasRowController)
        $('#fixture').html aliasRowController.render().el
        aliasRowController.$(".bv_aliasKind").val "new name"
        aliasRowController.$(".bv_aliasKind").trigger "change"

        expect(m1.get('ignored')).toBeTruthy()

  describe 'AliasListReadView', ->
    beforeEach ->
      @fixture = $.clone($('#fixture').get(0))
      a1 = new AliasModel({'lsType': 'alias type', 'aliasName': 'alias1', id: 1})
      a2 = new AliasModel({'lsType': 'alias type', 'aliasName': 'alias2', id: 2})
      coll  = new AliasCollection([a1, a2])
      @aliasReadView = new AliasListReadView({collection: coll})
      $('#fixture').html @aliasReadView.render().el

    afterEach ->
      $('#fixture').remove()
      $('body').append($(@fixture))

    describe 'initialization', ->
      it 'should render appropriate template content', ->
        expect(@aliasReadView.$('.bv_aliasName').length).toEqual 2

      xit 'should have an "edit" button', ->
        expect(@aliasReadView.$('.bv_editAliases').length).toEqual 1

    describe 'behavior', ->
      xit 'should call handleEditAliases bv_editAliases is clicked', ->
        spyOn(@aliasReadView, 'handleEditAliases')
        @aliasReadView.delegateEvents()
        @aliasReadView.$(".bv_editAliases").click()
        expect(@aliasReadView.handleEditAliases).toHaveBeenCalled()
