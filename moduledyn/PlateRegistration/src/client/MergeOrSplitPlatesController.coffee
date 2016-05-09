Backbone = require('backbone')

SplitPlatesController = require('./SplitPlateController.coffee').SplitPlatesController
MergePlatesController = require('./MergePlateController.coffee').MergePlatesController

PLATE_OPERATIONS =
  MERGE: "mergePlates"
  SPLIT: "splitPlates"

class MergeOrSplitPlatesController extends Backbone.View
  template: _.template(require('html!./MergeOrSplitPlates.tmpl'))

  events:
    "click button[name='mergePlates']": "handleMergePlatesClick"
    "click button[name='splitPlates']": "handleSplitPlatesClick"
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
    console.log "selected operation"
    console.log "the operation is:", @$("select[name='plateOperation']").val()
    if @$("select[name='plateOperation']").val() is PLATE_OPERATIONS.MERGE
      @$("div[name='operationSelectionContainer']").addClass "hide"
      @mergePlatesController = new MergePlatesController()
      @$("div[name='formContainer']").html @mergePlatesController.render().el
    else if @$("select[name='plateOperation']").val() is PLATE_OPERATIONS.SPLIT
      @$("div[name='operationSelectionContainer']").addClass "hide"
      @splitPlateController = new SplitPlatesController()
      @$("div[name='formContainer']").html @splitPlateController.render().el

  handleMergePlatesClick: =>
    console.log "handleMergePlatesClick"

    @mergePlatesController = new MergePlatesController()
    @$("div[name='formContainer']").html @mergePlatesController.render().el

  handleSplitPlatesClick: =>
    console.log "handleSplitPlatesClick"
    @splitPlateController = new SplitPlatesController()
    @$("div[name='formContainer']").html @splitPlateController.render().el

exports.MergeOrSplitPlatesController = MergeOrSplitPlatesController