_ = require('lodash')
$ = require('jquery')
Backbone = require('backbone')
BackboneValidation = require('backbone-validation')

_.extend(Backbone.Model.prototype, BackboneValidation.mixin);


SERIAL_DILUTION_MODEL_FIELDS =
  DESTINATION_WELL_VOLUME: "destinationWellVolume"
  DILUTION_FACTOR: "dilutionFactor"
  DIRECTION: "direction"
  NUMBER_OF_DOSES: "numberOfDoses"
  TEMPLATE: "template"
  TRANSFER_VOLUME: "transferVolume"
  IS_DILUTION_BY_VOLUME: "isDilutionByVolume"
  NUMBER_OF_COLUMNS_SELECTED: "numberOfColumnsSelected"
  NUMBER_OF_ROWS_SELECTED: "numberOfRowsSelected"
  SELECTED_ROW_IDX: "selectedRowIdx"
  SELECTED_COLUMN_IDX: "selectedColumnIdx"
  MAX_NUMBER_OF_COLUMNS: "maxNumberOfColumns"
  MAX_NUMBER_OF_ROWS: "maxNumberOfRows"
  LOWEST_VOLUME_WELL: "lowestVolumeWell"
  ALL_WELLS_HAVE_VOLUME: "allWellsHaveVolume"
  ALL_WELLS_HAVE_CONCENTRATION: "allWellsHaveConcentration"


class SerialDilutionModel extends Backbone.Model
  defaults:
    "destinationWellVolume": ""
    "dilutionFactor": ""
    "direction": "diluteRight"
    "numberOfDoses": 0
    "template": ""
    "transferVolume": ""
    "isDilutionByVolume": true

  validation:
    template:
      required: true
      msg: "Please Plate or Barcode"

  initialize: ->
    @errorMessages = []

  aRowIsSelected: ->
    aRowIsSelected = false
    if @get(SERIAL_DILUTION_MODEL_FIELDS.NUMBER_OF_COLUMNS_SELECTED) > 1
      aRowIsSelected = true
    aRowIsSelected

  aColumnIsSelected: ->
    aColumnIsSelected = false
    if @get(SERIAL_DILUTION_MODEL_FIELDS.NUMBER_OF_ROWS_SELECTED) > 1
      aColumnIsSelected = true
    aColumnIsSelected

  aSingleCellIsSelected: ->
    aSingleCellIsSelected = false
    if (@get(SERIAL_DILUTION_MODEL_FIELDS.NUMBER_OF_ROWS_SELECTED) is 1) and (@get(SERIAL_DILUTION_MODEL_FIELDS.NUMBER_OF_COLUMNS_SELECTED) is 1)
      aSingleCellIsSelected = true
    aSingleCellIsSelected

  enoughSpaceForNumberOfDoses: ->
    enoughSpaceForNumberOfDoses = false
    if @get(SERIAL_DILUTION_MODEL_FIELDS.SELECTED_ROW_IDX)? and @get(SERIAL_DILUTION_MODEL_FIELDS.SELECTED_COLUMN_IDX)?
      if @get(SERIAL_DILUTION_MODEL_FIELDS.DIRECTION) is "diluteLeft"
        if (@get(SERIAL_DILUTION_MODEL_FIELDS.SELECTED_COLUMN_IDX) - @get(SERIAL_DILUTION_MODEL_FIELDS.NUMBER_OF_DOSES)) > -1
          enoughSpaceForNumberOfDoses = true
      else if @get(SERIAL_DILUTION_MODEL_FIELDS.DIRECTION) is "diluteRight"
        if (@get(SERIAL_DILUTION_MODEL_FIELDS.SELECTED_COLUMN_IDX) + @get(SERIAL_DILUTION_MODEL_FIELDS.NUMBER_OF_DOSES)) < @get(SERIAL_DILUTION_MODEL_FIELDS.MAX_NUMBER_OF_COLUMNS)
          enoughSpaceForNumberOfDoses = true
      else if @get(SERIAL_DILUTION_MODEL_FIELDS.DIRECTION) is "diluteUp"
        if (@get(SERIAL_DILUTION_MODEL_FIELDS.SELECTED_ROW_IDX) - @get(SERIAL_DILUTION_MODEL_FIELDS.NUMBER_OF_DOSES)) > -1
          enoughSpaceForNumberOfDoses = true
      else if @get(SERIAL_DILUTION_MODEL_FIELDS.DIRECTION) is "diluteDown"
        if (@get(SERIAL_DILUTION_MODEL_FIELDS.SELECTED_ROW_IDX) + @get(SERIAL_DILUTION_MODEL_FIELDS.NUMBER_OF_DOSES)) < @get(SERIAL_DILUTION_MODEL_FIELDS.MAX_NUMBER_OF_ROWS)
          enoughSpaceForNumberOfDoses = true
    else
      enoughSpaceForNumberOfDoses = true
    unless enoughSpaceForNumberOfDoses
      @errorMessages.push "There is not enough space to perform the requested dilution"
    enoughSpaceForNumberOfDoses

  validRegionSelected: ->
    validRegionSelected = false
    if @aSingleCellIsSelected()
      validRegionSelected = true
    else
      if not @aColumnIsSelected() and not @aRowIsSelected()
        @errorMessages.push "Please select a plate region to perform a dilution"
        validRegionSelected = false
      else
        if (@get(SERIAL_DILUTION_MODEL_FIELDS.NUMBER_OF_COLUMNS_SELECTED) is 1) and (@get(SERIAL_DILUTION_MODEL_FIELDS.NUMBER_OF_ROWS_SELECTED) is 1)
          validRegionSelected = true
        else
          if @aRowIsSelected() and @aColumnIsSelected()
            @errorMessages.push "Please select either a single row or a single column"
          else
            if ((@get(SERIAL_DILUTION_MODEL_FIELDS.DIRECTION) is "diluteUp") or (@get(SERIAL_DILUTION_MODEL_FIELDS.DIRECTION) is "diluteDown"))
              if @aRowIsSelected() and not @aColumnIsSelected()
                validRegionSelected = true
              else
                @errorMessages.push "Please select a single row to perform a vertical dilution"
            else if ((@get(SERIAL_DILUTION_MODEL_FIELDS.DIRECTION) is "diluteRight") or (@get(SERIAL_DILUTION_MODEL_FIELDS.DIRECTION) is "diluteLeft"))
              if @aColumnIsSelected() and not @aRowIsSelected()
                validRegionSelected = true
              else
                @errorMessages.push "Please select a single column to perform a horizontal dilution"


    validRegionSelected

  validateNumberOfDoses: ->
    validNumberOfDoses = true
    if isNaN(@get(SERIAL_DILUTION_MODEL_FIELDS.NUMBER_OF_DOSES))
      @errorMessages.push "Please enter a numeric value for the number of doses"
      validNumberOfDoses = false
    else if $.trim(@get(SERIAL_DILUTION_MODEL_FIELDS.NUMBER_OF_DOSES)) is ""
      @errorMessages.push "Please enter the number of doses"
      validNumberOfDoses = false
    else if @get(SERIAL_DILUTION_MODEL_FIELDS.NUMBER_OF_DOSES) <= 0
      @errorMessages.push "The number of doses must be greater than 0"
      validNumberOfDoses = false

    validNumberOfDoses

  validateTransferVolume: ->
    valid = true
    startingVolumeGreaterThanTransfer = @get(SERIAL_DILUTION_MODEL_FIELDS.TRANSFER_VOLUME) > @get(SERIAL_DILUTION_MODEL_FIELDS.LOWEST_VOLUME_WELL)

    if @get SERIAL_DILUTION_MODEL_FIELDS.IS_DILUTION_BY_VOLUME
      if not @get(SERIAL_DILUTION_MODEL_FIELDS.ALL_WELLS_HAVE_VOLUME)
        @errorMessages.push "All wells must have a volume"
        valid = false
      else if not @get(SERIAL_DILUTION_MODEL_FIELDS.ALL_WELLS_HAVE_CONCENTRATION)
        @errorMessages.push "All wells must have a concentration value"
        valid = false
      else if isNaN(@get(SERIAL_DILUTION_MODEL_FIELDS.TRANSFER_VOLUME))
        @errorMessages.push "Please enter a numeric value for the transfer volume"
        valid = false
      else if $.trim(@get(SERIAL_DILUTION_MODEL_FIELDS.TRANSFER_VOLUME)) is ""
        @errorMessages.push "Please enter the transfer volume"
        valid = false
      else if @get(SERIAL_DILUTION_MODEL_FIELDS.TRANSFER_VOLUME) <= 0
        @errorMessages.push "The transfer volume must be greater than 0"
        valid = false
      else if @get(SERIAL_DILUTION_MODEL_FIELDS.TRANSFER_VOLUME) > @get(SERIAL_DILUTION_MODEL_FIELDS.LOWEST_VOLUME_WELL)
        @errorMessages.push "The transfer volume must be less than the lowest volume well"
        valid = false

    valid

  validateDestinationVolume: ->
    valid = true
    if @get SERIAL_DILUTION_MODEL_FIELDS.IS_DILUTION_BY_VOLUME
      if isNaN(@get(SERIAL_DILUTION_MODEL_FIELDS.DESTINATION_WELL_VOLUME))
        @errorMessages.push "Please enter a numeric value for the destination volume"
        valid = false
      else if $.trim(@get(SERIAL_DILUTION_MODEL_FIELDS.DESTINATION_WELL_VOLUME)) is ""
        @errorMessages.push "Please enter the destination volume"
        valid = false
      else if @get(SERIAL_DILUTION_MODEL_FIELDS.DESTINATION_WELL_VOLUME) <= 0
        @errorMessages.push "The destination volume must be greater than 0"
        valid = false

    valid

  validateDilutionFactor: ->
    valid = true
    unless @get SERIAL_DILUTION_MODEL_FIELDS.IS_DILUTION_BY_VOLUME
      if not @get(SERIAL_DILUTION_MODEL_FIELDS.ALL_WELLS_HAVE_VOLUME)
        @errorMessages.push "All wells must have a volume"
        valid = false
      else if not @get(SERIAL_DILUTION_MODEL_FIELDS.ALL_WELLS_HAVE_CONCENTRATION)
        @errorMessages.push "All wells must have a concentration value"
        valid = false
      else if isNaN(@get(SERIAL_DILUTION_MODEL_FIELDS.DILUTION_FACTOR))
        @errorMessages.push "Please enter a numeric value for the dilution factor"
        valid = false
      else if $.trim(@get(SERIAL_DILUTION_MODEL_FIELDS.DILUTION_FACTOR)) is ""
        @errorMessages.push "Please enter the dilution factor"
        valid = false
      else if @get(SERIAL_DILUTION_MODEL_FIELDS.DILUTION_FACTOR) < 1
        @errorMessages.push "The dilution factor must be greater than 0"
        valid = false


    valid

  isItValid: ->
    @errorMessages = []
    if @validateNumberOfDoses()
      @enoughSpaceForNumberOfDoses()
    @validRegionSelected()
    @validateTransferVolume()
    @validateDestinationVolume()
    @validateDilutionFactor()

    if _.size(@errorMessages)is 0
      return true
    else
      return false

  reset: ->
    @.set
      "destinationWellVolume": ""
      "dilutionFactor": ""
      "direction": ""
      "numberOfDoses": ""
      "template": ""
      "transferVolume": ""


module.exports =
  SerialDilutionModel: SerialDilutionModel
  SERIAL_DILUTION_MODEL_FIELDS: SERIAL_DILUTION_MODEL_FIELDS