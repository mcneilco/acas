Backbone = require('backbone')

_ = require('lodash')
$ = require('jquery')

class EditorFormTabViewController extends Backbone.View
  template: require('html!./EditorFormTabView.tmpl')
  initialize: (options) ->
    @tabSelectors = [".editorTabInfo", ".editorTabAddContent", ".editorTabTemplate", ".editorTabSerialDilution"]
    @containerSelectors = ["div[name='info_form']", "div[name='add_content_form']", "div[name='template_form']", "div[name='serial_dilution_form']"]

    @plateInfoController = options.plateInfoController
    @addContentController = options.addContentController
    @templateController = options.templateController
    @serialDilutionController = options.serialDilutionController

  events:
    "click a[name='info_tab']": "handleInfoTabClick"
    "click a[name='add_content_tab']": "handleAddContentTabClick"
    "click a[name='template_tab']": "handleTemplateTabClick"
    "click a[name='serial_dilution_tab']": "handleSerialDilutionTabClick"
    "click .editorCollapseButton": "handleEditorCollapseButtonClick"

  render: =>
    $(@el).html @template

    @$("div[name='info_form']").html @plateInfoController.render().el
    @$("div[name='add_content_form']").html @addContentController.render().el
    @$("div[name='template_form']").html @templateController.render().el
    @$("div[name='serial_dilution_form']").html @serialDilutionController.render().el

    @handleInfoTabClick()

    @

  handleInfoTabClick: =>
    @clearPreviouslySelectedTab()
    @hidePreviouslyDisplayedFormContainer()
    @$(".editorTabInfo").addClass("tabSelected")
    @$("div[name='info_form']").removeClass("hide")

  handleAddContentTabClick: =>
    @clearPreviouslySelectedTab()
    @hidePreviouslyDisplayedFormContainer()
    @$(".editorTabAddContent").addClass("tabSelected")
    @$("div[name='add_content_form']").removeClass("hide")

  handleTemplateTabClick: =>
    @clearPreviouslySelectedTab()
    @hidePreviouslyDisplayedFormContainer()
    @$(".editorTabTemplate").addClass("tabSelected")
    @$("div[name='template_form']").removeClass("hide")

  handleSerialDilutionTabClick: =>
    @clearPreviouslySelectedTab()
    @hidePreviouslyDisplayedFormContainer()
    @$(".editorTabSerialDilution").addClass("tabSelected")
    @$("div[name='serial_dilution_form']").removeClass("hide")

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

module.exports =
  EditorFormTabViewController: EditorFormTabViewController