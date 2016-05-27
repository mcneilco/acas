$ = require('jquery')
_ = require('lodash')

EditorFormTabViewController = require('../src/client/EditorFormTabViewController.coffee').EditorFormTabViewController
PlateInfoController = require('../src/client/PlateInfoController.coffee').PlateInfoController
AddContentController = require('../src/client/AddContentController.coffee').AddContentController
TemplateController = require('../src/client/TemplateController.coffee').TemplateController
SerialDilutionController = require('../src/client/SerialDilutionController.coffee').SerialDilutionController

describe "EditorFormTabViewController", ->
  beforeEach ->
    @editorFormTabViewController = new EditorFormTabViewController({plateInfoController: {}, addContentController: {}, templateController: {}, serialDilutionController: {}})

  it "should exist", ->
    expect(@editorFormTabViewController).toBeTruthy()