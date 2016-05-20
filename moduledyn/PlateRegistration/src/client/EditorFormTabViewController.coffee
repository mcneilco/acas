Backbone = require('backbone')

_ = require('lodash')
$ = require('jquery')

EDITOR_FORM_TABLE_VIEW_CONTROLLER_EVENTS =
  EDITOR_FORMS_MINIMIZED: "editorFormsMinimized"
  EDITOR_FORMS_MAXIMIZED: "editorFormsMaximized"

class EditorFormTabViewController extends Backbone.View
  template: require('html!./EditorFormTabView.tmpl')
  initialize: (options) ->
    @tabSelectors = [".editorTabInfo", ".editorTabAddContent", ".editorTabTemplate", ".editorTabSerialDilution", ".editorTabFillPatterns"]
    @containerSelectors = ["div[name='info_form']", "div[name='add_content_form']", "div[name='template_form']", "div[name='serial_dilution_form']", "div[name='fill_patterns_form']"]

    @plateInfoController = options.plateInfoController
    @addContentController = options.addContentController
    @templateController = options.templateController
    @serialDilutionController = options.serialDilutionController
    @fillPlateController = options.fillPlateController

  events:
    "click a[name='info_tab']": "handleInfoTabClick"
    "click a[name='add_content_tab']": "handleAddContentTabClick"
    "click a[name='template_tab']": "handleTemplateTabClick"
    "click a[name='serial_dilution_tab']": "handleSerialDilutionTabClick"
    "click a[name='fill_patterns_tab']": "handleFillPatternsTabClick"
    "click .editorCollapseButton": "handleEditorCollapseButtonClick"

  render: =>
    $(@el).html @template

    @$("div[name='info_form']").html @plateInfoController.render().el
    @$("div[name='add_content_form']").html @addContentController.render().el
    @$("div[name='template_form']").html @templateController.render().el
    @$("div[name='serial_dilution_form']").html @serialDilutionController.render().el
    @$("div[name='fill_patterns_form']").html @fillPlateController.render().el
    @handleInfoTabClick()

    @

  handleInfoTabClick: (e)=>
    if e?
      e.preventDefault()
    @clearPreviouslySelectedTab()
    @hidePreviouslyDisplayedFormContainer()
    @$(".editorTabInfo").addClass("tabSelected")
    @$("div[name='info_form']").removeClass("hide")

  handleAddContentTabClick: (e)=>
    e.preventDefault()
    @clearPreviouslySelectedTab()
    @hidePreviouslyDisplayedFormContainer()
    @$(".editorTabAddContent").addClass("tabSelected")
    @$("div[name='add_content_form']").removeClass("hide")

  handleTemplateTabClick: (e)=>
    e.preventDefault()
    @clearPreviouslySelectedTab()
    @hidePreviouslyDisplayedFormContainer()
    @$(".editorTabTemplate").addClass("tabSelected")
    @$("div[name='template_form']").removeClass("hide")

  handleSerialDilutionTabClick: (e)=>
    e.preventDefault()
    @clearPreviouslySelectedTab()
    @hidePreviouslyDisplayedFormContainer()
    @$(".editorTabSerialDilution").addClass("tabSelected")
    @$("div[name='serial_dilution_form']").removeClass("hide")

  handleFillPatternsTabClick: (e)=>
    e.preventDefault()
    @clearPreviouslySelectedTab()
    @hidePreviouslyDisplayedFormContainer()
    @$(".editorTabFillPatterns").addClass("tabSelected")
    @$("div[name='fill_patterns_form']").removeClass("hide")

  clearPreviouslySelectedTab: =>
    _.each(@tabSelectors, (selector) =>
      @$(selector).removeClass("tabSelected")
    )

  hidePreviouslyDisplayedFormContainer: =>
    _.each(@containerSelectors, (selector) =>
      @$(selector).addClass("hide")
    )

  handleEditorCollapseButtonClick: =>
    @$(".editorPanel").toggleClass("hidden")
    if @$(".editorPanel").hasClass("hidden")
      @trigger EDITOR_FORM_TABLE_VIEW_CONTROLLER_EVENTS.EDITOR_FORMS_MINIMIZED
    else
      @trigger EDITOR_FORM_TABLE_VIEW_CONTROLLER_EVENTS.EDITOR_FORMS_MAXIMIZED

module.exports =
  EditorFormTabViewController: EditorFormTabViewController
  EDITOR_FORM_TABLE_VIEW_CONTROLLER_EVENTS: EDITOR_FORM_TABLE_VIEW_CONTROLLER_EVENTS