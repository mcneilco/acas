Backbone = require('backbone')

SplitPlatesController = require('./SplitPlateController.coffee').SplitPlatesController
MergePlatesController = require('./MergePlateController.coffee').MergePlatesController

PLATE_OPERATIONS =
  MERGE: "mergePlates"
  SPLIT: "splitPlates"

class MergeOrSplitPlatesController extends Backbone.View
  template: _.template(require('html!./MergeOrSplitPlates.tmpl'))

  events:
    "click button[name='splitMergeNextStep']": "handleSplitMergeNextStepClick"
    "change select[name='plateOperation']": "handlePlateOperationChange"

  render: =>
    $(@el).html @template()
    
    @

  handlePlateOperationChange: =>
    if @$("select[name='plateOperation']").val() is PLATE_OPERATIONS.MERGE or @$("select[name='plateOperation']").val() is PLATE_OPERATIONS.SPLIT
      @$("button[name='splitMergeNextStep']").removeClass "disabled"
      @$("button[name='splitMergeNextStep']").prop "disabled", false
    else
      @$("button[name='splitMergeNextStep']").addClass "disabled"
      @$("button[name='splitMergeNextStep']").prop "disabled", true

  handleSplitMergeNextStepClick: =>
    if @$("select[name='plateOperation']").val() is PLATE_OPERATIONS.MERGE
      appRouter.navigate("/mergePlates", {trigger: true})
    else if @$("select[name='plateOperation']").val() is PLATE_OPERATIONS.SPLIT
      appRouter.navigate("/splitPlates", {trigger: true})


exports.MergeOrSplitPlatesController = MergeOrSplitPlatesController